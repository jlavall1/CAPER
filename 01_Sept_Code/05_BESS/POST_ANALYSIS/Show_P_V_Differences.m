%Show difference in BESS w/out BESS:
clear
clc
close all
main_dir='C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\BESS';

n=1;
addpath(strcat(main_dir,'\POI_1_NBESS'));
load YR_SIM_P_FLAY_010.mat      %YEAR_SIM_P
load YR_SIM_SUBV_FLAY_010.mat   %YEAR_SUB
load YR_SIM_LTC_CTLFLAY_010.mat %YEAR_LTCSTATUS

RUN(n).SUB_P= YEAR_SIM_P;
RUN(n).SUB_V= YEAR_SUB;
RUN(n).SUB_TAP= YEAR_LTCSTATUS;
clear YEAR_SIM_P YEAR_SUB YEAR_LTCSTATUS

n=n+1;
addpath(strcat(main_dir,'\POI_1_BESS'));
load YR_SIM_P_FLAY_010.mat      %YEAR_SIM_P
load YR_SIM_SUBV_FLAY_010.mat   %YEAR_SUB
load YR_SIM_BESS_STATEFLAY_010.mat %YEAR_BESS
load YR_SIM_LTC_CTLFLAY_010.mat %YEAR_LTCSTATUS

RUN(n).SUB_P= YEAR_SIM_P;
RUN(n).SUB_V= YEAR_SUB;
RUN(n).BESS = YEAR_BESS;
RUN(n).SUB_TAP= YEAR_LTCSTATUS;
clear YEAR_SIM_P YEAR_SUB YEAR_BESS YEAR_LTCSTATUS
%%
DOY=152;
P_3H=0;
fig = 0;
fig = fig + 1;
figure(fig);
n=1;
X=[1/3600:1/3600:24]';
P_3H=RUN(n).SUB_P(DOY).DSS_SUB(:,1)+RUN(n).SUB_P(DOY).DSS_SUB(:,2)+RUN(n).SUB_P(DOY).DSS_SUB(:,3);
plot(X,P_3H,'b-');
n=2;
hold on
P_3H=RUN(n).SUB_P(DOY).DSS_SUB(:,1)+RUN(n).SUB_P(DOY).DSS_SUB(:,2)+RUN(n).SUB_P(DOY).DSS_SUB(:,3);
plot(X,P_3H,'r-');
%settings:
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC 3-ph Real Power (P) [kW]','FontSize',12,'FontWeight','bold');
axis([0 24 -1500 2500]);
legend('PV1 w/o BESS','PV1 w/ BESS','Location','SouthWest');
set(gca,'XTick',0:4:24);
grid on
%--------------------------------------------------------------------------
fig = fig + 1;
figure(fig);
n=1;
V_PT=RUN(n).SUB_V(DOY).V(:,3)/60;
plot(X,V_PT,'b-');
hold on
n=2;
V_PT=RUN(n).SUB_V(DOY).V(:,3)/60;
plot(X,V_PT,'r-');
%Settings:
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC Control Voltage (V_{PT}) [V]','FontSize',12,'FontWeight','bold');
axis([0 24 123 125]);
legend('PV1 w/o BESS','PV1 w/ BESS','Location','SouthWest');
%--------------------------------------------------------------------------
fig = fig + 1;
figure(fig);
n=1;
OLTC_P=RUN(n).SUB_TAP(DOY).TAP_POS(:,1);
plot(X,OLTC_P,'b-');
hold on
n=2;
OLTC_P=RUN(n).SUB_TAP(DOY).TAP_POS(:,1);
plot(X,OLTC_P,'r-');
%}
legend('PV1 w/o BESS','PV1 w/ BESS','Location','SouthWest');
axis([0 24 0.99 1.01]);
%--------------------------------------------------------------------------
fig = fig + 1;
figure(fig);
% 5sec samples;
XX=[5/3600:5/3600:6]';
XX=XX+10;
n=1;
MAX_V=RUN(n).SUB_V(DOY).max_V;
plot(XX,MAX_V,'b-');
hold on
n=2;
MAX_V=RUN(n).SUB_V(DOY).max_V;
plot(XX,MAX_V,'r-');
hold on
plot(XX,1.05,'k--','LineWidth',3);
%Settings:
legend('PV1 w/o BESS','PV1 w/ BESS','Location','SouthWest');
