%Start of Chapter 4 Plotting Function:
clear
clc
close all
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);
fig = 0;
base_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\Three_Month_Runs';
section=menu('What Section of Chapter 4 would you like to initiate?','Section 1 (Vreg control schemes)','Section 2 (Solar Coeff)','Section 3 (Intro of DER-PV)','Section 4 (Centralized Approach)');
while section<1
    section=menu('What Section of Chapter 4 would you like to initiate?','Section 1 (Vreg control schemes)','Section 2 (Solar Coeff)','Section 3 (Intro of DER-PV)','Section 4 (Centralized Approach)');
end
if section == 1
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
        
elseif section == 4
    %DSDR on ROX:
    fig = 0;
    addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\04_ROX\DAY_44');
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
    
    fig=fig+1;
    j=1;
    for i=1:1:length(YEAR_SIM_P(44).DSS_SUB)
        if mod(i,60)==0
            DSS_LOAD(j,1)=YEAR_SIM_Q(44).DSS_SUB(i,1);
            DSS_LOAD(j,2)=YEAR_SIM_Q(44).DSS_SUB(i,2);
            DSS_LOAD(j,3)=YEAR_SIM_Q(44).DSS_SUB(i,3);
            DSS_LOAD(j,4)=YEAR_SIM_P(44).DSS_SUB(i,1);
            DSS_LOAD(j,5)=YEAR_SIM_P(44).DSS_SUB(i,2);
            DSS_LOAD(j,6)=YEAR_SIM_P(44).DSS_SUB(i,3);
            
            j = j + 1;
        end
    end
            
            
    figure(fig);
    DOY=44;
    plot(CAP_OPS_STEP1(DOY).data(:,4),'r--');
    hold on
    plot(CAP_OPS_STEP1(DOY).data(:,5),'b--');
    hold on
    plot(CAP_OPS_STEP1(DOY).data(:,6),'g--');
    hold on
    plot(DSS_LOAD(:,4),'r-');
    hold on
    plot(DSS_LOAD(:,5),'b-');
    hold on
    plot(DSS_LOAD(:,6),'g-');
    
    %now look at reactive power:
    fig = fig + 1;
    figure(fig);
    plot(CAP_OPS_STEP1(DOY).data(:,1),'r--');
    hold on
    plot(CAP_OPS_STEP1(DOY).data(:,2),'b--');
    hold on
    plot(CAP_OPS_STEP1(DOY).data(:,3),'g--');
    hold on
    plot(DSS_LOAD(:,1),'r-');
    hold on
    plot(DSS_LOAD(:,2),'b-');
    hold on
    plot(DSS_LOAD(:,3),'g-');
    
    
    
    
    fig=fig+1;
    figure(fig)
    %X=[0:15:24*60-15]/1440;
    i=1;
    DAY_FIN=364;
    for DOY=1:1:DAY_FIN
        %X(1,i:i+95) = [(i*15-15):15:(i)*1425];
        Y(i:i+95,1) = CAP_OPS(DOY).oper(:,1);
        Y(i:i+95,2) = CAP_OPS(DOY).oper(:,2)+1;
        Y(i:i+95,3) = CAP_OPS(DOY).oper(:,3)+2;
        i = i + 96;
        %plot(X,CAP_OPS(DOY).oper(:,1),'b-');
        %hold on
    end
    X=[0:(15):DAY_FIN*24*60-15];
    plot(X/1440,Y)
    axis([0 DAY_FIN -0.5 3.5]);
    
    fig=fig+1;
    figure(fig);
    
    
    
end
    
    
