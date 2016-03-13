%3 month runs showing impact of PV on (2) Test Feeders.
clear
clc
close all
%Select Choice--
Feeder = 3;
POI = 1;
basepath = 'C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff';
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
load M_MOCKS
M_PVSITE = M_MOCKS;
load M_MOCKS_INFO
M_PVSITE_INFO = M_MOCKS_INFO;
load M_MOCKS_SC
M_PVSITE_SC = M_MOCKS_SC;
clear M_MOCKS M_MOCKS_INFO M_MOCKS_SC
%Load to historical Loadsets:
load Annual_daytime_load_FLAY.mat
load Annual_ls_FLAY.mat         %MAX.MONTH.KW.A
load FLAY.mat
LOAD(3).MAX = max(MAX.MONTH.KW.A(1:12,1)+MAX.MONTH.KW.B(1:12,1)+MAX.MONTH.KW.C(1:12,1));
LOAD(3).KW = WINDOW.KW.A(:,1)+WINDOW.KW.B(:,1)+WINDOW.KW.C(:,1);
%Find monthly averages:
months = [31,28,31,30,31,30,31,31,30,31,30,31];
mn_max = 0;
t_w=0;  
tt =0;
sum = 0;
day_t=1;
%Increment through the months & find averages
for i=1:12
    x_w=60*6*months(i);
    for ii=tt+1:x_w+tt
        if isnan(LOAD(3).KW(ii,1))
            %fprintf('fuck you\n');
        else
            sum = abs(LOAD(3).KW(ii,1)) + sum;
        end
        day_t = day_t + 1;
    end
    tt = tt+x_w;
    LOAD(3).KW_avg(i,1) = sum/x_w;
    sum = 0;
end
clear MAX WINDOW FLAY

%   -FEEDER 02-
load Annual_daytime_load_CMNWLTH.mat
load Annual_ls_CMNWLTH.mat
LOAD(2).MAX = max(MAX.MONTH.KW.A(1:12,1)+MAX.MONTH.KW.B(1:12,1)+MAX.MONTH.KW.C(1:12,1));
LOAD(2).KW = WINDOW.KW.A(:,1)+WINDOW.KW.B(:,1)+WINDOW.KW.C(:,1);
mn_max = 0;
t_w=0;  
tt =0;
sum = 0;
day_t=1;
%Increment through the months & find averages
for i=1:12
    x_w=60*6*months(i);
    for ii=tt+1:x_w+tt
        if isnan(LOAD(2).KW(ii,1))
            %fprintf('fuck you\n');
        else
            sum = abs(LOAD(2).KW(ii,1)) + sum;
        end
        day_t = day_t + 1;
    end
    tt = tt+x_w;
    LOAD(2).KW_avg(i,1) = sum/x_w;
    sum = 0;
end


        
if Feeder == 3
        addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\Feeder_Data');
        
        
        
        %LOAD(3).AVG = 
        addpath(strcat(basepath,'\03_FLAY\Three_Month_Runs\Base_Sequential'));
    %Base Case Load:
        load YR_SIM_CAP1_FLAY_00.mat    %YEAR_CAPSTATUS
        RUN(1).YEAR_CAPSTATUS = YEAR_CAPSTATUS;
        clear YEAR_CAPSTATUS
        load YR_SIM_CAP2_FLAY_00.mat    %YEAR_CAPCNTRL
        RUN(1).YEAR_CAPCNTRL = YEAR_CAPCNTRL;
        clear YEAR_CAPCNTRL
        load YR_SIM_MEAS_FLAY_00.mat    %DATA_SAVE
        RUN(1).DATA_SAVE = DATA_SAVE;
        clear DATA_SAVE
        load YR_SIM_OLTC_FLAY_00.mat    %YEAR_LTC
        RUN(1).YEAR_LTC = YEAR_LTC;
        clear YEAR_LTC
        load YR_SIM_P_FLAY_00.mat       %YEAR_SIM_P
        RUN(1).YEAR_SIM_P = YEAR_SIM_P;
        clear YEAR_SIM_P
        load YR_SIM_Q_FLAY_00.mat       %YEAR_SIM_Q
        RUN(1).YEAR_SIM_Q = YEAR_SIM_Q;
        clear YEAR_SIM_Q
        load YR_SIM_SUBV_FLAY_00.mat    %YEAR_SUB
        RUN(1).YEAR_SUB = YEAR_SUB;
        clear YEAR_SUB
        load YR_SIM_TVD_FLAY_00.mat     %Settings
        RUN(1).Settings = Settings;
        clear Settings
    %POI_1 Case Load:
        n = 2;
        addpath(strcat(basepath,'\03_FLAY\Three_Month_Runs\POI_1_Sequential'));
        load YR_SIM_CAP1_FLAY_010.mat    %YEAR_CAPSTATUS
        RUN(n).YEAR_CAPSTATUS = YEAR_CAPSTATUS;
        clear YEAR_CAPSTATUS
        load YR_SIM_CAP2_FLAY_010.mat    %YEAR_CAPCNTRL
        RUN(n).YEAR_CAPCNTRL = YEAR_CAPCNTRL;
        clear YEAR_CAPCNTRL
        load YR_SIM_MEAS_FLAY_010.mat    %DATA_SAVE
        RUN(n).DATA_SAVE = DATA_SAVE;
        clear DATA_SAVE
        load YR_SIM_OLTC_FLAY_010.mat    %YEAR_LTC
        RUN(n).YEAR_LTC = YEAR_LTC;
        clear YEAR_LTC
        load YR_SIM_P_FLAY_010.mat       %YEAR_SIM_P
        RUN(n).YEAR_SIM_P = YEAR_SIM_P;
        clear YEAR_SIM_P
        load YR_SIM_Q_1_FLAY_010.mat       %YEAR_SIM_Q_1
        load YR_SIM_Q_2_FLAY_010.mat       %YEAR_SIM_Q_2
        RUN(n).YEAR_SIM_Q(32:60) = YEAR_SIM_Q_1(32:60);
        RUN(n).YEAR_SIM_Q(61:120) = YEAR_SIM_Q_2(61:120);
        clear YEAR_SIM_Q_1 YEAR_SIM_Q_2
        
        load YR_SIM_SUBV_FLAY_010.mat    %YEAR_SUB
        RUN(n).YEAR_SUB = YEAR_SUB;
        clear YEAR_SUB
        load YR_SIM_TVD_FLAY_010.mat     %Settings
        RUN(n).Settings = Settings;
        clear Settings
        load YR_SIM_FDR_V_FLAY_010.mat   %?
        RUN(n).YEAR_FDR = YEAR_FDR;
        clear YEAR_FDR
        
end
%%
fig = 0;
%Plot 1) Monthly Averages of VI/DARR:
M_VI = zeros(12,1);
M_CI = zeros(12,1);
M_DARR = zeros(12,1);
hit = 0;
for n=1:1:12
    for d=1:1:365
        if M_PVSITE_SC(d,2) == n
            M_VI(n) = M_VI(n) + M_PVSITE_SC(d,4);
            M_CI(n) = M_CI(n) + M_PVSITE_SC(d,5);
            M_DARR(n) = M_DARR(n) + M_PVSITE_SC(d,6);
            hit = hit + 1;
        end
    end
    M_VI(n) = M_VI(n)/hit;
    M_CI(n) = M_CI(n)/hit;
    M_DARR(n) = M_DARR(n)/hit;
    hit = 0;
end
fig = fig + 1;
figure(fig);
X=[1:1:12];
[AX,H1,H2]= plotyy(X,M_VI,X,M_DARR);
set(H1,'LineWidth',2);
set(H2,'LineWidth',2);
grid on
ylabel(AX(1),'Variability Index (VI)','FontSize',12,'FontWeight','bold');
ylabel(AX(2),'Daily Aggregate Ramp Rate (DARR)','FontSize',12,'FontWeight','bold');
xlabel('Month of Year','FontSize',12,'FontWeight','bold');
legend('Monthly Average VI','Monthly Average DARR','Location','SouthWest');
set(gca,'FontWeight','bold');
set(AX,'xtick',[1:1:12])
fig = fig + 1;
figure(fig);
plot(X,M_CI,'r-','LineWidth',2);
hold on
plot(X,LOAD(2).KW_avg/LOAD(2).MAX,'b-','LineWidth',1.5);
hold on
plot(X,LOAD(3).KW_avg/LOAD(3).MAX,'b--','LineWidth',1.5);
hold on
plot(X,M_CI-LOAD(2).KW_avg/LOAD(2).MAX,'k-','LineWidth',2);
hold on
plot(X,M_CI-LOAD(3).KW_avg/LOAD(3).MAX,'k--','LineWidth',2);
legend('Solar CI Avg.','Feeder 02 Daytime Load Avg.','Feeder 03 Daytime Load Avg.','CI - ( Pavg_{FDR2} )','CI - ( Pavg_{FDR3} )');
axis([1 12 -0.1 1.2]);
grid on


%[AX,H1,H2]= plotyy(X,M_CI,[X',X'],[LOAD(3).KW_avg/,LOAD(3).KW_avg+1000]);


        
        
