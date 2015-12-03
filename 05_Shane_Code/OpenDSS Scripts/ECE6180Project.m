% ECE 6180                      Project                     Shane Kimble

clear
clc
close('all')

% Desired Characteristics
%  For 1day at 1min resolution - nstp = 1440; step = 60;
date = '05/27/2014';
nstp = 1440; % Number of steps
step = 60;   % [s] - Resolution of step

fprintf('Simulation Starting %s - %d hrs at %d min resolution\n\n',date,nstp*step/(60*60),step/60)

%% Load Historical Data
tic
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
    DATA(i).Time = [sprintf('%02d',mod(floor(index(i)*res/3600),24)),':',sprintf('%02d',mod(floor(index(i)*res/60),60))];
    
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

% Load DSS file location
load('COMMONWEALTH_Location.mat');

% Generate Load Shape
fileID = fopen([filelocation,'Loadshape.dss'],'wt');
fprintf(fileID,['New loadshape.LS_PhaseA npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',[DATA.RealPowerPhaseA]),') qmult=(',...
    sprintf('%f ',[DATA.ReactivePowerPhaseA]+300),')\n\n'],nstp,step);
fprintf(fileID,['New loadshape.LS_PhaseB npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',[DATA.RealPowerPhaseB]),') qmult=(',...
    sprintf('%f ',[DATA.ReactivePowerPhaseB]+300),')\n\n'],nstp,step);
fprintf(fileID,['New loadshape.LS_PhaseC npts=%d sinterval=%d pmult=(',...
    sprintf('%f ',[DATA.RealPowerPhaseC]),') qmult=(',...
    sprintf('%f ',[DATA.ReactivePowerPhaseC]+300),')\n\n'],nstp,step);
fclose(fileID);

%% Initialize OpenDSS
toc
disp('Initializing OpenDSS...')

% Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;

% Compile Circuit
DSSText.command = ['Compile ',[filelocation,filename]];

% Configure Simulation
DSSText.command = 'set mode = daily';
DSSCircuit.Solution.Number = 1;
DSSCircuit.Solution.Stepsize = step;
DSSCircuit.Solution.dblHour = 0.0;

%% Record Timeseries Results from Historical Loadshape (Problem 1)
toc
disp('Running Time-series Simulation...')

for t = 1:nstp
    % Solve at current time step
    DSSCircuit.Solution.Solve
    
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
% Organize Lines by distance and discard non-3ph
LineNames = DSSCircuit.Lines.AllNames;
for i = 1:length(LineNames)
    Lines(i).ID = LineNames{i};
    DSSCircuit.SetActiveElement(['Line.',LineNames{i}]);
    Lines(i).Bus1 = regexp(DSSCircuit.ActiveCktElement.BusNames{1},'^.*?(?=[.])','match');
    Lines(i).Bus2 = regexp(DSSCircuit.ActiveCktElement.BusNames{2},'^.*?(?=[.])','match');
    Lines(i).Phase = DSSCircuit.ActiveCktElement.NumPhases;
    Lines(i).Amps = DSSCircuit.ActiveCktElement.NormalAmps;
    
    DSSCircuit.SetActiveBus(Lines(i).Bus1{1});
    Lines(i).Distance = DSSCircuit.ActiveBus.Distance;
end
Lines = Lines([Lines.Phase] == 3); % Only 3 phase
Lines = Lines([Lines.Amps] > 480); % Only >480A Current Rating
[~,index] = sortrows([Lines.Distance].');
Lines = Lines(index);

% Find Line that is at halfway point on Feeder
[~,index] = min(abs([Lines.Distance] - max([Lines.Distance])/2));

% Find the time at which the voltage is closest to 1.03PU
DSSText.command = ['Export Mon ',Lines(index).ID,'_mon_vi'];
MonitorFilename = DSSText.Result;
RawMonitorData  = importdata(MonitorFilename);
delete(MonitorFilename);

[~,index] = min(abs(reshape(RawMonitorData.data(:,3:5),[],1)/7200 - 1.03));
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

% Initialize Fault Study Mode
DSSText.command = 'Set Mode=FaultStudy';
DSSCircuit.Solution.Solve

%Lines_sc=getLineInfo(DSSCircObj);

DSSText.Command = 'New Fault.F1';

% Record Short Circuit Impedance and organize by Rsc
for i = 1:length(Lines)
    %DSSCircuit.SetActiveElement(['Line.',LineNames{i}])
        
    DSSCircuit.SetActiveBus(Lines(i).Bus1{1});
    Zsc = DSSCircuit.ActiveBus.Zsc1;
    Lines(i).Rsc = Zsc(1);
    Lines(i).Xsc = Zsc(2);
    
    % Fault Line
    DSSText.Command = sprintf('Edit Fault.F1 Bus1=%s.2',Lines(i).Bus1{1});
    DSSCircuit.Solution.Solve
    
    DSSCircuit.SetActiveElement('Line.259355408');
    Lines(i).Isc = DSSCircuit.ActiveCktElement.CurrentsMagAng(3); 
end

%Lines=getLineInfo(DSSCircObj);
%Now you find test locations





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
axis([X(1) X(2) 0 5])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Time [hr]','FontSize',12,'FontWeight','bold')
ylabel(gca,'Error [%]','FontSize',12,'FontWeight','bold')
title('Problem 1: Real Power Error','FontWeight','bold','FontSize',12);
legend('Phase A','Phase B','Phase C')

subplot(2,2,4)
plot([RESULTS.sDate],abs([RESULTS.SubRealPowerPhaseA]-[DATA.RealPowerPhaseA])/std([DATA.RealPowerPhaseA]),'-k',...
    [RESULTS.sDate],abs([RESULTS.SubRealPowerPhaseB]-[DATA.RealPowerPhaseB])/std([DATA.RealPowerPhaseB]),'-r',...
    [RESULTS.sDate],abs([RESULTS.SubRealPowerPhaseC]-[DATA.RealPowerPhaseC])/std([DATA.RealPowerPhaseC]),'-b')
grid on;
datetick('x','HH')
axis([X(1) X(2) 0 2])
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
axis([X(1) X(2) 122 124])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Time [hr]','FontSize',12,'FontWeight','bold')
datetick('x','HH')
ylabel(gca,'Voltage','FontSize',12,'FontWeight','bold')
title('Problem 1: Substation Transformer Voltage','FontWeight','bold','FontSize',12);
legend('Phase A','Phase B','Phase C') %,'Location','northwest')

subplot(1,2,1)
plot([RESULTS.sDate],[RESULTS.SubLTCTapPosition],'-k')
grid on;
axis([X(1) X(2) .995 1.01])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Time [hr]','FontSize',12,'FontWeight','bold')
datetick('x','HH')
ylabel(gca,'Substation LTC Position [pu]','FontSize',12,'FontWeight','bold')
title('Problem 1: Substation LTC Position','FontWeight','bold','FontSize',12);

% Problem 2 Plots
figure;
plot([Lines.Distance],[Lines.VoltageMagPhaseA]/7200,'.k',...
    [Lines.Distance],[Lines.VoltageMagPhaseB]/7200,'.r',...
    [Lines.Distance],[Lines.VoltageMagPhaseC]/7200,'.b')
grid on;
axis([0 5 .98 1.04])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Sub [km]','FontSize',12,'FontWeight','bold')
ylabel(gca,'Voltage [pu]','FontSize',12,'FontWeight','bold')
title(sprintf('Problem 2: Voltage Profile on %s',datestr(time)),'FontWeight','bold','FontSize',12);
legend('Phase A','Phase B','Phase C')

% Problem 3 Plots
plot([Lines.Rsc],[Lines.Isc],'.')

toc