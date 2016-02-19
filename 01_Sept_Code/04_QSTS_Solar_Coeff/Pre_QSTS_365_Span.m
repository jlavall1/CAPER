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
    Caps.Fixed(1)=300/3;
    Caps.Fixed(2)=600/3;
    
    %To be used for finding AllocationFactors for simulation:
    eff_KW(1,1) = 1;
    eff_KW(1,2) = 1;
    eff_KW(1,3) = 1;
    V_LTC = 124*60;
    polar = -1;
    
    % -- Commonwealth --
    root = 'Common';
    root1= 'Common';
    %Background files needed to run QSTS:
    %load CAP_Mult_60s_Flay.mat  %CAP_OPS_STEP1
    %load P_Mult_60s_Flay.mat    %CAP_OPS_STEP2
    %load Q_Mult_60s_Flay.mat    %CAP_OPS
    %load HOSTING_CAP_FLAY.mat %SU_MIN ; WN_MIN ; SU_AVG ; WN_AVG;
    
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
    V_LTC = 1.03*((12.47e3)/sqrt(3));
    % -- Flay 13.27km long --
    root = 'Flay';
    root1= 'Flay';
    polar = -1;
    
    %load P_Q_Mult_60s.mat
    %load P_Q_Mult_60s_1.mat %   |   CAP_OPS
    load CAP_Mult_60s_Flay.mat  %CAP_OPS_STEP1
    load P_Mult_60s_Flay.mat    %CAP_OPS_STEP2
    load Q_Mult_60s_Flay.mat    %CAP_OPS
    load HOSTING_CAP_FLAY.mat %SU_MIN ; WN_MIN ; SU_AVG ; WN_AVG;
    %Now set where PV Farm is located:
    %PV_ON_OFF=2;
    LC=3;
    if LC == 1
        fprintf('PV at 10% of Zsc_max\n');
    elseif LC == 2
        fprintf('PV at 25% of Zsc_max\n');
    elseif LC == 3
        fprintf('PV at 50% of Zsc_max\n');
    end
    %POI_loc=[63,184,771];   %   10%,25%,50%
    POI_loc=[232,65,251]; 
    POI_pmpp=[4000,1000,600];
    PV_bus=MAX_PV.SU_MIN(POI_loc(LC),9);
    PV_pmpp=POI_pmpp(LC);


    % 10%,25%,50%
    %POI_loc=[232,65,251]; 
    %POI_pmpp=[4000,1000,600];
    %PV_bus=MAX_PV.SU_MIN(POI_loc(LC),9);
    %PV_pmpp=POI_pmpp(LC);
    
elseif feeder_NUM == 3
    load ROX.mat
    FEEDER = ROX;
    clearvars ROX
    kW_peak = [3.189154306704542e+03,3.319270338767296e+03,3.254908188719974e+03];
elseif feeder_NUM == 4
    load HOLLY.mat
elseif feeder_NUM == 5
    load ERalh.mat
elseif feeder_NUM == 8
    load FLAY.mat
    FEEDER = FLAY;
    clearvars FLAY
    kW_peak = [1.424871573296857e+03,1.347528364235151e+03,1.716422704604557e+03];
    %EPRI Circuit 24
    root = 'ckt24';
    root1 = 'ckt24';
end
%%
if feeder_NUM == 2
    CUTOFF=10;
else
    CUTOFF=23;
end
s = ckt_direct(1:end-CUTOFF); % <--------THIS MIGHT CHANGE PER FEEDER !!!!!
str = ckt_direct;
idx = strfind(str,'\');
str = str(1:idx(8)-1);
idx = strfind(ckt_direct,'.');
ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_QSTS.dss');

