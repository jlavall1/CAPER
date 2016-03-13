%Start of Chapter 4 Plotting Function:
clear
clc
close all
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);
fig = 0;
base_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\Three_Month_Runs';
section=menu('What Section of Chapter 4 would you like to initiate?','Section 1 (Vreg control schemes)','Section 2 (Centralized Approach)','Section 3 (Intro of DER-PV)');
while section<1
    section=menu('What Section of Chapter 4 would you like to initiate?','Section 1 (Vreg control schemes)','Section 2 (Centralized Approach)','Section 3 (Intro of DER-PV)');
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
        
elseif section == 2
    %DSDR on ROX:
    fig = 0;
    run=menu('What run on ROX?','1 DAY','1 WEEK');
    while run<1
        run=menu('What run on ROX?','1 DAY','1 WEEK');
    end
    if run == 1
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
        %-------------------------
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
        %-------------------------
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
        %-------------------------
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
        %-------------------------
    elseif run == 2
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
    end

    
    
    
end
    
    
