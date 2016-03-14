function [ TVD ] = TVD_Calc_5sec( V_PU,phaseVoltagesPU)
%UNTITLED Summary of this function goes here
%   Voltage Deviation index, timeseries calc tho

%   DATA_SAVE(j,1).phaseV = subVoltages;
%V_PU=DSSCircObj.ActiveCircuit.AllBusVmagPu;
n = length(phaseVoltagesPU);
m = 1;
while m <= n
    %filter out non-three phase nodes:
    if length(phaseVoltagesPU{m,1}) == 3
        V_PU(m:m+2,2)=ones(3,1);
        V_PU(m,3)=1;
        V_PU(m+1,3)=2;
        V_PU(m+2,3)=3;
        m = m + 3;
    elseif length(phaseVoltagesPU{m,1}) == 2
        V_PU(m:m+1,2)=zeros(2,1);
        m = m + 2;
    else
        V_PU(m,2)=0;
        m = m + 1;
    end
end
TVD = zeros(1,4);
V_REG_A = V_PU(1,1);
V_REG_B = V_PU(2,1);
V_REG_C = V_PU(3,1);
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
%TVD=[TVD_A,TVD_B,TVD_C,VIOLATION=1]
end

