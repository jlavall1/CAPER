%Timeseries Analyses:
clear
clc
%{
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code')

%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%Find directory of Circuit:
% 1. Obtain user's choice of simulation:
DER_Planning_GUI_1
gui_response = STRING_0;
mainFile = gui_response{1,1};
feeder_NUM = gui_response{1,2};
scenerio_NUM = gui_response{1,3}; %1=VREG-top ; 2=VREG-bot ; 3=steadystate ; 4=RR_up ; 5=RR_down
base_path = gui_response{1,4};
cat_choice = gui_response{1,5};


% 1. Load background files:
path = strcat(base_path,'\01_Sept_Code');
addpath(path);
path = strcat(base_path,'\04_DSCADA');
addpath(path);
%}
addpath('C:\Users\jlavall\Documents\OpenDSS\GridPV\ExampleCircuit');
%%
P_PV = 7500;

%Initialize PV plant:

%exampleTimeseriesAnalyses('ExampleCircuit\master_ckt24.dss',{'ExampleCircuit\Ckt24_PV_Central_7_5.dss'})
% initiate COM interface (only need to do once when you open MATLAB)
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
% Define the circuit:
DSSCircuit = DSSCircObj.ActiveCircuit;
% Compile ckt 24:
caseNames{1} = 'C:\Users\jlavall\Documents\OpenDSS\GridPV\ExampleCircuit\master_ckt24.dss';
DSSfilename = caseNames{1};
location = cd;
DSSText.command = sprintf('Compile (%s)',caseNames{1}); %run basecase first
DSSText.command = 'solve';
cd(location);
%%

%Add PV Plant:
%{
DSSText.command = sprintf('new loadshape.PV_Loadshape npts=43200 sinterval=2 csvfile="PVloadshape_7_5MW_Central.txt" Pbase=%s action=normalize',P_PV/1000);
DSSText.command = sprintf('new pvsystem.PV bus1=N292212 irradiance=1 phases=3 kv=34.50 kVA=8250.00 pf=1.00 pmpp=%s duty=PV_Loadshape',P_PV);
%}
solarfilename = 'C:\Users\jlavall\Documents\OpenDSS\GridPV\ExampleCircuit\Ckt24_PV_Central_7_5.dss';
DSSText.command = sprintf('Compile (%s)',solarfilename); %add solar scenario
DSSText.command = 'solve';
cd(location);
%% 

%Run OpenDSS simulation for 1-week at 1-minute resolution
DSSText.command = 'Set mode=duty number=10080  hour=0  h=60 sec=0';
DSSText.Command = 'Set Controlmode=TIME';
DSSText.command = 'solve';
%% 

%Plot / observe simulation results:
%   Feeder Power
fileNameNoPath = DSSfilename(find(DSSfilename=='\',1,'last')+1:end-4);
plotMonitor(DSSCircObj,'fdr_05410_Mon_PQ');
ylabel('Power (kW,kVar)','FontSize',12,'FontWeight','bold')
title([strrep(fileNameNoPath,'_',' '),' Net Feeder 05410 Load'],'FontSize',12,'FontWeight','bold')
saveas(gcf,[DSSfilename(1:end-4),'_Net_Power.fig'])
%% Substation Voltage
    DSSText.Command = 'export mon subVI';
    monitorFile = DSSText.Result;
    MyCSV = importdata(monitorFile);
    delete(monitorFile);
    Hour = MyCSV.data(:,1); Second = MyCSV.data(:,2);
    subVoltages = MyCSV.data(:,3:2:7);
    
    figure;
    plot(Hour+Second/3600,subVoltages,'LineWidth',2);
    grid on;
    set(gca,'FontSize',10,'FontWeight','bold')
    xlabel('Hour','FontSize',12,'FontWeight','bold')
    ylabel('Voltage','FontSize',12,'FontWeight','bold')
    title([strrep(fileNameNoPath,'_',' '),' Substation Voltages'],'FontSize',12,'FontWeight','bold')
    saveas(gcf,[DSSfilename(1:end-4),'_Sub_Voltage.fig'])
%{
New Monitor.fdr_05410_Mon_VI  element=line.fdr_05410 term=1  mode=0 Residual=Yes
New Monitor.fdr_05410_Mon_PQ  element=line.fdr_05410 term=1  mode=1 PPolar=No
New Monitor.fdr_05410_Mon_VA  element=line.fdr_05410 term=1  mode=1 PPolar=Yes
New Monitor.OtherFeeder_Mon_PQ element=line.Other_Feeders term=1  mode=1 PPolar=No
New Monitor.Cap1 element=Capacitor.Cap_G2100PL6500 terminal=1 mode=65
New monitor.Cap1VI element=Capacitor.Cap_G2100PL6500 terminal=1 mode=0
New Monitor.LTC element=Transformer.SubXFMR terminal=2 mode=2
New monitor.subVI element=Transformer.SubXFMR terminal=2 mode=0
%}
%{
mode:
0   V&I, each phase, complex number
1   Power each phase, complex (kw & kvars)
2   transformer taps (connect to xfmr winding)
3   State variables (PCElement)

+16 Seq. components (012)
+32 Magnitude only
+64 (+)seq only / avg. phases if not 3phase.

export monitor command
%}
    