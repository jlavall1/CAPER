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
    %10seconds into sim, conduct initial guess:
    CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
    BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
    CSI_TH=0.2;
    C=BESS.Crated; %only for first DOY
    DSSText.command=sprintf('Edit Storage.BESS1 %%stored=%s',num2str(100*(1-BESS.DoD_max)));
    DoD=BESS.DoD_max;
    [SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD);
    k = 1; %kth interval for controller...
    DSSText.command='Edit Storage.BESS1 %Charge=0 %Discharge=0 State=IDLING';
    B_TRBL(k).P_PV = abs(SCADA(t).PV_P);
    B_TRBL(k).SOC = BESS_M(t).SOC;
    B_TRBL(k).CR = BESS_M(t).CR;
    B_TRBL(k).dP_PV = 0; 
end