clear
clc
close all
%This .m file will compare all PV Plant Site's RR CDFs:

%Load Results from individual analysis:
PV_Site_path1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC';
addpath(PV_Site_path1);
load M_SHELBY_INFO.mat
PV_Site_path2 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\02_Murphy_NC';
addpath(PV_Site_path2);
load M_MURPHY_INFO.mat
PV_Site_path3 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\03_Taylorsville_NC';
addpath(PV_Site_path3);
load M_TAYLOR_INFO.mat
PV_Site_path4 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC';
addpath(PV_Site_path4);
load M_MOCKS_INFO.mat
PV_Site_path5 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\05_AraratRock_NC';
addpath(PV_Site_path5);
load M_AROCK_INFO.mat
PV_Site_path6 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\06_OldDominion_NC';
addpath(PV_Site_path6);
load M_ODOM_INFO.mat
PV_Site_path7 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\07_MayBerry_NC';
addpath(PV_Site_path7);
load M_MAYB_INFO.mat

%%
%Create Plot of Cat.5 CDFs:
fig = 1;
figure(fig)
% 5MW
save_COUNT = M_MOCKS_INFO.save_COUNT(1,:);
plot(M_MOCKS_INFO.CDF_DARRcat(1:save_COUNT(1,5),5),M_MOCKS_INFO.CDF_DARRcat(1:save_COUNT(1,5),10),'g-','LineWidth',2.5);
d1 = length(M_MOCKS_INFO.RR_distrib.Cat5);
hold on
% 3.5MW
save_COUNT = M_AROCK_INFO.save_COUNT(1,:);
plot(M_AROCK_INFO.CDF_DARRcat(1:save_COUNT(1,5),5),M_AROCK_INFO.CDF_DARRcat(1:save_COUNT(1,5),10),'k-','LineWidth',2.5);
d2 = length(M_AROCK_INFO.RR_distrib.Cat5);
hold on
% 1.5MW
save_COUNT = M_ODOM_INFO.save_COUNT(1,:);
plot(M_ODOM_INFO.CDF_DARRcat(1:save_COUNT(1,5),5),M_ODOM_INFO.CDF_DARRcat(1:save_COUNT(1,5),10),'r-','LineWidth',2.5);
d3 = length(M_ODOM_INFO.RR_distrib.Cat5);
hold on
% 1.0MW
save_COUNT = M_SHELBY_INFO.save_COUNT(1,:);
plot(M_SHELBY_INFO.CDF_DARRcat(1:save_COUNT(1,5),5),M_SHELBY_INFO.CDF_DARRcat(1:save_COUNT(1,5),10),'b-','LineWidth',2.5);
d4 = length(M_SHELBY_INFO.RR_distrib.Cat5);
hold on
% 1.0MW
save_COUNT = M_MURPHY_INFO.save_COUNT(1,:);
plot(M_MURPHY_INFO.CDF_DARRcat(1:save_COUNT(1,5),5),M_MURPHY_INFO.CDF_DARRcat(1:save_COUNT(1,5),10),'k--','LineWidth',2.5);
d5 = length(M_MURPHY_INFO.RR_distrib.Cat5);
hold on
% 1.0MW
save_COUNT = M_TAYLOR_INFO.save_COUNT(1,:);
plot(M_TAYLOR_INFO.CDF_DARRcat(1:save_COUNT(1,5),5),M_TAYLOR_INFO.CDF_DARRcat(1:save_COUNT(1,5),10),'r--','LineWidth',2.5);
d6 = length(M_TAYLOR_INFO.RR_distrib.Cat5);
% 1.0MW
save_COUNT = M_MAYB_INFO.save_COUNT(1,:);
plot(M_MAYB_INFO.CDF_DARRcat(1:save_COUNT(1,5),5),M_MAYB_INFO.CDF_DARRcat(1:save_COUNT(1,5),10),'b--','LineWidth',2.5);
d7 = length(M_MAYB_INFO.RR_distrib.Cat5);






%Plot settings:
legend(sprintf('%s MW:%s days',num2str(M_MOCKS_INFO.kW/1000),num2str(d1)),sprintf('%s MW:%s days',num2str(M_AROCK_INFO.kW/1000),num2str(d2)),...
    sprintf('%s MW:%s days',num2str(M_ODOM_INFO.kW/1000),num2str(d3)),sprintf('%s MW:%s days',num2str(M_SHELBY_INFO.kW/1000),num2str(d4)),...
    sprintf('%s MW:%s days',num2str(M_MURPHY_INFO.kW/1000),num2str(d5)),sprintf('%s MW:%s days',num2str(M_TAYLOR_INFO.kW/1000),num2str(d6)),...
    sprintf('%s MW:%s days',num2str(M_MAYB_INFO.kW/1000),num2str(d7)),'Location','NorthWest');
axis([0 1.0 0.99 1])
grid on
set(gca,'FontWeight','bold');
xlabel('Ramp Rate (p.u.)','FontWeight','bold');
ylabel('Cumulative Probability','FontWeight','bold');
title('Minute ramp rates - Cat. 5 days - All plants, 2014','FontWeight','bold');