function [ SWC_STATE_O,LTC_STATE_O,MSTR_STATE_O] = OLTC_Control( DSSCircObj,SCADA,SWC_STATE,LTC_STATE,MSTR_STATE,t)
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
    MS_SC_CL=MSTR_STATE.SC_CL_EN;
    MS_SC_OP=MSTR_STATE.SC_OP_EN;
    
%--Regulator Relay CONTROL Settings:
    trans_name='FLAY_RET_16271201';
    LTC_CTRL_DELAY=45;
    LTC_BAND=1;
    LTC_VREG=124;
    VREG_MAX=LTC_VREG+LTC_BAND/2;
    VREG_MIN=LTC_VREG-LTC_BAND/2;
    TAP_MAX=1.1;
    TAP_MIN=0.9;
    TAP_SIZE=(TAP_MAX-TAP_MIN)/32; %0.00625
    
%-- Field Measurements from SCADA_PULL:
    V_PT=SCADA.OLTC_V;
    TAP_POS=SCADA.OLTC_TAP;
    SC_STATE=SCADA.SC_S;%1=Closed ; 0=Open

%-- Relay Logic, Sequential Control:
    if SVR_TMR == LTC_CTRL_DELAY
    %Now change tap pos. accordingly:
        if V_PT > VREG_MAX
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS-TAP_SIZE));
            SVR_TMR=0;
            BUCK=0;
            vio_LTC_time=0;
            fprintf('\tBuck Op. Completed.\n');
        elseif V_PT < VREG_MIN
            if SC_STATE == 0 && MS_SC_CL == 1
                %Capacitor is open & could be used for boosting voltage.
                F_CAP_CL=1;
                fprintf('\tFLAG\n');
            else
                DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,num2str(TAP_POS+TAP_SIZE));
                fprintf('\tBoost Op. Completed.\n');
            end
            SVR_TMR=0;
            BOOST=0;
            vio_LTC_time=0;

        else
            SVR_TMR=0; %no voltage violation when timer expired.
            fprintf('\tTimer Reset.\n');
        end 
    elseif SVR_TMR ~=0
        %increment timer:
        if V_PT < VREG_MAX && BUCK == 1
            SVR_TMR = 0; %reset timer.
            BUCK = 0;
            vio_LTC_time=0;
            fprintf('\tTimer Reset.\n');
        elseif V_PT > VREG_MIN && BOOST == 1
            SVR_TMR = 0;
            BOOST = 0;
            vio_LTC_time=0;
            fprintf('\tTimer Reset.\n');
        else
            if cap_timer ~= 0
                cap_timer = 0;
            end
            SVR_TMR = SVR_TMR + 1;
        end
    elseif V_PT > VREG_MAX
        if TAP_POS > TAP_MIN
            if SVR_TMR == 0
                vio_LTC_time=t;
                fprintf('OLTC Timer Initiated\n');
                SVR_TMR = SVR_TMR+1;
                BUCK=1;
            end
        end
    elseif V_PT < VREG_MIN
        if TAP_POS < TAP_MAX
            if SVR_TMR == 0
                vio_LTC_time=t;
                fprintf('OLTC Timer Initiated\n');
                SVR_TMR = SVR_TMR+1;
                BOOST=1;
            end
        end
    end
%-- Report to Master Controller:
    SWC_STATE_O.VIO_TIME = vio_time;
    SWC_STATE_O.SC_TMR = cap_timer;
    SWC_STATE_O.SC_OP = SC_OP;
    SWC_STATE_O.SC_CL = SC_CL;
    
    LTC_STATE_O.VIO_TIME=vio_LTC_time;
    LTC_STATE_O.SVR_TMR=SVR_TMR;
    LTC_STATE_O.HV = BUCK;
    LTC_STATE_O.LV = BOOST;
    
    MSTR_STATE_O.F_CAP_CL = F_CAP_CL;
    MSTR_STATE_O.F_CAP_OP = F_CAP_OP;
    MSTR_STATE_O.SC_CL_EN = MS_SC_CL;
    MSTR_STATE_O.SC_OP_EN = MS_SC_OP;

end

