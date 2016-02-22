function [ TVD ] = TVD_Calc( DATA_QSTS,V_REG)
%UNTITLED Summary of this function goes here
%   Voltage Deviation index, timeseries calc tho

%   DATA_SAVE(j,1).phaseV = subVoltages;

n = length(DATA_QSTS(2,1).phaseV(:,1));

TVD = zeros(n,3);
for t=1:1:n %Time
    V_NOM_A = DATA_QSTS(2,1).phaseV(t,1);
    V_NOM_B = DATA_QSTS(2,1).phaseV(t,2);
    V_NOM_C = DATA_QSTS(2,1).phaseV(t,3);
    
    for j=2:1:length(DATA_QSTS(:,1)) %circuit
        %V_REG = 1.04;
        V_A = DATA_QSTS(j,1).phaseV(t,1);
        V_B = DATA_QSTS(j,1).phaseV(t,2);
        V_C = DATA_QSTS(j,1).phaseV(t,3);
        
        TVD(t,1) = TVD(t,1) + (abs(V_REG-(V_A/V_NOM_A))^2); %phA
        TVD(t,2) = TVD(t,2) + (abs(V_REG-(V_B/V_NOM_B))^2); %phB
        TVD(t,3) = TVD(t,3) + (abs(V_REG-(V_C/V_NOM_C))^2); %phC
    end
end
end

