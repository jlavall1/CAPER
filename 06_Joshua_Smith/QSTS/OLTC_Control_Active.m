%OLTC_Control_Active
%Objective: Implement MATLAB control of tap changing based on timer, Vset
%       and bandwidth. Observing secondary voltage on PTphase=
%------------------------------------
%Potential Transformer Equivalent:
DSSCircuit.SetActiveElement(sprintf('Transformer.%s',trans_name));
Phs_V=DSSCircuit.ActiveElement.Voltages;
V_phC_s=Phs_V(13)+1i*Phs_V(14); %Phase C on secondary side
busPhase(t).V_PT =abs(V_phC_s)/60;
%------------------------------------
%Voltage Regulation Relay Equiv:
DSSText.command = sprintf('? Transformer.%s.Tap',trans_name);
TAP_POS = str2double(DSSText.Result);
%	 Settings:
LTC_CTRL_DELAY=45;
LTC_BAND=1;
LTC_VREG=124;
VREG_MAX=LTC_VREG+LTC_BAND/2;
VREG_MIN=LTC_VREG-LTC_BAND/2;
TAP_MAX=1.1;
TAP_MIN=0.9;
TAP_SIZE=(TAP_MAX-TAP_MIN)/32; %0.00625
%%
if VRR_Scheme == 2
    %--------------------Sequential Control Mode------------------------
    %-- REG CONTROL LOGIC:
    if tap_timer == LTC_CTRL_DELAY
        %Now change tap pos. accordingly:
        if busPhase(t).V_PT > VREG_MAX
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS-TAP_SIZE));
            tap_timer=0;
            BUCK=0;
            fprintf('\tBuck Op. Completed.\n');
        elseif busPhase(t).V_PT < VREG_MIN
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS+TAP_SIZE));
            tap_timer=0;
            BOOST=0;
            fprintf('\tBoost Op. Completed.\n');
        else
            tap_timer=0; %no voltage violation when timer expired.
            fprintf('\tTimer Reset.\n');
        end 
    elseif tap_timer ~=0
        %increment timer:
        if busPhase(t).V_PT < VREG_MAX && BUCK == 1
            tap_timer = 0; %reset timer.
            BUCK = 0;
            fprintf('\tTimer Reset.\n');
        elseif busPhase(t).V_PT > VREG_MIN && BOOST == 1
            tap_timer = 0;
            BOOST = 0;
            fprintf('\tTimer Reset.\n');
        else
            tap_timer = tap_timer + 1;
        end
    elseif busPhase(t).V_PT > VREG_MAX
        if TAP_POS > TAP_MIN
            if tap_timer == 0
                vio_tap_timer=t;
                fprintf('OLTC Timer Initiated\n');
                tap_timer = tap_timer+1;
                BUCK=1;
            end
        end
    elseif busPhase(t).V_PT < VREG_MIN
        if TAP_POS < TAP_MAX
            if tap_timer == 0
                vio_tap_timer=t;
                fprintf('OLTC Timer Initiated\n');
                tap_timer = tap_timer+1;
                BOOST=1;
            end
        end
    end
elseif VRR_Scheme == 3
    %--------------------Integral Control Mode------------------------
    %-- REG CONTROL LOGIC:
    if tap_timer >= LTC_CTRL_DELAY
        %Now change tap pos. accordingly:
        if busPhase(t).V_PT > VREG_MAX
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS-TAP_SIZE));
            tap_timer=0;
            BUCK=0;
            fprintf('\tBuck Op. Completed.\n');
        elseif busPhase(t).V_PT < VREG_MIN
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS+TAP_SIZE));
            tap_timer=0;
            BOOST=0;
            fprintf('\tBoost Op. Completed.\n');
        else
            tap_timer=0; %no voltage violation when timer expired.
            fprintf('\tTimer Reset.\n');
        end 
    elseif tap_timer < 0
        %Reset timer from -1.1 increments:
        tap_timer=0;
        BUCK = 0;
        BOOST = 0;
        fprintf('\tTimer Reset.\n');
    elseif tap_timer ~= 0
        %increment timer:
        if busPhase(t).V_PT < VREG_MAX && BUCK == 1
            tap_timer = tap_timer - 1.1; %reset timer.
            fprintf('\tTimer Dec.\n');
        elseif busPhase(t).V_PT > VREG_MIN && BOOST == 1
            tap_timer = tap_timer - 1.1;
            fprintf('\tTimer Dec.\n');
        else
            tap_timer = tap_timer + 1;
        end
    elseif busPhase(t).V_PT > VREG_MAX
        if TAP_POS > TAP_MIN
            if tap_timer == 0
                vio_tap_timer=t;
                fprintf('OLTC Timer Initiated\n');
                tap_timer = tap_timer+1;
                BUCK=1;
            end
        end
    elseif busPhase(t).V_PT < VREG_MIN
        if TAP_POS < TAP_MAX
            if tap_timer == 0
                vio_tap_timer=t;
                fprintf('OLTC Timer Initiated\n');
                tap_timer = tap_timer+1;
                BOOST=1;
            end
        end
    end
elseif VRR_Scheme == 4
    %--------------------Average Voltage Control Mode------------------------
    %-- REG CONTROL LOGIC:
    if tap_timer == LTC_CTRL_DELAY
        %Now change tap pos. accordingly:
        dV_req=(v_avg-LTC_VREG)/v_avg;
        MOVE=-1*floor(dV_req/TAP_SIZE);
        if MOVE < -5
            MOVE = -5;
        elseif MOVE > 5
            MOVE = 5;
        end
        DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS+MOVE*TAP_SIZE));
        if MOVE < 0
            fprintf('\tBuck Op. Completed.\n');
        else
            fprintf('\tBoost Op. Completed.\n');
        end
        tap_timer=0;
        MOVE = 0;
        v_sum = 0;
    elseif tap_timer ~=0
        %increment timer:
        v_sum = v_sum + busPhase(t).V_PT;
        v_avg = v_sum/(t-t_vio);
        tap_timer = tap_timer + 1;
    elseif busPhase(t).V_PT > VREG_MAX
        if TAP_POS > TAP_MIN
            if tap_timer == 0
                t_vio=t;
                fprintf('OLTC Timer Initiated\n');
                tap_timer = tap_timer+1;
            end
        end
    elseif busPhase(t).V_PT < VREG_MIN
        if TAP_POS < TAP_MAX
            if tap_timer == 0
                t_vio=t;
                fprintf('OLTC Timer Initiated\n');
                tap_timer = tap_timer+1;
            end
        end
    end
end
    
%%
%Save info for comparison:
YEAR_LTCSTATUS(DAY_I).TAP_POS(t,1)=TAP_POS;
YEAR_LTCSTATUS(DAY_I).WDG_PT(t,1)=busPhase(t).V_PT;
YEAR_LTCSTATUS(DAY_I).TAP_TMR(t,1)=tap_timer;
LTC_TRBL(t,1)=TAP_POS;
LTC_TRBL(t,2)=busPhase(t).V_PT;
LTC_TRBL(t,3)=tap_timer;
