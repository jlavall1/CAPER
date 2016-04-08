%PEAK_SHAVING_CONTROLLER
%   PK_SV_CTRL
SOC_tar=(1-DoD_tar)*100;
dT = 5/3600;
        
%fprintf('hit charging period\n');
if SOC < SOC_tar
    %   Stop DR:
    if PEAK_COMPLETE == 0
        DoD_DAY_SRT = (100-SOC)/100;
        PEAK_COMPLETE = 1;
    end
    DR_k = 0;
    S_state='IDLING';
    %fprintf('Start of IDLE: %d\n',k);
elseif T_DR_ON < 12*3600 
    %Special Case & when PV output is < 10% of rated
    if Sub_3P >= P_DR_ON+P_DR_ON*P_error
        DR_k = DR(t,1)+abs(Sub_3P-P_DR_ON);

        if DR_k > BESS.Prated
            DR_k = BESS.Prated;
        end
        S_state='DISCHARGING';
    elseif Sub_3P < P_DR_ON-P_DR_ON*P_error
        %   -- Lower Bound --
        %   change discharge rate:
        DR_k = DR(t,1)-abs(Sub_3P-P_DR_ON);
        if DR_k < 0
            DR_k = 0;
            S_state='IDLING';
        else
            S_state='DISCHARGING';
        end
    end
    %{
    DOD = 100-SOC; %Depth of Discharge:
    E_tar = (SOC_tar/100)*BESS.Crated;
    E_act = (SOC/100)*BESS.Crated;
    
    if DoD_tar*100-DOD < 5
        %slow DR down..
        epsilon=0.5;
    else
        epsilon=1;
    end
        
    DR_k = DR(t,1)- epsilon*(E_tar-(E_act-DR(t,1)*dT))/dT; 
    if DR_k < 0
        DR_k = 0;
        S_state='IDLING';
    elseif DR_k > 1000
        DR_k = 1000;
        S_state='DISCHARGING';
    else
        S_state='DISCHARGING';
    end
    %}
    
elseif Sub_3P >= P_DR_ON+P_DR_ON*P_error
    %-- Upper Bound Violation --

    %   Increase discharge rate:
    DR_k = DR(t,1)+abs(Sub_3P-P_DR_ON);

    if DR_k > BESS.Prated
        DR_k = BESS.Prated;
    end
    S_state='DISCHARGING';

elseif t < T_DR_OFF
    %continue discharge rate if within BW or below Lower Bound.
    if Sub_3P < P_DR_ON-P_DR_ON*P_error
        %   -- Lower Bound --
        %   change discharge rate:
        DR_k = DR(t,1)-abs(Sub_3P-P_DR_ON);
        if DR_k < 0
            DR_k = 0;
            S_state='IDLING';
        else
            S_state='DISCHARGING';
        end
        %fprintf('hit: %d\n',k);
    else
        DR_k = DR(t,1);
        if DR_k == 0
            S_state='IDLING';
            %fprintf('1.IDLE: %d\n',k);
        else
            S_state='DISCHARGING';
        end
    end

elseif t > T_DR_OFF
    if SOC > SOC_tar
        %continue to Discharge to reach DOD_tar
        DOD = 100-SOC; %Depth of Discharge:
        E_tar = (SOC_tar/100)*BESS.Crated;
        E_act = (SOC/100)*BESS.Crated;

        if DoD_tar*100-DOD < 5
            %slow DR down..
            epsilon=0.5;
        else
            epsilon=1;
        end

        DR_k = DR(t,1)- epsilon*(E_tar-(E_act-DR(t,1)*dT))/dT; 
        if DR_k < 0
            DR_k = 0;
            S_state='IDLING';
        elseif DR_k > 1000
            DR_k = 1000;
            S_state='DISCHARGING';
        else
            S_state='DISCHARGING';
        end
        %DR_k = DR(t,1); %4/4
        %DR_k = 1000;
        %S_state='DISCHARGING';
    end
end