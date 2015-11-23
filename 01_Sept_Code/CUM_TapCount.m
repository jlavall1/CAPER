function [ TAP ] = CUM_TapCount( DATA_SAVE)
%UNTITLED Summary of this function goes here
%   Voltage Deviation index, timeseries calc tho
n = length(DATA_SAVE(1).LTC_Ops);
TAP = zeros(n,3);
for i=2:1:n
    if DATA_SAVE(1).LTC_Ops(i,3) ~= DATA_SAVE(1).LTC_Ops(i-1,3)
        %This means a tap change:
        TAP(i,1) = TAP(i-1,1)+1;
        %{
        if abs(DATA_SAVE(1).LTC_Ops(i,3)-DATA_SAVE(1).LTC_Ops(i-1,3)) == 0.00625
            TAP(i,1) = TAP(i-1,1)+1;
        elseif abs(DATA_SAVE(1).LTC_Ops(i,3)-DATA_SAVE(1).LTC_Ops(i-1,3)) == 0.00625*2
            TAP(i,1) = TAP(i-1,1)+2;
        end
        %}
    else
        TAP(i,1) = TAP(i-1,1);
    end

end

end

