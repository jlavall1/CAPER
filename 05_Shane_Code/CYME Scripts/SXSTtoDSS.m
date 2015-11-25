% Snap to grid function for CYME file
clear
clc

filename = 0;
%filename = 'Flay 12-01 - 2-3-15 loads (original).sxst';
%filename = 'Commonwealth 12-05-  9-14 loads (original).sxst';
%filelocation = 'C:\Users\SJKIMBL\Documents\CYMEproject\CYMEproject\Commonwealth\';
while ~filename
    [filename,filelocation] = uigetfile({'*.*','All Files'},'Select .sxst file to convert');
end
savelocation = [filelocation,filename,'_DSS\'];

% Read File
FILE = fileread([filelocation,filename]);

% Print specs
n = length(strfind(FILE,'<Node>'));
s = length(strfind(FILE,'<Section>'));
l = length(strfind(FILE,'<SpotLoad>'));
lp = length(strfind(FILE,'<CustomerLoadValue>'));
fprintf('%d Nodes; %d Sections; %d Loads (%d by phase)\n',n,s,l,lp)

% Extract Node Information
nodeinfo = regexp(FILE,'<Node>(.*?)</Node>','match');
for i = 1:length(nodeinfo)
    % MILP
    NODE(i).ID = regexp(nodeinfo{i},'(?<=<NodeID>)(.*?)(?=</NodeID>)','match');
    
    % DSS
    Buses(i).ID = regexp(nodeinfo{i},'(?<=<NodeID>)(.*?)(?=</NodeID>)','match');
    Buses(i).XCoord = str2double(regexp(nodeinfo{i},'(?<=<X>)(.*?)(?=</X>)','match'));
    Buses(i).YCoord = str2double(regexp(nodeinfo{i},'(?<=<Y>)(.*?)(?=</Y>)','match'));
end

% Extract Section Information
sectinfo = regexp(FILE,'<Section>(.*?)</Section>','match');
k = 1;
for i = 1:length(sectinfo)
    % MILP
    SECTION(i).FROMNODE = regexp(sectinfo{i},'(?<=<FromNodeID>)(.*?)(?=</FromNodeID>)','match');
    SECTION(i).TONODE = regexp(sectinfo{i},'(?<=<ToNodeID>)(.*?)(?=</ToNodeID>)','match');
    SECTION(i).PHASE = regexp(sectinfo{i},'(?<=<Phase>)(.*?)(?=</Phase>)','match','once');

    % DSS
    Lines(i).ID = regexp(sectinfo{i},'(?<=<SectionID>)(.*?)(?=</SectionID>)','match');
    Lines(i).Phase = regexp(sectinfo{i},'(?<=<Phase>)(.*?)(?=</Phase>)','match','once');
    % String to be appended to bus info
    append = '';
    if ~isempty(strfind(Lines(i).Phase,'A'))
        append = [append,'.1'];
    end
    if ~isempty(strfind(Lines(i).Phase,'B'))
        append = [append,'.2'];
    end
    if ~isempty(strfind(Lines(i).Phase,'C'))
        append = [append,'.3'];
    end
    
    Lines(i).Phase = length(Lines(i).Phase);
    bus1 = regexp(sectinfo{i},'(?<=<FromNodeID>)(.*?)(?=</FromNodeID>)','match');
    bus2 = regexp(sectinfo{i},'(?<=<ToNodeID>)(.*?)(?=</ToNodeID>)','match');
    Lines(i).Bus1 = [bus1{1},append];
    Lines(i).Bus2 = [bus2{1},append];
            
    % Extract Device Info
    %  Overhead By Phase
    overheadinfo = regexp(sectinfo{i},'<OverheadByPhase>(.*?)</OverheadByPhase>','match');
    if ~isempty(overheadinfo)
        % DSS
        Lines(i).Length = str2double(regexp(overheadinfo{1},'(?<=<Length>)(.*?)(?=</Length>)','match'));
        Lines(i).Spacing = strrep(regexp(overheadinfo{1},'(?<=<ConductorSpacingID>)(.*?)(?=</ConductorSpacingID>)','match'),'&apos;','''');
        wires = regexp(overheadinfo{1},'(?<=<PhaseConductorID[ABC]>)(.*?)(?=</PhaseConductorID[ABC]>)','match');
        wires = [wires(~strcmp(wires,'NONE')),regexp(overheadinfo{1},'(?<=<NeutralConductorID>)(.*?)(?=</NeutralConductorID>)','match')];
        Lines(i).Wires = ['[''',strjoin(wires,''' '''),''']'];
    end
    
    %  Underground
    undergroundinfo = regexp(sectinfo{i},'<Underground>(.*?)</Underground>','match');
    if ~isempty(undergroundinfo)
        % DSS
        Lines(i).Length = str2double(regexp(undergroundinfo{1},'(?<=<Length>)(.*?)(?=</Length>)','match'));
        Lines(i).LineCode = regexp(undergroundinfo{1},'(?<=<CableID>)(.*?)(?=</CableID>)','match');
    end
    
    %  Spot Loads
    loadinfo = regexp(sectinfo{i},'<SpotLoad>(.*?)</SpotLoad>','match');
    spotloadinfo = regexp(sectinfo{i},'<CustomerLoadValue>(.*?)</CustomerLoadValue>','match');
    for j = 1:length(spotloadinfo)
        % MILP
        %<NormalPriority>0</NormalPriority>
        %<EmergencyPriority>0</EmergencyPriority>
        
        % DSS
        phase = regexp(spotloadinfo{j},'(?<=<Phase>)(.*?)(?=</Phase>)','match');
        % String to be appended to load info
        append = '';
        if ~isempty(strfind(phase{1},'A'))
            append = [append,'.1'];
        end
        if ~isempty(strfind(phase{1},'B'))
            append = [append,'.2'];
        end
        if ~isempty(strfind(phase{1},'C'))
            append = [append,'.3'];
        end
        
        Location = regexp(loadinfo{1},'(?<=<Location>)(.*?)(?=</Location>)','match');
        switch Location{1}
            case 'From'
                Loads(k).ID = [bus1{1},append];
            case 'To'
                Loads(k).ID = [bus2{1},append];
        end
        
        Loads(k).Phase = length(phase);
        Loads(k).XFKVA = str2double(regexp(spotloadinfo{j},'(?<=<ConnectedKVA>)(.*?)(?=</ConnectedKVA>)','match'));
        Loads(k).kW = str2double(regexp(spotloadinfo{j},'(?<=<KW>)(.*?)(?=</KW>)','match'));
        Loads(k).kVAR = str2double(regexp(spotloadinfo{j},'(?<=<KVAR>)(.*?)(?=</KVAR>)','match'));
        Loads(k).kVA = str2double(regexp(spotloadinfo{j},'(?<=<KVA>)(.*?)(?=</KVA>)','match'));
        Loads(k).pf = str2double(regexp(spotloadinfo{j},'(?<=<PF>)(.*?)(?=</PF>)','match'));
        Loads(k).kWh = str2double(regexp(spotloadinfo{j},'(?<=<KWH>)(.*?)(?=</KWH>)','match'));
        Loads(k).NumCust = str2double(regexp(spotloadinfo{j},'(?<=<NumberOfCustomer>)(.*?)(?=</NumberOfCustomer>)','match'));
        
        k = k+1;
    end
end