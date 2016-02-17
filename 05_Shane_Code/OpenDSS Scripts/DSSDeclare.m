%Algorithm for Dynamically Declaring Circuit in OpenDSS
clear
clc
close('all')

% Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;

[NODE,SECTION,LOAD,DER,PARAM,DSS] = sxstRead;

% Clear DSS
DSSText.command = 'Clear';

% Define Circuit
DSSText.command = DER.DSSCircuit;

% Library Data
fields = fieldnames(DSS);
for i = 1:length(fields)
    for j = 1:length(DSS.(fields{i}))
        DSSText.command = DSS.(fields{i}){j};
    end
end

% Circuit Element Data
% Lines
for i = 1:length(SECTION)
    DSSText.command = SECTION(i).DSS;
end

% Loads
for i = 1:length(LOAD)
    DSSText.command = LOAD(i).DSS;
end

% Capacitors and CapControls
Capacitors = {};
if isfield(NODE,'Capacitors')
    Capacitors = {NODE(~cellfun(@isempty,{NODE.Capacitors})).Capacitors};
end
if isfield(NODE,'CapCtrl')
    Capacitors = [Capacitors,{NODE(~cellfun(@isempty,{NODE.CapCtrl})).CapCtrl}];
end
for i = 1:length(Capacitors)
    DSSText.command = Capacitors{i};
end

%!Redirect Elements\Regulators.dss

%! Circuit Control Settings
%!Redirect Controls\FuseContrl.dss
%!Redirect Controls\SwitContrl.dss
%!Redirect Controls\ReclContrl.dss

% Set Voltage Bases
DSSText.command = DER.DSSVoltbase;

% Define an energy meter
DSSText.command = DER.EnergyMeter;


% Configure Simulation
DSSText.command = 'Set Mode=Snapshot';
%DSSText.command = 'Set Mode=FaultStudy';
DSSCircuit.Solution.Solve

% Define the bus coordinates
%DSSText.command = ['BusCoords [ ',sprintf('%s\n',NODE.DSS),' ]'];
fid = fopen('BusCoords.dss','wt');
fprintf(fid,'%s\n',NODE.DSS);
fclose(fid);
for i = 1:length(NODE)
    DSSText.command = sprintf('BusCoords %s\\BusCoords.dss',cd);
end
delete(sprintf('%s\\BusCoords.dss',cd))

% Collect Data
Lines = getLineInfo(DSSCircObj);
Bus = getBusInfo(DSSCircObj);
Load = getLoadInfo(DSSCircObj);
figure; plotKWProfile(DSSCircObj);
figure; plotVoltageProfile(DSSCircObj);
figure; plotCircuitLines(DSSCircObj,'Coloring','voltage120')