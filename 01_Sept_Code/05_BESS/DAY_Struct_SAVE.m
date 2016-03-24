% .m file that will place measurements in defined structs:

%SC STATES:
YEAR_CAPSTATUS(DAY_I).CAP_POS=[SCADA.SC_S];        %cap_pos;
YEAR_CAPSTATUS(DAY_I).Q_CAP=[SCADA.SC_Q];       %Reactive Power of cap_bank
YEAR_CAPCNTRL(DAY_I).CTL_PF=[SCADA.Sub_PF];     %control PF
YEAR_CAPCNTRL(DAY_I).LD_LG=[SCADA.Sub_LDLG];    %lead/lag

%OLTC STATES:
YEAR_LTCSTATUS(DAY_I).TAP_POS=[SCADA.OLTC_TAP];     %tap position:
YEAR_LTCSTATUS(DAY_I).WDG_PT=[SCADA.OLTC_V];        %busPhase(t).V_PT;
YEAR_LTCSTATUS(DAY_I).TAP_TMR=[LTC_STATE.SVR_TMR];  %(t,1)=tap_timer;
YEAR_LTC(DAY_I).OP=DATA_SAVE(1).LTC_Ops;
YEAR_SIM_P(DAY_I).DSS_SUB=DATA_SAVE(1).phaseP;
YEAR_SIM_Q(DAY_I).DSS_SUB=DATA_SAVE(1).phaseQ;

%BATT STATES:
if BESS_ON == 1
    YEAR_BESS(DAY_I).SOC = [BESS_M.SOC];
    YEAR_BESS(DAY_I).CR  = [BESS_M.CR];
    YEAR_BESS(DAY_I).DR  = [BESS_M.DR];
end

%OTHER INFO:
YEAR_SUB(DAY_I).V=DATA_SAVE(1).phaseV;
YEAR_SUB(DAY_I).TVD_SAVE = TVD_SAVE;
YEAR_SUB(DAY_I).max_V=max([YEAR_FDR.V]);
YEAR_SUB(DAY_I).min_V=min([YEAR_FDR.V]);
if slt_DAY_RUN == 7
    %Special case to save all voltages:
    YEAR_SUB(DAY_I).all_V=[YEAR_FDR.V];
end






%{
%Save info for comparison:
YEAR_LTCSTATUS(DAY_I).TAP_POS(t,1)=TAP_POS;
YEAR_LTCSTATUS(DAY_I).WDG_PT(t,1)=busPhase(t).V_PT;
YEAR_LTCSTATUS(DAY_I).TAP_TMR(t,1)=tap_timer;
LTC_TRBL(t,1)=TAP_POS;
LTC_TRBL(t,2)=busPhase(t).V_PT;
LTC_TRBL(t,3)=tap_timer;
%}
%{
%Save cap_pos command for next 1 sec of operation:
YEAR_CAPSTATUS(DAY_I).CAP_POS(t,1)=cap_pos;
YEAR_CAPSTATUS(DAY_I).Q_CAP(t,1)=MEAS(t).PF(1,7); %Reactive Power of cap_bank
YEAR_CAPCNTRL(DAY_I).CTL_PF(t,1)=MEAS(t).PF(1,4); %control PF
YEAR_CAPCNTRL(DAY_I).LD_LG(t,1)=MEAS(t).PF(1,6); %lead/lag

%CAPCNTRL_TROUBLE{1,1:4}={'cap_pos','Q_Cap','PF','Lead/lag'};

CAPCNTRL_TROUBLE{t+1,1}=cap_pos;
CAPCNTRL_TROUBLE{t+1,2}=MEAS(t).PF(1,7);
CAPCNTRL_TROUBLE{t+1,3}=MEAS(t).PF(1,4);
CAPCNTRL_TROUBLE{t+1,4}=MEAS(t).PF(1,6);
CAPCNTRL_TROUBLE{t+1,5}=cap_timer;
CAPCNTRL_TROUBLE{t+1,6}=MEAS(t).Sub_P_PhA+MEAS(t).Sub_P_PhB+MEAS(t).Sub_P_PhC;
CAPCNTRL_TROUBLE{t+1,7}=MEAS(t).PF(1,5);
%}