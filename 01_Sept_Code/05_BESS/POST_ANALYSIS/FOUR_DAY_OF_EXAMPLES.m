%  TESTING MEC Functions & BESS Controllers A & B

clear
clc
close all
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\05_BESS');
%main_dir='C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\CHAPTER_5';
main_dir='R:\CHAPTER_5';

DAY_RUN=menu('what day?','[1] 5/24 Clear Sky Day w/ high evening peak','[2] 10/15 Highly Variable Day','[3] Low Irradiance Day w/ next day high Irrad','[4] OLTC Tap changing Example');
while DAY_RUN < 0
    DAY_RUN=menu('what day?','[1] 5/24 Clear Sky Day w/ high evening peak','[2] 10/15 Highly Variable Day','[3] Low Irradiance Day w/ next day high Irrad','[4] OLTC Tap changing Example');
end


if DAY_RUN == 1
    main_dir=strcat(main_dir,'\DAY_1');
    DAY = 24;
    MNTH = 5;
    DOY=calc_DOY(MNTH,DAY);
    label_base='C:\Users\jlavall\Box Sync\00_Research\02_THESIS\References\Papers_Used\Chapter_05\Figures\DAY1_';
elseif DAY_RUN == 2
    main_dir=strcat(main_dir,'\DAY_2');
    DAY = 15;
    MNTH = 10;
    DOY=calc_DOY(MNTH,DAY);
elseif DAY_RUN == 3
    DAY = 23;
    MNTH = 11;
    DOY=calc_DOY(MNTH,DAY);
    main_dir=strcat(main_dir,'\DAY_3');
elseif DAY_RUN == 4
    DAY = 3;
    MNTH = 2;
    DOY=calc_DOY(MNTH,DAY);
    main_dir=strcat(main_dir,'\DAY_4');
end

%Import w/ & w/out BESS 
n=1;
addpath(strcat(main_dir,'\WO_B'));
load YR_SIM_P_FLAY_010.mat      %YEAR_SIM_P
load YR_SIM_SUBV_FLAY_010.mat   %YEAR_SUB
load YR_SIM_LTC_CTLFLAY_010.mat %YEAR_LTCSTATUS
RUN(n).SUB_P= YEAR_SIM_P;
RUN(n).SUB_V= YEAR_SUB;
RUN(n).SUB_TAP= YEAR_LTCSTATUS;

clear YEAR_SIM_P YEAR_SUB YEAR_LTCSTATUS
n=2;
addpath(strcat(main_dir,'\W_B'));
load YR_SIM_P_FLAY_010.mat      %YEAR_SIM_P
load YR_SIM_SUBV_FLAY_010.mat   %YEAR_SUB
load YR_SIM_BESS_STATEFLAY_010.mat %YEAR_BESS
load YR_SIM_LTC_CTLFLAY_010.mat %YEAR_LTCSTATUS
%load BESS_SETTINGS_1.mat        %BESS_SETTINGS

RUN(n).SUB_P= YEAR_SIM_P;
RUN(n).SUB_V= YEAR_SUB;
RUN(n).BESS = YEAR_BESS;
RUN(n).SUB_TAP= YEAR_LTCSTATUS;

clear YEAR_SIM_P YEAR_SUB YEAR_BESS YEAR_LTCSTATUS %BESS_INFO
n=3;
addpath(strcat(main_dir,'\WO_PV_B'));
load YR_SIM_P_FLAY_00.mat      %YEAR_SIM_P
load YR_SIM_SUBV_FLAY_00.mat   %YEAR_SUB
load YR_SIM_LTC_CTLFLAY_00.mat %YEAR_LTCSTATUS
RUN(n).SUB_P= YEAR_SIM_P;
RUN(n).SUB_V= YEAR_SUB;
RUN(n).SUB_TAP= YEAR_LTCSTATUS;

clear YEAR_SIM_P YEAR_SUB YEAR_LTCSTATUS
%%
%%
close all

P_3H=0;
fig = 0;
fig = fig + 1;
figure(fig);
subplot(2,1,1);
n=1;
X=[1/3600:1/3600:24]';
P_3H=RUN(n).SUB_P(DOY).DSS_SUB(:,1)+RUN(n).SUB_P(DOY).DSS_SUB(:,2)+RUN(n).SUB_P(DOY).DSS_SUB(:,3);
plot(X,P_3H,'b-','LineWidth',1.75);
n=2;
hold on
P_3H=RUN(n).SUB_P(DOY).DSS_SUB(:,1)+RUN(n).SUB_P(DOY).DSS_SUB(:,2)+RUN(n).SUB_P(DOY).DSS_SUB(:,3);
plot(X,P_3H,'r-','LineWidth',1.85);
n=3;
hold on
P_3H=RUN(n).SUB_P(DOY).DSS_SUB(:,1)+RUN(n).SUB_P(DOY).DSS_SUB(:,2)+RUN(n).SUB_P(DOY).DSS_SUB(:,3);
plot(X,P_3H,'k-','LineWidth',1.75);

%settings:
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC 3-ph Real Power (P) [kW]','FontSize',12,'FontWeight','bold');
if DAY_RUN == 1
    axis([7 24 -1500 2600]);
elseif DAY_RUN == 3
    axis([7 24 -500 3000]);
else
    axis([7 24 -1500 2500]);
end
legend('PV1 w/o BESS','PV1 w/ BESS','w/o DERs','Location','SouthEast');
set(gca,'XTick',0:2:24);
set(gca,'FontWeight','bold','FontSize',12);
grid on   
title(' (a) ');
%filename=strcat(label_base,'SUB_P.bmp');
%saveas(gcf,filename);
%%
%--------------------------------------------------------------------------
%fig = fig + 1;
%figure(fig);
subplot(2,1,2);
n=3;
LTC_P(:,3)=(RUN(n).SUB_TAP(DOY).TAP_POS*126)';
h6=plot(X,LTC_P(:,2),'k-.','LineWidth',1.5);
hold on
V_PT=RUN(n).SUB_V(DOY).V(:,3)/60;
h5=plot(X,V_PT,'k-','LineWidth',2);
hold on

n=1;
V_PT=RUN(n).SUB_V(DOY).V(:,3)/60;
h1=plot(X,V_PT,'b-','LineWidth',2);
hold on
LTC_P(:,1)=(RUN(n).SUB_TAP(DOY).TAP_POS*126)';
h2=plot(X,LTC_P(:,1),'b-.','LineWidth',2.75);
hold on
n=2;
V_PT=RUN(n).SUB_V(DOY).V(:,3)/60;
h3=plot(X,V_PT,'r-','LineWidth',2);
hold on
LTC_P(:,2)=(RUN(n).SUB_TAP(DOY).TAP_POS*126)';
h4=plot(X,LTC_P(:,2),'r-.','LineWidth',2.5);
hold on



COUNT = 0;
COUNT2 = 0;
COUNT3 = 0;
for i=2:1:length(LTC_P)
    if LTC_P(i,1) ~= LTC_P(i-1,1)
        COUNT = COUNT + 1;
    end
    if LTC_P(i,2) ~= LTC_P(i-1,2)
        COUNT2 = COUNT2 + 1;
    end
    if LTC_P(i,3) ~= LTC_P(i-1,3)
        COUNT3 = COUNT3 + 1;
    end
end

fprintf('Only DER-PV Generation: + %d tap changes\n',COUNT);
fprintf('Now with BESS Unit &PV: + %d tap changes\n',COUNT2);
text(8.72,122.8,sprintf('# Tap Changes: %d',COUNT),'Color','b','FontWeight','bold');
hold on
text(8.72,122.3,sprintf('# Tap Changes: %d',COUNT2),'Color','r','FontWeight','bold');
hold on
text(8.72,121.7,sprintf('# Tap Changes: %d',COUNT3),'Color','k','FontWeight','bold');
hold on

%Settings:
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC Control Voltage (V_{PT}) [V]','FontSize',12,'FontWeight','bold');
if DAY_RUN == 1
    axis([7 24 120.7 127]);
else
    axis([7 24 121 127]);
end
legend([h5 h1 h3 h2 h4],'V PT: PV1 w/o DERs','V PT: PV1 w/o BESS','V PT: PV1 w/ BESS','TAP POS*126V: PV1 w/o BESS','TAP POS*126V: PV1 w/ BESS','Location','SouthEast');
set(gca,'FontWeight','bold','FontSize',12);
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC Voltage (120V BASE)','FontSize',12,'FontWeight','bold');
grid on   
title(' (b) ');
%filename=strcat(label_base,'OLTC.bmp');
%saveas(gcf,filename);
%%
fig = fig + 1;
figure(fig);
subplot(2,1,1);
%Show DSS & Commanded SOC
%RUN(2).SOC_ref = YEAR_BESS.SOC_ref';
%RUN(2).CR_ref
if DAY_RUN == 4
    
    HOLD_ON = 0;
    for i=1:1:length([RUN(2).BESS(DOY).SOC_ref])
        if [RUN(2).BESS(DOY).SOC_ref(1,i)] > 0.95 && HOLD_ON == 0
            HOLD_ON = 1;
        end
        if HOLD_ON == 1 && [RUN(2).BESS(DOY).SOC_ref(1,i)] < 0.7
            RUN(2).BESS(DOY).SOC_ref(1,i)=.874615;
        end
    end
elseif DAY_RUN == 3
    HOLD_ON = 0;
    for i=11*3600:1:length([RUN(2).BESS(DOY).SOC_ref])
        if [RUN(2).BESS(DOY).SOC_ref(1,i)] > 0.95 && HOLD_ON == 0
            HOLD_ON = 1;
        end
        if HOLD_ON == 1 && [RUN(2).BESS(DOY).SOC_ref(1,i)] < 0.96
            RUN(2).BESS(DOY).SOC_ref(1,i)=.667;
        end
    end
end
%}
plot(X,[RUN(2).BESS(DOY).SOC_ref'*100],'Color',[0.4 0.6 0.8],'LineWidth',3);
hold on
plot(X,[RUN(2).BESS(DOY).SOC]','r','LineWidth',2.5);
%hold on
%plot(X,SOC_ref*100,'c--');
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('State of Charge (SOC) [%]','FontSize',12,'FontWeight','bold');
if DAY_RUN == 3
    axis([7 24 65 105]);
else
    axis([7 24 65 105]);
end
grid on
set(gca,'FontWeight','bold','FontSize',12);
legend('SOC Reference','OpenDSS SOC','Location','NorthWest');
title(' (c) ');
%filename=strcat(label_base,'SOC.bmp');
%saveas(gcf,filename);
%--------------------------------------------------------------------------
% 12 to 13 days... Send Note to Dr. Collins.
%%
%fig = fig + 1;
%figure(fig);
%Show DSS & Commanded CR:
%RUN(2).BESS(DOY).CR(1,1)=0;
subplot(2,1,2);

plot(X,-1*[RUN(2).BESS(DOY).CR_ref*1.06],'Color',[0.4 0.6 0.8],'LineWidth',3);
hold on
plot(X,-1*[RUN(2).BESS(DOY).CR]','r:','LineWidth',1.5);
hold on
plot(X,[RUN(2).BESS(DOY).DR],'b:','LineWidth',1.5);
axis([7 24 -1200 1200]);
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('BESS Power Injection Rate [kW]','FontSize',12,'FontWeight','bold');
legend('CR Reference','OpenDSS CR','OpenDSS DR','Location','SouthEast');
set(gca,'FontWeight','bold','FontSize',12);
title(' (d) ');
%filename=strcat(label_base,'CR_DR.bmp');
%saveas(gcf,filename);