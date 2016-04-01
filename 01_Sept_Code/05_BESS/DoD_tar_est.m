function [ DoD_tar ] = DoD_tar_est( M_PVSITE_SC_1,BESS,P_PV)
%This function is based on a linear regression model of PU*h~VI+CI

%   Update BESS Characteristics:
DoD_max=BESS.DoD_max;
C_r = BESS.Crated;
%P_PV = 3000; %KW
%   Calculate DOD_tar:

CI_k1 = M_PVSITE_SC_1(1,5);
if CI_k1 > 1
    CI_k1 = 1;
end
VI_k1 = M_PVSITE_SC_1(1,4);

%   Coeffiecients found doing least squares regression
%beta=[0.44380209  0.01994886  6.51296679];
beta=[0.45193329  0.01344715  7.28591556 ];
B_r = 0.2729; %C_bat/mean_kWh;

%   Find estimated per-unit*hours (daily aggregate energy)
E_pu=beta(1)+beta(2)*VI_k1+beta(3)*CI_k1;
%   Generate DoD target to prep for next day...
PU_HR=(DoD_max*C_r)/(P_PV*B_r);
if E_pu <= PU_HR %pu.hr
    DoD_tar=(0.33/PU_HR)*E_pu;
else
    DoD_tar=DoD_max;
end



end

