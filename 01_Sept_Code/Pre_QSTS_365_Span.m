%Pre QSTS_365_Span

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
    %AllocationFactors Terms:
    
    % -- Commonwealth --
    root = 'Common';
    root1= 'Common';
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
    
    %load P_Q_Mult_60s.mat %CAP_OPS
    load P_Q_Mult_60s_1.mat
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
ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_General.dss');
%%
%Import SOLAR FILES
addpath(PV_Site_path);

if PV_Site == 1
    load M_SHELBY_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_SHELBY_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_SHELBY_INFO.kW;
    M_PVSITE_INFO.name = M_SHELBY_INFO.name;
    M_PVSITE_INFO.VI = M_SHELBY_INFO.VI;
    M_PVSITE_INFO.CI = M_SHELBY_INFO.CI;
    load M_SHELBY.mat
    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_SHELBY(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_SHELBY(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_SHELBY(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    load M_SHELBY_SC.mat
    M_PVSITE_SC = M_SHELBY_SC;
    clearvars M_SHELBY_INFO M_SHELBY M_SHELBY_SC
elseif PV_Site == 2
    %MURPHY
    load M_MURPHY_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_MURPHY_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_MURPHY_INFO.kW;
    M_PVSITE_INFO.name = M_MURPHY_INFO.name;
    load M_MURPHY.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_MURPHY(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_MURPHY(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_MURPHY(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_MURPHY_INFO M_MURPHY
elseif PV_Site == 3
    %TAYLOR
    load M_TAYLOR_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_TAYLOR_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_TAYLOR_INFO.kW;
    M_PVSITE_INFO.name = M_TAYLOR_INFO.name;
    load M_TAYLOR.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_TAYLOR(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_TAYLOR(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_TAYLOR(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_TAYLOR_INFO M_TAYLOR
elseif PV_Site == 4
    load M_MOCKS_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_MOCKS_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_MOCKS_INFO.kW;
    M_PVSITE_INFO.name = M_MOCKS_INFO.name;
    load M_MOCKS.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_MOCKS(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_MOCKS(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_MOCKS(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_MOCKS_INFO M_MOCKS
elseif PV_Site == 5
    load M_AROCK_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_AROCK_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_AROCK_INFO.kW;
    M_PVSITE_INFO.name = M_AROCK_INFO.name;
    load M_AROCK.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_AROCK(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_AROCK(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_AROCK(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_AROCK_INFO M_AROCK

elseif PV_Site == 6
    load M_ODOM_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_ODOM_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_ODOM_INFO.kW;
    M_PVSITE_INFO.name = M_ODOM_INFO.name;
    load M_ODOM.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_ODOM(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_ODOM(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_ODOM(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_ODOM_INFO M_ODOM
elseif PV_Site == 7
    load M_MAYB_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_MAYB_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_MAYB_INFO.kW;
    M_PVSITE_INFO.name = M_MAYB_INFO.name;
    load M_MAYB.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_MAYB(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_MAYB(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_MAYB(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_MAYB_INFO M_MAYB
end
%%
if feeder_NUM == 1
    load Common_Bus_Impedance.mat
elseif feeder_NUM == 2
    addpath(strcat(base_path,'\03_OpenDSS_Circuits\Flay_Circuit_Opendss'));
    load Flay_Bus_Impedances.mat %Buses_Zsc
    load Flay_Static_maxPV.mat   %MAX_PV.L50 ; MAX_PV.L30 ; MAX_PV.L25 ;
end
