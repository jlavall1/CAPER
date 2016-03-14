phaseVoltagesPH = {Buses_info.numPhases}.';
phasesVoltageNODE = {Buses_info.nodes};
Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
V_PU=Voltages';

n = length(phaseVoltagesPH);
m = 1;
j = 1;

for i=1:1:n
    if phaseVoltagesPH{i} == 3
        V_PU(j,3)=1;
        j = j + 1;
        V_PU(j,3)=2;
        j = j + 1;
        V_PU(j,3)=3;
        j = j + 1;
    elseif phaseVoltagesPH{i} == 2
        V_PU(j,3)=phasesVoltageNODE{i}(1);
        j = j + 1;
        V_PU(j,3)=phasesVoltageNODE{i}(2);
        j = j + 1;
    elseif phaseVoltagesPH{i} == 1
        V_PU(j,3)=phasesVoltageNODE{i}(1);
        j = j + 1;
    end
end
%{
while m <= n
    %filter out non-three phase nodes:
    if phaseVoltagesPH{m,1} == 3
        %indicator of 3ph
        V_PU(m:m+2,2)=ones(3,1);
        %phase node
        V_PU(m,3)=1;
        V_PU(m+1,3)=2;
        V_PU(m+2,3)=3;
        m = m + 3;
    elseif phaseVoltagesPH{m,1} == 2
        %indicator of 3ph
        V_PU(m:m+1,2)=zeros(2,1);
        %phase node
        V_PU(m,3)=phasesVoltageNODE{j}(1);
        V_PU(m+1,3)=phasesVoltageNODE{j}(2);
        m = m + 2;
    else
        %indicator of 3ph
        V_PU(m,2)=0;
        %phase node
        V_PU(m,3)=phasesVoltageNODE{j}(1);
        m = m + 1;
    end
    j = j + 1
end
%}
%%
TVD = zeros(1,4);
V_REG_A = V_PU(7,1);
V_REG_B = V_PU(8,1);
V_REG_C = V_PU(9,1);
V_REG = [V_REG_A,V_REG_B,V_REG_C]

for j=7:1:n
    PH=V_PU(j,3);
    TVD(1,1)=TVD(1,1)+(V_PU(j,1)-V_REG(PH))^2;
end
plot(V_PU(:,1),'b.')
TVD(1,1)