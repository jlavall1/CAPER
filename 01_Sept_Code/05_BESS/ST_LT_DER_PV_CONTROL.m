%ST_LT_DER_PV_CONTROL
%Controller A
if dP_PV_pu < P_TH 
    %Extreme Decrease of generation!
    A1=a_PV_CR*-1;
    A2=a_PV_DR;
elseif dP_PV_pu > -1*P_TH
    %Extreme increase in generation!
    A1=a_PV_CR;
    A2=a_PV_DR*-1;
elseif CR(t,1) < CR_ref_5
    %Recovering from Decrease of gen!
    A1=a_PV_CR;
    A2=a_PV_DR*-1;
elseif CR(t,1) == 0 && DR(t,1) ~= 0
    %Extreme Recovery from Dec. of gen!
    A1=0;
    A2=a_PV_DR;
else
    %Continue normal ops:
    A1=0;
    A2=0;
end

%Update charge or discharge rate:
if CR(t,1) == 0
    %   In discharge mode:
    DR_k = DR(t,1)+A2*abs(dP_PV);
    if DR_k > BESS.Prated
        %over kW capacity!
        DR_k = BESS.Prated;
        S_state='DISCHARGING';
    elseif DR_k < 0
        %Moving to Charging Mode:
        CR_k = abs(DR_k);
        DR_k = 0;
        S_state='CHARGING';
    else
        S_state='DISCHARGING';
    end
elseif CR(t,1) < CR_ref_5
    %   In Charging mode:
    CR_k=CR(t,1)+A1*abs(dP_PV); %kW
    if CR_k < 0
        %Moving to Discharge mode:
        DR_k = abs(CR_k);
        CR_k = 0;
        S_state='DISCHARGING';
    elseif CR_k > BESS.Prated
        %over kW Capacity!
        CR_k = BESS.Prated;
        S_state='CHARGING';
    else
        S_state='CHARGING';
    end
elseif CR(t,1) >= CR_ref_5
    %   On Schedule or in STC mode:
    if A1 ~= 0
        %   Decrease CR b/c loss of gen.
        CR_k=CR(t,1)+A1*abs(dP_PV); %kW
        if CR_k > BESS.Prated 
            CR_k = BESS.Prated;
        end
        S_state='CHARGING';
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
        %   Under normal schedule:
        CR_k = CR_ref_5;
        S_state='CHARGING';
    end
end