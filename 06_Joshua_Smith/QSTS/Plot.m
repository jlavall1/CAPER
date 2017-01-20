clc; clear; close all;

%Load Historical DSCADA
load CAP_Mult_60s_ROX.mat
load P_Mult_60s_ROX.mat
load Q_Mult_60s_ROX.mat
load LoadTotals.mat
load ONEWEEK.mat
%%
slt_DAY_RUN=1;
if slt_DAY_RUN == 1
    %One day run on 6/18
    DAY = 18;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY;
elseif slt_DAY_RUN == 2
    %One week run
    DAY = 13;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+6; %1 week run.
end

RUN(1).SUB_P.DSS_SUB(:,1) = [YEAR_CAPSTATUS(169).SCADA.Sub_P_PhA];
RUN(1).SUB_P.DSS_SUB(:,2) = [YEAR_CAPSTATUS(169).SCADA.Sub_P_PhB];
RUN(1).SUB_P.DSS_SUB(:,3) = [YEAR_CAPSTATUS(169).SCADA.Sub_P_PhC];

RUN(1).SUB_P.REF = [CAP_OPS_STEP2(169).kW];

RUN(1).SUB_P.DIFF = RUN(1).SUB_P.DSS_SUB - RUN(1).SUB_P.REF;

RUN(1).SUB_Q.DSS_SUB(:,1) = [YEAR_CAPSTATUS(169).SCADA.Sub_Q_PhA];
RUN(1).SUB_Q.DSS_SUB(:,2) = [YEAR_CAPSTATUS(169).SCADA.Sub_Q_PhB];
RUN(1).SUB_Q.DSS_SUB(:,3) = [YEAR_CAPSTATUS(169).SCADA.Sub_Q_PhC];

RUN(1).SUB_Q.REF = [CAP_OPS_STEP1(169).data(:,1:3)];

RUN(1).SUB_Q.DER = [CAP_OPS(169).DSS];

RUN(1).SUB_Q.DIFF = RUN(1).SUB_Q.DSS_SUB - RUN(1).SUB_Q.REF;





%%
%Show 3-phase & 1-phase(faint) of three cases.
%{
fig=1;
figure(fig)
n=1;
X=[1/60:1/60:24]';
M=RUN(n).SUB_P.DSS_SUB(:,1);
plot(X,M,'b-','LineWidth',1.5);
hold on
M=RUN(n).SUB_P.DSS_SUB(:,2);
plot(X,M,'g-','LineWidth',1.5);
hold on
M=RUN(n).SUB_P.DSS_SUB(:,3);
plot(X,M,'r-','LineWidth',1.5);
hold on
M=RUN(n).SUB_P.REF(:,1);
plot(X,M,'b:','LineWidth',1.5);
hold on
M=RUN(n).SUB_P.REF(:,2);
plot(X,M,'g:','LineWidth',1.5);
hold on
M=RUN(n).SUB_P.REF(:,3);
plot(X,M,'r:','LineWidth',1.5);
hold on
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC 3-ph Real Power (P) [kW]','FontSize',12,'FontWeight','bold');
axis([0 24 1000 4000]);
set(gca,'XTick',[0:1:24])
grid on
set(gca,'FontWeight','bold');
legend('DSS(ph_A)','DSS(ph_B)','DSS(ph_C)','SCADA(ph_A)','SCADA(ph_B)','SCADA(ph_C)','location','northwest');
%}
%%
fig=2;
figure(fig)
set(gcf,'Position', [1 1 1280 1024]);
subplot(2,1,1)
n=1;
X=[1/60:1/60:24]';
M=RUN(n).SUB_Q.DSS_SUB(:,1);
plot(X,M,'b-','LineWidth',1.0);
hold on
M=RUN(n).SUB_Q.DSS_SUB(:,2);
plot(X,M,'g-','LineWidth',1.0);
hold on
M=RUN(n).SUB_Q.DSS_SUB(:,3);
plot(X,M,'r-','LineWidth',1.0);
hold on
M=RUN(n).SUB_Q.REF(:,1);
plot(X,M,'b:','LineWidth',1.0);
hold on
M=RUN(n).SUB_Q.REF(:,2);
plot(X,M,'g:','LineWidth',1.0);
hold on
M=RUN(n).SUB_Q.REF(:,3);
plot(X,M,'r:','LineWidth',1.0);
hold on
M=RUN(1).SUB_Q.DER(:,1);
plot(X,M,'b--','LineWidth',1.0);
hold on
M=RUN(1).SUB_Q.DER(:,2);
plot(X,M,'g--','LineWidth',1.0);
hold on
M=RUN(1).SUB_Q.DER(:,3);
plot(X,M,'r--','LineWidth',1.0);
hold on
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC 3-ph Reactive Power (Q) [kVAR]','FontSize',12,'FontWeight','bold');
axis([0 24 -500 1500]);
set(gca,'XTick',[0:1:24])
grid on
set(gca,'FontWeight','bold');
legend('DSS(ph_A)','DSS(ph_B)','DSS(ph_C)','SCADA(ph_A)','SCADA(ph_B)','SCADA(ph_C)','Load(ph_A)','Load(ph_B)','Load(ph_C)','location','northeastoutside');

%%
fig=3;
%figure(fig)
subplot(2,1,2)
n=1;
X=[1/60:1/60:24]';
M=RUN(n).SUB_P.DIFF(:,1);
plot(X,M,'b-','LineWidth',1.0);
hold on
M=RUN(n).SUB_P.DIFF(:,2);
plot(X,M,'g-','LineWidth',1.0);
hold on
M=RUN(n).SUB_P.DIFF(:,3);
plot(X,M,'r-','LineWidth',1.0);
hold on
M=RUN(n).SUB_Q.DIFF(:,1);
plot(X,M,'b:','LineWidth',1.0);
hold on
M=RUN(n).SUB_Q.DIFF(:,2);
plot(X,M,'g:','LineWidth',1.0);
hold on
M=RUN(n).SUB_Q.DIFF(:,3);
plot(X,M,'r:','LineWidth',1.0);
hold on

xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('Reactive Power Error (kVar)','FontSize',12,'FontWeight','bold');
axis([0 24 -500 500]);
set(gca,'XTick',[0:1:24])
grid on
set(gca,'FontWeight','bold');
legend('P(ph_A)____','P(ph_B)____','P(ph_C)____','Q(ph_A)____','Q(ph_B)____','Q(ph_C)____','location','northeastoutside');


%%
slt_DAY_RUN=2;
if slt_DAY_RUN == 1
    %One day run on 6/18
    DAY = 18;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY;
elseif slt_DAY_RUN == 2
    %One week run
    DAY = 13;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+6; %1 week run.
end

temp = [YEAR_CAPSTATUS.SCADA];
n=length(temp);
RUN(1).SUB_Q.DSS_SUB(1:n,1) = [temp.Sub_Q_PhA]';
RUN(1).SUB_Q.DSS_SUB(1:n,2) = [temp.Sub_Q_PhB]';
RUN(1).SUB_Q.DSS_SUB(1:n,3) = [temp.Sub_Q_PhC]';

temp = [YEAR_CAPSTATUS.CAP_POS;];
capPos = [temp(:,1:3);temp(:,4:6);temp(:,7:9);temp(:,10:12);temp(:,13:15);temp(:,16:18);temp(:,19:21)];

n=length(capPos);
RUN(1).CAP_OPS(1:n,1) = -546 + 50.*[capPos(:,1)];
RUN(1).CAP_OPS(1:n,2) = -492 + 50.*[capPos(:,2)];
RUN(1).CAP_OPS(1:n,3) = -600 + 50.*[capPos(:,3)];


%%
%{
fig=4;
figure(fig)
n=1;
X=[1/1440:1/1440:7]';
M=RUN(n).SUB_Q.DSS_SUB(:,1);
plot(X,M,'b-','LineWidth',1.5);
hold on
M=RUN(n).SUB_Q.DSS_SUB(:,2);
plot(X,M,'g-','LineWidth',1.5);
hold on
M=RUN(n).SUB_Q.DSS_SUB(:,3);
plot(X,M,'r-','LineWidth',1.5);
hold on
M=RUN(n).CAP_OPS(:,1);
plot(X(1:15:1440*7),M,'b-','LineWidth',1.5);
hold on
M=RUN(n).CAP_OPS(:,2);
plot(X(1:15:1440*7),M,'g-','LineWidth',1.5);
hold on
M=RUN(n).CAP_OPS(:,3);
plot(X(1:15:1440*7),M,'r-','LineWidth',1.5);
hold on


xlabel('Day of Week (DoW)','FontSize',12,'FontWeight','bold');
ylabel('Reactive Power (kVAR)','FontSize',12,'FontWeight','bold');
axis([0 7 -600 600]);
set(gca,'XTick',[0:1:7])
grid on
set(gca,'FontWeight','bold');
legend('P(ph_A)','P(ph_B)','P(ph_C)','CAP OP(ph_A)','CAP OP(ph_B)','CAP OP(ph_C)','location','northwest');
%}