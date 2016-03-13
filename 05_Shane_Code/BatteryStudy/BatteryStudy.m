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

%% Load Historical Data
%{
toc
disp('Loading Historical Data...')
load('CMNWLTH.mat');

% Data Characteristics
start = '01/01/2014'; % Date at which data starts
res   = 60;           % [s] - Resolution of data
ndat  = 525600;       % Number of Data Points

% Find desired indicies
index = (step/res)*(0:nstp-1) + (86400/res)*(datenum(date)-datenum(start));

% Check for Errors
if mod(step,res)
    error('Desired Resolution must be an integer multiple of the Data resolution')
elseif max(index) > ndat
    error('Desired Data out of range')
end

% Parce out Data
for i=1:nstp
    DATA(i).Date = datestr(floor(index(i)*(res/86400)) + datenum(start));
    DATA(i).Time = [sprintf('%02d',mod(floor(index(i)*res/3600),24)),':',...
        sprintf('%02d',mod(floor(index(i)*res/60),60))];
    
    DATA(i).VoltagePhaseA = CMNWLTH.Voltage.A(index(i));
    DATA(i).VoltagePhaseB = CMNWLTH.Voltage.B(index(i));
    DATA(i).VoltagePhaseC = CMNWLTH.Voltage.C(index(i));
    
    DATA(i).CurrentPhaseA = CMNWLTH.Amp.A(index(i));
    DATA(i).CurrentPhaseB = CMNWLTH.Amp.B(index(i));
    DATA(i).CurrentPhaseC = CMNWLTH.Amp.C(index(i));
    
    DATA(i).RealPowerPhaseA = CMNWLTH.kW.A(index(i));
    DATA(i).RealPowerPhaseB = CMNWLTH.kW.B(index(i));
    DATA(i).RealPowerPhaseC = CMNWLTH.kW.C(index(i));
    
    DATA(i).ReactivePowerPhaseA = CMNWLTH.kVAR.A(index(i));
    DATA(i).ReactivePowerPhaseB = CMNWLTH.kVAR.B(index(i));
    DATA(i).ReactivePowerPhaseC = CMNWLTH.kVAR.C(index(i));
end
clear CMNWLTH

%% Generate Load Shapes

% Find Peak Demand by Phase for normalization
LoadTotals = LoadsByPhase(DSSCircObj);

% Define Load shapes ***Add 300kvar per phase for capacitors
DSSText.Command = sprintf(['Edit Loadshape.DailyA npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',[DATA.RealPowerPhaseA]/LoadTotals.kWA),') qmult=(',...
    sprintf('%f ',([DATA.ReactivePowerPhaseA]+300)/LoadTotals.kVARA),')'],nstp,step);
DSSText.Command = sprintf(['Edit Loadshape.DailyB npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',[DATA.RealPowerPhaseB]/LoadTotals.kWB),') qmult=(',...
    sprintf('%f ',([DATA.ReactivePowerPhaseB]+300)/LoadTotals.kVARB),')'],nstp,step);
DSSText.Command = sprintf(['Edit Loadshape.DailyC npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',[DATA.RealPowerPhaseC]/LoadTotals.kWC),') qmult=(',...
    sprintf('%f ',([DATA.ReactivePowerPhaseC]+300)/LoadTotals.kVARC),')'],nstp,step);
%}
%% Find BESS Locations
tic
disp('Finding BESS Locations...')

% Set DSS to Fault study mode for Data Collection

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
    [~,Path] = findpath(SubBus,EndBus{i},Buses,Lines);
    BESBus = unique([BESBus,Path]);
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
DSSText.Command = ['New StorageController.BESS1 element=Line.259363665 terminal=1 ',...
    'kWTarget=3400 TimeChargeTrigger=-1 eventlog=yes modedischarge=PeakShave enable=no'];

% Initialize Loop and Collect Data for BESS Locations
pcc = length(BESBus);
Results = struct('PCC',BESBus);
DSSText.Command = 'Set Mode=FaultStudy';
DSSCircuit.Solution.Solve;
for i = 1:pcc
    % Record Zsc
    DSSCircuit.SetActiveBus(Results(i).PCC);
    Results(i).Zsc1 = DSSCircuit.ActiveBus.Zsc1;
    Results(i).Zsc0 = DSSCircuit.ActiveBus.Zsc0;
    
    % Record distance to each PV
    %[Results(i).DistPV1,~] = findpath(Results(i).PCC, PVLOCATION1 ,Buses,Lines);
    %[Results(i).DistPV2,~] = findpath(Results(i).PCC, PVLOCATION2 ,Buses,Lines);
    
end

% Place Battery on Each Bus
for i = 1:pcc
    
    %Results(i)
    
    DSSText.Command = sprintf('Edit Storage.BESS1 Bus1=%s %%stored=60',Results(i).PCC);
    %Results(i)
    
    % Simulation 1: Static Power Flow at light loading and High PV
    %   Battery Control Algoritm : Voltage
    DSSText.Command = 'Set Mode=Snapshot';
    DSSCircuit.Solution.Solve
    
    % Collect Data
    DSSCircuit.SetActiveBus(SubBus);
    SubVmagAng = DSSCircuit.ActiveBus.VMagAngle;
    SubVmagAvg = mean(SubVmagAng([1,3,5]));
    Results(i).VoltageVar = mean(abs(SubVmagAvg-DSSCircuit.AllBusVmag));
    
    
    
    
    % Simulation 2: Timseries simulation on high variability day
    %   Battery Control Algoritm : Smoothing
    DSSText.Command = 'Set Mode=Daily';
    DSSCircuit.Solution.Number = 1;
    DSSCircuit.Solution.Stepsize = step;
    DSSCircuit.Solution.dblHour = 0.0;
    
    DSSText.Command = 'Edit StorageController.BESS1 enable=yes';
    
    
    
    
    DSSText.Command = 'Edit StorageController.BESS1 enable=no';
end

%% Plot Results
tic
disp('Plotting Results...')