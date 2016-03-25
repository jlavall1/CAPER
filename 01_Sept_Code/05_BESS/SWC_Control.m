function [ SWC_STATE_O,LTC_STATE_O ] = SWC_Control( DSSCircObj,SCADA,SWC_STATE,LTC_STATE,MSTR_STATE,t)
%--Connect to DSS
    %DSSCircuit = DSSCircObj.ActiveCircuit;
    DSSText = DSSCircObj.Text;
%--I/O State Variables:
    %SWC_STATE
    cap_timer=SWC_STATE.SC_TMR;
    vio_time=SWC_STATE.VIO_TIME;
    SC_OP=SWC_STATE.SC_OP;
    SC_CL=SWC_STATE.SC_CL;
    %LTC_STATE
    vio_LTC_time=LTC_STATE.VIO_TIME;
    SVR_TMR=LTC_STATE.SVR_TMR;
    BUCK=LTC_STATE.HV;
    BOOST=LTC_STATE.LV;
    %MSTR_STATE
    F_CAP_CL = MSTR_STATE.F_CAP_CL;
    F_CAP_OP = MSTR_STATE.F_CAP_OP;

%-- CAP. CONTROL Settings:
    swcap_name='38391707_sw';
    PF_SUB_LG=0.96;  %lagging setpoint
    PF_SUB_LD=0.98; %leading setpoint
    CAP_CTRL_DELAY=45; %secs
    Caps.Swtch=150; %kVAR
%-- Field Measurements from SCADA_PULL:
    cap_pos = SCADA.SC_S;
    LD_LG = SCADA.Sub_LDLG; %1=lead & 0=lag
    SUB_3Q = SCADA.Sub_3Q;

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
            fprintf('SVR_TMR reset from SW CAP\n');
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
%%
%--Output Communication to Other Equipment:
    SWC_STATE_O.VIO_TIME = vio_time;
    SWC_STATE_O.SC_TMR = cap_timer;
    SWC_STATE_O.SC_OP = SC_OP;
    SWC_STATE_O.SC_CL = SC_CL;

    LTC_STATE_O.VIO_TIME=vio_LTC_time;
    LTC_STATE_O.SVR_TMR=SVR_TMR;
    LTC_STATE_O.HV = BUCK;
    LTC_STATE_O.LV = BOOST;
    


end

