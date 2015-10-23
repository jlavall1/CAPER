%load PV files.
for PV_location=1:1:7
    if PV_location == 1
        PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC');
        addpath(PV_dir);
        load M_SHELBY_INFO.mat
        %M_PVSITE_INFO = M_SHELBY_INFO;
        %clear M_SHELBY_INFO
    elseif PV_location == 2
        PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\02_Murphy_NC');
        addpath(PV_dir);
        load M_MURPHY_INFO.mat
        %M_PVSITE_INFO = M_MURPHY_INFO;
        %clear M_MURPHY_INFO
    elseif PV_location == 3
        PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\03_Taylorsville_NC');
        addpath(PV_dir);
        load M_TAYLOR_INFO.mat
        %M_PVSITE_INFO = M_TAYLOR_INFO;
        %clear M_TAYLOR_INFO
    elseif PV_location == 4
        PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
        addpath(PV_dir);
        load M_MOCKS_INFO.mat
        %M_PVSITE_INFO = M_MOCKS_INFO;
        %clear M_MOCKS_INFO
    elseif PV_location == 5
        PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\05_AraratRock_NC');
        addpath(PV_dir);
        load M_AROCK_INFO.mat
        %M_PVSITE_INFO = M_AROCK_INFO;
        %clear M_AROCK_INFO
    elseif PV_location == 6
        PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\06_OldDominion_NC');
        addpath(PV_dir);
        load M_ODOM_INFO.mat
        %M_PVSITE_INFO = M_ODOM_INFO;
        %clear M_ODOM_INFO
    elseif PV_location == 7
        PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\07_MayBerry_NC');
        addpath(PV_dir);
        load M_MAYB_INFO.mat
        %M_PVSITE_INFO = M_MAYB_INFO;
        %clear M_MAYB_INFO
    end
end