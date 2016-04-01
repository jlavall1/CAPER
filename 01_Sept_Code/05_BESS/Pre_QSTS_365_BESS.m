clear
clc
close all
%Pre QSTS_365_Span

ckt_direct      = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Master.dss'; %entire directory string of where the cktfile is locatted
feeder_NUM      = 2; %1=CMWTH 2=FLAY 3=ROX
base_path       = 'C:\Users\jlavall\Documents\GitHub\CAPER';

PV_Site_1       = 4; %MOCKS
PV_Site_2       = 1; %SHELBY
PV_Site_path_1  = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC';
PV_Site_path_2  = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC';

timeseries_span = 2; %Simulates 1 day (24hr) at a time.
int_select=1;   %1: 5s load, 1s sim 2:60s load, 60s sim
QSTS_select     = 4;

BESS_ON         = 1; %0 is no battery, 1 is a battery
DYN             = 1; %0 for just trap follow; 1 for dP adjustment
BESS_TYPE       = 2; %1=8000kWh 2=4000kWh 3=1000kWh

addpath(strcat(base_path,'\04_DSCADA'));
addpath(strcat(base_path,'\01_Sept_Code\05_BESS'));
addpath(strcat(base_path,'\01_Sept_Code\Result_Analysis'));


%%
%Objective:
%       To load in all background files nessessary to run sim.

MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
% User Select run length:
slt_DAY_RUN = 8; %was 9


if slt_DAY_RUN == 1
    %One day run on 2/13
    DAY = 13;
    MNTH = 2;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY;
elseif slt_DAY_RUN == 2
    %3 mnth run 2/1 - 5/1
    DAY = 1;
    MNTH = 2;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+MTH_LN(2)+MTH_LN(3)+MTH_LN(4)-1;
elseif slt_DAY_RUN == 3
    %Annual run
    DAY = 1;
    MNTH = 1;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F=364;
elseif slt_DAY_RUN == 4
    %One week run
    DAY = 1;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+6;
elseif slt_DAY_RUN == 5
    %Summer run:
    DAY = 1;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+MTH_LN(6)+MTH_LN(7)+MTH_LN(8)-1;
elseif slt_DAY_RUN == 6
    %DSDR to show cap movements:
    DAY = 13;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+6; %1 week run.
elseif slt_DAY_RUN == 7
    %DAY to show increase in TVD vs. Distance: (110)
    %One day run on 2/13
    DAY = 20;
    MNTH = 4;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY;
elseif slt_DAY_RUN == 8
    %One day run on 6/1 to test BESS
    DAY = 1;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY;
elseif slt_DAY_RUN == 9
    %One day run on 2/4 to test BESS
    %Peak Operations:
    DAY = 3;
    MNTH = 2;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY;
elseif slt_DAY_RUN == 10
    %TWO day run on 2/13 to 2/14
    DAY = 13;
    MNTH = 2;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+1;
end
    
if int_select == 1
    %5sec load sim step:
    int_1m=12;
    s_step=5; %sec
    ss=1;
    NUM_INC=60;
    fprintf('5 sec. Load w/ 1 sec Sim. stepsize\n');
elseif int_select == 2
    %60sec load sim step:
    int_1m=1;
    s_step=60; %sec
    ss=1;
    NUM_INC=1;
    fprintf('60 sec. Load w/ 60 sec Sim. stepsize\n');
elseif int_select == 3
    %5sec load sim step:
    int_1m=12;
    s_step=5; %sec
    ss=5;
    NUM_INC=60/5;
end

%%
% Feeder info:
path = strcat(base_path,'\04_DSCADA\Feeder_Data');
addpath(path);

if feeder_NUM == 2
    load FLAY.mat
    FEEDER = FLAY;
    clearvars FLAY
    kW_peak = [1.424871573296857e+03,1.347528364235151e+03,1.716422704604557e+03];
    Caps.Fixed(1)=600/3;
    Caps.Swtch(1)=450/3;
    %To be used for finding AllocationFactors for simulation:
    eff_KW(1,1) = 0.9862;
    eff_KW(1,2) = 0.993;
    eff_KW(1,3) = 0.9894;
    eff_KVAR(1,1) = 1;
    eff_KVAR(1,2) = 1;
    eff_KVAR(1,3) = 1;
    V_LTC_PU = 1.03;
    V_LTC = V_LTC_PU*((12.47e3)/sqrt(3));
    PT_RATIO = '60';
    CT_RATIO = '100';
    PT_PHASE = '3';
    V_LL = '12.47';
    % -- Flay 13.27km long --
    dss_rt = 'Flay';
    root = 'FLAY_0';
    root1= '03_FLAY';
    polar = -1;

    load CAP_Mult_60s_Flay.mat  %CAP_OPS_STEP1
    load P_Mult_60s_Flay.mat    %CAP_OPS_STEP2
    load Q_Mult_60s_Flay.mat    %CAP_OPS
    %Component Names:
    trans_name='FLAY_RET_16271201';
    sub_line='259363665';
    swcap_name='38391707_sw';
elseif feeder_NUM == 3
    load ROX.mat
    FEEDER = ROX;
    clearvars ROX
    kW_peak = [3.189154306704542e+03,3.319270338767296e+03,3.254908188719974e+03];
    %Unique Things:
    eff_KVAR(1,1) = 3.18;
    eff_KVAR(1,2) = 4.00;
    eff_KVAR(1,3) = 3.58;
    V_LTC = 124*60;
    polar = -1;
    PT_RATIO = '110';
    CT_RATIO = '100';
    PT_PHASE = '2';
    V_LL = '22.87';
    %String Names:
    dss_rt = 'Rox';
    root = 'ROX_0';
    root1= '04_ROX';
    %Background Datasets:
    load CAP_Mult_60s_ROX.mat   %CAP_OPS_STEP1
    load P_Mult_60s_ROX.mat     %CAP_OPS_STEP2
    load Q_Mult_60s_ROX.mat     %CAP_OPS.DSS & .oper
    %Component Names:
    Caps.Name{1}='E1183_2582120';
    Caps.Name{2}='E2M13_104080657';
    Caps.Name{3}='EXF80_2573355';
    Caps.Swtch(1)=1200/3; 
    Caps.Swtch(2)=1200/3; 
    Caps.Swtch(3)=1200/3;
    trans_name='T5240B12';
    sub_line='PH997__2571841';
    %Export_Monitors_Timeseries:
    load config_LINESBASE_ROX.mat   %Lines_Base
    
    [~,index] = sortrows([Lines_Base.bus1Distance].'); 
    Lines_Distance = Lines_Base(index); 
    load Loads_Total.mat %LoadTotals
end



%%
if feeder_NUM == 1
    CUTOFF=11;
elseif feeder_NUM == 2
    CUTOFF=10;
elseif feeder_NUM == 3
    CUTOFF=11;
else
    CUTOFF=23;
end
s = ckt_direct(1:end-CUTOFF); % <--------THIS MIGHT CHANGE PER FEEDER !!!!!
str = ckt_direct;
idx = strfind(str,'\');
str = str(1:idx(8)-1);
idx = strfind(ckt_direct,'.');
%%
%Connect DER-PV to desired position:
PV_SITE_DATA_import
Set_DER_PV_PCC
if DYN == 0
    QSTS_365_BESS
elseif DYN == 1
    QSTS_365_BESS_DYN
end
