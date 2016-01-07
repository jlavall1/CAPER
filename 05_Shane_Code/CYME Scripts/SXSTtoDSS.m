%{
SXSTtoDSS reads in a CYME file (.sxst) and generates the following files
Master.dss - OpenDSS redirect information for defining circuit
Shapes.dss - OpenDSS Daily and Yearly Loadshape definitions
BusesCoords.dss - Bus Coordinates for plotting circuit

\Libraries
% *WireData.dss
% *LineSpacing.dss
% *UGLineCodes.dss

\Elements
% Lines.dss - OpenDSS line definitions
% *LinesNO.dss - OpenDSS line definitions for Normally Open points for loops
% Loads.dss - OpenDSS load definitions
% Capacitors.dss - OpenDSS capacitor definitions
% *Regulators.dss - OpenDSS regulator definitions

\Controls
% *FuseContrl.dss - OpenDSS fuse control settings
% *SwitContrl.dss - OpenDSS switch control settings
% *ReclContrl.dss - OpenDSS recloser control settings

% All Files will be saved in folowing location:
%   SXSTdir\filename.sxst_DSS\ {here}
%}
clear
clc

fid(1) = fopen('pathdef.m');
rootlocation = textscan(fid(1),'%c')';
rootlocation = regexp(rootlocation{1}','C:[^.]*?CAPER\\','match','once');
fclose(fid(1));
rootlocation = [rootlocation,'07_CYME\'];

filelocation = rootlocation; filename = 0;
% ****To skip UIGETFILE uncomment desired filename****
% ******(Must be in rootlocation CAPER\07_CYME)*******
%filename = 'Flay 12-01 - 2-3-15 loads (original).sxst';
%filename = 'Commonwealth 12-05-  9-14 loads (original).sxst';
%filename = 'Kud1207 (original).sxst'
%filename = 'Bellhaven 12-04 - 8-14 loads.xst (original).sxst'
filename = 'Commonwealth_ret_01311205.sxst';
while ~filename
    [filename,filelocation] = uigetfile({'*.*','All Files'},'Select SXST file to Convert',...
        rootlocation);
end

% Generate Save Location
savelocation = [filelocation,filename,'_DSS\'];
if ~exist(savelocation,'dir')
    mkdir(savelocation)
    mkdir([savelocation,'Elements\'])
    mkdir([savelocation,'Controls\'])
end

tic
% Read SXST File
FILE = fileread([filelocation,filename]);

% Print Circuit Specs
sc = length(strfind(FILE,'<Source>'));

n = length(strfind(FILE,'<Node>'));
s = length(strfind(FILE,'<Section>'));
no = length(strfind(FILE,'<NormalStatus>Open</NormalStatus>'));

l = length(strfind(FILE,'<SpotLoad>'));
lp = length(strfind(FILE,'<CustomerLoadValue>'));
fprintf('%d Source(s)\n%d Nodes; %d Sections; (%d N.O. Switches)\n%d Loads (%d by phase)\n',sc,n,l,no,l,lp)

%% Generate Standard Files
% Output - Shapes.dss (Empty Loadshapes for Loads to Reference)
fid(2) = fopen([savelocation,'Shapes.dss'],'wt');
fprintf(fid(2),['New loadshape.DailyA\n',...
    'New loadshape.DailyB\n',...
    'New loadshape.DailyC\n\n',...
    'New loadshape.DutyA\n',...
    'New loadshape.DutyB\n',...
    'New loadshape.DutyC\n\n',...
    'New loadshape.YearlyA\n',...
    'New loadshape.YearlyB\n',...
    'New loadshape.YearlyC']);
fclose(fid(2));

%% Extract Database Informaiton
% Output - WireData.dss (OpenDSS Library of Wire Data)
%        - LineSpacing.dss (OpenDSS Library of Line Spacing)
%        - UGLineCodes.dss (OpenDSS Library of Line Codes)

EquipmentDB.Info = regexp(FILE,'<EquipmentDBs>(.*?)</EquipmentDBs>','match');

% <SubstationDB>
EquipmentDB.Substation = struct('Info',regexp(EquipmentDB.Info{1},'<SubstationDB>(.*?)<SubstationDetails>','match'));
for i =1:length(EquipmentDB.Substation)
    EquipmentDB.Substation(i).ID = regexp(EquipmentDB.Substation(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.Substation(i).ID = EquipmentDB.Substation(i).ID{1};
    
    % Read Data
    EquipmentDB.Substation(i).MVACapacity = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<NominalCapacityMVA>)(.*?)(?=</NominalCapacityMVA>)','match'));
    EquipmentDB.Substation(i).BaseKVLL = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<NominalKVLL>)(.*?)(?=</NominalKVLL>)','match'));
    EquipmentDB.Substation(i).SetKVLL = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<DesiredKVLL>)(.*?)(?=</DesiredKVLL>)','match'));
    EquipmentDB.Substation(i).SetVpu = EquipmentDB.Substation(i).SetKVLL/EquipmentDB.Substation(i).BaseKVLL;
    EquipmentDB.Substation(i).SetAngle = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<SourcePhaseAngle>)(.*?)(?=</SourcePhaseAngle>)','match'));
    EquipmentDB.Substation(i).ImpedanceUnit = regexp(EquipmentDB.Substation(i).Info,'(?<=<ImpedanceUnit>)(.*?)(?=</ImpedanceUnit>)','match');
    EquipmentDB.Substation(i).R1 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<PositiveSequenceResistance>)(.*?)(?=</PositiveSequenceResistance>)','match'));
    EquipmentDB.Substation(i).X1 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<PositiveSequenceReactance>)(.*?)(?=</PositiveSequenceReactance>)','match'));
    EquipmentDB.Substation(i).R2 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<NegativeSequenceResistance>)(.*?)(?=</NegativeSequenceResistance>)','match'));
    EquipmentDB.Substation(i).X2 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<NegativeSequenceReactance>)(.*?)(?=</NegativeSequenceReactance>)','match'));
    EquipmentDB.Substation(i).R0 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<ZeroSequenceResistance>)(.*?)(?=</ZeroSequenceResistance>)','match'));
    EquipmentDB.Substation(i).X0 = str2double(regexp(EquipmentDB.Substation(i).Info,'(?<=<ZeroSequenceReactance>)(.*?)(?=</ZeroSequenceReactance>)','match'));
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
end

% <CableDB>
EquipmentDB.Cable = struct('Info',regexp(EquipmentDB.Info{1},'<CableDB>(.*?)</CableDB>','match'));
for i =1:length(EquipmentDB.Cable)
    EquipmentDB.Cable(i).ID = regexp(EquipmentDB.Cable(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.Cable(i).ID = EquipmentDB.Cable(i).ID{1};
    
    % Read Data
    EquipmentDB.Cable(i).Rac = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<FirstResistance>)(.*?)(?=</FirstResistance>)','match'));
    EquipmentDB.Cable(i).GMRac = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<GMR>)(.*?)(?=</GMR>)','match'));
    EquipmentDB.Cable(i).diam = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<OutsideDiameter>)(.*?)(?=</OutsideDiameter>)','match'));
    EquipmentDB.Cable(i).normamps = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<NominalRating>)(.*?)(?=</NominalRating>)','match'));
    EquipmentDB.Cable(i).emergamps = str2double(regexp(EquipmentDB.Cable(i).Info,'(?<=<SecondRating>)(.*?)(?=</SecondRating>)','match'));
end

% <OverheadSpacingOfConductorDB>
EquipmentDB.Spacing = struct('Info',regexp(EquipmentDB.Info{1},'<OverheadSpacingOfConductorDB>(.*?)</OverheadSpacingOfConductorDB>','match'));
for i =1:length(EquipmentDB.Spacing)
    EquipmentDB.Spacing(i).ID = regexp(EquipmentDB.Spacing(i).Info,'(?<=<EquipmentID>)(.*?)(?=</EquipmentID>)','match'); EquipmentDB.Spacing(i).ID = EquipmentDB.Spacing(i).ID{1};
    
    % Read Data
    EquipmentDB.Spacing(i).Rac = str2double(regexp(EquipmentDB.Spacing(i).Info,'(?<=<FirstResistance>)(.*?)(?=</FirstResistance>)','match'));
    EquipmentDB.Spacing(i).GMRac = str2double(regexp(EquipmentDB.Spacing(i).Info,'(?<=<GMR>)(.*?)(?=</GMR>)','match'));
    EquipmentDB.Spacing(i).diam = str2double(regexp(EquipmentDB.Spacing(i).Info,'(?<=<OutsideDiameter>)(.*?)(?=</OutsideDiameter>)','match'));
    EquipmentDB.Spacing(i).normamps = str2double(regexp(EquipmentDB.Spacing(i).Info,'(?<=<NominalRating>)(.*?)(?=</NominalRating>)','match'));
    EquipmentDB.Spacing(i).emergamps = str2double(regexp(EquipmentDB.Spacing(i).Info,'(?<=<SecondRating>)(.*?)(?=</SecondRating>)','match'));
end

% <DoubleCircuitSpacingDB>

%% Extract Node Information
%  Output - Buses.dss (text file containing BusID, X, and Y Coords)
Buses = struct('Info',regexp(FILE,'<Node>(.*?)</Node>','match'));
fid(3) = fopen([savelocation,'BusCoords.dss'],'wt');
for b = 1:n
    Buses(b).ID = regexp(Buses(b).Info,'(?<=<NodeID>)(.*?)(?=</NodeID>)','match'); Buses(b).ID = Buses(b).ID{1};
    Buses(b).XCoord = str2double(regexp(Buses(b).Info,'(?<=<X>)(.*?)(?=</X>)','match'));
    Buses(b).YCoord = str2double(regexp(Buses(b).Info,'(?<=<Y>)(.*?)(?=</Y>)','match'));
    
    fprintf(fid(3),'%-30s %-15.2f %-15.2f\n',Buses(b).ID,Buses(b).XCoord,Buses(b).YCoord);
end
fclose(fid(3));
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
fid(4) = fopen([savelocation,'Elements\Lines.dss'],'wt');
fid(5) = fopen([savelocation,'Elements\Loads.dss'],'wt');
fid(6) = fopen([savelocation,'Elements\Capacitors.dss'],'wt');
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
    Lines(l).Bus2 = [bus2{1},append];
    
    % Reclosers (counter = rc)
    reclinfo = regexp(Lines(l).Info,'<Recloser>(.*?)</Recloser>','match');
    if ~isempty(reclinfo)
        Lines(l).Recloser = 1;
        Lines(l).ReclCode = regexp(reclinfo,'(?<=<DeviceID>)(.*?)(?=</DeviceID>)','match'); Lines(l).ReclCode = Lines(l).ReclCode{1};
    else
        Lines(l).Recloser = 0;
    end
    
    % Switches (counter = sw)
    switchinfo = regexp(Lines(l).Info,'<Switch>(.*?)</Switch>','match');
    if ~isempty(switchinfo)
        Lines(l).Switch = 1;
        Lines(l).SwitchCode = regexp(switchinfo,'(?<=<DeviceID>)(.*?)(?=</DeviceID>)','match'); Lines(l).SwitchCode = Lines(l).SwitchCode{1};
        Lines(l).Enable = regexp(switchinfo,'(?<=<NormalStatus>)(.*?)(?=</NormalStatus>)','match');
        Lines(l).Enable = strrep(Lines(l).Enable{1},'Closed','yes');
        Lines(l).Enable = strrep(Lines(l).Enable{1},'Open','no');
    else
        Lines(l).Switch = 0;
        Lines(l).Enable = 'yes';
    end
    
    % Fuses (counter = fs)
    fuseinfo = regexp(Lines(l).Info,'<Fuse>(.*?)</Fuse>','match');
    if ~isempty(fuseinfo)
        Lines(l).Fuse = 1;
        Lines(l).FuseCode = regexp(fuseinfo,'(?<=<DeviceID>)(.*?)(?=</DeviceID>)','match'); Lines(l).FuseCode = Lines(l).FuseCode{1};
    else
        Lines(l).Fuse = 0;
    end
    
    % Overhead Wire
    overheadinfo = regexp(Lines(l).Info,'<OverheadByPhase>(.*?)</OverheadByPhase>','match');
    if ~isempty(overheadinfo)
        Lines(l).Length = str2double(regexp(overheadinfo{1},'(?<=<Length>)(.*?)(?=</Length>)','match'));
        Lines(l).Spacing = strrep(regexp(overheadinfo{1},'(?<=<ConductorSpacingID>)(.*?)(?=</ConductorSpacingID>)','match'),'&apos;',''''); Lines(l).Spacing = Lines(l).Spacing{1};
        wires = regexp(overheadinfo{1},'(?<=<PhaseConductorID[ABC]>)(.*?)(?=</PhaseConductorID[ABC]>)','match');
        wires = [wires(~strcmp(wires,'NONE')),regexp(overheadinfo{1},'(?<=<NeutralConductorID>)(.*?)(?=</NeutralConductorID>)','match')];
        Lines(l).Wires = ['[''',strjoin(wires,''' '''),''']'];
        
        % Print to file Lines.dss
        fprintf(fid(4),['New Line.%s Phases= %d Bus1=%-15s Bus2=%-15s ',...
            'Length=%-6.2f units=m  Spacing=%s wires=%s\n'],...
            Lines(l).ID,Lines(l).numPhase,Lines(l).Bus1,Lines(l).Bus2,...
            Lines(l).Length,Lines(l).Spacing,Lines(l).Wires);
    end
    
    % Underground Cable
    undergroundinfo = regexp(Lines(l).Info,'<Underground>(.*?)</Underground>','match');
    if ~isempty(undergroundinfo)
        Lines(l).Length = str2double(regexp(undergroundinfo{1},'(?<=<Length>)(.*?)(?=</Length>)','match'));
        Lines(l).LineCode = regexp(undergroundinfo{1},'(?<=<CableID>)(.*?)(?=</CableID>)','match'); Lines(l).LineCode = Lines(l).LineCode{1};
        
        % Print to file Lines.dss
        fprintf(fid(4),['New Line.%s Bus1=%-15s Bus2=%-15s LineCode=%s ',...
            'Phases= %d Length=%-6.2f units=m enable=%s\n'],Lines(l).ID,...
            Lines(l).Bus1,Lines(l).Bus2,Lines(l).LineCode,Lines(l).numPhase,...
            Lines(l).Length,Lines(l).Enable);
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
                Loads(ld).ID = [bus1{1},append];
            case 'To'
                Loads(ld).ID = [bus2{1},append];
        end
        
        Loads(ld).Phase = Phase{1};
        Loads(ld).NumPhase = length(Phase);
        Loads(ld).Bus1 = strrep(Loads(ld).ID,'_','.');
        Loads(ld).kV = 7.2; % kV
        Loads(ld).XFKVA = str2double(regexp(spotloadinfo{i},'(?<=<ConnectedKVA>)(.*?)(?=</ConnectedKVA>)','match'));
        
        LoadType = regexp(spotloadinfo{i},'(?<=<LoadValue Type="LoadValue)(.*?)(?=">)','match');
        
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
                error('Unknown Load Type')
        end
        
        Loads(ld).kWh = str2double(regexp(spotloadinfo{i},'(?<=<KWH>)(.*?)(?=</KWH>)','match'));
        Loads(ld).NumCust = str2double(regexp(spotloadinfo{i},'(?<=<NumberOfCustomer>)(.*?)(?=</NumberOfCustomer>)','match'));
        
        % Print Load
        fprintf(fid(5),['New Load.%s Bus1=%-10s Phases=%d kV=%.4f ',...
        'kW=%.6f yearly=Yearly%c daily=Daily%c kVAR=%.6f\n'],...
        Loads(ld).ID,Loads(ld).Bus1,Loads(ld).NumPhase,Loads(ld).kV,...
        Loads(ld).kW,repmat(Loads(ld).Phase,1,2),Loads(ld).kVAR);
        
        ld = ld+1;
    end
    
    % Capacitors (counter = cp)
    capinfo = regexp(Lines(l).Info,'<ShuntCapacitor>(.*?)</ShuntCapacitor>','match');
    if ~isempty(capinfo)
        Location = regexp(capinfo{1},'(?<=<Location>)(.*?)(?=</Location>)','match');
        switch Location{1}
            case 'From'
                Capacitors(cp).ID = bus1{1};
            case 'To'
                Capacitors(cp).ID = bus2{1};
        end
        
        Capacitors(cp).Phases = 3;
        [Capacitors(cp).kVAR,type] = max([sum(str2double(regexp(capinfo{1},'(?<=<SwitchedKVAR[ABC]>)(.*?)(?=</SwitchedKVAR[ABC]>)','match'))),...
            sum(str2double(regexp(capinfo{1},'(?<=<FixedKVAR[ABC]>)(.*?)(?=</FixedKVAR[ABC]>)','match')))]);
        
        Capacitors(cp).kV = sqrt(3)*str2double(regexp(capinfo{1},'(?<=<KVLN>)(.*?)(?=</KVLN>)','match'));
        
        fprintf(fid(6),'New Capacitor.%s Bus1= %s Phases= %d kvar= %d kV= %.2f\n',...
            Capacitors(cp).ID,Capacitors(cp).ID,Capacitors(cp).Phases,...
            Capacitors(cp).kVAR,Capacitors(cp).kV);
        
        switch type
            case 1
                Capacitors(cp).Type = 'switched';
                
                fprintf(fid(6),'New Capcontrol.%s Element=Line.%s Capacitor=%s Terminal=1\n',Capacitors(cp).ID,Lines(l).ID,Capacitors(cp).ID);
                fprintf(fid(6),'!~ type=time Onsetting=6 offsetting=23\n');
                fprintf(fid(6),'!~ type=kvar ONSetting=250 OFFSetting=200\n');
                fprintf(fid(6),'!~ type=voltage ONsetting=116 OFFsetting=119 vmax=126 vmin=112 voltOverride=yes\n');
                
            case 2
                Capacitors(cp).Type = 'fixed';
        end
        
        cp = cp+1;
    end
    
    % Regulators (counter = rg)
    
    % Reclosers (counter = rc)
    
end
fclose(fid(4));
fclose(fid(5));
fclose(fid(6));
Lines = rmfield(Lines,'Info');

%% Generate Master File
Sources = struct('Info',regexp(FILE,'<Source>(.*?)</Source>','match'));
if sc > 1
    warning('Does not support multiple sources')
end

Sources.ID = regexp(Sources.Info,'(?<=<SourceNodeID>)(.*?)(?=</SourceNodeID>)','match'); Sources.ID = Sources.ID{1};
Sources.PeakAmps = str2double(regexp(Sources.Info,'(?<=<AMP>)(.*?)(?=</AMP>)','match'));

% Print Master File
fid(7) = fopen([savelocation,'Master.dss'],'wt');
fprintf(fid(7),['Clear\n\n! Define the Circuit\n',...
    sprintf('New Circuit.%s Bus1=%s',Sources(1).ID,Sources(1).ID),'\n',...
    sprintf('~ BasekV=%.2f  pu=%.4f  angle=%.2f',EquipmentDB.Substation(1).BaseKVLL,EquipmentDB.Substation(1).SetVpu,EquipmentDB.Substation(1).SetAngle),'\n',...
    sprintf('~ Z1=[ %.4f %.4f ]',EquipmentDB.Substation(1).R1,EquipmentDB.Substation(1).X1),'\n',...
    sprintf('~ Z2=[ %.4f %.4f ]',EquipmentDB.Substation(1).R2,EquipmentDB.Substation(1).X2),'\n',...
    sprintf('~ Z0=[ %.4f %.4f ]',EquipmentDB.Substation(1).R0,EquipmentDB.Substation(1).X0),'\n\n',...
    '! Library Data\n',...
    'Redirect Libraries\\WireData.dss\n',...
    'Redirect Libraries\\LineSpacing.dss\n',...
    'Redirect Libraries\\UGLineCodes.dss\n\n'...
    '! Loadshapes\n',...
    'Redirect Shapes.dss\n\n',...
    '! Circuit Element Data\n',...
    'Redirect Elements\\Lines_.dss\n',...
    'Redirect Elements\\Loads.dss\n',...
    'Redirect Elements\\Capacitors.dss\n',...
    'Redirect Elements\\Regulators.dss\n\n',...
    '! Circuit Control Settings\n',...
    '!Redirect Controls\\FuseContrl.dss\n',...
    '!Redirect Controls\\SwitContrl.dss\n',...
    '!Redirect Controls\\ReclContrl.dss\n\n',...
    '! Set the voltage bases\n',...
    'Set voltagebases = [ 12.47 7.20 0.480 0.208 0.240 0.120 ]\n',...
    'CalcVoltageBases\n\n',...
    '! Define the bus coordinates\n',...
    'Buscoords BusCoords.dss\n\n',...
    '! Define an energy meter\n',...
    'New EnergyMeter.CircuitMeter LINE.259355408 terminal=1 option=R PhaseVoltageReport=yes\n',...
    sprintf('~ peakcurrent=[ %.2f   %.2f   %.2f ]',Sources.PeakAmps)]);
fclose(fid(7));


fclose('all');
fprintf('Conversion Complete. Files saved to %s\n',savelocation)
toc