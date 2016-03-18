%DSDR_ON_ROX
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\04_ROX\1_WEEK');
load YR_SIM_CAP1_ROX_00.mat    %YEAR_CAPSTATUS
load YR_SIM_CAP2_ROX_00.mat    %YEAR_CAPCNTRL
load YR_SIM_MEAS_ROX_00.mat    %DATA_SAVE
load YR_SIM_OLTC_ROX_00.mat    %YEAR_LTC
load YR_SIM_P_ROX_00.mat       %YEAR_SIM_P
load YR_SIM_Q_ROX_00.mat       %YEAR_SIM_Q
load YR_SIM_SUBV_ROX_00.mat    %YEAR_SUB
load YR_SIM_TVD_ROX_00.mat     %Settings
load YR_SIM_LTC_CTLROX_00.mat  %YEAR_LTCSTATUS
%Background files:
load CAP_Mult_60s_ROX.mat   %CAP_OPS_STEP1
load P_Mult_60s_ROX.mat     %CAP_OPS_STEP2
load Q_Mult_60s_ROX.mat     %CAP_OPS.DSS & .oper
%%
%Show Real
fig=fig+1;
j=1;
for DOY=164:1:170
    for i=1:1:length(YEAR_SIM_P(DOY).DSS_SUB)
        if mod(i,60)==0
            D(DOY).DSS_LOAD(j,1)=YEAR_SIM_Q(DOY).DSS_SUB(i,1);
            D(DOY).DSS_LOAD(j,2)=YEAR_SIM_Q(DOY).DSS_SUB(i,2);
            D(DOY).DSS_LOAD(j,3)=YEAR_SIM_Q(DOY).DSS_SUB(i,3);
            D(DOY).DSS_LOAD(j,4)=YEAR_SIM_P(DOY).DSS_SUB(i,1);
            D(DOY).DSS_LOAD(j,5)=YEAR_SIM_P(DOY).DSS_SUB(i,2);
            D(DOY).DSS_LOAD(j,6)=YEAR_SIM_P(DOY).DSS_SUB(i,3);

            j = j + 1;
        end
    end
    j = 1;
end

%-------------------------
figure(fig);

D_ST=164;
X=[1/1440:1/1440:1]+164;
for DOY=D_ST:1:170
    %Plot Reactive Power DSS Load:
    h(1)=plot(X,D(DOY).DSS_LOAD(:,1),'r-.','LineWidth',2);
    hold on
    h(2)=plot(X,D(DOY).DSS_LOAD(:,2),'b-.','LineWidth',2);
    hold on
    h(3)=plot(X,D(DOY).DSS_LOAD(:,3),'g-.','LineWidth',2);

    %Plot Real Power DSS Load:
    h(4)=plot(X,D(DOY).DSS_LOAD(:,4),'r-','LineWidth',3);
    hold on
    h(5)=plot(X,D(DOY).DSS_LOAD(:,5),'b-','LineWidth',3);
    hold on
    h(6)=plot(X,D(DOY).DSS_LOAD(:,6),'g-','LineWidth',3);

    X=X+1;
end

%Settings:
xlabel('Day of Year (DOY)','FontSize',12,'FontWeight','bold');
ylabel('Single Phase Power (P,Q) [kW,kVAR]','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
legend([h(4) h(5) h(6) h(1) h(2) h(3)],'P_a','P_b','P_c','Q_a','Q_b','Q_c','Location','SouthWest','Orientation','horizontal');
%set(gca,'ytick',[0.99375:0.00625:1.0125]);
axis([164 171 -1000 3500])
grid on

%-------------------------
%now look at DSS-DSCADA:
fig = fig + 1;
figure(fig);
X=[1/1440:1/1440:1]+164;
for DOY=D_ST:1:170
    %Find errors:
    Y3(:,1)=CAP_OPS_STEP1(DOY).data(:,4)-D(DOY).DSS_LOAD(:,4);
    Y3(:,2)=CAP_OPS_STEP1(DOY).data(:,5)-D(DOY).DSS_LOAD(:,5);
    Y3(:,3)=CAP_OPS_STEP1(DOY).data(:,6)-D(DOY).DSS_LOAD(:,6);
    %Find errors:
    Y2(:,1)=CAP_OPS_STEP1(DOY).data(:,1)-D(DOY).DSS_LOAD(:,1);
    Y2(:,2)=CAP_OPS_STEP1(DOY).data(:,2)-D(DOY).DSS_LOAD(:,2);
    Y2(:,3)=CAP_OPS_STEP1(DOY).data(:,3)-D(DOY).DSS_LOAD(:,3);



    %Plot Error
    h(7)=plot(X,Y3(:,1),'r-','LineWidth',1.5);
    hold on
    plot(X,Y3(:,2),'r-','LineWidth',1.5);
    hold on
    plot(X,Y3(:,3),'r-','LineWidth',1.5);
    %Plot Error
    h(8)=plot(X,Y2(:,1),'b-','LineWidth',1.5);
    hold on
    plot(X,Y2(:,2),'b-','LineWidth',1.5);
    hold on
    plot(X,Y2(:,3),'b-','LineWidth',1.5);

    X=X+1;
end

%Settings:
xlabel('Day of Year (DOY)','FontSize',12,'FontWeight','bold');
ylabel('Single Phase Power (P,Q) [kW,kVAR]','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
legend([h(7) h(8)],'Real Power Difference','Reactive Power Difference','Location','NorthEast');
%set(gca,'ytick',[0.99375:0.00625:1.0125]);
grid on
%------------------------------------------------------------------
%This plot will observe certain capacitor change overlayed with
%three phase reactive power.
fig = fig + 1;
figure(fig);
X=[1/1440:1/1440:1]+D_ST;
X1=[1/96:1/96:1]+D_ST;
for DOY=D_ST:1:170
    %Find 3ph Q:

    %Plot SC OPS:
    plot(X1,YEAR_CAPSTATUS(DOY).Q_CAP(:,3),'r-','LineWidth',2);%+2400
    hold on
    plot(X1,YEAR_CAPSTATUS(DOY).Q_CAP(:,1),'b-','LineWidth',2);%+3600
    hold on
    plot(X1,YEAR_CAPSTATUS(DOY).Q_CAP(:,2),'g-','LineWidth',2);%+4800
    hold on
    Q_3ph=D(DOY).DSS_LOAD(:,1)+D(DOY).DSS_LOAD(:,2)+D(DOY).DSS_LOAD(:,3);
    plot(X,Q_3ph,'k--','LineWidth',1.5);

    %INC--
    X=X+1;
    X1=X1+1;
end
%Settings:
xlabel('Day of Year (DOY)','FontSize',12,'FontWeight','bold');
ylabel('Three Phase Reactive Power (Q) [kVAR]','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
legend('S.C. Bank 1','S.C. Bank 2','S.C. Bank 3','Substation Q');
%------------------------------------------------------------------
%This plot will observe the tap changes over the 1 weeks span taken
%at 30 second intervals --> From 1sec sim.

%Sample Tap Changes:
j=1;
for DOY=D_ST:1:170
    for i=1:1:length(YEAR_SIM_P(DOY).DSS_SUB)
        if mod(i,30)==0
            D(DOY).SVR(j,1)=YEAR_LTC(DOY).OP(i,3);       %LTC
            D(DOY).SVR(j,2)=YEAR_LTCSTATUS(DOY).SVR(1).TAP(i,1); %1A
            D(DOY).SVR(j,3)=YEAR_LTCSTATUS(DOY).SVR(1).TAP(i,2); %1A
            D(DOY).SVR(j,4)=YEAR_LTCSTATUS(DOY).SVR(1).TAP(i,3); %1A
            %Next Set:
            D(DOY).SVR(j,5)=YEAR_LTCSTATUS(DOY).SVR(2).TAP(i,1); %2A
            D(DOY).SVR(j,6)=YEAR_LTCSTATUS(DOY).SVR(3).TAP(i,1); %3A
            D(DOY).SVR(j,7)=YEAR_LTCSTATUS(DOY).SVR(4).TAP(i,2); %4B
            D(DOY).SVR(j,8)=YEAR_LTCSTATUS(DOY).SVR(5).TAP(i,1); %5A
            %{
            D(DOY).SVR(j,5)=DSS_LOAD(j,5)=YEAR_SIM_P(44).DSS_SUB(i,2);
            D(DOY).SVR(j,6)DSS_LOAD(j,6)=YEAR_SIM_P(44).DSS_SUB(i,3);
            %}

            j = j + 1;
        end
    end
    j=1;
end
fig = fig + 1;
figure(fig);
LW=2.5;
%1)
subplot(4,1,1);
X=[1/2880:1/2880:1]+D_ST;
for DOY=D_ST:1:170
    plot(X,D(DOY).SVR(:,1),'b-','LineWidth',LW);
    hold on
    X=X+1;
end
title('OLTC Tap Position');
axis([D_ST 170 .975 1.025]);
set(gca,'ytick',[.975:0.00625*2:1.025]);
set(gca,'xticklabel','');
grid on
set(gca,'FontWeight','bold');
%2)
subplot(4,1,2);
X=[1/2880:1/2880:1]+D_ST;
for DOY=D_ST:1:170
    plot(X,D(DOY).SVR(:,2),'b-','LineWidth',LW);
    hold on
    X=X+1;
end
title('SVR1-A Tap Position');
axis([D_ST 170 .975 1.025]);
set(gca,'ytick',[.975:0.00625*2:1.025]);
set(gca,'xticklabel','');
grid on
set(gca,'FontWeight','bold');
%3)
subplot(4,1,3);
X=[1/2880:1/2880:1]+D_ST;
for DOY=D_ST:1:170
    plot(X,D(DOY).SVR(:,3),'b-','LineWidth',LW);
    hold on
    X=X+1;
end
title('SVR1-B Tap Position');
axis([D_ST 170 .975 1.025]);
set(gca,'ytick',[.975:0.00625*2:1.025]);
set(gca,'xticklabel','');
grid on
set(gca,'FontWeight','bold');
%4)
subplot(4,1,4);
X=[1/2880:1/2880:1]+D_ST;
for DOY=D_ST:1:170
    plot(X,D(DOY).SVR(:,4),'b-','LineWidth',LW);
    hold on
    X=X+1;
end
title('SVR1-C Tap Position');
axis([D_ST 170 .975 1.025]);
set(gca,'ytick',[.975:0.00625*2:1.025]);
grid on
set(gca,'FontWeight','bold');
xlabel('Day of Year (DOY)','FontSize',12,'FontWeight','bold');
%-----next set-----------------------------------------------------
fig = fig + 1;
figure(fig);
%1)
subplot(4,1,1);
X=[1/2880:1/2880:1]+D_ST;
for DOY=D_ST:1:170
    plot(X,D(DOY).SVR(:,5),'b-','LineWidth',LW);
    hold on
    X=X+1;
end
title('SVR2(3ph)-A Tap Position');
axis([D_ST 170 .975 1.025]);
set(gca,'ytick',[.975:0.00625*2:1.025]);
set(gca,'xticklabel','');
grid on
set(gca,'FontWeight','bold');
%2)
subplot(4,1,2);
X=[1/2880:1/2880:1]+D_ST;
for DOY=D_ST:1:170
    plot(X,D(DOY).SVR(:,6),'b-','LineWidth',LW);
    hold on
    X=X+1;
end
title('SVR3-A Tap Position');
axis([D_ST 170 .975 1.025]);
set(gca,'ytick',[.975:0.00625*2:1.025]);
set(gca,'xticklabel','');
grid on
set(gca,'FontWeight','bold');
%3)
subplot(4,1,3);
X=[1/2880:1/2880:1]+D_ST;
for DOY=D_ST:1:170
    plot(X,D(DOY).SVR(:,7),'b-','LineWidth',LW);
    hold on
    X=X+1;
end
title('SVR4-B Tap Position');
axis([D_ST 170 .975 1.025]);
set(gca,'ytick',[.975:0.00625*2:1.025]);
set(gca,'xticklabel','');
grid on
set(gca,'FontWeight','bold');
%4)
subplot(4,1,4);
X=[1/2880:1/2880:1]+D_ST;
for DOY=D_ST:1:170
    plot(X,D(DOY).SVR(:,8),'b-','LineWidth',LW);
    hold on
    X=X+1;
end
title('SVR5-A Tap Position');
axis([D_ST 170 .975 1.025]);
set(gca,'ytick',[.975:0.00625*2:1.025]);
grid on
set(gca,'FontWeight','bold');
xlabel('Day of Year (DOY)','FontSize',12,'FontWeight','bold');   