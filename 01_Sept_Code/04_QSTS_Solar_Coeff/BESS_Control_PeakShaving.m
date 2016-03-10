%BESS_Control_PeakShaving:
%Objective: Implement MATLAB Control of kW & kVAR of BESS based on
%measurements from PCC:
%{
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
%}
%Control Power:
BESS(t).PCC=MEAS(t).Sub_P_PhA+MEAS(t).Sub_P_PhB+MEAS(t).Sub_P_PhC;
P_set=3500; %kW
P_max=1000;

DSSCircuit.SetActiveElement('Storage.BESS1');
%DSSCircuit.SetActiveElement('Bus.260007367');
DSSText.command='? Storage.BESS1.%stored';
BESS(t).SOC=str2double(DSSText.Result);
DSSText.command='? Storage.BESS1.%Discharge';
BESS(t).kW=P_max*(str2double(DSSText.Result))/100;

%{
if P_PCC(t)-P_set>P_set+P_set*0.02
    %Discharge
    P_diff=P_PCC(t)-P_set;
    if P_diff > P_max
        P_diff=P_max;
    end
    DSSText.command=sprintf('Edit Storage.BESS1 kW=%s State=DISCHARGING',num2str(P_diff));
    P_BAT(t)=P_diff;
else
    P_BAT(t)=0;
end
%}