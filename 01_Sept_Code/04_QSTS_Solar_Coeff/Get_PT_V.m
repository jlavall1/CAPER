%Finding correct V_PT:
DSSCircuit.SetActiveElement('Transformer.FLAY_RET_16271201 term=1')
DSSCircuit.ActiveElement.get

Phs_V=DSSCircuit.ActiveElement.Voltages;
V_phA=[Phs_V(1)+1i*Phs_V(2)];
V_phB=[Phs_V(3)+1i*Phs_V(4)];
V_phC=[Phs_V(5)+1i*Phs_V(6)];
V_mA=abs(V_phA)/60
V_mB=abs(V_phB)/60
V_mC=abs(V_phC)/60

V_phA_s=[Phs_V(9)+1i*Phs_V(10)];
V_phB_s=[Phs_V(11)+1i*Phs_V(12)];
V_phC_s=[Phs_V(13)+1i*Phs_V(14)];

V_mA_s=abs(V_phA_s)/60
V_mB_s=abs(V_phB_s)/60
V_mC_s=abs(V_phC_s)/60

v_PT=DSSCircObj.ActiveCircuit.AllBusVmagPu;
v_PT(6)*120

