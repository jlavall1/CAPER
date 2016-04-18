%Show_VREG_DAY

%   1) Tap Position vs. Time
%   2) PT Phase Voltage Meas
main_dir='C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\Three_Month_Runs';

n=1;
addpath(strcat(main_dir,'\Base_DSS'));
load YR_SIM_OLTC_FLAY_00    %YEAR_LTC
load YR_SIM_FDR_V_FLAY_00   %YEAR_FDR
load YR_SIM_SUBV_FLAY_00    %YEAR_SUB

RUN(n).LTC = YEAR_LTC;
RUN(n).VOLT = YEAR_FDR;
RUN(n).SUB_V = YEAR_SUB;
clear YEAR_LTC YEAR_FDR YEAR_SUB

n=n+1;
addpath(strcat(main_dir,'\Base_Sequential'));
load YR_SIM_OLTC_FLAY_00    %YEAR_LTC
load YR_SIM_FDR_V_FLAY_00   %YEAR_FDR
load YR_SIM_SUBV_FLAY_00    %YEAR_SUB

RUN(n).LTC = YEAR_LTC;
RUN(n).VOLT = YEAR_FDR;
RUN(n).SUB_V = YEAR_SUB;    %SUB_V
clear YEAR_LTC YEAR_FDR YEAR_SUB


%%

%Let us sample the large dataset to 5s interval:
DAY_T = 32;
DAY_F = 100;
i = 1;
for DOY=DAY_T:1:DAY_F
    for t=5:5:length(RUN(1).LTC(DAY_T).OP(:,3))
        if mod(t,15) == 0
            RUN(1).S_LTC(i,1:2) = RUN(1).LTC(DOY).OP(t,2:3);
            RUN(2).S_LTC(i,1:2) = RUN(2).LTC(DOY).OP(t,2:3);
            RUN(1).S_LTC(i,3) = RUN(1).SUB_V(DOY).V(t,3)/60;
            RUN(2).S_LTC(i,3) = RUN(2).SUB_V(DOY).V(t,3)/60;
            i = i + 1;
            %Add more...
        end
    end
    fprintf('DOY=%d\n',DOY);
end

%%
fig = 0;
fig = fig + 1;
figure(fig);
X=15/3600:15/3600:DAY_F-DAY_T;
X=X+DAY_T;
%
plot(RUN(1).S_LTC(:,3),'b-','LineWidth',3);
hold on
plot(RUN(2).S_LTC(:,3),'r-','LineWidth',1.5);
legend('OpenDSS Default','Sequential Mode');

fig = fig + 1;
figure(fig)
plot(RUN(1).S_LTC(:,2),'b-','LineWidth',3);
hold on
plot(RUN(2).S_LTC(:,2),'r-','LineWidth',1.5);

legend('OpenDSS Default','Sequential Mode');







%{
plot_type=menu('what plot?','All LTC Ops','Select DOY LTC Ops & V_PT','POI_1');
while plot_type<1
    plot_type=menu('what plot?','All LTC Ops','Select DOY LTC Ops & V_PT','POI_1');
end
if plot_type < 3
    addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\Three_Month_Runs\Base_Delay');
    load YR_SIM_CAP1_FLAY_00.mat    %YEAR_CAPSTATUS
    load YR_SIM_CAP2_FLAY_00.mat    %YEAR_CAPCNTRL
    load YR_SIM_MEAS_FLAY_00.mat    %DATA_SAVE
    load YR_SIM_OLTC_FLAY_00.mat    %YEAR_LTC
    load YR_SIM_P_FLAY_00.mat       %YEAR_SIM_P
    load YR_SIM_Q_FLAY_00.mat       %YEAR_SIM_Q
    load YR_SIM_SUBV_FLAY_00.mat    %YEAR_SUB
    load YR_SIM_TVD_FLAY_00.mat     %Settings
    %load YR_SIM_FDR_V_             %YEAR_FDR
end
%%


if plot_type == 1
    %SVR PT Voltage & LTC Position on same plot:
    fig= fig + 1;
    figure(fig)
    inc = 86400;
    min_s = 1;
    min_e = inc;

    for DOY=32:1:120
        X=min_s:1:min_e;
        plot(X,YEAR_LTC(DOY).OP(1:86400,3),'b-')
        hold on
        min_s=min_s+inc;
        min_e=min_e+inc;
    end

elseif plot_type == 2
    fig = fig + 1;
    figure(fig)
    DOY = 44;
    %X2=[1/3600:1/3600:24];
    HR_S=19;
    HR_F=23;
    X2=[HR_S:1/3600:HR_F];
    T_sec =HR_S*3600;
    T_end =HR_F*3600;
    X1=X2;
    plot(X2,YEAR_SUB(DOY).V(T_sec:T_end,1)/60,'k-','LineWidth',2)
    hold on
    plot(X2,YEAR_SUB(DOY).V(T_sec:T_end,2)/60,'k-','LineWidth',2)
    hold on
    plot(X2,YEAR_SUB(DOY).V(T_sec:T_end,3)/60,'r-','LineWidth',2)
    hold on
    plot(X2,124*ones(length(X2),1),'b-');
    hold on
    plot(X2,123*ones(length(X2),1),'b--');
    hold on
    plot(X2,125*ones(length(X2),1),'b--');
    %Settings
    axis([HR_S HR_F 122 126])
    legend('Phase A','Phase B','Phase C (Control)','V_{SET}','V_{SET}+BW/2')
    xlabel('Hour of Day (HoD) [hour]','FontSize',12,'FontWeight','bold');
    ylabel('Phase Voltage on 120V Base','FontSize',12,'FontWeight','bold');
    %grid on
    set(gca,'FontWeight','bold');
    %hold on
    %plot
    %axis([
    %----------------
    fig = fig + 1;
    figure(fig)
    plot(X2,YEAR_LTC(DOY).OP(T_sec:T_end,3),'k-','LineWidth',3)
    xlabel('Hour of Day (HoD) [hour]','FontSize',12,'FontWeight','bold');
    ylabel('Feeder SVR Tap Position','FontSize',12,'FontWeight','bold');
    set(gca,'FontWeight','bold');
    set(gca,'ytick',[0.99375:0.00625:1.0125]);
    grid on
    %[hAx,hLine1,hLine2]=plotyy(X1,Y1,X1,Y2);
    %set(hLine1,'LineWidth',3);
elseif plot_type == 3
    %addpath(strcat(base_dir,'\POI_1_Sequential'));
    %{
    addpath(strcat(base_dir,'\POI_1_DSS'));
    load YR_SIM_CAP1_FLAY_010.mat    %YEAR_CAPSTATUS
    YEAR_CAPSTATUS_1=YEAR_CAPSTATUS;
    load YR_SIM_CAP2_FLAY_010.mat    %YEAR_CAPCNTRL
    YEAR_CAPCNTRL_1 = YEAR_CAPCNTRL;
    load YR_SIM_MEAS_FLAY_010.mat    %DATA_SAVE
    DATA_SAVE_1 = DATA_SAVE;
    load YR_SIM_OLTC_FLAY_010.mat    %YEAR_LTC
    YEAR_LTC_1 = YEAR_LTC;
    load YR_SIM_P_FLAY_010.mat       %YEAR_SIM_P
    YEAR_SIM_P_1 = YEAR_SIM_P;
    load YR_SIM_Q_FLAY_010.mat       %YEAR_SIM_Q
    YEAR_SIM_Q_1 = YEAR_SIM_Q;
    load YR_SIM_SUBV_FLAY_010.mat    %YEAR_SUB
    YEAR_SUB_1 = YEAR_SUB;
    load YR_SIM_TVD_FLAY_010.mat     %Settings
    Settings_1 = Settings;
    load YR_SIM_FDR_V_FLAY_010.mat   %YEAR_FDR
    YEAR_FDR_1 = YEAR_FDR;
    load YR_SIM_LTC_CTLFLAY_010.mat  %YEAR_LTCSTATUS
    YEAR_LTCSTATUS_1 = YEAR_LTCSTATUS;
    %}
    cd(strcat(base_dir,'\POI_1_Int'));
    load YR_SIM_OLTC_FLAY_010.mat    %YEAR_LTC
    YEAR_LTC_1 = YEAR_LTC;
    load YR_SIM_LTC_CTLFLAY_010.mat  %YEAR_LTCSTATUS
    YEAR_LTCSTATUS_1 = YEAR_LTC;
    cd(strcat(base_dir,'\POI_1_Sequential'));
    load YR_SIM_OLTC_FLAY_010.mat    %YEAR_LTC
    load YR_SIM_LTC_CTLFLAY_010.mat  %YEAR_LTCSTATUS

    for DOY=32:1:120
        count(DOY)=0;
        count_1(DOY)=0;
        for t=1:1:86399
            if YEAR_LTC(DOY).OP(t,3) ~= YEAR_LTC(DOY).OP(t+1,3)
                count(DOY)=count(DOY)+1;
            end
            if YEAR_LTC_1(DOY).OP(t,3) ~= YEAR_LTC(DOY).OP(t+1,3)
                count_1(DOY)=count_1(DOY)+1;
            end
        end
    end
    %%
    fig = fig + 1;
    figure(fig)
    plot(count)
    hold on
    plot(count_1,'r-');
    %%



    fig= fig + 1;
    figure(fig)
    inc = 86400;
    min_s = 1;
    min_e = inc;

    for DOY=32:1:120
        X=min_s:1:min_e;
        plot(X,YEAR_LTC(DOY).OP(1:86400,3),'b-')
        hold on
        min_s=min_s+inc;
        min_e=min_e+inc;
    end
    fig = fig + 1;
    figure(fig)
    min_s = 1;
    min_e = inc;
    for DOY=32:1:120
        X=min_s:1:min_e;
        plot(X,YEAR_LTC_1(DOY).OP(1:86400,3),'b-')
        hold on
        min_s=min_s+inc;
        min_e=min_e+inc;
    end



end
%}