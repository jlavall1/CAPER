%Should be hit at every time step:
%Outputs:
%   SCADA(t)
%   BESS_M(t)

% ===== SCADA COMMUNICATION EQUIVALENT =====

%------------------------------------------------
%   Datapoint 1] BESS Information:
DSSCircuit.SetActiveElement('Storage.BESS1');
DSSText.command='? Storage.BESS1.%stored';
BESS_M(t).SOC=str2double(DSSText.Result);
DSSText.command='? Storage.BESS1.%Discharge';
BESS_M(t).DR=BESS.Prated*(str2double(DSSText.Result))/100;
DSSText.command='? Storage.BESS1.%Charge';
BESS_M(t).CR=BESS.Prated*(str2double(DSSText.Result))/100;

%------------------------------------------------
%   Datapoint 2] DER-PV Information:
DSSCircuit.SetActiveElement('generator.PV');
%   Three Phase Real Power:
Power   = DSSCircuit.ActiveCktElement.Powers;
SCADA(t).PV_P = Power(1)+Power(3)+Power(5);

%   Max PV-BUS Voltage:
DSSCircuit.SetActiveElement(sprintf('bus.%s',num2str(PV_bus)));
Phs_V = DSSCircuit.ActiveCktElement.Voltages;
PV_V(1) =abs(Phs_V(1)+1i*Phs_V(2))/60;
PV_V(2) =abs(Phs_V(3)+1i*Phs_V(4))/60;
PV_V(3) =abs(Phs_V(5)+1i*Phs_V(6))/60;
SCADA(t).PV_V = max(PV_V);

%------------------------------------------------
%   Datapoint 3] SC-State Information:
DSSCircuit.SetActiveElement(sprintf('Capacitor.%s',swcap_name));
Power   = DSSCircuit.ActiveCktElement.Powers;
%   Reactive Power:
SCADA(t).SC_Q = Power(2)*3;

%------------------------------------------------
%   Datapoint 4] OLTC Information:
DSSCircuit.SetActiveElement(sprintf('Transformer.%s',trans_name));
%   Control Voltage:
Phs_V=DSSCircuit.ActiveElement.Voltages;
SCADA(t).OLTC_V=(Phs_V(13)+1i*Phs_V(14))/60; %Phase C on secondary side
%   Autotransformer Tap Position:
DSSText.command = sprintf('? Transformer.%s.Tap',trans_name);
SCADA(t).OLTC_TAP = str2double(DSSText.Result);

%------------------------------------------------
%   Datapoint 5] Meter Point Information:
DSSCircuit.SetActiveElement('Line.259126903');
Power   = DSSCircuit.ActiveCktElement.Powers;
SCADA(t).Meter_P = Power(1)+Power(3)+Power(5);
Phs_V = DSSCircuit.ActiveCktElement.Voltages;
PV_V(1) =abs(Phs_V(1)+1i*Phs_V(2))/60;
PV_V(2) =abs(Phs_V(3)+1i*Phs_V(4))/60;
PV_V(3) =abs(Phs_V(5)+1i*Phs_V(6))/60;
SCADA(t).Meter_V = max(PV_V);

%   Load at su
%SCADA(t).OLTC_P=MEAS(t).Sub_P_PhA+MEAS(t).Sub_P_PhB+MEAS(t).Sub_P_PhC;