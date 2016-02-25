
%Goal: To implement an external capacitor controller.

%References:
%   Cap_info
%   Bus_info
%   Line_info
%   KVAR_ACTUAL.sw_cap(:,1)
%%
DSSCircuit.SetActiveElement(sprintf('Line.%s',Lines_info(1).name));
Power   = DSSCircuit.ActiveCktElement.Powers;
%Single Phase Real Power:
MEAS(t).Sub_P_PhA = Power(1);
MEAS(t).Sub_P_PhB = Power(3);
MEAS(t).Sub_P_PhC = Power(5);
%Single Phase Reactive Power:
MEAS(t).Sub_Q_PhA = Power(2);
MEAS(t).Sub_Q_PhB = Power(4);
MEAS(t).Sub_Q_PhC = Power(6);
%Calculate Substation PF:
MEAS(t).PF(1,1) = abs(MEAS(t).Sub_P_PhA)/(sqrt((MEAS(t).Sub_P_PhA^2)+(MEAS(t).Sub_Q_PhA^2))); %PF_phA
MEAS(t).PF(1,2) = abs(MEAS(t).Sub_P_PhB)/(sqrt((MEAS(t).Sub_P_PhB^2)+(MEAS(t).Sub_Q_PhB^2))); %PF_phB
MEAS(t).PF(1,3) = abs(MEAS(t).Sub_P_PhC)/(sqrt((MEAS(t).Sub_P_PhC^2)+(MEAS(t).Sub_Q_PhC^2))); %PF_phC
MEAS(t).PF(1,4) = (MEAS(t).PF(1,1)+MEAS(t).PF(1,2)+MEAS(t).PF(1,3))/3;                        %average PF
MEAS(t).PF(1,5) = MEAS(t).Sub_Q_PhA+MEAS(t).Sub_Q_PhB+MEAS(t).Sub_Q_PhC;
%See if PF is lead/lag:
if MEAS(t).PF(1,5) < 0
    MEAS(t).PF(1,6)=1; %lead
else
    MEAS(t).PF(1,6)=0; %lag
end
%%
DSSCircuit.SetActiveElement(sprintf('Capacitor.%s',swcap_name));
Power   = DSSCircuit.ActiveCktElement.Powers;
%Single Phase Reactive Power:
MEAS(t).CAP_Q_PhA = Power(2);
MEAS(t).CAP_Q_PhB = Power(4);
MEAS(t).CAP_Q_PhC = Power(6);
MEAS(t).PF(1,7) = MEAS(t).CAP_Q_PhA+MEAS(t).CAP_Q_PhB+MEAS(t).CAP_Q_PhC;
%DSSText.command = sprintf('? Capacitor.%s.states',swcap_name);
if abs(MEAS(t).CAP_Q_PhA) > Caps.Swtch*0.4
    cap_pos=1;
else
    cap_pos=0;
end
%%
%-- CAP. CONTROL:
PF_SUB_LG=0.96;  %lagging setpoint
PF_SUB_LD=0.98; %leading setpoint
CAP_CTRL_DELAY=45; %secs
if cap_timer == CAP_CTRL_DELAY
    %Now change the state accordingly:
    if cap_pos == 0
        DSSText.command=sprintf('Edit Capacitor.%s states=1',swcap_name);
        cap_pos=1;
        cap_timer=0;
        fprintf('\tCap Closed.\n');
    elseif cap_pos == 1
        DSSText.command=sprintf('Edit Capacitor.%s states=0',swcap_name);
        cap_pos=1;
        cap_timer=0;
        fprintf('\tCap Opened.\n');
    end
elseif cap_timer ~= 0
    %A timer is still running...
    cap_timer = cap_timer + 1;
elseif MEAS(t).PF(1,6) == 0 && MEAS(t).PF(1,5) > Caps.Swtch*3*1.1
    if cap_pos == 0 %meaning it is open right now:
        if cap_timer == 0
            vio_time=t;
            cap_timer = cap_timer+1;
            fprintf('SW_CAP Timer to close Initiated\n');
        end
    end
elseif MEAS(t).PF(1,6) == 1 && abs(MEAS(t).PF(1,5)) > Caps.Swtch*3*1.1 %to prevent low PF lag 
    if cap_pos == 1
        if cap_timer == 0
            vio_time=t;
            cap_timer = cap_timer+1;
            fprintf('SW_CAP Timer to open Initiated\n');
        end
    end
end

        
        
%%
%Save cap_pos command for next 1 sec of operation:
YEAR_CAPSTATUS(DAY_I).CAP_POS(t,1)=cap_pos;
YEAR_CAPSTATUS(DAY_I).Q_CAP(t,1)=MEAS(t).PF(1,7); %Reactive Power of cap_bank
YEAR_CAPCNTRL(DAY_I).CTL_PF(t,1)=MEAS(t).PF(1,4); %control PF
YEAR_CAPCNTRL(DAY_I).LD_LG(t,1)=MEAS(t).PF(1,6); %lead/lag

%CAPCNTRL_TROUBLE{1,1:4}={'cap_pos','Q_Cap','PF','Lead/lag'};
%{
CAPCNTRL_TROUBLE{t+1,1}=cap_pos;
CAPCNTRL_TROUBLE{t+1,2}=MEAS(t).PF(1,7);
CAPCNTRL_TROUBLE{t+1,3}=MEAS(t).PF(1,4);
CAPCNTRL_TROUBLE{t+1,4}=MEAS(t).PF(1,6);
CAPCNTRL_TROUBLE{t+1,5}=cap_timer;
CAPCNTRL_TROUBLE{t+1,6}=MEAS(t).Sub_P_PhA+MEAS(t).Sub_P_PhB+MEAS(t).Sub_P_PhC;
CAPCNTRL_TROUBLE{t+1,7}=MEAS(t).PF(1,5);
%}

