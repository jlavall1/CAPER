% BatteryStudy.m
%   BatteryStudy.m will run 3 different simulations with a battery placed 
%    at every bus on the Backbone of the chosen feeder and  and collect
%    data. The goal of this study is to find a relationship between the
%    effectiveness of a battery to mitigate PV impact and it's location on
%    the feeder.

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

kVBase = DSSCircuit.Settings.VoltageBases;

% Get Line info
Buses = struct('ID',DSSCircuit.AllBusNames);
Lines = struct('ID',DSSCircuit.Lines.AllNames);
for i = 1:length(Lines)
    DSSCircuit.Lines.name = Lines(i).ID;
    Lines(i).Bus1   = get(DSSCircuit.Lines,'Bus1');
    Lines(i).Bus2   = get(DSSCircuit.Lines,'Bus2');
    Lines(i).Length = get(DSSCircuit.Lines,'Length');
    Lines(i).Z1     = get(DSSCircuit.Lines,'R1')+1i*get(DSSCircuit.Lines,'X1');
end

%% Load Historical Data and Generate Load Shapes
toc
disp('Loading Historical Data...')

load('FlayLoad.mat');
% Data Characteristics
start = DATA(1).Date; % Date at which data starts
[nstp,~] = size(DATA(1).kW); % Number of Data points per row in struct
step = 24*60*60*(datenum(DATA(2).Date)-datenum(start))/nstp; % [s] - Resolution of data

% Find Peak Demand by Phase for normalization
LoadTotals = LoadsByPhase(DSSCircObj);

% Simulation 2 - High Variability Day (VI)
% [~,ind] = max([M_MOCKS_INFO.VI]+[M_SHELBY_INFO.VI])
%  DOY - 121 (5/1/2014)
date2 = '05/1/2014';
DATA2 = DATA(datenum(date2)-datenum(start)+1);

% Simulation 3 - High Penetration Day (CI)
% [~,ind] = max([M_MOCKS_INFO.CI]+[M_SHELBY_INFO.CI])
% DOY - 106 (4/16/2014)
date3 = '04/16/2014';
DATA3 = DATA(datenum(date3)-datenum(start)+1);

% Define Load shapes
DSSText.Command = sprintf(['New Loadshape.LSSim2A npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',DATA2.kW(:,1)/LoadTotals.kWA),') qmult=(',...
    sprintf('%f ',DATA2.kVAR(:,1)/LoadTotals.kVARA),')'],nstp,step);
DSSText.Command = sprintf(['New Loadshape.LSSim2B npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',DATA2.kW(:,2)/LoadTotals.kWB),') qmult=(',...
    sprintf('%f ',DATA2.kVAR(:,2)/LoadTotals.kVARB),')'],nstp,step);
DSSText.Command = sprintf(['New Loadshape.LSSim2C npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',DATA2.kW(:,3)/LoadTotals.kWC),') qmult=(',...
    sprintf('%f ',DATA2.kVAR(:,3)/LoadTotals.kVARC),')'],nstp,step);

% Define Load shapes
DSSText.Command = sprintf(['New Loadshape.LSSim3A npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',DATA3.kW(:,1)/LoadTotals.kWA),') qmult=(',...
    sprintf('%f ',DATA3.kVAR(:,1)/LoadTotals.kVARA),')'],nstp,step);
DSSText.Command = sprintf(['New Loadshape.LSSim3B npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',DATA3.kW(:,2)/LoadTotals.kWB),') qmult=(',...
    sprintf('%f ',DATA3.kVAR(:,2)/LoadTotals.kVARB),')'],nstp,step);
DSSText.Command = sprintf(['New Loadshape.LSSim3C npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',DATA3.kW(:,3)/LoadTotals.kWC),') qmult=(',...
    sprintf('%f ',DATA3.kVAR(:,3)/LoadTotals.kVARC),')'],nstp,step);

clear DATA DATA2 DATA3
%% Add PV to System and Generate Generator Shapes
toc
disp('Adding PV to System...')

% PV Specifications
PV(1).Bus1 = '260007367';
PV(1).kW = 4000;
PV(1).pf = 1;

PV(2).Bus1 = '258406388';
PV(2).kW = 500;
PV(2).pf = 1;

% Load PV Data
load('FlayPV.mat')

DATA2 = DATA(datenum(date2)-datenum(start)+1);
DATA3 = DATA(datenum(date3)-datenum(start)+1);

% Create Generator Shapes
DSSText.Command = sprintf(['New Loadshape.GSPV1Sim2 npts=%d sinterval=%d mult=(',...
    sprintf('%f ',DATA2.PV1),')'],nstp,step);
DSSText.Command = sprintf(['New Loadshape.GSPV2Sim2 npts=%d sinterval=%d mult=(',...
    sprintf('%f ',DATA2.PV2),')'],nstp,step);

DSSText.Command = sprintf(['New Loadshape.GSPV1Sim3 npts=%d sinterval=%d mult=(',...
    sprintf('%f ',DATA3.PV1),')'],nstp,step);
DSSText.Command = sprintf(['New Loadshape.GSPV2Sim3 npts=%d sinterval=%d mult=(',...
    sprintf('%f ',DATA3.PV2),')'],nstp,step);

% Create PV Generator Elements
for i = 1:2
    DSSText.Command = sprintf(['New Generator.PV%d Bus1=%s Phases=3 kV=%.2f ',...
        'kW=%d pf=%.3f'],i,PV(i).Bus1,kVBase(1),PV(i).kW,PV(i).pf);
end
        
clear DATA DATA2 DATA3
%% Find BESS Locations
toc
disp('Finding BESS Locations...')

SubBus = 'flay_ret_16271201';
EndBus = {'259596204' '258126280' '255192292'};
PCC = {};
for i = 1:length(EndBus)
    [~,Path] = findpath(SubBus,EndBus{i},Buses,Lines);
    PCC = unique([PCC,Path]);
end
clear Path


%% Run Simulation and Collect Data at all BESS Locations
toc
disp('Running BESS Simulations...')

% Battery Specs
VoltageBases = DSSCircuit.Settings.VoltageBases;
Battery.kV = VoltageBases(1);
Battery.kWRated = 1000;
Battery.kWhRated = 10000;
Battery.PctReserve = 20;
Battery.PctEffCharge = 93;
Battery.PctEffDisChrg = 96.7;

% Create Battery Storage Element
DSSText.Command = sprintf(['New Storage.BESS1 Bus1=%s Phases=3 kv=%.2f ',...
    'kWRated=%d kWhRated=%d %%reserve=%d %%EffCharge=%.1f %%EffDischarge=%.1f'],...
    SubBus,Battery.kV,Battery.kWRated,Battery.kWhRated,Battery.PctReserve,...
    Battery.PctEffCharge,Battery.PctEffDisChrg);
DSSText.Command = ['New StorageController.BESS1 element=Line.259363665 terminal=1 ',...
    'kWTarget=3400 TimeChargeTrigger=-1 eventlog=yes modedischarge=PeakShave'];

% Initialize Loop and Collect Data for BESS Locations
pcc = length(PCC);
Results = struct('PCC',PCC);

% Collect Data for Study at each PCC
for i = 1:pcc
    % Record Positiv Seq Resistance to each source
    [Results(i).Data.Z1Sub,~] = findpath(Results(i).PCC,SubBus,Buses,Lines,[Lines.Z1]);
    [Results(i).Data.Z1PV1,~] = findpath(Results(i).PCC,PV(1).Bus1,Buses,Lines,[Lines.Z1]);
    [Results(i).Data.Z1PV2,~] = findpath(Results(i).PCC,PV(2).Bus1,Buses,Lines,[Lines.Z1]);
end

% % Set DSS to Fault study mode for Data Collection
% DSSText.Command = 'Set Mode=FaultStudy';
% DSSCircuit.Solution.Solve;
% for i = 1:pcc
%     % Record Zsc
%     DSSCircuit.SetActiveBus(Results(i).PCC);
%     Results(i).Zsc1 = DSSCircuit.ActiveBus.Zsc1;
%     Results(i).Zsc0 = DSSCircuit.ActiveBus.Zsc0;
%     
%     % Record distance to each PV
%     %[Results(i).DistPV1,~] = findpath(Results(i).PCC, PVLOCATION1 ,Buses,Lines);
%     %[Results(i).DistPV2,~] = findpath(Results(i).PCC, PVLOCATION2 ,Buses,Lines);
%     
% end

% Place Battery on Each Bus
for i = 1:pcc
    DSSText.Command = sprintf('Edit Storage.BESS1 Bus1=%s %%stored=60',Results(i).PCC);
    
    % Simulation 1: Static Power Flow at 4 different load levels
    %  Load Levels - [ SU_min  WN_min  SU_avg  WN_avg ]
    LoadMult = [0.3 0.25 0.5 0.4];
    fields = {'SU_min' 'WM_min' 'SU_avg' 'WN_avg'};
    %  PV - Set all PV to max rated output
    DSSText.Command = 'BatchEdit Generator..* Status=Fixed';
    %  Battery Control - Find operating point that minimizes
    %   Voltage Variation
    DSSText.Command = 'Edit StorageController.BESS1 enable=no';
    
    DSSText.Command = 'Set Mode=Snapshot';
    for j = 1:4
        DSSCircuit.Solution.LoadMult = LoadMult(j);
        DSSCircuit.Solution.Solve
        
        % Collect Data
        DSSCircuit.SetActiveBus(SubBus);
        SubVmagAng = DSSCircuit.ActiveBus.VMagAngle;
        SubVmagAvg = mean(SubVmagAng([1,3,5]));
        Results(i).(fields{j}) =...
            mean(abs(SubVmagAvg-DSSCircuit.AllBusVmag));
    end
    
    
    
    
    % Simulation 2: Timseries simulation on high variability day
    %  Loadshapes - 
    %    Load - LSSim2(A,B,&C)
    %    PV1 - GSPV1Sim2
    %    PV2 - GSPV2Sim2
    DSSText.Command = 'BatchEdit Generator..* Status=Variable';
    DSSText.Command = 'Edit Loadshape.DailyA like=LSSim2A';
    DSSText.Command = 'Edit Loadshape.DailyB like=LSSim2B';
    DSSText.Command = 'Edit Loadshape.DailyC like=LSSim2C';
    DSSText.Command = 'Edit Generator.PV1 Daily=GSPV1Sim2';
    DSSText.Command = 'Edit Generator.PV2 Daily=GSPV2Sim2';
    
    %   Battery Control Algoritm : Smoothing
    DSSText.Command = 'Edit StorageController.BESS1 enable=yes';
    
    % Initialize Simualtion
    DSSText.Command = 'Set Mode=Daily';
    DSSCircuit.Solution.Number = 1;
    DSSCircuit.Solution.Stepsize = step;
    DSSCircuit.Solution.dblHour = 0.0;
    
    % Begin Timeseries
    for t = 1:nstp
        DSSCircuit.Solution.Solve
    end
    
    
    
    
    
    
    
    
    % Simulation 3: Timseries simulation on high penetration day
    %  Loadshapes - 
    %    Load - LSSim3(A,B,&C)
    %    PV1 - GSPV1Sim3
    %    PV2 - GSPV1Sim3
    DSSText.Command = 'Edit Loadshape.DailyA like=LSSim3A';
    DSSText.Command = 'Edit Loadshape.DailyB like=LSSim3B';
    DSSText.Command = 'Edit Loadshape.DailyC like=LSSim3C';
    DSSText.Command = 'Edit Generator.PV1 Daily=GSPV1Sim3';
    DSSText.Command = 'Edit Generator.PV2 Daily=GSPV2Sim3';
    
    % Initialize Simualtion
    DSSText.Command = 'Set Mode=Daily';
    DSSCircuit.Solution.Number = 1;
    DSSCircuit.Solution.Stepsize = step;
    DSSCircuit.Solution.dblHour = 0.0;
    
    % Begin Timeseries
    for t = 1:nstp
        DSSCircuit.Solution.Solve
    end
    
    % Print progress to Command Window
    toc
    fprintf('Completed PCC %d/%d\n',i,pcc)
end

%% Plot Results
tic
disp('Plotting Results...')