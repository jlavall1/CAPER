load('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC\M_SHELBY_SC.mat')
load('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC\M_MOCKS_SC.mat')
M2 = M_SHELBY_SC(:,6)/max(M_SHELBY_SC(:,6)+M_SHELBY_SC(:,5));
M1 = M_MOCKS_SC(:,6)/max(M_MOCKS_SC(:,6)+M_MOCKS_SC(:,5));
plot(M1,'g-')
hold on
plot(M2,'g-')
legend('PV1','PV2');
figure(2)
plot(M1+M2);