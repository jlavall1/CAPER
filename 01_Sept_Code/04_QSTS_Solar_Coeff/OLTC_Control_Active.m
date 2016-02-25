%OLTC_Control_Active
%Objective: Implement MATLAB control of tap changing based on timer, Vset
%       and bandwidth. Observing secondary voltage on PTphase=
%DSSCircuit.SetActiveElement('Transformer.FLAY_RET_16271201 terminal=2');
if t == 1
tic
end
v_PT=DSSCircObj.ActiveCircuit.AllBusVmagPu;
if t == 1
toc
end
%Reference circuit:
busPhase(t).V_PT = v_PT(6)*120;
DSSText.command = sprintf('? Transformer.%s.Tap',trans_name);
TAP_POS = str2double(DSSText.Result);
%VREG Settings:
LTC_CTRL_DELAY=45;
LTC_BAND=2;
LTC_VREG=124;
VREG_MAX=LTC_VREG+LTC_BAND/2;
VREG_MIN=LTC_VREG-LTC_BAND/2;
TAP_MAX=1.1;
TAP_MIN=0.9;
TAP_SIZE=(TAP_MAX-TAP_MIN)/32; %0.00625
%%
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
    %--------------------Sequential Control Mode------------------------
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
%%
%Save info for comparison:
YEAR_LTCSTATUS(DAY_I).TAP_POS(t,1)=TAP_POS;
YEAR_LTCSTATUS(DAY_I).WDG_PT(t,1)=busPhase(t).V_PT;
LTC_TRBL(t,1)=TAP_POS;
LTC_TRBL(t,2)=busPhase(t).V_PT;
LTC_TRBL(t,3)=tap_timer;
