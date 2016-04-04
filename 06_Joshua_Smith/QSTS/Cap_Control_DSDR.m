%Cap_Control_DSDR
%{
Caps.Name{1}='E1183_2582120';
%}
t_15=t*60/900;
%CAP1:

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

YEAR_CAPSTATUS(DAY_I).Q_CAP(t_15,1)=MEAS(t_15).CAP1_3Q; %Reactive Power of cap_bank1
YEAR_CAPSTATUS(DAY_I).Q_CAP(t_15,2)=MEAS(t_15).CAP2_3Q;
YEAR_CAPSTATUS(DAY_I).Q_CAP(t_15,3)=MEAS(t_15).CAP3_3Q;%(1,3);

YEAR_CAPCNTRL(DAY_I).CTL_PF(t_15,1)=0;%MEAS(t).PF(1,4); %control PF
YEAR_CAPCNTRL(DAY_I).LD_LG(t_15,1)=0;%MEAS(t).PF(1,6); %lead/lag

