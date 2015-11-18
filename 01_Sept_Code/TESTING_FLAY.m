%Timeseries Analyses:
% only for ckt24

clear
clc
close all

time_int=60;
feeder_NUM=2;

%{
s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\EPRI_ckt24');
%addpath(strcat(s_b,'\01_Sept_Code'));
ckt_direct_prime=strcat(s_b,'\03_OpenDSS_Circuits\EPRI_ckt24\Master.dss');
%}

s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss');
root1= 'Flay';

%---------Unique .DSS files------------------------------------------------------
%   Redirect Monitors_Flay_32_1.dss     |V,I   &    P,Q    Magnitude Only
%   Redirect Loads_Daily.dss            |Daily
%   Redirect AllocationFactors_Base.txt |
%   Redirect SourceRegulator_3ph.dss    |(124.5,125.5)
%--------------------------------------------------------------------------------
if time_int == 60
    ckt_direct_prime=strcat(s_b,'\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Master_24hr_60sec.dss');
elseif time_int == 5
    ckt_direct_prime=strcat(s_b,'\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Master_24hr_5sec.dss');
end
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;

%Start simulation:
tic
DSSText.command = ['Compile ',ckt_direct_prime];

%Run 1-day simulation at 1minute interval:
if time_int == 60
    DSSText.command='set mode=daily stepsize=1m number=1440'; %stepsize is now 1minute (60s)
elseif time_int == 5
    DSSText.command='set mode=daily stepsize=5s number=17280'; %stepsize is now 1minute (60s)
end

%Turn the overload report on:
DSSText.command='Set overloadreport=true';
DSSText.command='Set voltexcept=true';
%Solve QSTS Solution:
DSSText.command='solve';
DSSText.command='show eventlog';
Loads=getLoadInfo(DSSCircObj);

%%
%Now lets obtain results:
% 0]
addpath(strcat(s_b,'\01_Sept_Code'));
Export_Monitors_timeseries
%%
% 1]
DSSText.Command = 'export mon fdr_Flay_Mon_VI';
monitorFile = DSSText.Result;
MySUBv = importdata(monitorFile);
delete(monitorFile);
figure(2)
plot(MySUBv.data(:,[3,5,7])/((12.47e3)/sqrt(3)));
title('Voltage at substation');
% 2]
DSSText.Command = 'export mon fdr_Flay_Mon_PQ';
monitorFile = DSSText.Result;
MySUBp = importdata(monitorFile);
delete(monitorFile);
figure(3)
plot(MySUBp.data(:,[3,5,7]),'DisplayName','MySUBp.data(:,[3,5,7])');
title('Single Phase Real Power consumption');
% 3]
DSSText.Command = 'export mon LTC';
monitorFile = DSSText.Result;
MyLTC = importdata(monitorFile);
delete(monitorFile);
figure(4)
plot(MyLTC.data(:,end));
title('LTC operations');



