%Timeseries Analyses:
% only for ckt24

clear
clc
close all
s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\EPRI_ckt24');
%addpath(strcat(s_b,'\01_Sept_Code'));

feeder_NUM=8;
time_int=60;

if time_int == 5
    ckt_direct_prime=strcat(s_b,'\03_OpenDSS_Circuits\EPRI_ckt24\Master.dss');
elseif time_int == 60
    ckt_direct_prime=strcat(s_b,'\03_OpenDSS_Circuits\EPRI_ckt24\Master_24hr_60m.dss');
end
%{
s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss');
%addpath(strcat(s_b,'\01_Sept_Code'));
ckt_direct_prime=strcat(s_b,'\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Master_24hr.dss');
%}
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;

%Start simulation:
tic
DSSText.command = ['Compile ',ckt_direct_prime];
%{
DSSText.command = 'solve loadmult=1.0';
Lines_Base = getLineInfo(DSSCircObj);
Buses_Base = getBusInfo(DSSCircObj);
Loads_Base = getLoadInfo(DSSCircObj);
%Develop Lines_Distance for use of Monitors --
[~,index] = sortrows([Lines_Base.bus1Distance].'); 
Lines_Distance = Lines_Base(index); 
clear index
%
%%

NAMEPLATE=zeros(1,5);
ALLOC=zeros(length(Loads_Base),1);
for i=1:1:length(Loads_Base)
    if Loads_Base(i,1).nodes == 1
        NAMEPLATE(1,1) = NAMEPLATE(1,1) + Loads_Base(i,1).xfkVA;
    elseif Loads_Base(i,1).nodes == 2
        NAMEPLATE(1,2) = NAMEPLATE(1,2) + Loads_Base(i,1).xfkVA;
    elseif Loads_Base(i,1).nodes == 3
        NAMEPLATE(1,3) = NAMEPLATE(1,3) + Loads_Base(i,1).xfkVA;
    elseif Loads_Base(i,1).nodes == [1,2,3]
        NAMEPLATE(1,4) = NAMEPLATE(1,4) + Loads_Base(i,1).xfkVA;
    end
end
%%
for i=1:1:length(Loads_Base)
    if Loads_Base(i,1).nodes == 1
        ALLOC(i,1)=Loads_Base(i,1).xfkVA/NAMEPLATE(1,1);
    elseif Loads_Base(i,1).nodes == 2
        ALLOC(i,1)=Loads_Base(i,1).xfkVA/NAMEPLATE(1,2);
    elseif Loads_Base(i,1).nodes == 3
        ALLOC(i,1)=Loads_Base(i,1).xfkVA/NAMEPLATE(1,3);
    elseif Loads_Base(i,1).nodes == [1,2,3]
        ALLOC(i,1)=Loads_Base(i,1).xfkVA/NAMEPLATE(1,4);
    end
end
%}

%%
%Run 1-week simulation at hour 5280 out of 8760

%DSSText.command='set casename=Example1week';
%DSSText.command='set mode=yearly number=168 hour=5280'; %number=168 for 1hour intervals
%DSSText.command='set mode=yearly number=10080 hour=5280'; %number=168*60 for 1min intervals
%DSSText.command='set mode=duty number=10080 hour=5280'; %duty
if time_int == 5
    DSSText.command='set mode=daily stepsize=5s number=17280'; %stepsize is now        (05s)
elseif time_int == 60
    DSSText.command='set mode=daily stepsize=1m number=1440'; %stepsize is now 1minute (60s)
elseif time_int == 30
    DSSText.command='set mode=daily stepsize=30s number=2880'; %stepsize is now 1minute (30s)
end

%DSSText.command='set stepsize=60';
%DSSText.command='set mode=duty number=17280';
%DSSText.command = 'Set Controlmode=TIME';
%Other settings --c.
%Turn the overload report on:
DSSText.command='Set overloadreport=true';
DSSText.command='Set voltexcept=true';
%DSSText.command='Set demand=true'; %turns on demand interval/resets all energymeters
%DSSText.command='set DIVerbos=true';

%DSSText.command='Set Year=1';
%DSSText.command='Set hour=5280';
DSSText.command='solve';
DSSText.command='show eventlog';
%DSSText.command='closedi';
toc

%%
%Now lets obtain results:
% 0]
addpath(strcat(s_b,'\01_Sept_Code'));
Export_Monitors_timeseries
% 1]
%%
DSSText.Command = 'export mon fdr_05410_Mon_VI';
monitorFile = DSSText.Result;
MySUBv = importdata(monitorFile);
delete(monitorFile);
figure(2)
plot(MySUBv.data(:,[3,5,7])/166);
n = length(MySUBv.data);
%plot(DATA_SAVE(3).phaseV/166);
%n = length(DATA_SAVE(3).phaseV);
hold on
plot(1:1:n,121.5,'r-','LineWidth',3);
hold on
plot(1:1:n,123,'r--');
hold on
plot(1:1:n,124.5,'r-','LineWidth',3);
hold on
%If the control was 122 BW=3V:
plot(1:1:n,120.5,'b-','LineWidth',3);
hold on
plot(1:1:n,122,'b--');
hold on
plot(1:1:n,123.5,'b-','LineWidth',3);
hold on
%Show voltage after substation.
DSSText.Command = 'export mon 05410_339436oh_Mon_VI';
monitorFile = DSSText.Result;
MySUB1v = importdata(monitorFile);
delete(monitorFile);
%plot(MySUB1v.data(:,[3,4,5])/166);
%
% 2]
DSSText.Command = 'export mon fdr_05410_Mon_PQ';
monitorFile = DSSText.Result;
MySUBp = importdata(monitorFile);
delete(monitorFile);
figure(3)
plot(MySUBp.data(:,[3,5,7]),'DisplayName','MySUBp.data(:,[3,5,7])');
title('Single Phase Real Power consumption');
% 3]
DSSText.Command = 'export mon SubXFMR_taps';
monitorFile = DSSText.Result;
MyLTC = importdata(monitorFile);
delete(monitorFile);
figure(4)
plot(MyLTC.data(:,end));
title('LTC operations');
%{
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
%}



