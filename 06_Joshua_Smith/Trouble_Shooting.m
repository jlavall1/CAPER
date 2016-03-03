%Built to trouble shoot Josh's Circuit:
clear
clc
close all
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);

fileloc='C:\Users\jlavall\Documents\GitHub\CAPER\06_Joshua_Smith\DSS';
peak_current = [232.76,242.99,238.03];
energy_line='A1';
%DSS Start Up:
[DSSCircObj, DSSText] = DSSStartup; 
str = strcat(fileloc,'\Master.DSS');
DSSText.command = ['Compile ' str];
DSSText.command = sprintf('New EnergyMeter.CircuitMeter LINE.%s terminal=1 option=R PhaseVoltageReport=yes',energy_line);
DSSText.command = sprintf('EnergyMeter.CircuitMeter.peakcurrent=[  %s   %s   %s  ]',num2str(peak_current(1,1)),num2str(peak_current(1,2)),num2str(peak_current(1,3)));
DSSText.command = 'Disable Capacitor.*';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
%DSSText.command = 'Dump AllocationFactors';
DSSText.command = 'Enable Capacitor.*';
%Pick what you want...
%DSSText.command = 'Solve mode=faultstudy';
DSSText.command = 'Solve loadmult=0.5';
DSSText.command = 'Show Eventlog';
%Pull through COM interface:
warnSt = circuitCheck(DSSCircObj);

DSSCircuit = DSSCircObj.ActiveCircuit;
Buses=getBusInfo(DSSCircObj);
Lines=getLineInfo(DSSCircObj);
Loads=getLoadInfo(DSSCircObj);
[~,index] = sortrows([Lines.bus1Distance].'); 
Lines_Distance = Lines(index); 
%For Post_Process & Post_Process_2
xfmrNames = DSSCircuit.Transformers.AllNames;
lineNames = DSSCircuit.Lines.AllNames;
loadNames = DSSCircuit.Loads.AllNames;
Lines_Base = getLineInfo(DSSCircObj);
Buses_Base = getBusInfo(DSSCircObj);
%%
%Plot some things...
fig = 1;
figure(fig)
plot([Buses.voltage]/110)
hold on
plot(24,Buses(24).voltage/110,'bo'); %VR1
hold on
plot(46,Buses(46).voltage/110,'bo'); %VR2
hold on
plot(53,Buses(53).voltage/110,'bo'); %VR3
hold on
plot(62,Buses(62).voltage/110,'bo'); %VR3



