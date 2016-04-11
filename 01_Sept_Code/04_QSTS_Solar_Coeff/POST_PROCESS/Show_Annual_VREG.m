%Show_Annual_Sim_Results
main_dir='C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\Annual_Runs';

%---------------------------------
%DSS Controller:
n=1;
addpath(strcat(main_dir,'\DSS_INT_1YR'));
load YR_SIM_OLTC_FLAY_00    %YEAR_LTC(DOY).OP(:,3)
RUN(n).LTC = YEAR_LTC;
load YR_SIM_LTC_PT_V_1.mat
load YR_SIM_LTC_PT_V_2.mat
load YR_SIM_LTC_PT_V_3.mat
load YR_SIM_LTC_PT_V_4.mat
load YR_SIM_LTC_PT_V_5.mat
for DOY=1:1:364
    if DOY <= 60
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_1(DOY).WDG_PT];
    elseif DOY > 60 && DOY <= 120
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_2(DOY).WDG_PT];
    elseif DOY > 120 && DOY <= 200
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_3(DOY).WDG_PT];
    elseif DOY > 200 && DOY <= 280
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_4(DOY).WDG_PT];
    else
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_5(DOY).WDG_PT];
    end
end
clear YEAR_LTC YEAR_LTCSTATUS_1 YEAR_LTCSTATUS_2 YEAR_LTCSTATUS_3 YEAR_LTCSTATUS_4 YEAR_LTCSTATUS_5
%---------------------------------
%Time Sequential Controller:
n=n+1;
addpath(strcat(main_dir,'\TIME_SQE_1YR'));
load YR_SIM_OLTC_FLAY_00    %YEAR_LTC(DOY).OP(:,3)
RUN(n).LTC = YEAR_LTC;
load YR_SIM_LTC_PT_V_1.mat
load YR_SIM_LTC_PT_V_2.mat
load YR_SIM_LTC_PT_V_3.mat
load YR_SIM_LTC_PT_V_4.mat
load YR_SIM_LTC_PT_V_5.mat
for DOY=1:1:364
    if DOY <= 60
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_1(DOY).WDG_PT];
    elseif DOY > 60 && DOY <= 120
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_2(DOY).WDG_PT];
    elseif DOY > 120 && DOY <= 200
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_3(DOY).WDG_PT];
    elseif DOY > 200 && DOY <= 280
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_4(DOY).WDG_PT];
    else
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_5(DOY).WDG_PT];
    end
end
clear YEAR_LTC YEAR_LTCSTATUS_1 YEAR_LTCSTATUS_2 YEAR_LTCSTATUS_3 YEAR_LTCSTATUS_4 YEAR_LTCSTATUS_5
%---------------------------------
%Time Integrating Controller:
n=n+1;
addpath(strcat(main_dir,'\TIME_INT_1YR'));
load YR_SIM_OLTC_FLAY_00    %YEAR_LTC(DOY).OP(:,3)
RUN(n).LTC = YEAR_LTC;
load YR_SIM_LTC_PT_V_1.mat
load YR_SIM_LTC_PT_V_2.mat
load YR_SIM_LTC_PT_V_3.mat
load YR_SIM_LTC_PT_V_4.mat
load YR_SIM_LTC_PT_V_5.mat
for DOY=1:1:364
    if DOY <= 60
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_1(DOY).WDG_PT];
    elseif DOY > 60 && DOY <= 120
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_2(DOY).WDG_PT];
    elseif DOY > 120 && DOY <= 200
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_3(DOY).WDG_PT];
    elseif DOY > 200 && DOY <= 280
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_4(DOY).WDG_PT];
    else
        RUN(n).V(DOY).PT=[YEAR_LTCSTATUS_5(DOY).WDG_PT];
    end
end
clear YEAR_LTC YEAR_LTCSTATUS_1 YEAR_LTCSTATUS_2 YEAR_LTCSTATUS_3 YEAR_LTCSTATUS_4 YEAR_LTCSTATUS_5



%%

%Let us sample the large dataset to 5s interval:
DAY_T = 1;
DAY_F = 364;
i = 1;
RUN(1).S_LTC = zeros(2096640,2);
RUN(2).S_LTC = zeros(2096640,2);
RUN(3).S_LTC = zeros(2096640,2);
for DOY=DAY_T:1:DAY_F
    for t=15:15:length(RUN(1).LTC(DAY_T).OP(:,3))
        
        RUN(1).S_LTC(i,1) = RUN(1).LTC(DOY).OP(t,3);    %TAP POS
        RUN(1).S_LTC(i,2) = RUN(1).V(DOY).PT(t,1);      %PT VOLTAGE
        RUN(2).S_LTC(i,1) = RUN(2).LTC(DOY).OP(t,3);    %TAP POS
        RUN(2).S_LTC(i,2) = RUN(2).V(DOY).PT(t,1);      %PT VOLTAGE
        RUN(3).S_LTC(i,1) = RUN(3).LTC(DOY).OP(t,3);    %TAP POS
        RUN(3).S_LTC(i,2) = RUN(3).V(DOY).PT(t,1);      %PT VOLTAGE

        i = i + 1;
        %Add more...
       
    end
    fprintf('DOY=%d\n',DOY);
end

%%
fig = 0;
fig = fig + 1;
figure(fig);
X=(15/3600:15/3600:364*24);
X=X'/24;
%X=X+DAY_T;
%
plot(X,RUN(1).S_LTC(:,1),'b-','LineWidth',3);
%{
hold on
%plot(RUN(2).S_LTC(:,3),'r-','LineWidth',1.5);
%legend('OpenDSS Default','Sequential Mode');
%}
%%
%   Plot Voltage Range:
fig = fig + 1;
figure(fig)
subplot(2,1,1);
X2=(15/3600:15/3600:182*24);
X2=X2'/24;
hold on
index_end=182*24*4*60;
plot(X2,RUN(3).S_LTC(1:index_end,2),'r-','LineWidth',3);
hold on
plot(X2,RUN(2).S_LTC(1:index_end,2),'b-','LineWidth',2);
hold on
plot(X2,RUN(1).S_LTC(1:index_end,2),'c-','LineWidth',1);
%   Settings:
axis([0 183 123 125]);
xlabel('Day of Year (DOY)','FontSize',12,'FontWeight','bold');
ylabel('Measured PT Voltage on 120V Base','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold','FontSize',12);
grid on

subplot(2,1,2);
X2=X2+182;
index_end2=364*24*4*60;
h3=plot(X2,RUN(3).S_LTC(index_end+1:index_end2,2),'r-','LineWidth',3);
hold on
h2=plot(X2,RUN(2).S_LTC(index_end+1:index_end2,2),'b-','LineWidth',2);
hold on
h1=plot(X2,RUN(1).S_LTC(index_end+1:index_end2,2),'c-','LineWidth',1);
%   Settings:
legend([h1 h2 h3],'OpenDSS Controller','Time Sequential Controller','Time Integrating Controller');
grid on
axis([183 364 123 125]);
xlabel('Day of Year (DOY)','FontSize',12,'FontWeight','bold');
ylabel('Measured PT Voltage on 120V Base','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold','FontSize',12);

%%
fig = fig + 1;
figure(fig);
plot(X,(RUN(1).S_LTC(:,1)-RUN(2).S_LTC(:,1))/0.00625,'b-','LineWidth',5);
hold on
plot(X,(RUN(1).S_LTC(:,1)-RUN(3).S_LTC(:,1))/0.00625,'r-','LineWidth',2);

%axis([183 364 123 125]);
xlabel('Day of Year (DOY)','FontSize',12,'FontWeight','bold');
ylabel('Tap Position Differential','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold','FontSize',12);

legend('(DSS Tap Pos.) - (TIME SEQUENTIAL Tap Pos.)','(DSS Tap Pos.) - (TIME INTEGRATING Tap Pos.)');
set(gca,'YTick',[-2:1:2]);
axis([0 364 -2 2])
set(gca,'XTick',[0:30:364]);
set(gca,'FontWeight','bold','FontSize',12);
%%
fig = fig + 1;
figure(fig);
subplot(2,1,1);

DOY=213;
index_srt=DOY*24*4*60;
index_fin=index_srt+24*4*60-1;

X3=(15/3600:15/3600:24);
Y=RUN(3).S_LTC(index_srt:index_fin,2);
h3=plot(X3,RUN(3).S_LTC(index_srt:index_fin,2),'Color',[0.4 0.6 1.0],'LineWidth',6);
hold on
h2=plot(X3,RUN(2).S_LTC(index_srt:index_fin,2),'Color',[0.6 0.0 0.8],'LineWidth',2); %purp
hold on
h1=plot(X3,RUN(1).S_LTC(index_srt:index_fin,2),'Color',[0.2 0.8 0.2],'LineWidth',2);

%   Settings:
%legend([h1 h2 h3],'OpenDSS Controller','Time Sequential Controller','Time Integrating Controller');
grid on
axis([0 24 123 125]);
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('Measured PT Voltage on 120V Base','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold','FontSize',12);

%       now tap position...
subplot(2,1,2);
h3=plot(X3,RUN(3).S_LTC(index_srt:index_fin,1),'Color',[0.4 0.6 1.0],'LineWidth',6);
hold on
h2=plot(X3,RUN(2).S_LTC(index_srt:index_fin,1),'Color',[0.6 0.0 0.8],'LineWidth',2); %purp
hold on
h1=plot(X3,RUN(1).S_LTC(index_srt:index_fin,1),'Color',[0.2 0.8 0.2],'LineWidth',2);
%   Settings:
legend([h1 h2 h3],'OpenDSS Controller','Time Sequential Controller','Time Integrating Controller');
set(gca,'YTick',[0.99375:0.00625:1.00625]);
ylabel('OLTC Tap Position','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold','FontSize',12);
axis([0 24 0.99375 1.00625+0.00625]);
grid on







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