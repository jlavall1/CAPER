%Just testing:
clear
clc
close all
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis');
load config_LEGALBUSES_FLAY.mat
load config_LEGALDISTANCE_FLAY.mat

fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss';
peak_current = [196.597331353572,186.718068471483,238.090235458346];
peak_kW = 1343.768+1276.852+1653.2766;
min_kW = 1200;

energy_line = '259363665';
fprintf('Characteristics for:\t1 - FLAY\n\n');
vbase = 7;

str = strcat(fileloc,'\Master.DSS'); 
[DSSCircObj, DSSText] = DSSStartup; 
DSSText.command = ['Compile ' str]; 
DSSText.command = sprintf('New EnergyMeter.CircuitMeter LINE.%s terminal=1 option=R PhaseVoltageReport=yes',energy_line);
DSSText.command = sprintf('EnergyMeter.CircuitMeter.peakcurrent=[  %s   %s   %s  ]',num2str(peak_current(1,1)),num2str(peak_current(1,2)),num2str(peak_current(1,3)));
DSSText.command = 'Disable Capacitor.*';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'Enable Capacitor.*';

%Run at desired Load Level:
DSSText.command = 'solve loadmult=0.50';
Buses_1=getBusInfo(DSSCircObj);
for i=1:1:length(Buses_1)
    if strcmp(Buses_1(i,1).name,'263395399') == 1
        PV_PCC=i;
    end
end
%%
figure(1)
plotVoltageProfile(DSSCircObj,'SecondarySystem','off','Only3Phase','on');
%hold on
%{'263395399',2,1.02685896756743,1.72214829937927,5.70324000000000}


DSSText.command = sprintf('new generator.PV bus1=%s phases=3 kv=12.47 kW=1200 pf=1.00 enabled=true','263395399');
DSSText.command = 'solve loadmult=0.50';
Buses=getBusInfo(DSSCircObj);
Lines=getLineInfo(DSSCircObj);

figure(2)
gcf=plotVoltageProfile(DSSCircObj,'SecondarySystem','off','Only3Phase','on');
%set(gcf,'title','');
hold on
busHandle=plot(Buses(PV_PCC,1).distance,Buses(PV_PCC,1).phaseVoltagesPU(1,1)*120,'gh','MarkerSize',14,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor','g');
hold on
plot(Buses(PV_PCC,1).distance,Buses(PV_PCC,1).phaseVoltagesPU(1,2)*120,'gh','MarkerSize',14,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor','g')
hold on
plot(Buses(PV_PCC,1).distance,Buses(PV_PCC,1).phaseVoltagesPU(1,3)*120,'gh','MarkerSize',14,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor','g')
legend([gcf.legendHandles,busHandle'],[gcf.legendText,'DG_{PCC}'] )
