function [ KVAR_ACTUAL ] = Find_Cap_Ops(KVAR_ACTUAL,sim_num,s_step,Caps)
%Goal: Find Capacitor operations based on profile

%sim_num=1440
%s_step=60s
for i=2:1:1400
    for ph=1:1:3
        KVAR_diff = KVAR_ACTUAL(i-1,ph)-KVAR_ACTUAL(i,ph);
        if KVAR_diff > Caps.Swtch(1)*0.5
            %increases in Q meaning Cap turns off.
            KVAR_ACTUAL(i,ph+3)=0;
        elseif KVAR_diff < -1*Caps.Swtch(1)*0.4
            KVAR_ACTUAL(i,ph+3)=1;
        end
    end
end


end

