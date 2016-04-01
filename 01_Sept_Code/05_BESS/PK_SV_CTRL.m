%PEAK_SHAVING_CONTROLLER
%   PK_SV_CTRL
SOC_tar=(1-DoD_tar)*100;
        
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
        DR_k = DR(t,1);
        S_state='DISCHARGING';
    end
end