%This supplemental .m file will demonstrate the DR_INT constructing the
%peak shaving window of operation.
clear
clc
%-------- Load in background datasets ------------
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\05_BESS');

load M_MOCKS.mat
load M_MOCKS_SC.mat
M_PVSITE_SC_1 = M_MOCKS_SC;
for i=1:1:12
    M_PVSITE(i).GHI = M_MOCKS(i).GHI;
    M_PVSITE(i).kW = M_MOCKS(i).kW;
end
load P_Mult_60s_Flay.mat

%Adv. Lead Acid Bat. Utility T&D (S15):
BESS.Prated=1000;
BESS.Crated=12121; %4000kWh
BESS.DoD_max=0.33;
BESS.Eff_DR=.967;
BESS.Eff_CR=.93;
PV_pmpp = 3000;


%-------- Iterate through Entire Year to find ON ------------

MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,29]; %Dec = 31
for MNTH=1:1:12
    for DAY=1:1:MTH_LN(1,MNTH)
        DOY = calc_DOY(MNTH,DAY);
        
        %   Obtain current & next day kW loadsets:
        P_DAY1=CAP_OPS_STEP2(DOY).kW(:,1)+CAP_OPS_STEP2(DOY).kW(:,2)+CAP_OPS_STEP2(DOY).kW(:,3);
        P_DAY2=CAP_OPS_STEP2(DOY+1).kW(:,1)+CAP_OPS_STEP2(DOY+1).kW(:,2)+CAP_OPS_STEP2(DOY+1).kW(:,3);
        [t_max,DAY_NUM,P_max,E_kWh]=Peak_Estimator_MSTR(P_DAY1,P_DAY2);
        %   Save Results:
        Y_PEAK(DOY).DAY_NUM = DAY_NUM;
        Y_PEAK(DOY).t_max = t_max;
        Y_PEAK(DOY).P_max = P_max;
        
        DoD_tar = DoD_tar_est( M_PVSITE_SC_1(DOY+1,:),BESS,PV_pmpp);
        Y_PEAK(DOY).DoD_tar = DoD_tar;
        if MNTH == 1 && DAY == 1
            %conduct only for first day to get things going:
            if DAY_NUM == 1
                DAY_ON = DOY;
                T_MAX_HOLD=0;
                
            elseif DAY_NUM == 2
                DAY_ON = DOY+1;
                T_MAX_HOLD=t_max;
            end
            %Construct peak loading Period:
            if DOY == DAY_ON
            [peak,P_DR_ON,T_DR_ON,T_DR_OFF] = DR_INT(t_max,P_DAY1,DoD_tar,BESS,1);
            else
                %skip this day during peak shaving.
                P_DR_ON = 0;
                T_DR_ON = 0;
                T_DR_OFF = 0;
            end
            
        else
            %for next day(s):
        
            if DOY == DAY_ON
                [peak,P_DR_ON,T_DR_ON,T_DR_OFF] = DR_INT(t_max,P_DAY1,DoD_tar,BESS,1);
            else
                %skip this day during peak shaving.
                P_DR_ON = 0;
                T_DR_ON = 0;
                T_DR_OFF = 0;
            end
        
            %Update for next consectuative day:
            if DAY_NUM == 1
                DAY_ON = DOY;
                T_MAX_HOLD=0;
            elseif DAY_NUM == 2
                DAY_ON = DOY+1;
                T_MAX_HOLD=t_max;
            end
        end
        %Save more variables:
        Y_PEAK(DOY).DAY_ON = DAY_ON;
        Y_PEAK(DOY).T_DR_ON = T_DR_ON;
        

    end
end

