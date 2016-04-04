%SCADA
DSSCircuit.SetActiveElement(sprintf('Line.%s',sub_line));
Power   = DSSCircuit.ActiveCktElement.Powers;
%Single Phase Real Power:
MEAS(t).Sub_P_PhA = Power(1);
MEAS(t).Sub_P_PhB = Power(3);
MEAS(t).Sub_P_PhC = Power(5);
%Single Phase Reactive Power:
MEAS(t).Sub_Q_PhA = Power(2);
MEAS(t).Sub_Q_PhB = Power(4);
MEAS(t).Sub_Q_PhC = Power(6);

%%
cap_n = 1;
DSSCircuit.SetActiveElement(sprintf('Capacitor.%s',Caps.Name{cap_n}));
Power   = DSSCircuit.ActiveCktElement.Powers;
%   Single Phase Reactive Power:
MEAS(t).CAP2_Q_PhA = Power(2);
MEAS(t).CAP2_Q_PhB = Power(4);
MEAS(t).CAP2_Q_PhC = Power(6);
MEAS(t).CAP2_3Q = MEAS(t).CAP2_Q_PhA+MEAS(t).CAP2_Q_PhB+MEAS(t).CAP2_Q_PhC;
%%
%CAP2:
cap_n = cap_n + 1;
DSSCircuit.SetActiveElement(sprintf('Capacitor.%s',Caps.Name{cap_n}));
Power   = DSSCircuit.ActiveCktElement.Powers;
%   Single Phase Reactive Power:
MEAS(t).CAP3_Q_PhA = Power(2);
MEAS(t).CAP3_Q_PhB = Power(4);
MEAS(t).CAP3_Q_PhC = Power(6);
MEAS(t).CAP3_3Q = MEAS(t).CAP3_Q_PhA+MEAS(t).CAP3_Q_PhB+MEAS(t).CAP3_Q_PhC;
%%
%CAP3:
cap_n = cap_n + 1;
DSSCircuit.SetActiveElement(sprintf('Capacitor.%s',Caps.Name{cap_n}));
Power   = DSSCircuit.ActiveCktElement.Powers;
%   Single Phase Reactive Power:
MEAS(t).CAP1_Q_PhA = Power(2);
MEAS(t).CAP1_Q_PhB = Power(4);
MEAS(t).CAP1_Q_PhC = Power(6);
MEAS(t).CAP1_3Q = MEAS(t).CAP1_Q_PhA+MEAS(t).CAP1_Q_PhB+MEAS(t).CAP1_Q_PhC;