function [ TVD ] = TVD_Calc( DATA_SAVE)
%UNTITLED Summary of this function goes here
%   Voltage Deviation index, timeseries calc tho
n = length(DATA_SAVE(2).phaseV);
TVD = zeros(n,3);
for i=1:1:n
    for j=2:1:length(DATA_SAVE)
        V_B = DATA_SAVE(j).Vbase;
        V_REG = 1.04;
        TVD(i,1) = TVD(i,1) + (abs(V_REG-(DATA_SAVE(j).phaseV(i,1)/V_B))^2); %phA
        TVD(i,2) = TVD(i,2) + (abs(V_REG-(DATA_SAVE(j).phaseV(i,2)/V_B))^2); %phA
        TVD(i,3) = TVD(i,3) + (abs(V_REG-(DATA_SAVE(j).phaseV(i,3)/V_B))^2); %phA
    end
end
end

