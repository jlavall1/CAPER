%Show Reference SOC Examples:

clear
clc
close all
main_dir='C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\05_BESS';
addpath(main_dir);
%   Load CSI / BnCI dataset reference:
%{
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
load M_MOCKS.mat
for i=1:1:12
    M_PVSITE(i).GHI = M_MOCKS(i).GHI;
end
%}
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC');
load M_SHELBY.mat
for i=1:1:12
    M_PVSITE(i).GHI = M_SHELBY(i).GHI;
end
%battery info:
CSI_TH=0.2;
BESS.Prated=1000;
BESS.Crated=12121; %4000kWh
BESS.DoD_max=0.33;
BESS.Eff_DR=.967;
BESS.Eff_CR=.93;
%---------------------
n = 1;
DAY = 4;
MNTH = 2;
DOY=calc_DOY(MNTH,DAY);
CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
C=BESS.Crated;
[SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,BESS.DoD_max);
DAY_S(1).SOC_ref = SOC_ref;
DAY_S(1).CR_Ref = CR_ref;
%---------------------
n = n+1;
DAY = 1;
MNTH = 6;
DOY=calc_DOY(MNTH,DAY);
CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
C=BESS.Crated;
[SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,BESS.DoD_max);
DAY_S(n).SOC_ref = SOC_ref;
DAY_S(n).CR_Ref = CR_ref;
%---------------------
n = n+1;
DAY = 1;
MNTH = 10;
DOY=calc_DOY(MNTH,DAY);
CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
C=BESS.Crated;
[SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,BESS.DoD_max);
DAY_S(n).SOC_ref = SOC_ref;
DAY_S(n).CR_Ref = CR_ref;
%%
ON = 0;
for n=1:1:3
    for j=1:1:86400
        if 1-DAY_S(n).SOC_ref(j,1) < 0.0001 && ON == 0
            ON = 1;
        end
        if ON == 1
            DAY_S(n).SOC_ref(j,1) = 1;
        end
    end
    ON = 0;
end
        
%PLOT:
fig = 0;
X=[1/3600:1/3600:24]';

fig = fig + 1;
figure(fig);
plot(X,[DAY_S(1).SOC_ref],'b-','LineWidth',2);
hold on
plot(X,[DAY_S(2).SOC_ref],'r-','LineWidth',2);
hold on
plot(X,[DAY_S(3).SOC_ref],'g-','LineWidth',2);
axis([6 20 0.6 1.05]);
legend('2/4','6/1','10/1','Location','NorthWest');
set(gca,'FontWeight','bold');
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('State of Charge (SOC) [%]','FontSize',12,'FontWeight','bold');

fig = fig + 1;
figure(fig);
plot(X,[DAY_S(1).CR_Ref],'b-','LineWidth',2);
hold on
plot(X,[DAY_S(2).CR_Ref],'r-','LineWidth',2);
hold on
plot(X,[DAY_S(3).CR_Ref],'g-','LineWidth',2);
axis([6 20 0 800]);
legend('2/4','6/1','10/1','Location','NorthEast');
set(gca,'FontWeight','bold');
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('Charge Rate (CR) [kW]','FontSize',12,'FontWeight','bold');


