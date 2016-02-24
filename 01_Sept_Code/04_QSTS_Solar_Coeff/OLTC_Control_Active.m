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
busPhase(t).V_PT = v_PT(6)*120;

%DSSCircuit.SetActiveElement('Transformer.flay_ret_16271201_reg');
%TAP_POS=get(DSSCircuit.Transformers,'Taps');
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
%-- REG CONTROL LOGIC:
if busPhase(t).V_PT > VREG_MAX
    if TAP_POS > TAP_MIN
        if tap_timer == 0
            vio_tap_timer=t;
            fprintf('OLTC Timer Initiated\n');
            tap_timer = tap_timer+1;
        elseif tap_timer == LTC_CTRL_DELAY
            %Let us now move tap down 1 position:
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS-TAP_SIZE));
            tap_timer=0;
            fprintf('\tCompleted.\n');
        else
            tap_timer = tap_timer + 1;
        end
    end
elseif busPhase(t).V_PT < VREG_MIN
    if TAP_POS < TAP_MAX
        if tap_timer == 0
            vio_tap_timer=t;
            fprintf('OLTC Timer Initiated\n');
            tap_timer = tap_timer+1;
        elseif tap_timer == LTC_CTRL_DELAY
            %Let us now move tap down 1 position:
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS+TAP_SIZE));
            tap_timer=0;
            fprintf('\tCompleted.\n');
        else
            tap_timer = tap_timer + 1;
        end
    end
end
%%
%Save info for comparison:
YEAR_LTCSTATUS(DOY).TAP_POS(t,1)=TAP_POS;
YEAR_LTCSTATUS(DOY).WDG_PT(t,1)=busPhase(t).V_PT;   
