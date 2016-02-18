function [Buses,Lines,Loads,Source,PARAM,DSS] = sxstRead(fullfilename)
%{
SXSTread takes a .sxst file and returns 5 structs
--NODE--
.ID         - Node ID
.w          - weight of Node demand
.p          - real power demand of Node
.q          - reactive power demand of Node
.XCoord     - X coordinate of Node
.YCoord     - Y coordinate of Node

--SECTION--
--LOAD--
--DER--
--PARAM--
--DSS--
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
FILE = fileread([filelocation,filename]);

% Find Circuit Specs
n = length(strfind(FILE,'<Node>'));
s = length(strfind(FILE,'<Section>'));

%% Generate Standard DSS Files
% Output - Shapes.dss (Empty Loadshapes for Loads to Reference)
DSS.Shapes = {'New loadshape.DailyA';'New loadshape.DailyB';'New loadshape.DailyC';...
    'New loadshape.DutyA';'New loadshape.DutyB';'New loadshape.DutyC';...
    'New loadshape.YearlyA';'New loadshape.YearlyB';'New loadshape.YearlyC'};

%% Extract Database Informaiton

EquipmentDB.Types = regexp(FILE,'(?<=<EquipmentDBType>)(.*?)(?=</EquipmentDBType>)','match');

% Output - WireData.dss (OpenDSS Library of Wire Data)
%        - LineSpacing.dss (OpenDSS Library of Line Spacing)
%        - UGLineCodes.dss (OpenDSS Library of Line Codes)
EquipmentDB.Info = regexp(FILE,'<EquipmentDBs>(.*?)</EquipmentDBs>','match');


% <SubstationDB>
EquipmentDB.Substation = struct('Info',regexp(EquipmentDB.Info{1},'<SubstationDB>(.*?)</SubstationDB>','match'));
for i =1:length(EquipmentDB.Substation)
    EquipmentDB.Substation(i).ID = regexp(EquipmentDB.Substation(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.Substation(i).ID = EquipmentDB.Substation(i).ID{1};
    
    % Read Data
    EquipmentDB.Substation(i).MVACapacity = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<NominalCapacityMVA>)(.*?)(?=</NominalCapacityMVA>)','match'));
    EquipmentDB.Substation(i).BaseKVLL = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<NominalKVLL>)(.*?)(?=</NominalKVLL>)','match'));
    EquipmentDB.Substation(i).SetKVLL = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<DesiredKVLL>)(.*?)(?=</DesiredKVLL>)','match'));
    EquipmentDB.Substation(i).SetVpu = EquipmentDB.Substation(i).SetKVLL/EquipmentDB.Substation(i).BaseKVLL;
    EquipmentDB.Substation(i).SetAngle = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<SourcePhaseAngle>)(.*?)(?=</SourcePhaseAngle>)','match'));
    EquipmentDB.Substation(i).ImpedanceUnit = regexp(EquipmentDB.Substation(i).Info,'(?<=<ImpedanceUnit>)(.*?)(?=</ImpedanceUnit>)','match');
    EquipmentDB.Substation(i).R1 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<PositiveSequenceResistance>)(.*?)(?=</PositiveSequenceResistance>)','match','once'));
    EquipmentDB.Substation(i).X1 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<PositiveSequenceReactance>)(.*?)(?=</PositiveSequenceReactance>)','match','once'));
    EquipmentDB.Substation(i).R2 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<NegativeSequenceResistance>)(.*?)(?=</NegativeSequenceResistance>)','match','once'));
    EquipmentDB.Substation(i).X2 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<NegativeSequenceReactance>)(.*?)(?=</NegativeSequenceReactance>)','match','once'));
    EquipmentDB.Substation(i).R0 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<ZeroSequenceResistance>)(.*?)(?=</ZeroSequenceResistance>)','match','once'));
    EquipmentDB.Substation(i).X0 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<ZeroSequenceReactance>)(.*?)(?=</ZeroSequenceReactance>)','match','once'));
end

% <SwitchDB>
EquipmentDB.Switch = struct('Info',regexp(EquipmentDB.Info{1},'<SwitchDB>(.*?)</SwitchDB>','match'));
for i =1:length(EquipmentDB.Switch)
    EquipmentDB.Switch(i).ID = regexp(EquipmentDB.Switch(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.Switch(i).ID = EquipmentDB.Switch(i).ID{1};
    
    % Read Data
    EquipmentDB.Switch(i).RatedkV = str2double(regexp(EquipmentDB.Switch(i).Info,'(?<=<RatedVoltage>)(.*?)(?=</RatedVoltage>)','match'));
    EquipmentDB.Switch(i).RatedAmps = str2double(regexp(EquipmentDB.Switch(i).Info,'(?<=<RatedCurrent>)(.*?)(?=</RatedCurrent>)','match'));
end

% <FuseDB>
EquipmentDB.Fuse = struct('Info',regexp(EquipmentDB.Info{1},'<FuseDB>(.*?)</FuseDB>','match'));
for i =1:length(EquipmentDB.Fuse)
    EquipmentDB.Fuse(i).ID = regexp(EquipmentDB.Fuse(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.Fuse(i).ID = EquipmentDB.Fuse(i).ID{1};
    
    % Read Data
    EquipmentDB.Fuse(i).RatedkV = str2double(regexp(EquipmentDB.Fuse(i).Info,'(?<=<RatedVoltage>)(.*?)(?=</RatedVoltage>)','match'));
    EquipmentDB.Fuse(i).RatedAmps = str2double(regexp(EquipmentDB.Fuse(i).Info,'(?<=<RatedCurrent>)(.*?)(?=</RatedCurrent>)','match'));
end

% <RecloserDB>
EquipmentDB.Recloser = struct('Info',regexp(EquipmentDB.Info{1},'<RecloserDB>(.*?)</RecloserDB>','match'));
for i =1:length(EquipmentDB.Recloser)
    EquipmentDB.Recloser(i).ID = regexp(EquipmentDB.Recloser(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.Recloser(i).ID = EquipmentDB.Recloser(i).ID{1};
    
    % Read Data
    EquipmentDB.Recloser(i).RatedkV = str2double(regexp(EquipmentDB.Recloser(i).Info,'(?<=<RatedVoltage>)(.*?)(?=</RatedVoltage>)','match'));
    EquipmentDB.Recloser(i).RatedAmps = str2double(regexp(EquipmentDB.Recloser(i).Info,'(?<=<RatedCurrent>)(.*?)(?=</RatedCurrent>)','match'));
end

% <ShuntCapacitorDB>
EquipmentDB.Capacitor = struct('Info',regexp(EquipmentDB.Info{1},'<ShuntCapacitorDB>(.*?)</ShuntCapacitorDB>','match'));
for i =1:length(EquipmentDB.Capacitor)
    EquipmentDB.Capacitor(i).ID = regexp(EquipmentDB.Capacitor(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.Capacitor(i).ID = EquipmentDB.Capacitor(i).ID{1};
    
    % Read Data
    EquipmentDB.Capacitor(i).RatedkV = sqrt(3)*str2double(regexp(EquipmentDB.Capacitor(i).Info,'(?<=<RatedVoltageKVLN>)(.*?)(?=</RatedVoltageKVLN>)','match'));
    EquipmentDB.Capacitor(i).RatedkVAR = 3*str2double(regexp(EquipmentDB.Capacitor(i).Info,'(?<=<RatedKVAR>)(.*?)(?=</RatedKVAR>)','match'));
end

% <ConductorDB>
EquipmentDB.Conductor = struct('Info',regexp(EquipmentDB.Info{1},'<ConductorDB>(.*?)</ConductorDB>','match'));
for i =1:length(EquipmentDB.Conductor)
    EquipmentDB.Conductor(i).ID = regexp(EquipmentDB.Conductor(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.Conductor(i).ID = EquipmentDB.Conductor(i).ID{1};
    
    % Read Data
    EquipmentDB.Conductor(i).Rac = str2double(regexp(EquipmentDB.Conductor(i).Info,'(?<=<FirstResistance>)(.*?)(?=</FirstResistance>)','match'));
    EquipmentDB.Conductor(i).GMRac = str2double(regexp(EquipmentDB.Conductor(i).Info,'(?<=<GMR>)(.*?)(?=</GMR>)','match'));
    EquipmentDB.Conductor(i).diam = str2double(regexp(EquipmentDB.Conductor(i).Info,'(?<=<OutsideDiameter>)(.*?)(?=</OutsideDiameter>)','match'));
    EquipmentDB.Conductor(i).normamps = str2double(regexp(EquipmentDB.Conductor(i).Info,'(?<=<NominalRating>)(.*?)(?=</NominalRating>)','match'));
    EquipmentDB.Conductor(i).emergamps = str2double(regexp(EquipmentDB.Conductor(i).Info,'(?<=<SecondRating>)(.*?)(?=</SecondRating>)','match'));
    
    % Print to file
    if ~strcmp(EquipmentDB.Conductor(i).ID,'NONE') && ~strcmp(EquipmentDB.Conductor(i).ID,'DEFAULT') % Exclude NONE and DEFAULT for WireData
        DSS.WireData{i} = sprintf(['New WireData.%s Rac=%.6f GMRac=%.6f diam=%.6f ',...
            'normamps=%d emergamps=%d Runits=km GMRunits=cm radunits=cm'],...
            EquipmentDB.Conductor(i).ID,EquipmentDB.Conductor(i).Rac,EquipmentDB.Conductor(i).GMRac,...
            EquipmentDB.Conductor(i).diam,EquipmentDB.Conductor(i).normamps,EquipmentDB.Conductor(i).emergamps);
    end
end
DSS.WireData = DSS.WireData(~cellfun(@isempty,DSS.WireData));

% <CableDB>
EquipmentDB.Cable = struct('Info',regexp(EquipmentDB.Info{1},'<CableDB>(.*?)</CableDB>','match'));
for i =1:length(EquipmentDB.Cable)
    EquipmentDB.Cable(i).ID = regexp(EquipmentDB.Cable(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.Cable(i).ID = EquipmentDB.Cable(i).ID{1};
    
    % Read Data
    EquipmentDB.Cable(i).R1 = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<PositiveSequenceResistance>)(.*?)(?=</PositiveSequenceResistance>)','match'));
    EquipmentDB.Cable(i).X1 = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<PositiveSequenceReactance>)(.*?)(?=</PositiveSequenceReactance>)','match'));
    EquipmentDB.Cable(i).R0 = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<ZeroSequenceResistance>)(.*?)(?=</ZeroSequenceResistance>)','match'));
    EquipmentDB.Cable(i).X0 = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<ZeroSequenceReactance>)(.*?)(?=</ZeroSequenceReactance>)','match'));
    EquipmentDB.Cable(i).B1 = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<PositiveSequenceShuntSusceptance>)(.*?)(?=</PositiveSequenceShuntSusceptance>)','match'));
    EquipmentDB.Cable(i).B0 = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<ZeroSequenceShuntSusceptance>)(.*?)(?=</ZeroSequenceShuntSusceptance>)','match'));
    EquipmentDB.Cable(i).normamps = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<NominalRating>)(.*?)(?=</NominalRating>)','match'));
    EquipmentDB.Cable(i).emergamps = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<SecondRating>)(.*?)(?=</SecondRating>)','match'));
    
    % Print to file
    DSS.LineCode{i} = sprintf(['New LineCode.%s R1=%.6f X1=%.6f R0=%.6f X0=%.6f ',...
        'B1=%.6f B0=%.6f normamps=%d emergamps=%d Units=km'],...
        EquipmentDB.Cable(i).ID,EquipmentDB.Cable(i).R1,EquipmentDB.Cable(i).X1,...
        EquipmentDB.Cable(i).R0,EquipmentDB.Cable(i).X0,EquipmentDB.Cable(i).B1,...
        EquipmentDB.Cable(i).B0,EquipmentDB.Cable(i).normamps,EquipmentDB.Cable(i).emergamps);
end
DSS.LineCode = DSS.LineCode(~cellfun(@isempty,DSS.LineCode));

% <OverheadSpacingOfConductorDB>
EquipmentDB.Spacing = struct('Info',regexp(EquipmentDB.Info{1},'<OverheadSpacingOfConductorDB>(.*?)</OverheadSpacingOfConductorDB>','match'));
for i =1:length(EquipmentDB.Spacing)
    EquipmentDB.Spacing(i).ID = strrep(regexp(EquipmentDB.Spacing(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'),'&apos;',''''); EquipmentDB.Spacing(i).ID = EquipmentDB.Spacing(i).ID{1};

    % Read Data
    EquipmentDB.Spacing(i).x = str2double(regexp(EquipmentDB.Spacing(i).Info,'(?<=<X>)(.*?)(?=</X>)','match'));
    EquipmentDB.Spacing(i).h = str2double(regexp(EquipmentDB.Spacing(i).Info,'(?<=<Y>)(.*?)(?=</Y>)','match'));
    EquipmentDB.Spacing(i).Ncond = length(EquipmentDB.Spacing(i).x);
    EquipmentDB.Spacing(i).Nphases = EquipmentDB.Spacing(i).Ncond - str2double(regexp(EquipmentDB.Spacing(i).Info,'(?<=<NbNeutrals>)(.*?)(?=</NbNeutrals>)','match'));
    
    % Print to file
    DSS.LineSpacing{i} = sprintf('New LineSpacing.%s Ncond=%d Nphases=%d x=[%s] h=[%s]',...
        EquipmentDB.Spacing(i).ID,EquipmentDB.Spacing(i).Ncond,...
        EquipmentDB.Spacing(i).Nphases,sprintf(' %.4f ',EquipmentDB.Spacing(i).x),...
        sprintf(' %.4f ',EquipmentDB.Spacing(i).h));
end

% <DoubleCircuitSpacingDB>
EquipmentDB.DCSpacing = struct('Info',regexp(EquipmentDB.Info{1},'<DoubleCircuitSpacingDB>(.*?)</DoubleCircuitSpacingDB>','match'));
for i =1:length(EquipmentDB.DCSpacing)
    EquipmentDB.DCSpacing(i).ID = regexp(EquipmentDB.DCSpacing(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.DCSpacing(i).ID = EquipmentDB.DCSpacing(i).ID{1};
    
    % Read Data
    EquipmentDB.DCSpacing(i).x = str2double(regexp(EquipmentDB.DCSpacing(i).Info,'(?<=<X>)(.*?)(?=</X>)','match'));
    EquipmentDB.DCSpacing(i).h = str2double(regexp(EquipmentDB.DCSpacing(i).Info,'(?<=<Y>)(.*?)(?=</Y>)','match'));
    EquipmentDB.DCSpacing(i).Ncond = length(EquipmentDB.DCSpacing(i).x);
    EquipmentDB.DCSpacing(i).Nphases = EquipmentDB.DCSpacing(i).Ncond - str2double(regexp(EquipmentDB.DCSpacing(i).Info,'(?<=<NbNeutrals>)(.*?)(?=</NbNeutrals>)','match'));
    
    % Print to file
    DSS.LineSpacing{end+1} = sprintf('New LineSpacing.%s Ncond=%d Nphases=%d x=[%s] h=[%s]',...
        EquipmentDB.DCSpacing(i).ID,EquipmentDB.DCSpacing(i).Ncond,...
        EquipmentDB.DCSpacing(i).Nphases,sprintf(' %.4f ',EquipmentDB.DCSpacing(i).x),...
        sprintf(' %.4f ',EquipmentDB.DCSpacing(i).h));
end
DSS.LineSpacing = DSS.LineSpacing(~cellfun(@isempty,DSS.LineSpacing));

%% Extract Source Information
sourceinfo = regexp(FILE,'<Source>(.*?)</Source>','match');
%Source = struct('Info',regexp(FILE,'<Source>(.*?)</Source>','match'));
for sc = 1:length(sourceinfo)
    SourceID = regexp(sourceinfo{sc},'(?<=<SourceNodeID>)(.*?)(?=</SourceNodeID>)','match');
    index = find(ismember({EquipmentDB.Substation.ID},SourceID{1}));
    Source(sc) = EquipmentDB.Substation(index);
    Source(sc).Info = sourceinfo{sc};
end

%% Extract Node Information
%  Output - Buses.dss (text file containing BusID, X, and Y Coords)
Buses = struct('Info',regexp(FILE,'<Node>(.*?)</Node>','match'));
for b = 1:n
    Buses(b).ID = regexp(Buses(b).Info,'(?<=<NodeID>)(.*?)(?=</NodeID>)','match'); Buses(b).ID = Buses(b).ID{1};
    
    % Fixed is to determine fixed loads and capacitors
    Buses(b).Fixed = false;
    
    % X and Y Coordinates
    Buses(b).XCoord = str2double(regexp(Buses(b).Info,'(?<=<X>)(.*?)(?=</X>)','match'));
    Buses(b).YCoord = str2double(regexp(Buses(b).Info,'(?<=<Y>)(.*?)(?=</Y>)','match'));
    
    % Print Node Info to file
    Buses(b).DSS = sprintf('%-30s %-15.2f %-15.2f\n',Buses(b).ID,Buses(b).XCoord,Buses(b).YCoord);
end
Buses = rmfield(Buses,'Info');

%% Extract Section Information
%  Output - Lines.dss, Loads.dss

% Initialize counters
ld = 1; % Loads
sw = 1; % Switches
fs = 1; % Fuses
cp = 1; % Capacitors
rg = 1; % Regulators
rc = 1; % Reclosers

Lines = struct('Info',regexp(FILE,'<Section>(.*?)</Section>','match'));
for l = 1:s
    Lines(l).ID = regexp(Lines(l).Info,'(?<=<SectionID>)(.*?)(?=</SectionID>)','match'); Lines(l).ID = Lines(l).ID{1};
    Lines(l).Phase = regexp(Lines(l).Info,'(?<=<Phase>)(.*?)(?=</Phase>)','match','once');
    Lines(l).numPhase = length(Lines(l).Phase);
    
    % String to be appended to bus info
    append = '';
    if ~isempty(strfind(Lines(l).Phase,'A'))
        append = [append,'.1'];
    end
    if ~isempty(strfind(Lines(l).Phase,'B'))
        append = [append,'.2'];
    end
    if ~isempty(strfind(Lines(l).Phase,'C'))
        append = [append,'.3'];
    end
    
    bus1 = regexp(Lines(l).Info,'(?<=<FromNodeID>)(.*?)(?=</FromNodeID>)','match');
    bus2 = regexp(Lines(l).Info,'(?<=<ToNodeID>)(.*?)(?=</ToNodeID>)','match');
    Lines(l).Bus1 = [bus1{1},append];
    Lines(l).FROM = bus1{1};
    Lines(l).Bus2 = [bus2{1},append];
    Lines(l).TO   = bus2{1};
    
    % Reclosers (counter = rc)
    reclinfo = regexp(Lines(l).Info,'<Recloser>(.*?)</Recloser>','match');
    if ~isempty(reclinfo)
        Lines(l).Recloser = true;
        Lines(l).ReclCode = regexp(reclinfo,'(?<=<DeviceID>)(.*?)(?=</DeviceID>)','match'); Lines(l).ReclCode = Lines(l).ReclCode{1};
    else
        Lines(l).Recloser = false;
    end
    
    % Switches (counter = sw)
    switchinfo = regexp(Lines(l).Info,'<Switch>(.*?)</Switch>','match');
    if ~isempty(switchinfo)
        Lines(l).Switch = true;
        Lines(l).SwitchCode = regexp(switchinfo,'(?<=<DeviceID>)(.*?)(?=</DeviceID>)','match'); Lines(l).SwitchCode = Lines(l).SwitchCode{1};
        Lines(l).NormalStatus = regexp(switchinfo,'(?<=<NormalStatus>)(.*?)(?=</NormalStatus>)','match');
        Lines(l).NormalStatus = strcmp(Lines(l).NormalStatus{1},'Closed');
    else
        Lines(l).Switch = false;
        Lines(l).NormalStatus = true;
    end
    
    % Fuses (counter = fs)
    fuseinfo = regexp(Lines(l).Info,'<Fuse>(.*?)</Fuse>','match');
    if ~isempty(fuseinfo)
        Lines(l).Fuse = true;
        Lines(l).FuseCode = regexp(fuseinfo,'(?<=<DeviceID>)(.*?)(?=</DeviceID>)','match'); Lines(l).FuseCode = Lines(l).FuseCode{1};
    else
        Lines(l).Fuse = false;
    end
    
    % Overhead Wire
    overheadbyphaseinfo = regexp(Lines(l).Info,'<OverheadByPhase>(.*?)</OverheadByPhase>','match');
    overheadlineinfo    = regexp(Lines(l).Info,'<OverheadLine>(.*?)</OverheadLine>','match');
    
    if ~isempty(overheadbyphaseinfo)
        Lines(l).Length = str2double(regexp(overheadbyphaseinfo{1},'(?<=<Length>)(.*?)(?=</Length>)','match'));
        Lines(l).Spacing = strrep(regexp(overheadbyphaseinfo{1},'(?<=<ConductorSpacingID>)(.*?)(?=</ConductorSpacingID>)','match'),'&apos;',''''); Lines(l).Spacing = Lines(l).Spacing{1};
        wires = regexp(overheadbyphaseinfo{1},'(?<=<PhaseConductorID[ABC]>)(.*?)(?=</PhaseConductorID[ABC]>)','match');
        wires = [wires(~strcmp(wires,'NONE')),regexp(overheadbyphaseinfo{1},'(?<=<NeutralConductorID>)(.*?)(?=</NeutralConductorID>)','match')];
        Lines(l).Wires = ['[''',strjoin(wires,''' '''),''']'];
        
        % Print to file Lines.dss
        Lines(l).DSS = sprintf(['New Line.%s Phases= %d Bus1=%-15s Bus2=%-15s ',...
            'Length=%-6.2f units=m  Spacing=%s wires=%s'],...
            Lines(l).ID,Lines(l).numPhase,Lines(l).Bus1,Lines(l).Bus2,...
            Lines(l).Length,Lines(l).Spacing,Lines(l).Wires);
    end
    
    if ~isempty(overheadlineinfo)
        Lines(l).Length = str2double(regexp(overheadlineinfo{1},'(?<=<Length>)(.*?)(?=</Length>)','match'));
        
        % Print to file Lines.dss
%         fprintf(fid(4),['New Line.%s Phases= %d Bus1=%-15s Bus2=%-15s ',...
%             'Length=%-6.2f units=m\n'],...
%             Lines(l).ID,Lines(l).numPhase,Lines(l).Bus1,Lines(l).Bus2,...
%             Lines(l).Length);

        % Print to file Lines.dss
        Lines(l).DSS = sprintf(['New Line.%s Phases= %d Bus1=%-15s Bus2=%-15s ',...
            'Length=%-6.2f units=m  Spacing=%s wires=%s'],...
            Lines(l).ID,Lines(l).numPhase,Lines(l).Bus1,Lines(l).Bus2,...
            Lines(l).Length,'8''-ARM-NON-CENTER-POST-3PH',...
        '[''336-ACSR-B-18X1'' ''336-ACSR-B-18X1'' ''336-ACSR-B-18X1'' ''1/0-ACSR-B-6X1'']');
    end
    
    
    % Underground Cable
    undergroundinfo = regexp(Lines(l).Info,'<Underground>(.*?)</Underground>','match');
    if ~isempty(undergroundinfo)
        Lines(l).Length = str2double(regexp(undergroundinfo{1},'(?<=<Length>)(.*?)(?=</Length>)','match'));
        Lines(l).LineCode = regexp(undergroundinfo{1},'(?<=<CableID>)(.*?)(?=</CableID>)','match'); Lines(l).LineCode = Lines(l).LineCode{1};
        
        % Print to file Lines.dss
        Lines(l).DSS = sprintf(['New Line.%s Bus1=%-15s Bus2=%-15s LineCode=%s ',...
            'Phases= %d Length=%-6.2f units=m'],Lines(l).ID,...
            Lines(l).Bus1,Lines(l).Bus2,Lines(l).LineCode,Lines(l).numPhase,...
            Lines(l).Length);
    end

    %% Extract Device Information
    %  Spot Loads (counter = ld)
    loadinfo = regexp(Lines(l).Info,'<SpotLoad>(.*?)</SpotLoad>','match');
    spotloadinfo = regexp(Lines(l).Info,'<CustomerLoadValue>(.*?)</CustomerLoadValue>','match');
    for i = 1:length(spotloadinfo)
        Phase = regexp(spotloadinfo{i},'(?<=<Phase>)(.*?)(?=</Phase>)','match');
        % String to be appended to load info
        append = '';
        if ~isempty(strfind(Phase{1},'A'))
            append = [append,'_1'];
        end
        if ~isempty(strfind(Phase{1},'B'))
            append = [append,'_2'];
        end
        if ~isempty(strfind(Phase{1},'C'))
            append = [append,'_3'];
        end
        
        Location = regexp(loadinfo{1},'(?<=<Location>)(.*?)(?=</Location>)','match');
        switch Location{1}
            case 'From'
                index = find(ismember({Buses.ID},Lines(l).FROM));
                Loads(ld).ID = bus1{1};
                Loads(ld).Name = [bus1{1},append];
            case 'To'
                index = find(ismember({Buses.ID},Lines(l).TO));
                Loads(ld).ID = bus2{1};
                Loads(ld).Name = [bus2{1},append];
        end
        
        Loads(ld).XCoord = Buses(index).XCoord;
        Loads(ld).YCoord = Buses(index).YCoord;
        Loads(ld).Phase = Phase{1};
        Loads(ld).NumPhase = length(Phase);
        Loads(ld).Bus1 = strrep(Loads(ld).Name,'_','.');
        Loads(ld).kV = Source(1).BaseKVLL/sqrt(3); % kV
        Loads(ld).XFKVA = str2double(regexp(spotloadinfo{i},'(?<=<ConnectedKVA>)(.*?)(?=</ConnectedKVA>)','match'));
        
        LoadType = regexp(spotloadinfo{i},'(?<=<LoadValue Type="LoadValue)(.*?)(?=">)','match');
        Loads(ld).Type = LoadType;
        switch LoadType{1}
            case 'KW_KVAR'
                Loads(ld).kW = str2double(regexp(spotloadinfo{i},'(?<=<KW>)(.*?)(?=</KW>)','match'));
                Loads(ld).kVAR = str2double(regexp(spotloadinfo{i},'(?<=<KVAR>)(.*?)(?=</KVAR>)','match'));
                Loads(ld).kVA = sqrt(Loads(ld).kW^2 + Loads(ld).kVAR^2);
                Loads(ld).pf  = cos(atan(Loads(ld).kVAR/Loads(ld).kW));
            case 'KVA_PF'
                Loads(ld).kVA = str2double(regexp(spotloadinfo{i},'(?<=<KVA>)(.*?)(?=</KVA>)','match'));
                Loads(ld).pf  = str2double(regexp(spotloadinfo{i},'(?<=<PF>)(.*?)(?=</PF>)','match'))/100;
                Loads(ld).kW   = Loads(ld).kVA*Loads(ld).pf;
                Loads(ld).kVAR = Loads(ld).kVA*sqrt(1-Loads(ld).pf^2);
            case 'KW_PF'
                Loads(ld).kW = str2double(regexp(spotloadinfo{i},'(?<=<KW>)(.*?)(?=</KW>)','match'));
                Loads(ld).pf  = str2double(regexp(spotloadinfo{i},'(?<=<PF>)(.*?)(?=</PF>)','match'))/100;
                Loads(ld).kVA = Loads(ld).kW/loads(ld).pf;
                Loads(ld).kVAR = Loads(ld).kVA*sqrt(1-Loads(ld).pf^2);
            otherwise
                error('Unknown Load Type at Node %s',Loads.ID)
        end
        
        Loads(ld).w = 1;
        Loads(ld).p = Loads(ld).kW;
        Loads(ld).kWh = str2double(regexp(spotloadinfo{i},'(?<=<KWH>)(.*?)(?=</KWH>)','match'));
        Loads(ld).NumCust = str2double(regexp(spotloadinfo{i},'(?<=<NumberOfCustomer>)(.*?)(?=</NumberOfCustomer>)','match'));
        
        % Print Load
        % kW=#.###### yearly=YearlyP daily=DailyP kVAR=#.######
        Loads(ld).DSS = sprintf(['New Load.%s Bus1=%-10s Phases=%d kV=%.4f ',...
        'kW=%.6f yearly=Yearly%c daily=Daily%c kVAR=%.6f'],...
        Loads(ld).Name,Loads(ld).Bus1,Loads(ld).NumPhase,Loads(ld).kV,...
        Loads(ld).kW,repmat(Loads(ld).Phase,1,2),Loads(ld).kVAR);
        %20,repmat(Loads(ld).Phase,1,2),2);

        % XFKVA=#.#(min10KVA) PF=0.95 yearly=YearlyP daily=DailyP
%         Loads(ld).DSS = sprintf(['New Load.%s Bus1=%-10s Phases=%d kV=%.4f ',...
%         'XFKVA=%.1f PF=%.2f yearly=Yearly%c daily=Daily%c'],...
%         Loads(ld).Name,Loads(ld).Bus1,Loads(ld).NumPhase,Loads(ld).kV,...
%         max(Loads(ld).XFKVA,10),0.95,repmat(Loads(ld).Phase,1,2));
        
        ld = ld+1;
    end
    
    % Capacitors (counter = cp)
    capinfo = regexp(Lines(l).Info,'<ShuntCapacitor>(.*?)</ShuntCapacitor>','match');
    if ~isempty(capinfo)
        Location = regexp(capinfo{1},'(?<=<Location>)(.*?)(?=</Location>)','match');
        switch Location{1}
            case 'From'
                index = find(ismember({Buses.ID},Lines(l).FROM));
                Capacitors(cp).ID = bus1{1};
            case 'To'
                index = find(ismember({Buses.ID},Lines(l).TO));
                Capacitors(cp).ID = bus2{1};
        end
        
        Capacitors(cp).Phases = 3;
        [Capacitors(cp).kVAR,type] = max([sum(str2double(regexp(capinfo{1},'(?<=<SwitchedKVAR[ABC]>)(.*?)(?=</SwitchedKVAR[ABC]>)','match'))),...
            sum(str2double(regexp(capinfo{1},'(?<=<FixedKVAR[ABC]>)(.*?)(?=</FixedKVAR[ABC]>)','match')))]);
        
        Capacitors(cp).kV = sqrt(3)*str2double(regexp(capinfo{1},'(?<=<KVLN>)(.*?)(?=</KVLN>)','match'));
        
        Buses(index).Capacitors = sprintf('New Capacitor.%s Bus1= %s Phases= %d kvar= %d kV= %.2f',...
            Capacitors(cp).ID,Capacitors(cp).ID,Capacitors(cp).Phases,...
            Capacitors(cp).kVAR,Capacitors(cp).kV);
        
        switch type
            case 1
                Capacitors(cp).Type = 'switched';
                
                Buses(index).CapCtrl = sprintf(['New Capcontrol.%s Element=Line.%s Capacitor=%s Terminal=1 ',...
                    'type=voltage ONsetting=122 OFFsetting=124 PTRatio=%d VoltOverride=N Vmax = 126 Vmin = 116 delay = 45',...
                    Capacitors(cp).ID,Lines(l).ID,Capacitors(cp).ID,round(1000*Capacitors(cp).kv/(60*sqrt(3)))]);
                
            case 2
                Capacitors(cp).Type = 'fixed';
                Buses(index).Fixed = true;
        end
        
        cp = cp+1;
    end
    
    % Regulators (counter = rg)
    
    Lines(l).Device = Lines(l).Switch | Lines(l).Recloser | Lines(l).Fuse;
    
end
Lines = rmfield(Lines,'Info');

% Define Parameters
PARAM.NO = {};
PARAM.NC = {Buses([Buses.Fixed]).ID};
PARAM.SO = {};
PARAM.SC = {Lines(~[Lines.Device]).ID};
Buses = rmfield(Buses,'Fixed');

%% Generate Source Commands
for sc = 1:length(Source)
    index = mod(find(ismember([{Lines.FROM},{Lines.TO}],Source(sc).ID)),l);
    Source(sc).MeterLine = Lines(index).ID;
    
    Source(sc).PeakAmps = str2double(regexp(Source(sc).Info,'(?<=<AMP>)(.*?)(?=</AMP>)','match'));
    Source(sc).SetVolt  = str2double(regexp(Source(sc).Info,'(?<=<DesiredVoltage>)(.*?)(?=</DesiredVoltage>)','match'));
    
    if isempty(Source(sc).R2)
        Source(sc).R2 = Source(sc).R1; Source(sc).X2 = Source(sc).X1;
        warning('Missing Negative Sequence Source Impedance. Default Z2 = Z1')
    end
    if isnan(Source(sc).PeakAmps)
        defaultPeak = [400,400,400];
        Source(sc).PeakAmps = defaultPeak;
        warning('Missing Peak Source Current. Default A: %dA, B: %dA, C: %dA',defaultPeak)
    end
    if isnan(Source(sc).SetVolt)
        defaultPU = 1.03;
        Source(sc).SetVolt = defaultPU*Source(sc).BaseKVLL;
        warning('Missing Source Voltage Set Point. Default %.2fpu',defaultPU)
    end
    
    % Print Master File
    Source(sc).DSSCircuit = sprintf(['New Circuit.%s Bus1=%s BasekV=%.2f  pu=%.4f ',...
        'angle=%.2f Z1=[ %.4f %.4f ] Z2=[ %.4f %.4f ] Z0=[ %.4f %.4f ]'],...
        Source(sc).ID,Source(sc).ID,Source(sc).BaseKVLL,Source(sc).SetVolt/Source(sc).BaseKVLL,...
        Source(sc).SetAngle,Source(sc).R1,Source(sc).X1,Source(sc).R2,Source(sc).X2,Source(sc).R0,Source(sc).X0);
    Source(sc).DSSVoltbase = sprintf('Set voltagebases = [ %.2f %.2f ] CalcVoltageBases',...
        Source(sc).BaseKVLL,Source(sc).BaseKVLL/sqrt(3));
    Source(sc).EnergyMeter = sprintf(['New EnergyMeter.CircuitMeter Line.%s ',...
        'terminal=1 option=R PhaseVoltageReport=yes peakcurrent=[ %.2f   %.2f   %.2f ]'],...
        Source(sc).MeterLine,Source(sc).PeakAmps);
end

fclose('all');