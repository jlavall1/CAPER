%playing with DoD Schedule:
clear
clc
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
load M_MOCKS.mat
load M_MOCKS_SC.mat
M_PVSITE_SC = M_MOCKS_SC;
%
for i=1:1:12
    M_PVSITE(i).DAY(:,:) = M_MOCKS(i).DAY(1:end-1,1:6);    
    M_PVSITE(i).RR_1MIN(:,:) = M_MOCKS(i).RR_1MIN(:,1:3);
    M_PVSITE(i).kW(:,:) = M_MOCKS(i).kW(1:end-1,1);
    M_PVSITE(i).GHI = M_MOCKS(i).GHI;
end
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
DOY = 1;
for MNTH=1:1:12
    for DAY=1:1:MTH_LN(MNTH)
        kW_PU(:,DOY) = M_PVSITE(MNTH).kW(time2int(DAY,0,0):time2int(DAY,23,59),1)/5000; %PU
        DOY = DOY + 1;
    end
end
SET_REG=zeros(365,3);
for DOY=1:1:365
    SET_REG(DOY,2)=M_PVSITE_SC(DOY,4); %VI
    SET_REG(DOY,3)=M_PVSITE_SC(DOY,5); %CI
    for min=1:1:1440
        SET_REG(DOY,1) = SET_REG(DOY,1)+kW_PU(min,DOY)/60; %PU*h
    end
end

%GHI=M_PVSITE(MNTH).kW(time2int(DAY,0,0):time2int(DAY,23,59),1)/5000; %PU
%%
%CI = 0.01:0.01:1;
%beta=0.33;
beta=[0.44380209  0.01994886  6.51296679];
%normalize=7.5503;
%beta=beta/normalize;
B0=beta(1);
B1=beta(2);
B2=beta(3);

for DOY=1:1:365
    VI=SET_REG(DOY,2);
    CI=SET_REG(DOY,3);
    E(DOY,1)=B0+B1*VI+B2*CI;
    PU_HR = 5.33;
    if E(DOY,1) <= PU_HR %pu.hr
        DoD_tar(DOY,1)=(0.33/PU_HR)*E(DOY,1);
    else
        DoD_tar(DOY,1)=0.33;
    end
end
X=1:1:365;
plot(X,E(:,1),'r-');
hold on
plot(X,SET_REG(:,1),'b.');
fprintf('mean=%0.4f\n',mean(E(:,1)));
figure(2)
plot(X,DoD_tar)
