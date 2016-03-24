%OLTC_Control_Active
%Objective: Implement MATLAB control of tap changing based on timer, Vset
%       and bandwidth. Observing secondary voltage on PTphase=
%------------------------------------
%I/O Control Communications:
%   vio_LTC_time
%   tap_timer
%   BUCK
%   BOOST
%------------------------------------
vio_LTC_time=LTC_STATE(t).VIO_TIME;
tap_timer=LTC_STATE(t).SVR_TMR;
BUCK=LTC_STATE(t).HV;
BOOST=LTC_STATE(t).LV;
%----------------------SWC_STATE-----
cap_timer=SWC_STATE(t).SC_TMR;
vio_time=SWC_STATE(t).VIO_TIME;
SC_OP=SWC_STATE(t).SC_OP;
SC_CL=SWC_STATE(t).SC_CL;

%------------------------------------
F_CAP_CL=MSTR_STATE(t).F_CAP_CL;
F_CAP_OP=MSTR_STATE(t).F_CAP_OP;
MS_SC_CL=MSTR_STATE(t).SC_CL_EN;
MS_SC_OP=MSTR_STATE(t).SC_OP_EN;

%Voltage Regulator Relay Settings:
LTC_CTRL_DELAY=45;
LTC_BAND=1;
LTC_VREG=124;
VREG_MAX=LTC_VREG+LTC_BAND/2;
VREG_MIN=LTC_VREG-LTC_BAND/2;
TAP_MAX=1.1;
TAP_MIN=0.9;
TAP_SIZE=(TAP_MAX-TAP_MIN)/32; %0.00625
%Inputs from SCADA_PULL:
V_PT=SCADA(t).OLTC_V;
TAP_POS=SCADA(t).OLTC_TAP;
SC_STATE=SCADA(t).SC_S; %1=Closed ; 0=Open

%%
%--------------------Sequential Control Mode------------------------
%-- REG CONTROL LOGIC:

if tap_timer == LTC_CTRL_DELAY
    %Now change tap pos. accordingly:
    if V_PT > VREG_MAX
        DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS-TAP_SIZE));
        tap_timer=0;
        BUCK=0;
        vio_LTC_time=0;
        fprintf('\tBuck Op. Completed.\n');
    elseif V_PT < VREG_MIN
        if SC_STATE == 0 && MS_SC_CL == 1
            %Capacitor is open & could be used for boosting voltage.
            F_CAP_CL=1;
        else
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS+TAP_SIZE));
            fprintf('\tBoost Op. Completed.\n');
        end
        tap_timer=0;
        BOOST=0;
        vio_LTC_time=0;
        
    else
        tap_timer=0; %no voltage violation when timer expired.
        fprintf('\tTimer Reset.\n');
    end 
elseif tap_timer ~=0
    %increment timer:
    if V_PT < VREG_MAX && BUCK == 1
        tap_timer = 0; %reset timer.
        BUCK = 0;
        vio_LTC_time=0;
        fprintf('\tTimer Reset.\n');
    elseif V_PT > VREG_MIN && BOOST == 1
        tap_timer = 0;
        BOOST = 0;
        vio_LTC_time=0;
        fprintf('\tTimer Reset.\n');
    else
        if cap_timer ~= 0
            cap_timer = 0;
        end
        tap_timer = tap_timer + 1;
    end
elseif V_PT > VREG_MAX
    if TAP_POS > TAP_MIN
        if tap_timer == 0
            vio_LTC_time=t;
            fprintf('OLTC Timer Initiated\n');
            tap_timer = tap_timer+1;
            BUCK=1;
        end
    end
elseif V_PT < VREG_MIN
    if TAP_POS < TAP_MAX
        if tap_timer == 0
            vio_LTC_time=t;
            fprintf('OLTC Timer Initiated\n');
            tap_timer = tap_timer+1;
            BOOST=1;
        end
    end
end
%Output Control Communications:
%   vio_LTC_time
%   tap_timer
%   BUCK
%   BOOST
LTC_STATE(t+1).VIO_TIME=vio_LTC_time;
LTC_STATE(t+1).SVR_TMR=tap_timer;
LTC_STATE(t+1).HV = BUCK;
LTC_STATE(t+1).LV = BOOST;
%---
SWC_STATE(t+1).VIO_TIME = vio_time;
SWC_STATE(t+1).SC_TMR = cap_timer;
SWC_STATE(t+1).SC_OP = SC_OP;
SWC_STATE(t+1).SC_CL = SC_CL;
