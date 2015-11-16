%Timeseries Analyses:
% only for ckt24

clear
clc
close all
%{
s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\EPRI_ckt24');
%addpath(strcat(s_b,'\01_Sept_Code'));
ckt_direct_prime=strcat(s_b,'\03_OpenDSS_Circuits\EPRI_ckt24\Master.dss');
%}
s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss');
%addpath(strcat(s_b,'\01_Sept_Code'));
ckt_direct_prime=strcat(s_b,'\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Master_24hr.dss');

%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;

%Start simulation:
tic
DSSText.command = ['Compile ',ckt_direct_prime];

%Run 1-day simulation at 1minute interval:
DSSText.command='set mode=daily stepsize=1m number=1440'; %stepsize is now 1minute (60s)
%Turn the overload report on:
DSSText.command='Set overloadreport=true';
DSSText.command='Set voltexcept=true';
%Solve QSTS Solution:
DSSText.command='solve';

%%
%Now lets obtain results:
% 1]
DSSText.Command = 'export mon fdr_Flay_Mon_VI';
monitorFile = DSSText.Result;
MySUBv = importdata(monitorFile);
delete(monitorFile);
figure(1)
plot(MySUBv.data(:,[3,5,7])/((12.47e3)/sqrt(3)));
title('Voltage at substation');
% 2]
DSSText.Command = 'export mon fdr_Flay_Mon_PQ';
monitorFile = DSSText.Result;
MySUBp = importdata(monitorFile);
delete(monitorFile);
figure(2)
plot(MySUBp.data(:,[3,5,7]),'DisplayName','MySUBp.data(:,[3,5,7])');
title('Single Phase Real Power consumption');
% 3]
DSSText.Command = 'export mon LTC';
monitorFile = DSSText.Result;
MyLTC = importdata(monitorFile);
delete(monitorFile);
figure(3)
plot(MyLTC.data(:,end));
title('LTC operations');



