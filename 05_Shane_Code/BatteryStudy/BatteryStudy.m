% BatteryStudy.m
%   This function will place a battery at every bus on the Backbone of the
%   feeder 

clear
clc
close('all')

%% Initialize OpenDSS
tic
disp('Initializing OpenDSS...')

% Find CAPER directory
fid = fopen('pathdef.m','r');
rootlocation = textscan(fid,'%c')';
rootlocation = regexp(rootlocation{1}','C:[^.]*?CAPER\\','match','once');
fclose(fid);
rootlocation = [rootlocation,'07_CYME\'];
% Read in filelocation
filelocation = rootlocation; filename = 0;
% ****To skip UIGETFILE uncomment desired filename****
% ******(Must be in rootlocation CAPER\07_CYME)*******
filename = 'Flay_ret_16271201.sxst_DSS\Master.dss';
%filename = 'Commonwealth 12-05-  9-14 loads (original).sxst_DSS\Master.dss';
%filename = 'Kud1207 (original).sxst_DSS\Master.dss';
%filename = 'Bellhaven 12-04 - 8-14 loads.xst (original).sxst_DSS\Master.dss'
%filename = 'Bellhaven_ret_01291204.sxst_DSS\Master.dss';
%filename = 'Mocksville_Main_2401.sxst_DSS\Master.dss';
%filename = 'Commonwealth_ret_01311205.sxst_DSS\Master.dss';
while ~filename
    [filename,filelocation] = uigetfile({'*.*','All Files'},'Select DSS Master File',...
        rootlocation);
end

% Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;

% Compile Circuit
DSSText.command = ['Compile ',[filelocation,filename]];
DSSCircuit.Solution.Solve

%% Find BESS Locations
tic
disp('Finding BESS Locations...')

Buses = struct('ID',DSSCircuit.AllBusNames);
Lines = struct('ID',DSSCircuit.Lines.AllNames);
for i = 1:length(Lines)
    DSSCircuit.Lines.name = Lines(i).ID;
    Lines(i).Bus1   = get(DSSCircuit.Lines,'Bus1');
    Lines(i).Bus2   = get(DSSCircuit.Lines,'Bus2');
    Lines(i).Length = get(DSSCircuit.Lines,'Length');
end

SubBus = 'flay_ret_16271201';
EndBus = {'259596204' '258126280' '255192292'};
BESBus = {};
for i = 1:length(EndBus)
    BESBus = unique([BESBus,findpath(SubBus,EndBus{i},Buses,Lines)]);
end


%% Run Simulation and Collect Data at all BESS Locations
tic
disp('Running BESS Simulations...')

% Create Battery
VoltageBases = DSSCircuit.Settings.VoltageBases;
Battery.kV = VoltageBases(1);
Battery.kWRated = 1000;
Battery.kWhRated = 10000;
Battery.PctReserve = 20;
Battery.PctEffCharge = 93;
Battery.PctEffDisChrg = 96.7;

DSSText.Command = [sprintf('New Storage.BESS1 Bus1=%s Phases=3 kv=%.2f ',SubBus,Battery.kV),...
    sprintf('kWRated=%d kWhRated=%d ',Battery.kWRated,Battery.kWhRated),...
    sprintf('%%reserve=%d %%EffCharge=%.1f ',Battery.PctReserve,Battery.PctEffCharge),...
    sprintf('%%EffDischarge=%.1f',Battery.PctEffDisChrg)];
DSSText.Command = ['New StorageController.BESS1 element=Line.259363665 terminal=1',...
    'kWTarget=3400 TimeChargeTrigger=-1 eventlog=yes modedischarge=PeakShave'];

% Place Battery on Each Bus
for i = 1:length(BESBus)
    DSSText.Command = sprintf('Edit Storage.BESS1 Bus1=%s %%stored=60',BESBus{i});
    
    % Simulation 1: Static Power Flow at light loading and High PV
    %   Battery Control Algoritm : Voltage
    
    
    
    
    % Simulation 2: Timseries simulation on high variability day
    %   Battery Control Algoritm : Smoothing
    DSSText.Command = 'Edit StorageController.BESS1 enable=yes';
    
    
    
    
    DSSText.Command = 'Edit StorageController.BESS1 enable=no';
end

%% Plot Results
tic
disp('Plotting Results...')