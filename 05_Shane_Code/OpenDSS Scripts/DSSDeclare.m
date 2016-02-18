function [DSSCircuit, DSSCircObj, DSSText, gridpvPath] = DSSDeclare(NODE,SECTION,LOAD,Source,DSS)
%{
Algorithm for Dynamically Declaring Circuit in OpenDSS
--Source-- must contain only one source which has:
Source.DSSCircuit - Circuit Definition
Source.DSSVoltbase - Circuit Volage Bases
Source.EnergyMeter - Energy Meter Definition

--NODE--
Contains BusCoords & Capacitor Data

--SECTION--
Contains Line info

--LOAD--
Contains Load info

--DSS--
Contains Loadshape Objects and Library info
%}

% Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;

% Clear DSS
DSSText.command = 'Clear';

% Define Circuit
DSSText.command = Source.DSSCircuit;

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
DSSText.command = Source.DSSVoltbase;

% Define an energy meter
DSSText.command = Source.EnergyMeter;


% Configure Simulation
DSSText.command = 'Set Mode=Snapshot';
%DSSText.command = 'Set Mode=FaultStudy';
DSSCircuit.Solution.Solve

% Define the bus coordinates
%DSSText.command = ['BusCoords [ ',sprintf('%s\n',NODE.DSS),' ]'];
BusCoords = [tempname,'.dss'];
fid = fopen(BusCoords,'wt');
fprintf(fid,'%s\n',NODE.DSS);
fclose(fid);
for i = 1:length(NODE)
    DSSText.command = ['BusCoords ',BusCoords];
end
delete(BusCoords)

end