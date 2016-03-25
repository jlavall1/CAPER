function [ TVD ] = TVD_Calc_5sec( V_PU,phaseVoltagesPH,phasesVoltageNODE,feeder_NUM)
%UNTITLED Summary of this function goes here
%   Voltage Deviation index, timeseries calc tho

%   DATA_SAVE(j,1).phaseV = subVoltages;
%V_PU=DSSCircObj.ActiveCircuit.AllBusVmagPu;
n = length(phaseVoltagesPH);
m = 1;
j = 1;
%Assign phase to NODE
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
        V_PU(m,3)=phaseVoltagesPH{m,1};
        V_PU(m+1,3)=phaseVoltagesPH{m+1,1};
        m = m + 2;
    else
        %indicator of 3ph
        V_PU(m,2)=0;
        %phase node
        V_PU(m,3)=phaseVoltagesPH{m,1};
        m = m + 1;
    end
end
V_PU
%}
TVD = zeros(1,1);
if feeder_NUM == 1
    V_REG_A = V_PU(7,1);
    V_REG_B = V_PU(8,1);
    V_REG_C = V_PU(9,1);
elseif feeder_NUM == 2
    V_REG_A = V_PU(7,1);
    V_REG_B = V_PU(8,1);
    V_REG_C = V_PU(9,1);
else
    V_REG_A = V_PU(1,1);
    V_REG_B = V_PU(2,1);
    V_REG_C = V_PU(3,1);
end
V_REG = [V_REG_A,V_REG_B,V_REG_C];

for j=1:1:n
    PH=V_PU(j,3);
    TVD(1,1)=TVD(1,1)+(V_PU(j,1)-V_REG(PH))^2;
end


%{
for j=1:1:n
    %go through and conduct inner summation:
    if V_PU(j,2) == 1
        if V_PU(j,3) == 1
            %phase A
            V_A = V_PU(j,1);
            if V_A > 1.05
                TVD(1,4)=1;
            end
            TVD(1,1) = TVD(1,1) + (abs(V_REG_A-V_A)^2);
        elseif V_PU(j,3) == 2
            %phase B
            V_B = V_PU(j,1);
            if V_B > 1.05
                TVD(1,4)=1;
            end
            TVD(1,2) = TVD(1,2) + (abs(V_REG_B-V_B)^2);
        elseif V_PU(j,3) == 3
            %phase C
            V_C = V_PU(j,1);
            if V_C > 1.05
                TVD(1,4)=1;
            end
            TVD(1,3) = TVD(1,3) + (abs(V_REG_C-V_C)^2);
        end
    end
end
%}
%TVD=[TVD_A,TVD_B,TVD_C,VIOLATION=1]
end

