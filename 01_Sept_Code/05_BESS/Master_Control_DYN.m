%Beginning of Master Controller:
if t==6*3600/ss
    %MSTR_STATE(t+1).F_CAP_OP = 1;
    %MSTR_STATE(t+1).SC_OP_EN = 1;
    MSTR_STATE(t+1).F_CAP_OP = 0;
    MSTR_STATE(t+1).SC_OP_EN = 0;
else
    MSTR_STATE(t+1).F_CAP_OP = 0;
    MSTR_STATE(t+1).F_CAP_CL = 0;
    MSTR_STATE(t+1).SC_OP_EN = 0;
    MSTR_STATE(t+1).SC_CL_EN = 0;
end

%%
if BESS_ON == 1
    %Energy Coordination:
    if t == 1
        %1] Pull background reference data for Energy Management.
        CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
        BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
        CSI_TH=0.1;             %(used to estimate when PV will generate).

        %2] Estimate peak loading time.
        P_DAY1=CAP_OPS_STEP2(DAY_I).kW(:,1)+CAP_OPS_STEP2(DAY_I).kW(:,2)+CAP_OPS_STEP2(DAY_I).kW(:,3);
        P_DAY2=CAP_OPS_STEP2(DAY_I+1).kW(:,1)+CAP_OPS_STEP2(DAY_I+1).kW(:,2)+CAP_OPS_STEP2(DAY_I+1).kW(:,3);
        if DAY_I == DOY
            %Only hit during first day of simulation:
            [t_max,DAY_NUM,P_max,E_kWh]=Peak_Estimator_MSTR(P_DAY1,P_DAY2);
            if DAY_NUM == 1
                DAY_ON = DAY_I;
                T_MAX_HOLD=0;
            elseif DAY_NUM == 2
                DAY_ON = DAY_I+1;
                T_MAX_HOLD=t_max;
            end
            %[~,~,~,~,DoD_tar] = DR_INT(T_MAX_HOLD,P_DAY1,M_PVSITE_SC_1(DAY_I,:),BESS,1);
            DoD_DAY_SRT = DoD_tar_est( M_PVSITE_SC_1(DAY_I,:),BESS,PV_pmpp);
            fprintf('State of Charge @ start of Day: %0.3f %%\n',(1-DoD_DAY_SRT)*100);
            %DoD_DAY_SRT = BESS.DoD_max;
            %DoD_DAY_SRT = DoD_tar;
        else
            %Conseq. run:
            [t_max,DAY_NUM,P_max,E_kWh]=Peak_Estimator_MSTR(P_DAY1,P_DAY2);
            %Pull the SOC from previous day & reset BESS.
            DoD_DAY_SRT = DoD_DAY;

        end
        %4] Set BESS Object in DSS.
        DSSText.command=sprintf('Edit Storage.BESS1 %%stored=%s',num2str(100*(1-DoD_DAY_SRT)));
        DSSText.command='Edit Storage.BESS1 %Charge=0 %Discharge=0 State=IDLING';

        %6] Make initial estimate of cut-in kW & or start of peak shaving period
        if DAY_ON == DAY_I
            %peak will occur in the evening:
            if T_MAX_HOLD ~= 0
                DoD_tar = DoD_tar_est( M_PVSITE_SC_1(DAY_I+1,:),BESS,PV_pmpp);
                [peak,P_DR_ON,T_DR_ON,T_DR_OFF] = DR_INT(T_MAX_HOLD,P_DAY1,DoD_tar,BESS,1);
            elseif T_MAX_HOLD == 0
                DoD_tar = DoD_tar_est( M_PVSITE_SC_1(DAY_I+1,:),BESS,PV_pmpp);
                [peak,P_DR_ON,T_DR_ON,T_DR_OFF] = DR_INT(t_max,P_DAY1,DoD_tar,BESS,1);
            end

        elseif DAY_ON ~= DAY_I
            %peak will occur tomorrow w/ no previous carry request
            %[peak,P_DR_ON,~,T_DR_OFF,DoD_tar] = DR_INT(t_max,P_DAY2,M_PVSITE_SC_1(DAY_I+2,:),BESS,1);
            T_DR_ON = 25*3600; %(to ensure peak shaving will not operate)
            P_DR_ON = 0;
        end

        %3] Generate SOC reference profile based on known datasets.
        C=BESS.Crated;
        [SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD_DAY_SRT);


        %7] Update day of peak shaving for future operation:
        if DAY_NUM == 1
            DAY_ON = DOY;
        elseif DAY_NUM == 2
            DAY_ON = DOY+1;
        end

        %7] Initialize needed variables for BESS controller.
        k = 1;
        BESS_C1_ADJ = 0;
        
        B_TRBL(k).P_PV = abs(SCADA(t).PV_P);
        B_TRBL(k).SOC = BESS_M(t).SOC;
        B_TRBL(k).CR = BESS_M(t).CR;
        B_TRBL(k).dP_PV = 0; 
    end
    if t == T_DR_ON && T_MAX_HOLD == 0
        %adjust peak shaving by updating SOC @ start
        fprintf('updated peak shaving based on actual SOC\n');
        DoD_tar = DoD_tar_est( M_PVSITE_SC_1(DAY_I+1,:),BESS,PV_pmpp);
        fprintf('>>>DoD_tar for NEXT DAY=%0.3f\n',DoD_tar);
        [peak,P_DR_ON,T_DR_ON,T_DR_OFF] = DR_INT(t_max,P_DAY1,DoD_tar,BESS,[BESS_M(t).SOC]/100);
    end
    
    if PEAK_COMPLETE == 1 && BESS_C1_ADJ == 0 && t < 12*3600
        %The peak shaving has complete in the morning, now needs to update 
        %   Controller A reference;
        
        [SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD_DAY_SRT);
        BESS_C1_ADJ = 1;
        fprintf('updated SOC reference AFTER peak shaving complete.\n');
    end
    %}
end
