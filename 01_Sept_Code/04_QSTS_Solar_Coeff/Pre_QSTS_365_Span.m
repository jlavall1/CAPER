%Pre QSTS_365_Span
addpath(strcat(base_path,'\01_Sept_Code\04_QSTS_Solar_Coeff'));
addpath(strcat(base_path,'\01_Sept_Code\Result_Analysis'));
%Objective:
%       To load in all background files nessessary to run sim.
%%
% Simulation info:
if strcmp(time_int,'1h') == 1
    t_int=0;
    s_step=3600;
    sim_num='24';
    fprintf('Sim. timestep=1hr\n');
elseif strcmp(time_int,'1m') == 1
    t_int=1;
    s_step=60;
    sim_num='1440';
    fprintf('Sim. timestep=60s\n');
elseif strcmp(time_int,'30s') == 1
    t_int=2;
    s_step=30;
    sim_num='2880';
    fprintf('Sim. timestep=30s\n');
elseif strcmp(time_int,'5s') == 1
    t_int=12;
    s_step=5;
    sim_num='17280';
    fprintf('Sim. timestep=5s\n');
end
%%
% Feeder info:
path = strcat(base_path,'\04_DSCADA\Feeder_Data');
addpath(path);

if feeder_NUM == 0
    load BELL.mat
    FEEDER = BELL;
    clearvars BELL
    kW_peak = [2.940849617143377e+03,2.699860573083591e+03,3.092128804831415e+03];
    %AllocationFactors Terms:
    
    % -- Bellhaven --
    root = 'Bell';
    root1= 'Bell';
elseif feeder_NUM == 1
    load CMNWLTH.mat
    FEEDER = CMNWLTH;
    clearvars CMNWLTH
    kW_peak = [2.475021572579630e+03,2.609588847297235e+03,2.086659558753901e+03];
    Caps.Swtch(1)=300/3;
    Caps.Fixed(2)=600/3;
    
    %To be used for finding AllocationFactors for simulation:
    eff_KW(1,1) = 1;
    eff_KW(1,2) = 1;
    eff_KW(1,3) = 1;
    eff_KVAR(1,1) = 1;
    eff_KVAR(1,2) = 1;
    eff_KVAR(1,3) = 1;
    
    V_LTC = 124*60;
    PT_RATIO = '60';
    CT_RATIO = '100';
    PT_PHASE = '3';
    V_LL = '12.47';
    polar = -1;
    
    % -- Commonwealth --
    dss_rt = 'Common';
    root = 'CMNW_0';
    root1= '02_CMNW';
    %Background files needed to run QSTS:
    load CAP_Mult_60s_CMNW.mat  %CAP_OPS_STEP1
    load P_Mult_60s_CMNW.mat    %CAP_OPS_STEP2
    load Q_Mult_60s_CMNW.mat    %CAP_OPS
    %Unique Component Names:
    trans_name='COMMONWEALTH_RET_01311205';
    swcap_name='258903785';
    %Export_Monitors_Timeseries:
    load config_LINESBASE_CMNWLTH.mat %Lines_Base
    [~,index] = sortrows([Lines_Base.bus1Distance].'); 
    Lines_Distance = Lines_Base(index); 
    %
elseif feeder_NUM == 2
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
elseif feeder_NUM == 4
    load HOLLY.mat
elseif feeder_NUM == 5
    load ERalh.mat
elseif feeder_NUM == 8

end
%Connect DER-PV to desired position:
Set_DER_PV_PCC


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
ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_QSTS.dss');

