%BESS_Control_PeakShaving:
%Objective: Implement MATLAB Control


%obtain SOC-ref:
if t == 1
    %10seconds into sim, conduct initial guess:
    CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
    BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
    CSI_TH=0.2;
    C=BESS.Crated; %only for first DOY
    DSSText.command=sprintf('Edit Storage.BESS1 %%stored=%s',num2str(100*(1-BESS.DoD_max)));
    DoD=BESS.DoD_max;
    [SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD);
end


%%

if CR_ref(t,1) ~= 0 && BESS_M(t).SOC < 100
    DSSText.command=sprintf('Edit Storage.BESS1 %%Charge=%s State=CHARGING',num2str(100*1.06*(CR_ref(t,1)/BESS.Prated)));
elseif BESS_M(t).CR ~= 0
    %because the CR_ref wanted 0 & SOC might be > 100 then:
    DSSText.command='Edit Storage.BESS1 %Charge=0 State=IDLING';
end

%{
if t==t_CR(1,1)*3600
    DSSText.command=sprintf('Edit Storage.BESS1 %%Charge=%s State=CHARGING',num2str(100*(363.6300/BESS.Prated)));
elseif t==t_CR(1,7)*3600
    DSSText.command='Edit Storage.BESS1 kW=0 State=IDLING';
end
%}  





%{
if ss*t/3600 < 12 && t > 2 %>2 to make up for going from 5sec -> 1sec.
    if BESS_M(t).PCC>P_set+P_set*0.01
        %-- Upper Bound --

        %Discharge
        P_diff=BESS_M(t).PCC-P_set;
        if P_diff > P_max
            P_diff=P_max;
        end
        DSSText.command=sprintf('Edit Storage.BESS1 kW=%s State=DISCHARGING',num2str(P_diff));
        P_BAT(t)=P_diff;
    else
        DSSText.command='Edit Storage.BESS1 State=IDLING';
        P_BAT(t)=0;
    end
else
    %do nothing
    DSSText.command='Edit Storage.BESS1 State=IDLING';
    P_BAT(t)=0;
end
%}



