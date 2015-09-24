%Start of Irradiance / PV - kW Output Analysis:
clear
clc

%Ask user which site do they want?
USER_DEF = GUI_PV_Locations();
sim_type = USER_DEF(1,1);
PV_Site = USER_DEF(1,2);
FIG_type = USER_DEF(1,3);
Algo_num = USER_DEF(1,4);
BASE_path = 'C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code';
fig = 0;

if sim_type == 1
    %%
    if PV_Site == 1
        PV_Site_path1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC';
        addpath(PV_Site_path1);
        [GHI_K,Date,~] = xlsread('Shelby_1MW.xlsx','Shelby'); %Horiz_Irrad ; Power ; A.Temp ; Elevation ; Azimuth
    elseif PV_Site == 2
        PV_Site_path2 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\02_Murphy_NC';
        addpath(PV_Site_path2);
        [GHI_K,Date,~] = xlsread('Murphy_1MW.xlsx','Murphy'); %Horiz_Irrad ; Power ; A.Temp ; Elevation ; Azimuth
    elseif PV_Site == 3
        PV_Site_path3 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\03_Taylorsville_NC';
        addpath(PV_Site_path3);
        [GHI_K,Date,~] = xlsread('Taylorsville_1MW.xlsx','Taylorsville'); %Horiz_Irrad ; Power ; A.Temp ; Elevation ; Azimuth
    end
    %1]
    %
    %Initate Data Quality & Structuring Algorithm:
    if Algo_num == 1 || Algo_num == 2
        Create_IrradianceMeasurements_Datafile
    end
    %
    %2]VI_CI_DARR.m
    %
    if Algo_num == 1 || Algo_num == 3
        if PV_Site == 1
            load M_SHELBY.mat
            M_PVSITE = M_SHELBY;
        elseif PV_Site == 2
            load M_MURPHY.mat
            M_PVSITE = M_MURPHY;
        elseif PV_Site == 3
            load M_TAYLOR.mat
            M_PVSITE = M_TAYLOR;
        end
        %
        %Initate VI CI DARR Calculations:
        clc
        Find_VI_CI_DARR
    end
    %
    %3]Pre_PV_Ramping.m
    %
    if Algo_num == 1 || Algo_num == 4
        clc
        fprintf('Pre_PV_Ramping\n');
        %Load Appropriate Data:
        if PV_Site == 1
            PV_Site_path1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC';
            addpath(PV_Site_path1);
            load M_SHELBY.mat
            load M_SHELBY_SC.mat
            M_PVSITE = M_SHELBY;    %make general --
            M_PVSITE_SC = M_SHELBY_SC;
            PV1_MW.name = 'Shelby';
            PV1_MW.kW = 1000;
        elseif PV_Site == 2
            PV_Site_path2 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\02_Murphy_NC';
            addpath(PV_Site_path2);
            load M_MURPHY.mat
            load M_MURPHY_SC.mat
            M_PVSITE = M_MURPHY;    %make general --
            M_PVSITE_SC = M_MURPHY_SC;
            PV1_MW.name = 'Murphy';
            PV1_MW.kW = 1000;
        elseif PV_Site == 3
            PV_Site_path3 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\03_Taylorsville_NC';
            addpath(PV_Site_path3);
            load M_TAYLOR.mat
            load M_TAYLOR_SC.mat
            M_PVSITE = M_TAYLOR;    %make general --
            M_PVSITE_SC = M_TAYLOR_SC;
            PV1_MW.name = 'Taylorsville';
            PV1_MW.kW = 1000;
        end
        %
        %Initiate .m File:
        addpath(BASE_path);
        Pre_PV_Ramping
        
    end

elseif sim_type == 2
    %%
    if PV_Site == 1
        PV_Site_path4 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC';
        addpath(PV_Site_path4);
        [PV_OUT,Date,~] = xlsread('Mocksville_5MW.xlsx','Mocksville'); %Power kW ; R.Power kVAR ; RECL Status
        %Load Solar Angles.mat file --
        load TAYLOR_GHI.mat %imports ANGLES_GHI
    elseif PV_Site == 2
        PV_Site_path5 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\05_AraratRock_NC';
        addpath(PV_Site_path5);
        [PV_OUT,Date,~] = xlsread('Ararat_3_5MW.xlsx','Ararat'); %Power kW ; R.Power kVAR ; RECL Status
        %Load Solar Angles.mat file --
        load TAYLOR_GHI.mat %imports ANGLES_GHI
    end
    %
    %
    %Initate Data Quality & Structuring Algorithm:
    if Algo_num == 1 || Algo_num == 2
        %Create_IrradianceMeasurements_Datafile
        PV_OUT(:,3:5)=ANGLES_GHI;
        Create_SolarFarmMeasurments_Datafile
    end
    %
    %
end