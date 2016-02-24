
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
DSSCircuit.SetActiveElement('Capacitor.38391707_sw');
Power   = DSSCircuit.ActiveCktElement.Powers;
%Single Phase Reactive Power:
MEAS(t).CAP_Q_PhA = Power(2);
MEAS(t).CAP_Q_PhB = Power(4);
MEAS(t).CAP_Q_PhC = Power(6);
MEAS(t).PF(1,7) = MEAS(t).CAP_Q_PhA+MEAS(t).CAP_Q_PhB+MEAS(t).CAP_Q_PhC;
%%
%-- CAP. CONTROL:
PF_SUB_LG=0.98;  %lagging setpoint
PF_SUB_LD=0.999; %leading setpoint
CAP_CTRL_DELAY=45; %secs
if MEAS(t).PF(1,6) == 0 && MEAS(t).PF(1,4) < PF_SUB_LG
    if cap_pos == 0 %meaning it is open right now:
        if cap_timer == 0 && MEAS(t).PF(1,5) > Caps.Swtch*3*1.2 %to prevent leading PF
            vio_time=t;
            cap_timer = cap_timer+1;
        elseif cap_timer == CAP_CTRL_DELAY
            %Let us now change CAP state:
            DSSText.command='Edit Capacitor.38391707_sw states=1';
            cap_pos=1;
            cap_timer=0;
        else
            cap_timer = cap_timer + 1 %inc by 1 sec. on timer
        end
    end
elseif MEAS(t).PF(1,6) == 1 %&& MEAS(t).PF(1,4) < PF_SUB_LD
    if cap_pos == 1
        if cap_timer == 0
            vio_time=t;
            cap_timer = cap_timer+1;
        elseif cap_timer == CAP_CTRL_DELAY
            %Let us now change CAP state:
            DSSText.command='Edit Capacitor.38391707_sw states=0';
            cap_pos=0;
            cap_timer=0;
        else
            cap_timer = cap_timer + 1 %inc by 1 sec. on timer
        end
    end
end
%%
%Save cap_pos command for next 1 sec of operation:
YEAR_CAPSTATUS(DOY).CAP_POS(t,1)=cap_pos;
YEAR_CAPSTATUS(DOY).Q_CAP(t,1)=MEAS(t).PF(1,7); %Reactive Power of cap_bank
YEAR_CAPCNTRL(DOY).CTL_PF(t,1)=MEAS(t).PF(1,4); %control PF
YEAR_CAPCNTRL(DOY).LD_LG(t,1)=MEAS(t).PF(1,6); %lead/lag

