% ECE 6180                      Project                     Shane Kimble

clear
clc

%% Load Historical Data
load('CMNWLTH.mat');
% Data Characteristics
start = '01/01/2014'; % Date at which data starts
res   = 60;           % [s] - Resolution of data
ndat  = 525600;       % Number of Data Points

% Desired Characteristics
%  For 1day at 1min resolution - nstp = 1440; step = 60;
date = '06/01/2014';
nstp = 1440; % Number of steps
step = 60;   % [s] - Resolution of step

% Find desired indicies
index = (step/res)*(0:nstp-1) + (86400/res)*(datenum(date)-datenum(start));

% Check for Errors
if mod(step,res)
    error('Desired Resolution must be an integer multiple of the Data resolution')
elseif max(index) > ndat
    error('Desired Data out of range')
end

for i=1:nstp
    DATA(i).Date = datestr(floor(index(i)*(res/86400)) + datenum(start),23);
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
fprintf(fileID,[sprintf('New loadshape.LS_PhaseA npts=%d sinterval=%d mult=(',nstp,step),...
    sprintf('%f ',[DATA.RealPowerPhaseA]/max([DATA.RealPowerPhaseA])),...
    ') action=normalize\n\n']);
fprintf(fileID,[sprintf('New loadshape.LS_PhaseB npts=%d sinterval=%d mult=(',nstp,step),...
    sprintf('%f ',[DATA.RealPowerPhaseB]/max([DATA.RealPowerPhaseB])),...
    ') action=normalize\n\n']);
fprintf(fileID,[sprintf('New loadshape.LS_PhaseC npts=%d sinterval=%d mult=(',nstp,step),...
    sprintf('%f ',[DATA.RealPowerPhaseC]/max([DATA.RealPowerPhaseC])),...
    ') action=normalize\n\n']);
fclose(fileID);

%% Initialize OpenDSS
% Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;

% Compile Circuit
DSSText.command = ['Compile ',[filelocation,filename]];

% Configure Simulation
DSSText.command = 'set mode = daily';
DSSCircuit.Solution.Number = 1;
DSSCircuit.Solution.Stepsize = 60;
DSSCircuit.Solution.dblHour = 0.0;

% Loop through load shape and collect Results
for t = 1:nstp
    % Solve at current time step
    DSSCircuit.Solution.Solve
    
    % Read Data from OpenDSS
    RESULTS(t).Date = DATA(t).Date;
    RESULTS(t).Time = DATA(t).Time;
    DSSCircuit.SetActiveElement('Line.259355408');
    Power   = DSSCircuit.ActiveCktElement.Powers;
    Voltage = DSSCircuit.ActiveCktElement.VoltagesMagAng;
    
    RESULTS(t).SubRealPowerPhaseA = Power(1);
    RESULTS(t).SubRealPowerPhaseB = Power(3);
    RESULTS(t).SubRealPowerPhaseC = Power(5);
    
    RESULTS(t).SubReactivePowerPhaseA = Power(2);
    RESULTS(t).SubReactivePowerPhaseB = Power(4);
    RESULTS(t).SubReactivePowerPhaseC = Power(6);
    
    RESULTS(t).SubPhaseVoltageMagPhaseA = Voltage(1);
    RESULTS(t).SubPhaseVoltageAngPhaseA = Voltage(2);
    RESULTS(t).SubPhaseVoltageMagPhaseB = Voltage(3);
    RESULTS(t).SubPhaseVoltageAngPhaseB = Voltage(4);
    RESULTS(t).SubPhaseVoltageMagPhaseC = Voltage(5);
    RESULTS(t).SubPhaseVoltageAngPhaseC = Voltage(6);
    
    RESULTS(t).SubLTCTapPosition = DSSCircuit.Transformers.Tap;
end


%% Analyze Data
plot(index,[RESULTS.SubPhaseVoltageMagPhaseB]/60,[min(index),max(index)],[123.5,123.5],[min(index),max(index)],[122.5,122.5])