%BESS_Control_PeakShaving:
%Objective: Implement MATLAB Control

%{
%obtain SOC-ref:
if t == 1
    %10seconds into sim, conduct initial guess:
    CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
    BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
    CSI_TH=0.2;
    C=BESS.Crated; %only for first DOY
    DSSText.command=sprintf('Edit Storage.BESS1 %%stored=%s',num2str(100*(1-BESS.DoD_max)));
    DoD=BESS.DoD_max;
    [SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD);
end
%}
%{
    References:
abs(SCADA(t).PV_P)
BESS(t).SOC
BESS(t).CR
BESS(t).DR
%}
%%
%Settings:
P_TH=-1*0.0125;
SOC_TH = 0.8; % a 1% difference will initiate change in CR to attempt to match
epison=1;
dT = 5/3600;
a_PV_CR=0.5;
a_PV_DR=0.5;
CR_ER = 1.06;

%%
%save control variables:
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
%%
if k > 1
    %Implement Controller after:
    P_PV = abs(SCADA(t).PV_P);
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
    
    if t > T_DR_ON && P_PV < 0.1*PV_pmpp
        PK_SV_CTRL
    elseif CR_ref(t,1) ~=0 && BESS_M(t).SOC < 100
        
        if HV == 1 || LV == 1
            a_PV_CR=a_PV_CR*1.25;
            a_PV_DR=a_PV_DR*1.25;
        end    
%{
            %High voltage is 
            if DR(t,1) ~= 0
                %BESS is currently discharging as gen, decrease this:
                A2=a_PV_DR*-.25;
                DR_k = DR(t,1)+A2*DR(t,1);
                if DR_k < 0
                    CR_k = abs(DR_k);
                    DR_k = 0;
                    S_state='CHARGING';
                else
                    S_state='DISCHARGING';
                end
            elseif CR(t,1) ~= 0
                %BESS is currently charging, increase this:
                A1=a_PV_CR*.25;
                CR_k = CR(t,1)+A1*CR(t,1);
                if CR_k > BESS.Prated
                    CR_k = BESS.Prated;
                end
                S_state='CHARGING';
            end

        elseif LV == 1
            A1=a_PV_CR*-1.5;
            A2=a_PV_CR*1.5;
%}
        ST_LT_DER_PV_CONTROL

    %elseif t > T_DR_ON
        %---Now lets move to peak discharge mode:
        %PK_SV_CTRL
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
    
end
    
k = k + 1;








