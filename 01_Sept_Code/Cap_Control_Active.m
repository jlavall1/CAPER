
%Goal: To implement an external capacitor controller.

%References:
%   Cap_info
%   Bus_info
%   Line_info
%   KVAR_ACTUAL.sw_cap(:,1)

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
DSSCircuit.SetActiveElement('Capacitor.38391707_sw');
Power   = DSSCircuit.ActiveCktElement.Powers;
%Single Phase Reactive Power:
MEAS(t).CAP_Q_PhA = Power(2);
MEAS(t).CAP_Q_PhB = Power(4);
MEAS(t).CAP_Q_PhC = Power(6);
%Calculate Substation PF:
MEAS(t).PF(1,1) = abs(MEAS(t).Sub_P_PhA)/(sqrt((MEAS(t).Sub_P_PhA^2)+(MEAS(t).Sub_Q_PhA^2)));
MEAS(t).PF(1,2) = abs(MEAS(t).Sub_P_PhB)/(sqrt((MEAS(t).Sub_P_PhB^2)+(MEAS(t).Sub_Q_PhB^2)));
MEAS(t).PF(1,3) = abs(MEAS(t).Sub_P_PhC)/(sqrt((MEAS(t).Sub_P_PhC^2)+(MEAS(t).Sub_Q_PhC^2)));
MEAS(t).PF(1,4) = (MEAS(t).PF(1,1)+MEAS(t).PF(1,2)+MEAS(t).PF(1,3))/3;
MEAS(t).PF(1,5) = MEAS(t).Sub_Q_PhA+MEAS(t).Sub_Q_PhB+MEAS(t).Sub_Q_PhC;
MEAS(t).PF(1,7) = MEAS(t).CAP_Q_PhA+MEAS(t).CAP_Q_PhB+MEAS(t).CAP_Q_PhC;
if MEAS(t).PF(1,5) < 0
    MEAS(t).PF(1,6)=1; %Leading 3ph
else
    MEAS(t).PF(1,6)=0; %Lagging 3ph
end
%{
if sw_cap(t,1) == 1
    DSSText.command='Edit Capacitor.38391707_sw enabled=true';
    cap_pos=cap_pos+1;
else
    DSSText.command='Edit Capacitor.38391707_sw enabled=false';
    cap_pos=cap_pos-1;
end
%}
%if sw_cap(t,1) ~= cap_pos

    if MEAS(t).PF(1,6) == 0 && MEAS(t).PF(1,4) < 0.9
        if cap_pos ~= 1
            %DSSText.command='Edit Capacitor.38391707_sw enabled=true';
            cap_pos=cap_pos+1;
            wait_t = t;
        end
    elseif MEAS(t).PF(1,6) == 1 && MEAS(t).PF(1,4) < 0.99
        
        if cap_pos ~= 0
            %DSSText.command='Edit Capacitor.38391707_sw enabled=false';
            cap_pos=cap_pos-1;
            wait_t = t;
        end
    end
%end
%Save cap_pos after each interval:
CAP_OPS(DOY).PF(t,6)=cap_pos;
CAP_OPS(DOY).PF(t,7)=MEAS(t).PF(1,7);
CAP_OPS(DOY).PF(t,8)=MEAS(t).PF(1,4);

