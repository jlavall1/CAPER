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

%Energy Coordination:
if t == 1
    %1] Pull background reference data for Energy Management.
    CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
    BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
    CSI_TH=0.1;             %(used to estimate when PV will generate).
    
    %2] Pull the SOC from previous day & reset BESS.
    DoD_DAY_SRT = BESS.DoD_max;
    
    %3] Generate SOC reference profile based on known datasets.
    C=BESS.Crated;
    [SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD_DAY_SRT);
    
    %4] Set BESS Object in DSS.
    DSSText.command=sprintf('Edit Storage.BESS1 %%stored=%s',num2str(100*(1-DoD_DAY_SRT)));
    DSSText.command='Edit Storage.BESS1 %Charge=0 %Discharge=0 State=IDLING';
    
    %5] Estimate peak loading time.
    P_DAY1=CAP_OPS_STEP2(DOY).kW(:,1)+CAP_OPS_STEP2(DOY).kW(:,2)+CAP_OPS_STEP2(DOY).kW(:,3);
    P_DAY2=CAP_OPS_STEP2(DOY+1).kW(:,1)+CAP_OPS_STEP2(DOY+1).kW(:,2)+CAP_OPS_STEP2(DOY+1).kW(:,3);
    [t_max,DAY_NUM,P_max,E_kWh]=Peak_Estimator_MSTR(P_DAY1,P_DAY2);
    
    %6] Make initial estimate of cut-in kW & start of peak shaving period
    [peak,P_DR_ON,T_DR_ON,T_DR_OFF,DoD_tar] = DR_INT(t_max,P_DAY1,M_PVSITE_SC_1(DOY+1,:),BESS,1);
    
    
    %7] Initialize needed variables for BESS controller.
    k = 1;
    B_TRBL(k).P_PV = abs(SCADA(t).PV_P);
    B_TRBL(k).SOC = BESS_M(t).SOC;
    B_TRBL(k).CR = BESS_M(t).CR;
    B_TRBL(k).dP_PV = 0; 
end
if t == T_DR_ON
    %adjust peak shaving by updating SOC @ start
    fprintf('updated peak shaving based on actual SOC\n');
    [peak,P_DR_ON,T_DR_ON,T_DR_OFF,DoD_tar] = DR_INT(t_max,P_DAY1,M_PVSITE_SC_1(DOY+1,:),BESS,[BESS_M(t).SOC]/100);
end