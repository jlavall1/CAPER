
%Inputs each kth interval:
%   cap_timer
%   vio_time
%   t
%SWC_STATE
cap_timer=SWC_STATE(t).SC_TMR;
vio_time=SWC_STATE(t).VIO_TIME;
SC_OP=SWC_STATE(t).SC_OP;
SC_CL=SWC_STATE(t).SC_CL;
%LTC_STATE
SVR_TMR=LTC_STATE(t).SVR_TMR;
%MSTR_STATE
F_CAP_CL = MSTR_STATE(t).F_CAP_CL;
F_CAP_OP = MSTR_STATE(t).F_CAP_OP;


%-- CAP. CONTROL Settings:
PF_SUB_LG=0.96;  %lagging setpoint
PF_SUB_LD=0.98; %leading setpoint
CAP_CTRL_DELAY=45; %secs
Caps.Swtch=150; %kVAR
%-- Inputs from SCADA_PULL:
cap_pos = SCADA(t).SC_S;
LD_LG = SCADA(t).Sub_LDLG; %1=lead & 0=lag
SUB_3Q = SCADA(t).Sub_3Q;

%%
%-- Relay Logic:
if cap_timer == CAP_CTRL_DELAY
    %Now change the state accordingly:
    if cap_pos == 0
        DSSText.command=sprintf('Edit Capacitor.%s states=1',swcap_name);
        SC_CL=0;
        cap_timer=0;
        vio_time=0;
        fprintf('\tCap Closed.\n');
    elseif cap_pos == 1
        DSSText.command=sprintf('Edit Capacitor.%s states=0',swcap_name);
        SC_OP=0;
        cap_timer=0;
        vio_time=0;
        fprintf('\tCap Opened.\n');
    end
elseif cap_timer ~= 0
    %A timer is still running...
    cap_timer = cap_timer + 1;
    if SVR_TMR ~= 0
        %Prevent both Operating at once.
        SVR_TMR=0;
    end
elseif F_CAP_CL == 1
    %Override the capacitor to close in order to fix LV @ OLTC
    %   Condition is that cap_timer = 0
    if cap_pos == 0
        vio_time=t;
        SC_CL=1;
        cap_timer = cap_timer+1;
        fprintf('Override of SW_CAP Closing Initiated\n');
    else
        vio_time=0;
        SC_CL=0;
        cap_timer = 0;
    end
elseif F_CAP_OP == 1
    %Override the capacitor to open in order to fix HV @ OLTC
    %   Condition is that cap_timer = 0
    if cap_pos == 1
        vio_time=t;
        SC_OP=1;
        cap_timer = cap_timer+1;
        fprintf('Override of SW_CAP Opening Initiated\n');
    else
        vio_time=0;
        SC_OP=0;
        cap_timer = 0;
    end
elseif LD_LG == 0 && SUB_3Q > Caps.Swtch*3*1.1
    if cap_pos == 0 %meaning it is open right now:
        if cap_timer == 0
            vio_time=t;
            SC_CL=1;
            cap_timer = cap_timer+1;
            fprintf('SW_CAP Timer to close Initiated\n');
        end
    end
elseif LD_LG == 1 && abs(SUB_3Q) > Caps.Swtch*3*1.1 %to prevent low PF lag 
    if cap_pos == 1
        if cap_timer == 0
            vio_time=t;
            SC_OP=1;
            cap_timer = cap_timer+1;
            fprintf('SW_CAP Timer to open Initiated\n');
        end
    end
end
%Output Communication to Other Equipment:
SWC_STATE(t+1).VIO_TIME = vio_time;
SWC_STATE(t+1).SC_TMR = cap_timer;
SWC_STATE(t+1).SC_OP = SC_OP;
SWC_STATE(t+1).SC_CL = SC_CL;

LTC_STATE(t+1).SVR_TMR=SVR_TMR;

