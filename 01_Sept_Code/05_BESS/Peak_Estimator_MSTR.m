function [ t_max, DAY_NUM,KW_MAX,E_kWh ] = Peak_Estimator_MSTR( P_DAY1,P_DAY2)
%Peak_Estimator: Look ahead function that will select peak kW interval of
%current day & next day. 
%   MASTER CONTROLLER FUNCTION ---
hr=1;
sum1=0;
sum2=0;
P_max=zeros(2,2);
for m=1:1:length(P_DAY1)
    if m < hr*60
        %Aggregate kWs
        sum1=sum1+P_DAY1(m);
        sum2=sum2+P_DAY2(m);
    elseif m == hr*60
        %Energy calc after aggregate completed.
        sum1=sum1+P_DAY1(m);
        sum2=sum2+P_DAY2(m);
        E_kWh(hr,1)=sum1/60;
        E_kWh(hr,2)=sum2/60;
        hr = hr + 1;
        sum1 = 0;
        sum2 = 0;
    end
    E_DAY1(m,1)=P_DAY1(m)/(1440/60);
    E_DAY2(m,1)=P_DAY2(m)/(1440/60);
    %now look for maximums:
    if P_DAY1(m) > P_max(1,1)
        P_max(1,1) = P_DAY1(m);
        P_max(2,1) = m;
    end
    if P_DAY2(m) > P_max(1,2)
        P_max(1,2) = P_DAY2(m);
        P_max(2,2) = m;
    end
end
%
if P_max(2,2)/60 < 9
    %then we have a peak during the morning, save energy!
    t_max=P_max(2,2); %hours
    DAY_NUM = 2;
    KW_MAX = P_max(1,2);
else
    %Typical evening peaking event
    t_max=P_max(2,1);
    DAY_NUM = 1;
    KW_MAX = P_max(1,1);
end
fprintf('\nTarget PEAK KW - kth min: %0.2f\n',t_max);
fprintf('On %dth Day\n',DAY_NUM);



end

