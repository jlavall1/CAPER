% ECE 6180                      Project                     Shane Kimble
%{
I. Time-series Power Flow
    1. Compile the system and run a 24hour simulation
        i. Show Substation Real Power Consumption.
        ii. LTC P.U. Phase Voltage across substation windings,
        iii. LTC tap position vs. time. 
    2. Place V, I &P,Q monitors at three-phase nodes (monitor modes 0 & 1). 
       Re-run 24hour simulation and complete the following:
        i. Construct a post-analysis algorithm that will organize data into 
           structs by node distance from substation. 
        ii. Find point in time when voltage headroom halfway down the feeder 
           is minimum (or the closest to 1.04PU). Then plot the  Phase 
           Voltages in P.U. vs. distance away from substation.

II. Fault Analysis
    1. Initiate single snapshot faults SLG faults on highest loaded phase
    2. Three phase fault at the substation, then find the circuit breaker
       rating.
%}

clear
clc
%close('all')

% Desired Characteristics
%  For 1day at 1min resolution - nstp = 1440; step = 60;
date = '05/27/2014';
nstp = 1440; % Number of steps
step = 60;   % [s] - Resolution of step

fprintf('Simulation Starting %s - %d hrs at %d min resolution\n\n',...
    date,nstp*step/(60*60),step/60)

%% Initialize OpenDSS
tic
disp('Initializing OpenDSS...')

% Find CAPER directory
fid = fopen('pathdef.m','r');
rootlocation = textscan(fid,'%c')';
rootlocation = regexp(rootlocation{1}','C:[^.]*?CAPER\\','match','once');
fclose(fid);

% Read in filelocation
filelocation = rootlocation; filename = 0;
% ****To skip UIGETFILE uncomment desired filename****
% ******(Must be in rootlocation CAPER\07_CYME)*******
%filename = 'Flay 12-01 - 2-3-15 loads (original).sxst';
%filename = 'Commonwealth 12-05-  9-14 loads (original).sxst';
%filename = 'Kud1207 (original).sxst';
%filename = 'Bellhaven 12-04 - 8-14 loads.xst (original).sxst'
%filename = 'Commonwealth_ret_01311205.sxst';
%filename = 'Bellhaven_ret_01291204.sxst';
filename = '07_CYME\Mocksville_Main_2401.sxst_DSS\Master.dss';
% ******To skip UIGETFILE uncomment desired filename*******
% ***(Must be in rootlocation CAPER03_OpenDSS_Circuits\)***
%filename = 'Master.dss'; filelocation = [rootlocation,'07_CYME\Commonwealth_ret_01311205.sxst_DSS\'];
%filename = 'Master.dss'; filelocation = [rootlocation,\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\01_Shane\';
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
%{
% Read in DSS Load data for peak normalization
LoadNames = DSSCircuit.Loads.AllNames;
for i = 1:length(LoadNames)
    % Separate out ID from Phase Designation
    Loads(i).ID = LoadNames{i};
    Phase = regexp(LoadNames{i},'(?<=[_]).*?$','match');
    switch Phase{1}
        case '1'
            Loads(i).Phase = 'A';
        case '2'
            Loads(i).Phase = 'B';
        case '3'
            Loads(i).Phase = 'C';
    end
    DSSCircuit.SetActiveElement(['Load.',LoadNames{i}]);
    Powers = DSSCircuit.ActiveCktElement.Powers;
    Loads(i).kW = Powers(1);
    Loads(i).kVAR = Powers(2);
end

% Find per phase demand totals
kWtotA = sum([Loads(regexp([Loads.Phase],'A')).kW]);
kWtotB = sum([Loads(regexp([Loads.Phase],'B')).kW]);
kWtotC = sum([Loads(regexp([Loads.Phase],'C')).kW]);
kVARtotA = sum([Loads(regexp([Loads.Phase],'A')).kVAR]);
kVARtotB = sum([Loads(regexp([Loads.Phase],'B')).kVAR]);
kVARtotC = sum([Loads(regexp([Loads.Phase],'C')).kVAR]);

% Define Load shapes ***Add 300kvar per phase for capacitors
DSSText.Command = sprintf(['Edit Loadshape.DailyA npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',[DATA.RealPowerPhaseA]/kWtotA),') qmult=(',...
    sprintf('%f ',([DATA.ReactivePowerPhaseA]+300)/kVARtotA),')'],nstp,step);
DSSText.Command = sprintf(['Edit Loadshape.DailyB npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',[DATA.RealPowerPhaseB]/kWtotB),') qmult=(',...
    sprintf('%f ',([DATA.ReactivePowerPhaseB]+300)/kVARtotB),')'],nstp,step);
DSSText.Command = sprintf(['Edit Loadshape.DailyC npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',[DATA.RealPowerPhaseC]/kWtotC),') qmult=(',...
    sprintf('%f ',([DATA.ReactivePowerPhaseC]+300)/kVARtotC),')'],nstp,step);

%}

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






%% Generate Monitors
toc
disp('Defining Monitors...')

% Initialize Fault Study Mode To read Zsc
DSSText.Command = 'Solve Mode=FaultStudy';

% Organize Lines by distance and discard non-3ph and laterals
LineNames = DSSCircuit.Lines.AllNames;
% Remove these lines (3ph and 336AAC Laterals)
Remove = {'258896341' '258896356' '258896361' '455183899' '455183905' '258908179' ...
    '263534356' '263534361' '258896491' '275423519' '275423535' '258896496' ...
    '264379695' '264379700' '716733195' '716733190'};
for i = 1:length(Remove)
    LineNames = LineNames(~strcmp(Remove{i},LineNames));
end

% Read in Line Data from DSS
for i = 1:length(LineNames)
    Lines(i).ID = LineNames{i};
    DSSCircuit.SetActiveElement(['Line.',LineNames{i}]);
    Lines(i).Bus1 = regexp(DSSCircuit.ActiveCktElement.BusNames{1},'^.*?(?=[.])','match');
    Lines(i).Bus2 = regexp(DSSCircuit.ActiveCktElement.BusNames{2},'^.*?(?=[.])','match');
    Lines(i).Phase = DSSCircuit.ActiveCktElement.NumPhases;
    Lines(i).Amps = DSSCircuit.ActiveCktElement.NormalAmps;
    
    % Find Upstream Bus
    DSSCircuit.SetActiveBus(Lines(i).Bus1{1});
    Lines(i).Distance = DSSCircuit.ActiveBus.Distance;
    DSSCircuit.SetActiveBus(Lines(i).Bus2{1});
    [Lines(i).Distance,index] = min([DSSCircuit.ActiveBus.Distance,Lines(i).Distance]);
    if index == 2
        DSSCircuit.SetActiveBus(Lines(i).Bus1{1}); % Go back to origional Bus
    end
    
    % Record Zsc
    Zsc = DSSCircuit.ActiveBus.Zsc1;
    Lines(i).Rsc = Zsc(1);
    Lines(i).Xsc = Zsc(2);
end
% Remove Unwanted lines and sort
Lines = Lines([Lines.Phase] == 3); % Only 3 phase
Lines = Lines([Lines.Amps] > 480); % Only >480A Current Rating
[~,index] = sortrows([Lines.Distance].');
Lines = Lines(index);

% Place Monitors on all remaining Lines
for i = 1:length(Lines)
    DSSText.Command = sprintf('New Monitor.%s_Mon_VI element=Line.%s term=1 mode=32',...
            Lines(i).ID,Lines(i).ID);
    DSSText.Command = sprintf('New Monitor.%s_Mon_PQ element=Line.%s term=1 mode=1 PPolar=No',...
            Lines(i).ID,Lines(i).ID);
end

%% Run Timeseries and Record Results (Problem 1)
toc
disp('Running Time-series Simulation...')

% Configure Simulation
DSSText.command = 'set mode = daily';
DSSCircuit.Solution.Number = 1;
DSSCircuit.Solution.Stepsize = step;
DSSCircuit.Solution.dblHour = 0.0;

% Initialize movie
figure
ax = gca;
ax.NextPlot = 'replaceChildren';
F(nstp) = struct('cdata',[],'colormap',[]);

for t = 1:nstp
    % Solve at current time step
    DSSCircuit.Solution.Solve
    
    plotVoltageProfile(DSSCircObj);
    ylim([116 124])
    ax = gcf;
    F(t) = getframe(ax);
    close all
    
    % Read Data from OpenDSS
    RESULTS(t).Date = DATA(t).Date;
    RESULTS(t).Time = DATA(t).Time;
    
    % Generate sdate
    RESULTS(t).sDate = datenum([RESULTS(t).Date,' ',RESULTS(t).Time,':00']);
    
    DSSCircuit.SetActiveElement('Line.259355408');
    Power   = DSSCircuit.ActiveCktElement.Powers;
    Voltage = DSSCircuit.ActiveCktElement.VoltagesMagAng;
    
    RESULTS(t).SubRealPowerPhaseA = Power(1);
    RESULTS(t).SubRealPowerPhaseB = Power(3);
    RESULTS(t).SubRealPowerPhaseC = Power(5);
    
    RESULTS(t).SubReactivePowerPhaseA = Power(2);
    RESULTS(t).SubReactivePowerPhaseB = Power(4);
    RESULTS(t).SubReactivePowerPhaseC = Power(6);
    
    RESULTS(t).SubVoltageMagPhaseA = Voltage(1);
    RESULTS(t).SubVoltageAngPhaseA = Voltage(2);
    RESULTS(t).SubVoltageMagPhaseB = Voltage(3);
    RESULTS(t).SubVoltageAngPhaseB = Voltage(4);
    RESULTS(t).SubVoltageMagPhaseC = Voltage(5);
    RESULTS(t).SubVoltageAngPhaseC = Voltage(6);
    
    RESULTS(t).SubLTCTapPosition = DSSCircuit.Transformers.Tap;
end

%% Collect Monitor Data and Perform Analysis (Problem 2)
toc
disp('Collecting Monitor Data...')
% Find Line that is at halfway point on Feeder
[~,index] = min(abs([Lines.Distance] - max([Lines.Distance])/2));

% Find the time at which the voltage is closest to 1.03PU
DSSText.command = ['Export Mon ',Lines(index).ID,'_mon_vi'];
MonitorFilename = DSSText.Result;
RawMonitorData  = importdata(MonitorFilename);
delete(MonitorFilename);

[~,index] = min(abs(reshape(RawMonitorData.data(:,3:5),[],1)/7200 - 1.025));
[r,~] = size(RawMonitorData.data);
index = mod(index-1,r)+1;
time = RESULTS(index).sDate;

% Record Voltages fort this time
for i = 1:length(Lines)
    DSSText.command = ['Export Mon ',Lines(i).ID,'_mon_vi'];
    MonitorFilename = DSSText.Result;
    RawMonitorData  = importdata(MonitorFilename);
    delete(MonitorFilename);
    
    Lines(i).VoltageMagPhaseA = RawMonitorData.data(index,3);
    Lines(i).VoltageMagPhaseB = RawMonitorData.data(index,4);
    Lines(i).VoltageMagPhaseC = RawMonitorData.data(index,5);
end

%% Conduct Fault Analysis (Problem 3)
toc
disp('Conducting Fault Analysis...')

% Configure Simulation
DSSText.command = 'Set Mode=Snapshot';
DSSCircuit.Solution.Solve

% Begin Fault Study
DSSText.Command = 'New Fault.F1 enabled=no';

% Record Short Circuit Impedance and organize by Rsc
for i = 1:length(Lines)
    % Fault Phase p on Bus1 of Line i
    DSSText.Command = 'Solve Mode=Snapshot';
    DSSText.Command = sprintf('Edit Fault.F1 Bus1=%s.%d enabled=yes',Lines(i).Bus1{1},2);
    DSSText.Command = 'Solve Mode=dynamic number=1';
    
    DSSCircuit.SetActiveElement('Fault.F1');
    Lines(i).IscB = DSSCircuit.ActiveCktElement.CurrentsMagAng(1);
    DSSText.Command = 'Edit Fault.F1 enabled=no';
end

% 3 Phase Fault at Substaion
DSSText.Command = 'Solve Mode=Snapshot';
DSSText.Command = 'Edit Fault.F1 Bus1=commonwealth_ret_01311205.1.2.3 Phase=3 enabled=yes';
DSSText.Command = 'Solve Mode=dynamic number=1';

% Analysis
DSSCircuit.SetActiveElement('Fault.F1');
Current = DSSCircuit.ActiveElement.CurrentsMagAng([1 3 5]);
fprintf('\nSubstation 3 Phase to Ground Fault Currents:\nPhaseA: %.0f A\t\tPhaseB: %.0f A\t\tPhaseC: %.0f A\n',...
    Current);
k = 1.6;
MVAsc = sqrt(3)*k*sum(Current)/1000;
fprintf('Short Circuit Breaker MVA(k=%.1f): %.0f MVA\nReccommended Breaker Size: %.0f MVA\n\n',...
    k,MVAsc,25*ceil(MVAsc/25));

%% Generate Plots
toc
disp('Generating Plots...')

% Formatting
X = [min([RESULTS.sDate]),max([RESULTS.sDate])];
if nstp*step > (2*24*60*60) % Simulation greater than 2 days
    format = 'mmm dd';
else
    format = 'HH';
end

% Problem 1 Plots
figure;
subplot(2,2,1)
plot([RESULTS.sDate],[RESULTS.SubRealPowerPhaseA],'-k',...
    [RESULTS.sDate],[RESULTS.SubRealPowerPhaseB],'-r',...
    [RESULTS.sDate],[RESULTS.SubRealPowerPhaseC],'-b',...
    [RESULTS.sDate],[DATA.RealPowerPhaseA],'--k',...
    [RESULTS.sDate],[DATA.RealPowerPhaseB],'--r',...
    [RESULTS.sDate],[DATA.RealPowerPhaseC],'--b')
grid on;
datetick('x',format)
xlim(X)
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Time [hr]','FontSize',12,'FontWeight','bold')
ylabel(gca,'Real Power [kW]','FontSize',12,'FontWeight','bold')
title('Problem 1: Substation Real Power','FontWeight','bold','FontSize',12);
legend('Phase A OpenDSS','Phase B OpenDSS','Phase C OpenDSS',...
    'Phase A Actual','Phase B Actual','Phase C Actual')

subplot(2,2,2)
plot([RESULTS.sDate],[RESULTS.SubReactivePowerPhaseA],'-k',...
    [RESULTS.sDate],[RESULTS.SubReactivePowerPhaseB],'-r',...
    [RESULTS.sDate],[RESULTS.SubReactivePowerPhaseC],'-b',...
    [RESULTS.sDate],[DATA.ReactivePowerPhaseA],'--k',...
    [RESULTS.sDate],[DATA.ReactivePowerPhaseB],'--r',...
    [RESULTS.sDate],[DATA.ReactivePowerPhaseC],'--b')
grid on;
datetick('x',format)
xlim(X)
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Time [hr]','FontSize',12,'FontWeight','bold')
ylabel(gca,'Reactive Power [kVAR]','FontSize',12,'FontWeight','bold')
title('Problem 1: Substation Reactive Power','FontWeight','bold','FontSize',12);
legend('Phase A OpenDSS','Phase B OpenDSS','Phase C OpenDSS',...
    'Phase A Actual','Phase B Actual','Phase C Actual')

subplot(2,2,3)
plot([RESULTS.sDate],100*abs([RESULTS.SubRealPowerPhaseA]-[DATA.RealPowerPhaseA])./[DATA.RealPowerPhaseA],'-k',...
    [RESULTS.sDate],100*abs([RESULTS.SubRealPowerPhaseB]-[DATA.RealPowerPhaseB])./[DATA.RealPowerPhaseB],'-r',...
    [RESULTS.sDate],100*abs([RESULTS.SubRealPowerPhaseC]-[DATA.RealPowerPhaseC])./[DATA.RealPowerPhaseC],'-b')
grid on;
datetick('x',format)
%axis([X(1) X(2) 0 5])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Time [hr]','FontSize',12,'FontWeight','bold')
ylabel(gca,'Error [%]','FontSize',12,'FontWeight','bold')
title('Problem 1: Real Power Error','FontWeight','bold','FontSize',12);
legend('Phase A','Phase B','Phase C')

subplot(2,2,4)
plot([RESULTS.sDate],abs([RESULTS.SubReactivePowerPhaseA]-[DATA.ReactivePowerPhaseA])/std([DATA.ReactivePowerPhaseA]),'-k',...
    [RESULTS.sDate],abs([RESULTS.SubReactivePowerPhaseB]-[DATA.ReactivePowerPhaseB])/std([DATA.ReactivePowerPhaseB]),'-r',...
    [RESULTS.sDate],abs([RESULTS.SubReactivePowerPhaseC]-[DATA.ReactivePowerPhaseC])/std([DATA.ReactivePowerPhaseC]),'-b')
grid on;
datetick('x','HH')
%axis([X(1) X(2) 0 2])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Time [hr]','FontSize',12,'FontWeight','bold')
ylabel(gca,'Error [\sigma_{actual}]','FontSize',12,'FontWeight','bold')
title('Problem 1: Reactive Power Error','FontWeight','bold','FontSize',12);
legend('Phase A','Phase B','Phase C')

figure;
subplot(1,2,2)
plot([RESULTS.sDate],[RESULTS.SubVoltageMagPhaseA]/60,'-k',...
    [RESULTS.sDate],[RESULTS.SubVoltageMagPhaseB]/60,'-r',...
    [RESULTS.sDate],[RESULTS.SubVoltageMagPhaseC]/60,'-b',...
    X,[122.5 122.5],'--r',X,[123.5 123.5],'--r')
grid on;
%axis([X(1) X(2) 122 124])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Time [hr]','FontSize',12,'FontWeight','bold')
datetick('x','HH')
ylabel(gca,'Voltage','FontSize',12,'FontWeight','bold')
title('Problem 1: Substation Transformer Voltage','FontWeight','bold','FontSize',12);
legend('Phase A','Phase B','Phase C') %,'Location','northwest')

subplot(1,2,1)
plot([RESULTS.sDate],[RESULTS.SubLTCTapPosition],'-k')
grid on;
%axis([X(1) X(2) .995 1.01])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Time [hr]','FontSize',12,'FontWeight','bold')
datetick('x','HH')
ylabel(gca,'Substation LTC Position [pu]','FontSize',12,'FontWeight','bold')
title('Problem 1: Substation LTC Position','FontWeight','bold','FontSize',12);

% Problem 2 Plots
figure;
plot([Lines.Distance],[Lines.VoltageMagPhaseA]/7200,'-k','LineWidth',2)
hold on
plot([Lines.Distance],[Lines.VoltageMagPhaseB]/7200,'-r','LineWidth',2)
plot([Lines.Distance],[Lines.VoltageMagPhaseC]/7200,'-b','LineWidth',2)
hold off
grid on;
%axis([0 4.5 .98 1.04])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Sub [km]','FontSize',12,'FontWeight','bold')
ylabel(gca,'Voltage [pu]','FontSize',12,'FontWeight','bold')
title(sprintf('Problem 2: Voltage Profile on %s',datestr(time)),'FontWeight','bold','FontSize',12);
legend('Phase A','Phase B','Phase C')

% Problem 3 Plots
figure;
subplot(1,2,1)
plot([Lines.Distance],[Lines.Rsc],'-k','LineWidth',2)
grid on;
xlim([0,5])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance From Substation [km]','FontSize',12,'FontWeight','bold')
ylabel(gca,'Short Circuit Resistance [\Omega]','FontSize',12,'FontWeight','bold')
title('Problem 3: SLG Fault Study on Phase B','FontWeight','bold','FontSize',12);

subplot(1,2,2)
plot([Lines.Rsc],[Lines.IscB],'-k','LineWidth',2)
grid on;
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Short Circuit Resistance [\Omega]','FontSize',12,'FontWeight','bold')
ylabel(gca,'Short Circuit Current [A]','FontSize',12,'FontWeight','bold')
title('Problem 3: SLG Fault Study on Phase B','FontWeight','bold','FontSize',12);

toc