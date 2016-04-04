%This is to select which days to simulate....
clear
clc
close all
load Y_PEAK.mat
load Y_SOLAR_COEFF.mat

addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\05_BESS');
load M_MOCKS.mat
BESS.Prated=1000;
BESS.Crated=12121; %4000kWh
BESS.DoD_max=0.33;
BESS.Eff_DR=.967;
BESS.Eff_CR=.93;
C = BESS.Crated;

CSI_TH=0.1;
n=1;
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
for MNTH=1:1:12
    for DAY=1:1:MTH_LN(MNTH)
        BncI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
        CSI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
        DoD=BESS.DoD_max;
        [ SOC_ref(n,:) ,CR_ref(n,:), t_CR(n,:) ] = SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD);
        n = n + 1;
    end
    
end
        
        



