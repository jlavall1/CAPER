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
    elseif PV_Site == 3
        PV_Site_path6 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\06_OldDominion_NC';
        addpath(PV_Site_path6);
    elseif PV_Site == 4
        PV_Site_path7 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\07_MayBerry_NC';
        addpath(PV_Site_path6);
    end
    
    
    %1]
    %
    %Initate Data Quality & Structuring Algorithm:
    if Algo_num == 1 || Algo_num == 2
        %Create_IrradianceMeasurements_Datafile
        PV_OUT(:,3:5)=ANGLES_GHI(:,1:3);
        Create_SolarFarmMeasurments_Datafile
    end
    
    
    %2]VI_CI_DARR.m
    %
    if Algo_num == 1 || Algo_num == 3
        if PV_Site == 1     %Mocksville
            load M_MOCKS.mat
            M_PVSITE = M_MOCKS;
            %Closest irradiance dataset:
            load M_TAYLOR.mat
            M_PSEUDO = M_TAYLOR;
            
            load M_TAYLOR_SC.mat
            Solar_Constants = M_TAYLOR_SC;
        elseif PV_Site == 2 %Ararat Rock
            load M_AROCK.mat
            M_PVSITE = M_AROCK;
            %Closest irradiance dataset:
            load M_TAYLOR.mat
            M_PSEUDO = M_TAYLOR;
            
            load M_TAYLOR_SC.mat
            Solar_Constants = M_TAYLOR_SC;
        elseif PV_Site == 3 %Old Dom
            %load M_TAYLOR.mat
            %M_PVSITE = M_TAYLOR;
        elseif PV_Site == 4 %MayBerry
            %load M_TAYLOR.mat
            %M_PVSITE = M_TAYLOR;
        end
        %
        %Initate DARR Calculations:
        clc
        Find_DARR
    end
    
    %3]Pre_PV_Ramping.m
    %
    if Algo_num == 1 || Algo_num == 4
        clc
        fprintf('Pre_PV_Ramping\n');
        %Load Appropriate Data:
        if PV_Site == 1
            %   Mocksville:
            PV_Site_path4 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC';
            addpath(PV_Site_path4);
            load M_MOCKS.mat
            load M_MOCKS_SC.mat
            M_PVSITE = M_MOCKS;    %make general --
            M_PVSITE_SC = M_MOCKS_SC;
            PV1_MW.name = 'Mocksville Solar Farm';
            PV1_MW.kW = 4500;
        elseif PV_Site == 2
            %   Ararat Rock:
            PV_Site_path5 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\05_AraratRock_NC';
            addpath(PV_Site_path5);
            load M_AROCK.mat
            load M_AROCK_SC.mat
            M_PVSITE = M_AROCK;
            M_PVSITE_SC = M_AROCK_SC;
            PV1_MW.name = 'Ararat Rock Solar Farm';
            PV1_MW.kW = 3500;
        end
        %
        %Initiate .m File:
        addpath(BASE_path);
        Pre_PV_Ramping
    end
        
end