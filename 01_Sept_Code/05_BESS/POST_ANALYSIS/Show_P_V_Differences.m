%Show difference in BESS w/out BESS:
clear
clc
close all
main_dir='C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\BESS';

%load SOC_ref_6_1.mat
%load CR_ref_6_1.mat
%load BESS_SETTINGS_1.mat        %BESS_INFO
%RUN(1).BESS_INFO = BESS_INFO;
%load BESS_SETTINGS_152.mat
%{
load YR_SIM
RUN(2).SOC_ref = YEAR_BESS.SOC_ref';
RUN(2).CR_ref = YEAR_BESS.CR_ref';
RUN(2).CSI = YEAR_BESS.CSI;
%}
%RUN(2).BESS_INFO = BESS_INFO;

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
load BESS_SETTINGS_1.mat        %BESS_SETTINGS

RUN(n).SUB_P= YEAR_SIM_P;
RUN(n).SUB_V= YEAR_SUB;
RUN(n).BESS = YEAR_BESS;
RUN(n).SUB_TAP= YEAR_LTCSTATUS;

clear YEAR_SIM_P YEAR_SUB YEAR_BESS YEAR_LTCSTATUS BESS_INFO
%%
close all
DOY=34;
P_3H=0;
fig = 0;
fig = fig + 1;
figure(fig);
n=1;
X=[1/3600:1/3600:24]';
P_3H=RUN(n).SUB_P(DOY).DSS_SUB(:,1)+RUN(n).SUB_P(DOY).DSS_SUB(:,2)+RUN(n).SUB_P(DOY).DSS_SUB(:,3);
plot(X,P_3H,'b-','LineWidth',1.75);
n=2;
hold on
P_3H=RUN(n).SUB_P(DOY).DSS_SUB(:,1)+RUN(n).SUB_P(DOY).DSS_SUB(:,2)+RUN(n).SUB_P(DOY).DSS_SUB(:,3);
plot(X,P_3H,'r-','LineWidth',1.85);
%settings:
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC 3-ph Real Power (P) [kW]','FontSize',12,'FontWeight','bold');
axis([8 24 -1500 2500]);
legend('PV1 w/o BESS','PV1 w/ BESS','Location','SouthEast');
set(gca,'XTick',0:4:24);
set(gca,'FontWeight','bold');
grid on
%%
%--------------------------------------------------------------------------
fig = fig + 1;
figure(fig);
n=1;
V_PT=RUN(n).SUB_V(DOY).V(:,3)/60;
plot(X,V_PT,'b-','LineWidth',2);
hold on
n=2;
V_PT=RUN(n).SUB_V(DOY).V(:,3)/60;
plot(X,V_PT,'r-','LineWidth',2);
%Settings:
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC Control Voltage (V_{PT}) [V]','FontSize',12,'FontWeight','bold');
axis([8 24 123 125]);
legend('PV1 w/o BESS','PV1 w/ BESS','Location','SouthEast');
set(gca,'FontWeight','bold');
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC PT Voltage (120V BASE)','FontSize',12,'FontWeight','bold');
grid on
%%
%--------------------------------------------------------------------------
%fig = 0;
fig = fig + 1;
figure(fig);
n=1;
OLTC_P=RUN(n).SUB_TAP(DOY).TAP_POS(1,:)';
plot(X,OLTC_P,'b-','LineWidth',1.5);
hold on
n=2;
OLTC_P2=RUN(n).SUB_TAP(DOY).TAP_POS(1,:)';
plot(X,OLTC_P2,'r-','LineWidth',2);
%Settings:
TOP_T=1+2*(.2/32);
BOT_T=1-1*(.2/32);
axis([8 24 BOT_T TOP_T])
set(gca,'XTick',[0:4:24])
set(gca,'YTick',[BOT_T:(.2/32):TOP_T])
grid on
legend('PV1 w/o BESS','PV1 w/ BESS','Location','SouthEast');
set(gca,'FontWeight','bold');
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC Tap Position','FontSize',12,'FontWeight','bold');
COUNT = 0;
COUNT2 = 0;
for i=2:1:length(OLTC_P)
    if OLTC_P(i,1) ~= OLTC_P(i-1,1)
        COUNT = COUNT + 1;
    end
    if OLTC_P2(i,1) ~= OLTC_P2(i-1,1)
        COUNT2 = COUNT2 + 1;
    end
end
fprintf('Only DER-PV Generation: + %d tap changes\n',COUNT);
fprintf('Now with BESS Unit &PV: + %d tap changes\n',COUNT2);
%%
%--------------------------------------------------------------------------
fig = fig + 1;
figure(fig);
% 5sec samples;
XX=[5/3600:5/3600:6]';
XX=XX+10;
n=1;
MAX_V=RUN(n).SUB_V(DOY).max_V;
h(1)=plot(XX,MAX_V,'b-','LineWidth',2);
MIN_V=RUN(n).SUB_V(DOY).min_V;
hold on
plot(XX,MIN_V,'b--','LineWidth',2);
hold on
n=2;
MAX_V=RUN(n).SUB_V(DOY).max_V;
h(2)=plot(XX,MAX_V,'r-','LineWidth',2);
hold on
MIN_V=RUN(n).SUB_V(DOY).min_V;
plot(XX,MIN_V,'r--','LineWidth',2);
hold on
plot(XX,1.05,'k--','LineWidth',3);
%Settings:
legend([h(1) h(2)],'PV1 w/o BESS','PV1 w/ BESS','Location','NorthEast');
set(gca,'FontWeight','bold');
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('Min./Max. Observed Voltage (PU)','FontSize',12,'FontWeight','bold');
%--------------------------------------------------------------------------
%%
fig = fig + 1;
figure(fig);
%Show DSS & Commanded SOC
%RUN(2).SOC_ref = YEAR_BESS.SOC_ref';
%RUN(2).CR_ref

plot(X,[RUN(2).BESS(DOY).SOC_ref'*100],'b','LineWidth',4);
hold on
plot(X,[RUN(2).BESS(DOY).SOC]','r','LineWidth',1.5);
%hold on
%plot(X,SOC_ref*100,'c--');
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('State of Charge (SOC) [%]','FontSize',12,'FontWeight','bold');
axis([8 19 65 105]);
grid on
set(gca,'FontWeight','bold');
legend('SOC Reference','OpenDSS SOC','Location','NorthWest');
%--------------------------------------------------------------------------
%%
fig = fig + 1;
figure(fig);
%Show DSS & Commanded CR:
%RUN(2).BESS(DOY).CR(1,1)=0;

plot(X,[RUN(2).BESS(DOY).CR_ref*1.06],'b','LineWidth',4);
hold on
plot(X,[RUN(2).BESS(DOY).CR]','r','LineWidth',1.5);
%hold on
%plot(X,CR_ref,'c--');
axis([8 19 0 800]);
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('Charge Rate (CR) [kW]','FontSize',12,'FontWeight','bold');
legend('CR Reference','OpenDSS CR','Location','NorthEast');
set(gca,'FontWeight','bold');
