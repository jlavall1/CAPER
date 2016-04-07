function BESSControllerA(DSSCircObj,date,t)
    global SCADA BESS_M LTC_STATE SWC_STATE MSTR_STATE M_PVSITE M_PVSITE_SC SOC_ref CR_ref t_CR k
    global PV BESS

%%
% Pre Calc driving variables
P_TH=-1*0.0125;
SOC_TH = 0.8; % a 1% difference will initiate change in CR to attempt to match
epison=1;
dT = 5/3600;
a_PV_CR=0.5;
a_PV_DR=0.5;
CR_ER = 1.06;

PV_pmpp=PV(1).kw;
PV_bus=PV(1).Bus1;
trans_name='FLAY_RET_16271201';
sub_line='259363665';
swcap_name='38391707_sw';

SCADA_PULL
%%
% Controller A every 5 seconds
 %Implement Controller after:
 if mod(t,5) == 1 && t > 5%Dispatch every 5 seconds
     
    %Control Variables:
    PV_P = abs(SCADA(t).PV_P);
    B_TRBL(k).P_PV = PV_P;
    
    B_TRBL(k).SOC = BESS_M(t).SOC;
    CR(t,1) = BESS_M(t).CR;
    DR(t,1) = BESS_M(t).DR;
    B_TRBL(k).CR = CR(t,1);
    B_TRBL(k).DR = DR(t,1);
    
    CR_ref_5 = CR_ER*CR_ref(t,1);
    B_TRBL(k).CR_ref = CR_ref_5;
    B_TRBL(k).SOC_ref = SOC_ref(t,1);
    
    %COMM OF COMMANDS:
    HV=LTC_STATE(t).HV;
    LV=LTC_STATE(t).LV;
    
    dP_PV = (abs(SCADA(t).PV_P)-abs(SCADA(t-5).PV_P));
    dP_PV_pu = dP_PV/PV_pmpp;
    B_TRBL(k).dP_PV_pu = dP_PV_pu; 
    B_TRBL(k).dP_PV = dP_PV;
    SOC = BESS_M(t).SOC; % Percentage NOT Decimal
    SOC_E = (SOC/100)*BESS.Crated; %kWh
    P_error = 0.01;
    %-----------------
    a_PV_CR=SOC/100;
    a_PV_DR=SOC/100;
    %-----------------
    SOC_ERROR = abs(SOC_ref(t,1)*100-SOC);
    B_TRBL(k).SOC_ER = SOC_ERROR;
    B_TRBL(k).SOC_E = SOC_E;
    B_TRBL(k).SOC_E_ref = SOC_ref(t,1)*BESS.Crated;
    %-----------------
    Sub_3P = SCADA(t).Sub_3P;
    P_diff_DR = Sub_3P-P_DR_ON;
    B_TRBL(k).P_diff_DR = P_diff_DR;
    B_TRBL(k).Sub_3P = Sub_3P;
    
    if HV == 1 || LV == 1
        a_PV_CR=a_PV_CR*1.25;
        a_PV_DR=a_PV_DR*1.25;
    end
    
    if CR_ref(t,1) ~=0 && BESS_M(t).SOC < 100    
        ST_LT_DER_PV_CONTROL
    else 
        %Either not in scheduled window or SOC = 100%
        %   stay IDLE:
        CR_k = 0;
        S_state='IDLING';
    end
    %Implement new rate:
    if strcmp(S_state,'DISCHARGING') == 1
        DSSText.command=sprintf('Edit Storage.BESS1 %%Charge=0 %%Discharge=%s State=%s',num2str(100*(DR_k/BESS.Prated)),S_state);
    elseif strcmp(S_state,'CHARGING') == 1
        DSSText.command=sprintf('Edit Storage.BESS1 %%Charge=%s %%Discharge=0 State=%s',num2str(100*(CR_k/BESS.Prated)),S_state);
    else
        DSSText.command=sprintf('Edit Storage.BESS1 %%Charge=0 %%Discharge=0 State=%s',S_state);
    end
    k = k + 1;
 end
    
    

% Call shit

end