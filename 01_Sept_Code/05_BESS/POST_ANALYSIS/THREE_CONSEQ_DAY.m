%   This is plottind code for the first (3) Day conseq. RUN:

clear
clc
close all
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\05_BESS');
main_dir='R:\CHAPTER_5';

DAY_RUN=menu('what day?','[1] 2/3 - 2/5','[2] TBA');
while DAY_RUN < 0
    DAY_RUN=menu('what day?','[1] 2/3 - 2/5','[2] TBA');
end

if DAY_RUN == 1
    main_dir=strcat(main_dir,'\3_DAY_RUN_1');
    DAY = 3;
    MNTH = 2;
    DOY=calc_DOY(MNTH,DAY);
    %label_base='C:\Users\jlavall\Box Sync\00_Research\02_THESIS\References\Papers_Used\Chapter_05\Figures\DAY1_';
end
%Import w/ & w/out BESS 
n=1;
addpath(strcat(main_dir,'\WO_B'));
load YR_SIM_P_FLAY_010.mat      %YEAR_SIM_P
load YR_SIM_SUBV_FLAY_010.mat   %YEAR_SUB
load YR_SIM_LTC_CTLFLAY_010.mat %YEAR_LTCSTATUS
RUN(n).SUB_P= YEAR_SIM_P(DOY:DOY+2);
RUN(n).SUB_V= YEAR_SUB(DOY:DOY+2);
RUN(n).SUB_TAP= YEAR_LTCSTATUS(DOY:DOY+2);

clear YEAR_SIM_P YEAR_SUB YEAR_LTCSTATUS

n=2;
addpath(strcat(main_dir,'\W_B'));
load YR_SIM_P_FLAY_010.mat      %YEAR_SIM_P
load YR_SIM_SUBV_FLAY_010.mat   %YEAR_SUB
load YR_SIM_BESS_STATEFLAY_010.mat %YEAR_BESS
load YR_SIM_LTC_CTLFLAY_010.mat %YEAR_LTCSTATUS

RUN(n).SUB_P= YEAR_SIM_P(DOY:DOY+2);
RUN(n).SUB_V= YEAR_SUB(DOY:DOY+2);
RUN(n).BESS = YEAR_BESS(DOY:DOY+2);
RUN(n).SUB_TAP= YEAR_LTCSTATUS(DOY:DOY+2);
clear YEAR_SIM_P YEAR_SUB YEAR_BESS YEAR_LTCSTATUS

n=3;
addpath(strcat(main_dir,'\WO_PV_B'));
load YR_SIM_P_FLAY_00.mat      %YEAR_SIM_P
load YR_SIM_SUBV_FLAY_00.mat   %YEAR_SUB
load YR_SIM_LTC_CTLFLAY_00.mat %YEAR_LTCSTATUS
RUN(n).SUB_P= YEAR_SIM_P(DOY:DOY+2);
RUN(n).SUB_V= YEAR_SUB(DOY:DOY+2);
RUN(n).SUB_TAP= YEAR_LTCSTATUS(DOY:DOY+2);

clear YEAR_SIM_P YEAR_SUB YEAR_LTCSTATUS

%%
fig =1;
figure(fig);
X=[1/3600:1/3600:24]';
subplot(2,1,1);
for D_SEL=1:1:3
    n=1;
    P_3H=RUN(n).SUB_P(D_SEL).DSS_SUB(:,1)+RUN(n).SUB_P(D_SEL).DSS_SUB(:,2)+RUN(n).SUB_P(D_SEL).DSS_SUB(:,3);
    plot(X,P_3H,'b-','LineWidth',1.75);
    hold on
    
    n=2;
    P_3H=RUN(n).SUB_P(D_SEL).DSS_SUB(:,1)+RUN(n).SUB_P(D_SEL).DSS_SUB(:,2)+RUN(n).SUB_P(D_SEL).DSS_SUB(:,3);
    plot(X,P_3H,'r-','LineWidth',1.85);
    hold on
    
    n=3;
    P_3H=RUN(n).SUB_P(D_SEL).DSS_SUB(:,1)+RUN(n).SUB_P(D_SEL).DSS_SUB(:,2)+RUN(n).SUB_P(D_SEL).DSS_SUB(:,3);
    plot(X,P_3H,'k-','LineWidth',1.75);
    hold on
    plot([max(X) max(X)],[-2000 4000],'k-','LineWidth',2);
    hold on
    X=X+24;
end
%settings:
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC 3-ph Real Power (P) [kW]','FontSize',12,'FontWeight','bold');
legend('PV1 w/o BESS','PV1 w/ BESS','w/o DERs','Location','South');
set(gca,'XTick',0:4:24*3);
axis([0 72 -2000 3200]);
set(gca,'FontWeight','bold','FontSize',12);
grid on   
title(' (a) ');
%
subplot(2,1,2);

%fig = fig + 1;
%figure(fig);
X=[1/3600:1/3600:24]';
for D_SEL=1:1:3
    %--- BASE CASE DAY RUN
    n=3;
    LTC_P(:,3)=(RUN(n).SUB_TAP(D_SEL).TAP_POS*126)';
    h6=plot(X,LTC_P(:,3),'k-.','LineWidth',1.5);
    hold on
    V_PT=RUN(n).SUB_V(D_SEL).V(:,3)/60;
    h5=plot(X,V_PT,'k-','LineWidth',2);
    hold on
    
    %--- W/O BESS
    n=1;
    V_PT=RUN(n).SUB_V(D_SEL).V(:,3)/60;
    h1=plot(X,V_PT,'b-','LineWidth',2);
    hold on
    LTC_P(:,1)=(RUN(n).SUB_TAP(D_SEL).TAP_POS*126)';
    h2=plot(X,LTC_P(:,1),'b-.','LineWidth',2.75);
    hold on
    
    %--- WITH BESS
    n=2;
    V_PT=RUN(n).SUB_V(D_SEL).V(:,3)/60;
    h3=plot(X,V_PT,'r-','LineWidth',2);
    hold on
    LTC_P(:,2)=(RUN(n).SUB_TAP(D_SEL).TAP_POS*126)';
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
    %LTC_C(D_SEL,1)=COUNT;
    %LTC_C(D_SEL,2)=COUNT2;
    %LTC_C(D_SEL,3)=COUNT3;
    text(8.72+(max(X)-24),122.8,sprintf('# Tap Changes: %d',COUNT),'Color','b','FontWeight','bold');
    hold on
    text(8.72+(max(X)-24),122.3,sprintf('# Tap Changes: %d',COUNT2),'Color','r','FontWeight','bold');
    hold on
    text(8.72+(max(X)-24),121.7,sprintf('# Tap Changes: %d',COUNT3),'Color','k','FontWeight','bold');
    hold on
    plot([max(X) max(X)],[120 135],'k-','LineWidth',2);
    hold on
    X = X + 24;
end




%Settings:
legend([h5 h1 h3 h2 h4],'V PT: PV1 w/o DERs','V PT: PV1 w/o BESS','V PT: PV1 w/ BESS','TAP POS*126V: PV1 w/o BESS','TAP POS*126V: PV1 w/ BESS','Location','North');
set(gca,'FontWeight','bold','FontSize',12);
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC Voltage (120V BASE)','FontSize',12,'FontWeight','bold');
grid on   
title(' (b) ');
axis([0 72 121 132]);
set(gca,'XTick',0:4:24*3);





%%
fig = fig + 1;
figure(fig)
subplot(2,1,1);

%Fix SOC Reference Line:
D_SEL=1;
HOLD_ON = 0;
for i=1:1:length([RUN(2).BESS(D_SEL).SOC_ref])
    if [RUN(2).BESS(D_SEL).SOC_ref(1,i)] > 0.95 && HOLD_ON == 0
        HOLD_ON = 1;
    end
    if HOLD_ON == 1 && [RUN(2).BESS(D_SEL).SOC_ref(1,i)] < 0.7
        RUN(2).BESS(D_SEL).SOC_ref(1,i)=.874615;
    end
end
D_SEL=2;
HOLD_ON = 0;
for i=1:1:length([RUN(2).BESS(D_SEL).SOC_ref])
    if [RUN(2).BESS(D_SEL).SOC_ref(1,i)] > 0.95 && HOLD_ON == 0
        HOLD_ON = 1;
    end
    if HOLD_ON == 1 && [RUN(2).BESS(D_SEL).SOC_ref(1,i)] < 0.9
        RUN(2).BESS(D_SEL).SOC_ref(1,i)=1;
    end
end
D_SEL=3;
HOLD_ON = 0;
for i=1:1:length([RUN(2).BESS(D_SEL).SOC_ref])
    
    if [RUN(2).BESS(D_SEL).SOC_ref(1,i)] > 0.95 && HOLD_ON == 0
        HOLD_ON = 1;
    end
    if HOLD_ON == 1 && [RUN(2).BESS(D_SEL).SOC_ref(1,i)] < 0.9
        RUN(2).BESS(D_SEL).SOC_ref(1,i)=1;
    end
    
    if i < 19446
        RUN(2).BESS(D_SEL).SOC_ref(1,i)=1;
    end
    
    
end


X=[1/3600:1/3600:24]';
for D_SEL=1:1:3
    plot(X,[RUN(2).BESS(D_SEL).SOC_ref'*100],'Color',[0.4 0.6 0.8],'LineWidth',3);
    hold on
    plot(X,[RUN(2).BESS(D_SEL).SOC]','r','LineWidth',2.5);
    hold on
    plot([max(X) max(X)],[60 105],'k-','LineWidth',2);
    hold on
    X = X + 24;
end
%Settings:
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('State of Charge (SOC) [%]','FontSize',12,'FontWeight','bold');
axis([0 24*3 65 105]);
set(gca,'XTick',0:4:24*3);
grid on
set(gca,'FontWeight','bold','FontSize',12);
legend('SOC Reference','OpenDSS SOC','Location','NorthWest');
title(' (c) ');


%fig = fig + 1;
%figure(fig);
subplot(2,1,2);
X=[1/3600:1/3600:24]';

for D_SEL=1:1:3
    plot(X,-1*[RUN(2).BESS(D_SEL).CR_ref*1.06],'Color',[0.4 0.6 0.8],'LineWidth',3);
    hold on
    plot(X,-1*[RUN(2).BESS(D_SEL).CR]','r:','LineWidth',1.5);
    hold on
    plot(X,[RUN(2).BESS(D_SEL).DR],'b:','LineWidth',1.5);
    hold on
    plot([max(X) max(X)],[-1200 1200],'k-','LineWidth',2);
    hold on
    X=X+24;
end




xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('BESS Power Injection Rate [kW]','FontSize',12,'FontWeight','bold');
legend('CR Reference','OpenDSS CR','OpenDSS DR','Location','NorthWest');
set(gca,'FontWeight','bold','FontSize',12);
title(' (d) ');
axis([0 24*3 -1200 1200]);
set(gca,'XTick',0:4:24*3);