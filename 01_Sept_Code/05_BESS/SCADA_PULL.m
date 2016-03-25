%Should be hit at every time step:
%Outputs:
%   SCADA(t)
%   BESS_M(t)

% ===== SCADA COMMUNICATION EQUIVALENT =====

%--------------
%   Datapoint 1] BESS Information:
DSSCircuit.SetActiveElement('Storage.BESS1');
DSSText.command='? Storage.BESS1.%stored';
BESS_M(t).SOC=str2double(DSSText.Result);           %<---------------------
DSSText.command='? Storage.BESS1.%Discharge';
BESS_M(t).DR=BESS.Prated*(str2double(DSSText.Result))/100;%<---------------
DSSText.command='? Storage.BESS1.%Charge';
BESS_M(t).CR=BESS.Prated*(str2double(DSSText.Result))/100;%<---------------

%--------------
%   Datapoint 2] DER-PV Information:
DSSCircuit.SetActiveElement('generator.PV');
%   Three Phase Real Power:
Power   = DSSCircuit.ActiveCktElement.Powers;
SCADA(t).PV_P = Power(1)+Power(3)+Power(5);         %<---------------------

%   Max PV-BUS Voltage:
DSSCircuit.SetActiveElement(sprintf('bus.%s',num2str(PV_bus)));
Phs_V = DSSCircuit.ActiveCktElement.Voltages;
PV_V(1) =abs(Phs_V(1)+1i*Phs_V(2))/60;
PV_V(2) =abs(Phs_V(3)+1i*Phs_V(4))/60;
PV_V(3) =abs(Phs_V(5)+1i*Phs_V(6))/60;
SCADA(t).PV_V = max(PV_V);                          %<---------------------

%---------------
%   Datapoint 3] SC-State Information:
DSSCircuit.SetActiveElement(sprintf('Capacitor.%s',swcap_name));
Power   = DSSCircuit.ActiveCktElement.Powers;
%   Reactive Power:
SCADA(t).SC_Q = Power(2)+Power(4)+Power(6);         %<---------------------
if SCADA(t).SC_Q == 0
    SCADA(t).SC_S = 0;                              %<---------------------
else
    SCADA(t).SC_S = 1;                              %<---------------------
end

%---------------
%   Datapoint 4] OLTC Information:
DSSCircuit.SetActiveElement(sprintf('Transformer.%s',trans_name));
%   Control Voltage:
Phs_V=DSSCircuit.ActiveElement.Voltages; %Phase C on secondary side
SCADA(t).OLTC_V=abs((Phs_V(13)+1i*Phs_V(14)))/60;   %<---------------------
%   Autotransformer Tap Position:
DSSText.command = sprintf('? Transformer.%s.Tap',trans_name);
SCADA(t).OLTC_TAP = str2double(DSSText.Result);     %<---------------------

%---------------
%   Datapoint 5] Meter Point Information:
DSSCircuit.SetActiveElement('Line.259126903');
Power   = DSSCircuit.ActiveCktElement.Powers;
SCADA(t).Meter_P = Power(1)+Power(3)+Power(5);      %<---------------------
Phs_V = DSSCircuit.ActiveCktElement.Voltages;
PV_V(1) =abs(Phs_V(1)+1i*Phs_V(2))/60;
PV_V(2) =abs(Phs_V(3)+1i*Phs_V(4))/60;
PV_V(3) =abs(Phs_V(5)+1i*Phs_V(6))/60;
SCADA(t).Meter_V = max(PV_V);                       %<---------------------

%---------------
%   Datapoint 6] Head of Feeder Point Information:
DSSCircuit.SetActiveElement(sprintf('Line.%s',sub_line));
%   Real Power:
Power   = DSSCircuit.ActiveCktElement.Powers;
SCADA(t).Sub_P(1) = Power(1);
SCADA(t).Sub_P(2) = Power(3);
SCADA(t).Sub_P(3) = Power(5);
SCADA(t).Sub_3P = SCADA(t).Sub_P(1)+SCADA(t).Sub_P(2)+SCADA(t).Sub_P(3);
%   Reactive Power:
SCADA(t).Sub_Q(1) = Power(2);
SCADA(t).Sub_Q(2) = Power(4);
SCADA(t).Sub_Q(3) = Power(6);
SCADA(t).Sub_3Q = SCADA(t).Sub_Q(1)+SCADA(t).Sub_Q(2)+SCADA(t).Sub_Q(3);
%   PF for SC Control:
PF_A = abs(SCADA(t).Sub_P(1))/(sqrt((SCADA(t).Sub_P(1)^2)+(SCADA(t).Sub_Q(1)^2)));
PF_B = abs(SCADA(t).Sub_P(2))/(sqrt((SCADA(t).Sub_P(2)^2)+(SCADA(t).Sub_Q(2)^2)));
PF_C = abs(SCADA(t).Sub_P(3))/(sqrt((SCADA(t).Sub_P(3)^2)+(SCADA(t).Sub_Q(3)^2)));
SCADA(t).Sub_PF = mean([PF_A,PF_B,PF_C]);
if SCADA(t).Sub_3Q < 0
    SCADA(t).Sub_LDLG=1; %lead
else
    SCADA(t).Sub_LDLG=0; %lag
end








