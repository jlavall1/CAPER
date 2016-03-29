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
P_TH=-1*0.015;
SOC_TH = 1; % a 1% difference will initiate change in CR to attempt to match
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
    %-----------------
    a_PV_CR=SOC/100;
    a_PV_DR=SOC/100;
    %-----------------
    SOC_ERROR = abs(SOC_ref(t,1)*100-SOC);
    B_TRBL(k).SOC_ER = SOC_ERROR;
    B_TRBL(k).SOC_E = SOC_E;
    B_TRBL(k).SOC_E_ref = SOC_ref(t,1)*BESS.Crated;
    
    
    if CR_ref(t,1) ~= 0
        if dP_PV_pu < P_TH 
            %loss of generation!
            if CR(t,1) ~= 0
                %   still in charging mode
                CR_k=CR(t,1)+a_PV_CR*dP_PV; %kW
                if CR_k > 0
                    S_state='CHARGING';
                else
                    %now lets switch to discharge mode:
                    DR_k = abs(CR_k);
                    if DR_k > BESS.Prated
                        %over kW capacity!
                        DR_k = BESS.Prated;
                    end
                    S_state='DISCHARGING';

                    %CR_k = 0;
                    %S_state='IDLING';
                end
            elseif CR(t,1) == 0
                %   ran out of decreasing Charing capability
                DR_k = DR(t,1)+a_PV_DR*abs(dP_PV);
                if DR_k > BESS.Prated
                        %over kW capacity!
                        DR_k = BESS.Prated;
                end
                S_state='DISCHARGING';
            end
        elseif dP_PV_pu > -1*P_TH
            %after loss of gen, PV is ramping back up:
            if CR(t,1) ~= 0
                %   chrg mode but damped:
                CR_k=CR(t,1)+a_PV_CR*abs(dP_PV); %kW
                if CR_k > 0 && CR_k < CR_ref_5
                    S_state='CHARGING';
                elseif CR_k > CR_ref_5
                    %   do not surpass scheduled CR
                    CR_k = CR_ref_5;
                    S_state='CHARGING';
                end
            elseif CR(t,1) == 0
                %   in discharge mode, need to move back to charge mode
                DR_k = DR(t,1)-a_PV_DR*abs(dP_PV);
                if DR_k > 0
                    S_state='DISCHARGING';
                else
                    CR_k = abs(DR_k);
                    DR_k = 0;
                    S_state='CHARGING';
                end
            end
                
            
        elseif BESS_M(t).SOC < 100
                if CR(t,1) < CR_ref_5
                    %means an event has occured but no crazy dP:
                    CR_k = CR(t,1)+a_PV_CR*abs(dP_PV);
                    S_state='CHARGING';
                elseif CR(t,1) == 0 && DR(t,1) ~= 0
                    %means an event has occured & DR still in operation:
                    DR_k = DR(t,1)-a_PV_CR*abs(dP_PV);
                    S_state='DISCHARGING';
                    
                elseif SOC_ERROR > SOC_TH
                    %   Check SOC Schedule:
                    CR_k = CR(t,1)+epison*(SOC_ref(t,1)*BESS.Crated-(SOC_E+CR(t,1)*dT))/dT; %kW
                    if CR_k > BESS.Prated 
                        
                        CR_k = BESS.Prated;
                        if CR_k > P_PV
                            CR_k = P_PV;
                        end
                        %putting a cap on charing state:
                    end
                    S_state='CHARGING';
                else
                %   keep at schedule..
                    CR_k = CR_ref_5; %kW
                    S_state='CHARGING';
                end
        elseif BESS_M(t).SOC >= 100
            %   Battery is at energy capacity, stay IDLE
            CR_k = 0;
            S_state='IDLING';
        end
    
    elseif CR_ref(t,1) == 0
        %because the CR_ref wanted 0 & SOC might be > 100 then:
        CR_k = 0;
        S_state='IDLING';
        %DSSText.command='Edit Storage.BESS1 %Charge=0 State=IDLING';
    end
    
    %Implement new rate:
    if strcmp(S_state,'DISCHARGING') == 1
        DSSText.command=sprintf('Edit Storage.BESS1 %%Charge=0 %%Discharge=%s State=%s',num2str(100*(DR_k/BESS.Prated)),S_state);
    else
        DSSText.command=sprintf('Edit Storage.BESS1 %%Charge=%s %%Discharge=0 State=%s',num2str(100*(CR_k/BESS.Prated)),S_state);
    end
    
end
    
k = k + 1;








