%Cap_Control_DSDR
%{
Caps.Name{1}='E1183_2582120';
%}
t_15=t/900;
%CAP1:
cap_n = 1;
DSSCircuit.SetActiveElement(sprintf('Capacitor.%s',Caps.Name{cap_n}));
Power   = DSSCircuit.ActiveCktElement.Powers;
%   Single Phase Reactive Power:
MEAS(t_15).CAP_Q_PhA = Power(2);
MEAS(t_15).CAP_Q_PhB = Power(4);
MEAS(t_15).CAP_Q_PhC = Power(6);
MEAS(t_15).PF(1,cap_n) = MEAS(t_15).CAP_Q_PhA+MEAS(t_15).CAP_Q_PhB+MEAS(t_15).CAP_Q_PhC;
%CAP2:
cap_n = cap_n + 1;
DSSCircuit.SetActiveElement(sprintf('Capacitor.%s',Caps.Name{cap_n}));
Power   = DSSCircuit.ActiveCktElement.Powers;
%   Single Phase Reactive Power:
MEAS(t_15).CAP_Q_PhA = Power(2);
MEAS(t_15).CAP_Q_PhB = Power(4);
MEAS(t_15).CAP_Q_PhC = Power(6);
MEAS(t_15).PF(1,cap_n) = MEAS(t_15).CAP_Q_PhA+MEAS(t_15).CAP_Q_PhB+MEAS(t_15).CAP_Q_PhC;
%CAP3:
cap_n = cap_n + 1;
DSSCircuit.SetActiveElement(sprintf('Capacitor.%s',Caps.Name{cap_n}));
Power   = DSSCircuit.ActiveCktElement.Powers;
%   Single Phase Reactive Power:
MEAS(t_15).CAP_Q_PhA = Power(2);
MEAS(t_15).CAP_Q_PhB = Power(4);
MEAS(t_15).CAP_Q_PhC = Power(6);
MEAS(t_15).PF(1,cap_n) = MEAS(t_15).CAP_Q_PhA+MEAS(t_15).CAP_Q_PhB+MEAS(t_15).CAP_Q_PhC;
%%
%Update to new cap positions:
DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{1},num2str(CAP_OPS(DAY_I).oper(t_15,1)));
DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{2},num2str(CAP_OPS(DAY_I).oper(t_15,2)));
DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{3},num2str(CAP_OPS(DAY_I).oper(t_15,3)));
%%
%Save cap_pos command for next 1 sec of operation:
YEAR_CAPSTATUS(DAY_I).CAP_POS(t_15,1)=CAP_OPS(DAY_I).oper(t_15,1);
YEAR_CAPSTATUS(DAY_I).CAP_POS(t_15,2)=CAP_OPS(DAY_I).oper(t_15,2);
YEAR_CAPSTATUS(DAY_I).CAP_POS(t_15,3)=CAP_OPS(DAY_I).oper(t_15,3);

YEAR_CAPSTATUS(DAY_I).Q_CAP(t_15,1)=MEAS(t_15).PF(1,1); %Reactive Power of cap_bank1
YEAR_CAPSTATUS(DAY_I).Q_CAP(t_15,2)=MEAS(t_15).PF(1,2);
YEAR_CAPSTATUS(DAY_I).Q_CAP(t_15,3)=MEAS(t_15).PF(1,3);

YEAR_CAPCNTRL(DAY_I).CTL_PF(t_15,1)=0;%MEAS(t).PF(1,4); %control PF
YEAR_CAPCNTRL(DAY_I).LD_LG(t_15,1)=0;%MEAS(t).PF(1,6); %lead/lag

