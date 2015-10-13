%feeder_Loadshape_generation: This .m file will generate the .txt single
%phase files of the desired day user define.
%%
%Temp init. vars/actions
%{
clear
clc
base_path = 'C:\Users\jlavall\Documents\GitHub\CAPER';
ckt_direct = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Run_Master_Allocate.dss';
feeder_NUM = 2;
timeseries_span = 1;
DOY = 40;
%}
%%
%As of 10/12 - user pre-defines and it is not dynamic yet.
path = strcat(base_path,'\04_DSCADA\Feeder_Data');
addpath(path);

if feeder_NUM == 0
    load BELL.mat
    FEEDER = BELL;
    clearvars BELL
    kW_peak = [0,0,0];
elseif feeder_NUM == 1
    load COMN.mat
    FEEDER = COMN;
    clearvars COMN
    kW_peak = [2.475021572579630e+03,2.609588847297235e+03,2.086659558753901e+03];
elseif feeder_NUM == 2
    load FLAY.mat
    FEEDER = FLAY;
    clearvars FLAY
    kW_peak = [1.424871573296857e+03,1.347528364235151e+03,1.716422704604557e+03];
elseif feeder_NUM == 3
    load ROX.mat
    FEEDER = ROX;
    clearvars ROX
    kW_peak = [3.189154306704542e+03,3.319270338767296e+03,3.254908188719974e+03];
elseif feeder_NUM == 4
    load HOLLY.mat
elseif feeder_NUM == 5
    load ERalh.mat
end
%%
%Select DOY & convert to P.U. --
%   DOY already decided from PV_Loadshape_generation.
LS_PhaseA(:,1) = FEEDER.kW.A(time2int(DOY,0,0):time2int(DOY,23,59),1)./kW_peak(1,1);
LS_PhaseB(:,1) = FEEDER.kW.B(time2int(DOY,0,0):time2int(DOY,23,59),1)./kW_peak(1,2);
LS_PhaseC(:,1) = FEEDER.kW.C(time2int(DOY,0,0):time2int(DOY,23,59),1)./kW_peak(1,3);

%%
%Save .txt per phase --
s = ckt_direct(1:end-23);
str = ckt_direct;
idx = strfind(str,'\');
str = str(1:idx(8)-1);
if timeseries_span == 1
    %10AM to 4PM, at 1minute intervals
    s_kwA = strcat(s,'LS1_PhaseA.txt');
    s_kwB = strcat(s,'LS1_PhaseB.txt');
    s_kwC = strcat(s,'LS1_PhaseC.txt');
    FEEDER.SIM.npts= 6*60;  %simulating 6 hours
    FEEDER.SIM.minterval = 1; %1 minute intervals
    idx = strfind(ckt_direct,'.');
    ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_6hr.dss');
elseif timeseries_span == 2
    %24 Hours, 1 DAY at 1minute intervals
    s_kwA = strcat(s,'LS2_PhaseA.txt');
    s_kwB = strcat(s,'LS2_PhaseB.txt');
    s_kwC = strcat(s,'LS2_PhaseC.txt');
    FEEDER.SIM.npts= 24*60;     %simulating 24 hours
    FEEDER.SIM.minterval = 1;   %1 minute intervals
    idx = strfind(ckt_direct,'.');
    ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_24hr.dss');
elseif timeseries_span == 3
    %1 Week simulation
    s_kwA = strcat(s,'LS3_PhaseA.txt');
    s_kwB = strcat(s,'LS3_PhaseB.txt');
    s_kwC = strcat(s,'LS3_PhaseC.txt');
    FEEDER.SIM.npts= 7*24*60;   %simulating 168 hours
    FEEDER.SIM.minterval = 1;   %1 minute intervals
    idx = strfind(ckt_direct,'.');
    ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_168hr.dss');
end
csvwrite(s_kwA,LS_PhaseA)
csvwrite(s_kwB,LS_PhaseB)
csvwrite(s_kwC,LS_PhaseC)

