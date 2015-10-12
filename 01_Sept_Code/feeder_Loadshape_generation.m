%feeder_Loadshape_generation: This .m file will generate the .txt single
%phase files of the desired day user define.
%%
%Temp init. vars/actions
clear
clc
base_path = 'C:\Users\jlavall\Documents\GitHub\CAPER';
ckt_direct = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Run_Master_Allocate.dss';
feeder_NUM = 2;
timeseries_span = 1;
%
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
for i = 1:1:length(FEEDER)
    FEEDER.kW.A(time2int(DAY,0,0))
end

%%
%Save .txt per phase --
s = ckt_direct(1:end-23);
str = ckt_direct;
idx = strfind(str,'\');
str = str(1:idx(8)-1);
if timeseries_span == 1
    s_kwA = strcat(s,'\LS1_PhaseA.txt');
    csvwrite(s_kwA,LS1_PhaseA)
    s_kwB = strcat(s,'\LS1_PhaseB.txt');
    csvwrite(s_kwB,LS1_PhaseB)
    s_kwC = strcat(s,'\LS1_PhaseC.txt');
    csvwrite(s_kwC,LS1_PhaseC)
elseif timeseries_span == 2
    s_kwA = strcat(s,'\LS2_PhaseA.txt');
    csvwrite(s_kwA,LS_PhaseA)
    s_kwB = strcat(s,'\LS2_PhaseB.txt');
    csvwrite(s_kwB,LS_PhaseB)
    s_kwC = strcat(s,'\LS2_PhaseC.txt');
    csvwrite(s_kwC,LS_PhaseC)
end


