%DUCK CURVE EXAMPLE:
clear
clc
close all
load Y_PEAK.mat
load Y_SOLAR_COEFF.mat
load P_Mult_60s_Flay.mat

addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\05_BESS');
load M_MOCKS.mat

DOY=106;
MNTH=4;
DAY=16;
P_PV=M_MOCKS(MNTH).kW(time2int(DAY,0,0):time2int(DAY,23,59),1);
DOY_2=207; %was 207
P_DAY1=CAP_OPS_STEP2(DOY_2).kW(:,1)+CAP_OPS_STEP2(DOY_2).kW(:,2)+CAP_OPS_STEP2(DOY_2).kW(:,3);


BncI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
CSI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
BESS.Prated=1000;
BESS.Crated=12121; %4000kWh
BESS.DoD_max=0.5;
BESS.Eff_DR=.967;
BESS.Eff_CR=.93;
C = BESS.Crated;

DoD=BESS.DoD_max;
CSI_TH=0.1;
[ ~,CR_ref, t_CR ] = SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD);
CR_ref(1:23*3600,1)=CR_ref(3601:24*3600,1);
j=1;
for i=1:60:length(CR_ref)
    CR_r_1m(j,1)=CR_ref(i,1);
    j = j + 1;
end

P_PV_PU=P_PV/max(P_PV(:,1));

figure(1)
X=[1/60:1/60:24];
plot(X,P_DAY1,'Color',[0.4 0.6 0.8],'LineWidth',3);
hold on
plot(X,P_DAY1-P_PV_PU*1000,'Color',[0.6 0.4 0.2],'LineWidth',3);
hold on
plot(X,P_DAY1-P_PV_PU*2000,'Color',[0.6 0.6 0.2],'LineWidth',3);
hold on
plot(X,P_DAY1-P_PV_PU*3000,'Color',[0.6 0.8 0.2],'LineWidth',3);
hold on
X2=[1/3600:1/3600:24];
plot(X2,CR_ref,'k-','LineWidth',3);
hold on
plot(X,P_DAY1-P_PV_PU*3000+CR_r_1m,'k--','Color',[0.6 0.8 0.2],'LineWidth',2.5);



%------------------
%       SETTINGS

set(gca,'FontWeight','bold','FontSize',12);
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('Distribution Feeder Real Power (P) [kW]','FontSize',12,'FontWeight','bold');
grid on   
axis([0 24 -1000 4000]);
set(gca,'XTick',0:4:24);
h=legend('(actual)','(1MW DER-PV)','(2MW DER-PV)','(3MW DER-PV)','(BESS CR Profile)','(3MW DER-PV/BESS)','Location','NorthWest');

