function [NODE,SECTION,DER,PARAM] = sxstRead_old2(fullfilename)
%{
SXSTread takes a .sxst file and returns 4 structs
--NODE--
.ID         - Node ID
.w          - weight of Node demand
.p          - real power demand of Node
.q          - reactive power demand of Node
.XCoord     - X coordinate of Node
.YCoord     - Y coordinate of Node

--SECTION--

PARAM
DER

%}

if ~nargin
    fid = fopen('pathdef.m');
    rootlocation = textscan(fid,'%c')';
    rootlocation = regexp(rootlocation{1}','C:[^.]*?CAPER\\','match','once');
    fclose(fid);
    rootlocation = [rootlocation,'07_CYME\'];

    filelocation = rootlocation;
    % ****To skip UIGETFILE uncomment desired filename****
    % ******(Must be in rootlocation CAPER\07_CYME)*******
    %filename = 'Flay 12-01 - 2-3-15 loads (original).sxst';
    %filename = 'Commonwealth 12-05-  9-14 loads (original).sxst';
    %filename = 'Kud1207 (original).sxst'
    %filename = 'Bellhaven 12-04 - 8-14 loads.xst (original).sxst'
    filename = 'Commonwealth_ret_01311205.sxst';
    fullfilename = [filelocation,filename];
end

% Read SXST File
FILE = fileread(fullfilename);

% Find Circuit Specs
n = length(strfind(FILE,'<Node>'));
s = length(strfind(FILE,'<Section>'));

%% Extract Node Information
NODE = struct('Info',regexp(FILE,'<Node>(.*?)</Node>','match'));
for b = 1:n
    NODE(b).ID = regexp(NODE(b).Info,'(?<=<NodeID>)(.*?)(?=</NodeID>)','match'); NODE(b).ID = NODE(b).ID{1};
    
    % Initialize w, p, q, and Fixed
    NODE(b).w = 1;
    NODE(b).p = 0;
    NODE(b).q = 0;
    %NODE(b).s = 0;
    %NODE(b).pf = 0;
    NODE(b).Fixed = false;

    
    % Read in Bus Coordinates
    NODE(b).XCoord = str2double(regexp(NODE(b).Info,'(?<=<X>)(.*?)(?=</X>)','match'));
    NODE(b).YCoord = str2double(regexp(NODE(b).Info,'(?<=<Y>)(.*?)(?=</Y>)','match'));
end
NODE = rmfield(NODE,'Info');

%% Extract Section Information
SECTION = struct('Info',regexp(FILE,'<Section>(.*?)</Section>','match'));
for l = 1:s
    SECTION(l).ID = regexp(SECTION(l).Info,'(?<=<SectionID>)(.*?)(?=</SectionID>)','match'); SECTION(l).ID = SECTION(l).ID{1};
    SECTION(l).Phase = regexp(SECTION(l).Info,'(?<=<Phase>)(.*?)(?=</Phase>)','match','once');
    SECTION(l).FROM = regexp(SECTION(l).Info,'(?<=<FromNodeID>)(.*?)(?=</FromNodeID>)','match'); SECTION(l).FROM = SECTION(l).FROM{1};
    SECTION(l).TO = regexp(SECTION(l).Info,'(?<=<ToNodeID>)(.*?)(?=</ToNodeID>)','match'); SECTION(l).TO = SECTION(l).TO{1};
    
    % Reclosers
    reclinfo = regexp(SECTION(l).Info,'<Recloser>(.*?)</Recloser>','match');
    if ~isempty(reclinfo)
        SECTION(l).Device = true;
    else
        SECTION(l).Device = false;
    end
    
    SECTION(l).NormalStatus = true;
    
    % Switches
    switchinfo = regexp(SECTION(l).Info,'<Switch>(.*?)</Switch>','match');
    if ~isempty(switchinfo)
        SECTION(l).Device = true;
        SECTION(l).NormalStatus = regexp(switchinfo,'(?<=<NormalStatus>)(.*?)(?=</NormalStatus>)','match');
        SECTION(l).NormalStatus = strcmp(SECTION(l).NormalStatus{1},'Closed');
    end
    
    % Fuses
    fuseinfo = regexp(SECTION(l).Info,'<Fuse>(.*?)</Fuse>','match');
    if ~isempty(fuseinfo)
        SECTION(l).Device = true;
    end

    %% Extract Device Information
    %  Spot Loads
    loadinfo = regexp(SECTION(l).Info,'<SpotLoad>(.*?)</SpotLoad>','match');
    spotloadinfo = regexp(SECTION(l).Info,'<CustomerLoadValue>(.*?)</CustomerLoadValue>','match');
    for i = 1:length(spotloadinfo)
        Location = regexp(loadinfo{1},'(?<=<Location>)(.*?)(?=</Location>)','match');
        switch Location{1}
            case 'From'
                index = find(ismember({NODE.ID},SECTION(l).FROM));
            case 'To'
                index = find(ismember({NODE.ID},SECTION(l).TO));
        end
        
        LoadType = regexp(spotloadinfo{i},'(?<=<LoadValue Type="LoadValue)(.*?)(?=">)','match');
        
        switch LoadType{1}
            case 'KW_KVAR'
                NODE(index).p = NODE(index).p + str2double(regexp(spotloadinfo{i},'(?<=<KW>)(.*?)(?=</KW>)','match'));
                NODE(index).q = NODE(index).q + str2double(regexp(spotloadinfo{i},'(?<=<KVAR>)(.*?)(?=</KVAR>)','match'));
                %NODE(index).s = sqrt(NODE(index).p^2 + NODE(index).q^2);
                %NODE(index).pf = cos(atan(NODE(index).q/NODE(index).p));
            case 'KVA_PF'
                KVA = str2double(regexp(spotloadinfo{i},'(?<=<KVA>)(.*?)(?=</KVA>)','match'));
                pf = str2double(regexp(spotloadinfo{i},'(?<=<PF>)(.*?)(?=</PF>)','match'))/100;
                NODE(index).p = NODE(index).p + KVA*pf;
                NODE(index).q = NODE(index).q + KVA*sqrt(1-pf^2);
                %NODE(index).s = sqrt(NODE(index).p^2 + NODE(index).q^2);
                %NODE(index).pf = cos(atan(NODE(index).q/NODE(index).p));
            case 'KW_PF'
                pf = str2double(regexp(spotloadinfo{i},'(?<=<PF>)(.*?)(?=</PF>)','match'))/100;
                NODE(index).p = NODE(index).p + str2double(regexp(spotloadinfo{i},'(?<=<KW>)(.*?)(?=</KW>)','match'));
                NODE(index).q = NODE(index).q + NODE(index).p*tan(acos(pf));
                %NODE(index).s = sqrt(NODE(index).p^2 + NODE(index).q^2);
                %NODE(index).pf = cos(atan(NODE(index).q/NODE(index).p));
            otherwise
                error('Unknown Load Type')
        end
    end
    
    % Capacitors (counter = cp)
    capinfo = regexp(SECTION(l).Info,'<ShuntCapacitor>(.*?)</ShuntCapacitor>','match');
    if ~isempty(capinfo)
        Location = regexp(capinfo{1},'(?<=<Location>)(.*?)(?=</Location>)','match');
        switch Location{1}
            case 'From'
                index = find(ismember({NODE.ID},SECTION(l).FROM));
            case 'To'
                index = find(ismember({NODE.ID},SECTION(l).TO));
        end
        
        [KVAR,type] = max([sum(str2double(regexp(capinfo{1},'(?<=<SwitchedKVAR[ABC]>)(.*?)(?=</SwitchedKVAR[ABC]>)','match'))),...
            sum(str2double(regexp(capinfo{1},'(?<=<FixedKVAR[ABC]>)(.*?)(?=</FixedKVAR[ABC]>)','match')))]);
        NODE(index).q = NODE(index).q - KVAR;
        NODE(index).Fixed = (type==2);
        
    end 
end
SECTION = rmfield(SECTION,'Info');

% Define Parameters
PARAM.NO = {};
PARAM.NC = {NODE([NODE.Fixed]).ID};
PARAM.SO = {};
PARAM.SC = {SECTION(~[SECTION.Device]).ID};
NODE = rmfield(NODE,'Fixed');

% Define DER
DER = struct('Info',regexp(FILE,'<Source>(.*?)</Source>','match'));
DER.DB = struct('DBInfo',regexp(FILE,'<SubstationDB>(.*?)<SubstationDetails>','match'));

for i =1:length(DER.DB)
    DER.DB(i).ID = regexp(DER.DB(i).DBInfo,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); DER.DB(i).ID = DER.DB(i).ID{1};
    DER.DB(i).MVACapacity = str2double(regexp(DER.DB(i).DBInfo,'(?<=<NominalCapacityMVA>)(.*?)(?=</NominalCapacityMVA>)','match'));
end

for i = 1:length(DER)
    DER(i).ID = regexp(DER(i).Info,'(?<=<SourceNodeID>)(.*?)(?=</SourceNodeID>)','match'); DER(i).ID = DER(i).ID{1};
    DER.CAPACITY = DER.DB(ismember({DER.DB.ID},DER(i).ID)).MVACapacity;
end
DER = rmfield(DER,{'Info' 'DB'});
