%Start of Irradiance / PV - kW Output Analysis:
clear
clc
close all
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
    if Algo_num <= 3 %only will hit if 'ALL' or '1) DATA import' has been selected
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
            PV1_MW.name = 'Shelby';
            PV1_MW.kW = 1000;
        elseif PV_Site == 2
            load M_MURPHY.mat
            M_PVSITE = M_MURPHY;
            PV1_MW.name = 'Murphy';
            PV1_MW.kW = 1000;
        elseif PV_Site == 3
            load M_TAYLOR.mat
            M_PVSITE = M_TAYLOR;
            PV1_MW.name = 'Taylorsville';
            PV1_MW.kW = 1000;
        end
        %
        %Initate VI CI DARR Calculations:
        clc
        Find_VI_CI_DARR
    end
    
    
    %3]Pre_PV_Ramping.m
    %
    if Algo_num == 1 || Algo_num == 4 || Algo_num == 5
        clc
        %Load Appropriate Data:
        if PV_Site == 1
            PV_Site_path1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC';
            addpath(PV_Site_path1);
            load M_SHELBY.mat
            load M_SHELBY_SC.mat
            %make general --
            if Algo_num == 5
                for i=1:1:12
                    M_PVSITE(i).DAY(:,:) = M_SHELBY(i).DAY(1:end-1,1:6);    
                    M_PVSITE(i).RR_1MIN(:,:) = M_SHELBY(i).RR_1MIN(:,1:3);
                end
                load M_SHELBY_INFO.mat
                M_PVSITE_INFO = M_SHELBY_INFO;
                clearvars M_SHELBY_INFO
            else %Algo_num == 4
                M_PVSITE = M_SHELBY;    
            end
            M_PVSITE_SC = M_SHELBY_SC;
            clearvars M_SHELBY M_SHELBY_SC
            %site informat --
            PV1_MW.name = 'Shelby';
            PV1_MW.kW = 1000;
        elseif PV_Site == 2
            PV_Site_path2 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\02_Murphy_NC';
            addpath(PV_Site_path2);
            load M_MURPHY.mat
            load M_MURPHY_SC.mat
            %make general --
            if Algo_num == 5
                for i=1:1:12
                    M_PVSITE(i).DAY(:,:) = M_MURPHY(i).DAY(1:end-1,1:6);    
                    M_PVSITE(i).RR_1MIN(:,:) = M_MURPHY(i).RR_1MIN(:,1:3);
                end
                load M_MURPHY_INFO.mat
                M_PVSITE_INFO = M_MURPHY_INFO;
                clearvars M_MURPHY_INFO
            else
                M_PVSITE = M_MURPHY;        
            end
            M_PVSITE_SC = M_MURPHY_SC;
            clearvars M_MURPHY M_MURPHY_SC
            %site informat --
            PV1_MW.name = 'Murphy';
            PV1_MW.kW = 1000;
        elseif PV_Site == 3
            PV_Site_path3 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\03_Taylorsville_NC';
            addpath(PV_Site_path3);
            load M_TAYLOR.mat
            load M_TAYLOR_SC.mat
            %make general --
            if Algo_num == 5
                for i=1:1:12
                    M_PVSITE(i).DAY(:,:) = M_TAYLOR(i).DAY(1:end-1,1:6);    
                    M_PVSITE(i).RR_1MIN(:,:) = M_TAYLOR(i).RR_1MIN(:,1:3);
                end
                load M_TAYLOR_INFO.mat
                M_PVSITE_INFO = M_TAYLOR_INFO;
                clearvars M_TAYLOR_INFO
            else 
                M_PVSITE = M_TAYLOR;
            end
            M_PVSITE_SC = M_TAYLOR_SC;
            clearvars M_TAYLOR M_TAYLOR_SC
            %site informat --
            PV1_MW.name = 'Taylorsville';
            PV1_MW.kW = 1000;
        end
        %
        %Initiate .m File:
        addpath(BASE_path);
        if Algo_num == 1 || Algo_num == 4
            Pre_PV_Ramping
            fprintf('Pre_PV_Ramping Initiated\n');
        end
        if Algo_num == 1 || Algo_num == 5
            %Generate CDFs:
            CDF_calc
            fprintf('CDF Calculation Initiated\n');
        end
    end

elseif sim_type == 2
    %%
    if Algo_num <= 3 %only will hit if 'ALL' or '1) DATA import' has been selected
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
            [PV_OUT,Date,~] = xlsread('oldDOM_1_5MW.xlsx','oldDOM'); %Power kW ; R.Power kVAR ; RECL Status
            %Load Solar Angles.mat file --
            load TAYLOR_GHI.mat %imports ANGLES_GHI  (THIS SHOULD BE SHELBY)
        elseif PV_Site == 4
            PV_Site_path7 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\07_MayBerry_NC';
            addpath(PV_Site_path7);
            [PV_OUT,Date,~] = xlsread('MayBRY_1MW.xlsx','Mayberry'); %Power kW ; R.Power kVAR ; RECL Status
            %Load Solar Angles.mat file --
            load TAYLOR_GHI.mat %imports ANGLES_GHI  (THIS SHOULD BE SHELBY)
        end
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
            PV1_MW.name = 'Mocksville';
            PV1_MW.kW = 4653; %5MW
            %Closest irradiance dataset:
            load M_TAYLOR.mat
            M_PSEUDO = M_TAYLOR;
            load M_TAYLOR_SC.mat
            M_PVSITE_SC = M_TAYLOR_SC;

        elseif PV_Site == 2 %Ararat Rock
            load M_AROCK.mat
            M_PVSITE = M_AROCK;
            PV1_MW.name = 'Ararat Rock';
            PV1_MW.kW = 3500;
            %Closest irradiance dataset:
            load M_TAYLOR.mat
            M_PSEUDO = M_TAYLOR;
            load M_TAYLOR_SC.mat
            M_PVSITE_SC = M_TAYLOR_SC;
            
        elseif PV_Site == 3 %Old Dom
            load M_ODOM.mat
            M_PVSITE = M_ODOM;
            PV1_MW.name = 'Old Dominion';
            PV1_MW.kW = 1500;
            %Closest irradiance dataset:
            load M_SHELBY.mat
            M_PSEUDO = M_SHELBY;
            load M_SHELBY_SC.mat
            M_PVSITE_SC = M_SHELBY_SC;
            
        elseif PV_Site == 4 %MayBerry
            load M_MAYB.mat
            M_PVSITE = M_MAYB;
            PV1_MW.name = 'Mayberry Solar Farm';
            PV1_MW.kW = 1000;
            %Closest irradiance dataset:
            load M_TAYLOR.mat
            M_PSEUDO = M_TAYLOR;
            load M_TAYLOR_SC.mat
            M_PVSITE_SC = M_TAYLOR_SC;
            
        end
        %
        %Initate DARR Calculations:
        clc
        fprintf('Solar Constants Initiated\n');
        Find_DARR
    end
    
    %3]Pre_PV_Ramping.m
    %
    if Algo_num == 1 || Algo_num == 4 || Algo_num == 5
        clc          
        fprintf('Pre_PV_Ramping\n');
        %Load Appropriate Data:
        if PV_Site == 1
            %   Mocksville:
            PV_Site_path4 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC';
            addpath(PV_Site_path4);
            load M_MOCKS.mat
            load M_MOCKS_SC.mat
            %make general --
            if Algo_num == 5
                for i=1:1:12
                    M_PVSITE(i).DAY(:,:) = M_MOCKS(i).DAY(1:end-1,1:6);    
                    M_PVSITE(i).RR_1MIN(:,:) = M_MOCKS(i).RR_1MIN(:,1:3);
                end
                load M_MOCKS_INFO.mat
                M_PVSITE_INFO = M_MOCKS_INFO;
                clearvars M_MOCKS_INFO
            else %Algo_num == 4
                M_PVSITE = M_MOCKS;    
            end
            M_PVSITE_SC = M_MOCKS_SC;
            clearvars M_MOCKS M_MOCKS_SC
            %site informat --
            PV1_MW.name = 'Mocksville';
            PV1_MW.kW = 5000;
            
        elseif PV_Site == 2
            %   Ararat Rock:
            PV_Site_path5 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\05_AraratRock_NC';
            addpath(PV_Site_path5);
            load M_AROCK.mat
            load M_AROCK_SC.mat
            %make general --
            if Algo_num == 5
                for i=1:1:12
                    M_PVSITE(i).DAY(:,:) = M_AROCK(i).DAY(1:end-1,1:6);    
                    M_PVSITE(i).RR_1MIN(:,:) = M_AROCK(i).RR_1MIN(:,1:3);
                end
                load M_AROCK_INFO.mat
                M_PVSITE_INFO = M_AROCK_INFO;
                clearvars M_AROCK_INFO
            else %Algo_num == 4
                M_PVSITE = M_AROCK;    
            end
            M_PVSITE_SC = M_AROCK_SC;
            clearvars M_AROCK M_AROCK_SC
            %site informat --
            PV1_MW.name = 'Ararat Rock';
            PV1_MW.kW = 3500;
        elseif PV_Site == 3
            %   Old Dominion:
            PV_Site_path6 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\06_OldDominion_NC';
            addpath(PV_Site_path6);
            load M_ODOM.mat
            load M_ODOM_SC.mat
            %make general --
            if Algo_num == 5
                for i=1:1:12
                    M_PVSITE(i).DAY(:,:) = M_ODOM(i).DAY(1:end-1,1:6);    
                    M_PVSITE(i).RR_1MIN(:,:) = M_ODOM(i).RR_1MIN(:,1:3);
                end
                load M_ODOM_INFO.mat
                M_PVSITE_INFO = M_ODOM_INFO;
                clearvars M_ODOM_INFO
            else %Algo_num == 4
                M_PVSITE = M_ODOM;    
            end
            M_PVSITE_SC = M_ODOM_SC;
            %site informat --
            PV1_MW.name = 'Old Dominion';
            PV1_MW.kW = 1500;
        elseif PV_Site == 4
            %   Mayberry Farm:
            PV_Site_path7 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\07_MayBerry_NC';
            addpath(PV_Site_path7);
            load M_MAYB.mat
            load M_MAYB_SC.mat
            %make general --
            if Algo_num == 5
                for i=1:1:12
                    M_PVSITE(i).DAY(:,:) = M_MAYB(i).DAY(1:end-1,1:6);    
                    M_PVSITE(i).RR_1MIN(:,:) = M_MAYB(i).RR_1MIN(:,1:3);
                end
                load M_MAYB_INFO.mat
                M_PVSITE_INFO = M_MAYB_INFO;
                clearvars M_MAYB_INFO
            else %Algo_num == 4
                M_PVSITE = M_MAYB;    
            end
            M_PVSITE_SC = M_MAYB_SC;
            %site informat --
            PV1_MW.name = 'Mayberry Farm';
            PV1_MW.kW = 1000;
        end   
        %
        %Initiate .m File:
        addpath(BASE_path);
        if Algo_num == 1 || Algo_num == 4
            Pre_PV_Ramping
            fprintf('Pre_PV_Ramping Initiated\n');
        end
        if Algo_num == 1 || Algo_num == 5
            %Generate CDFs:
            CDF_calc
            fprintf('CDF Calculation Initiated\n');
        end
    end
        
end