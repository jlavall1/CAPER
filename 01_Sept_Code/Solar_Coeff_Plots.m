%distributions of solar coefficients --

clear
clc
close all
s_b = 'C:\Users\jlavall\Documents\GitHub\CAPER';

%PV_location = 5; %shelby;murphy;taylorsville,mocksville,ararat,OldDOM,Mayberry
if PV_location == 1
    PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC');
    addpath(PV_dir);
    load M_SHELBY_INFO.mat
    M_PVSITE_INFO = M_SHELBY_INFO;
    clear M_SHELBY_INFO
elseif PV_location == 2
    PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\02_Murphy_NC');
    addpath(PV_dir);
    load M_MURPHY_INFO.mat
    M_PVSITE_INFO = M_MURPHY_INFO;
    clear M_MURPHY_INFO
elseif PV_location == 3
    PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\03_Taylorsville_NC');
    addpath(PV_dir);
    load M_TAYLOR_INFO.mat
    M_PVSITE_INFO = M_TAYLOR_INFO;
    clear M_TAYLOR_INFO
elseif PV_location == 4
    PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
    addpath(PV_dir);
    load M_MOCKS_INFO.mat
    M_PVSITE_INFO = M_MOCKS_INFO;
    clear M_MOCKS_INFO
elseif PV_location == 5
    PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\05_AraratRock_NC');
    addpath(PV_dir);
    load M_AROCK_INFO.mat
    M_PVSITE_INFO = M_AROCK_INFO;
    clear M_AROCK_INFO
elseif PV_location == 6
    PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\06_OldDominion_NC');
    addpath(PV_dir);
    load M_ODOM_INFO.mat
    M_PVSITE_INFO = M_ODOM_INFO;
    clear M_ODOM_INFO
elseif PV_location == 7
    PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\07_MayBerry_NC');
    addpath(PV_dir);
    load M_MAYB_INFO.mat
    M_PVSITE_INFO = M_MAYB_INFO;
    clear M_MAYB_INFO
end 

figure(1);
X = 0:1:364;
%Draw bands of categories --
Y = ones(1,365)*3;
plot(X,Y,'k-','LineWidth',3);
hold on
Y = ones(1,365)*13;
plot(X,Y,'k-','LineWidth',3);
hold on
Y = ones(1,365)*23;
plot(X,Y,'k-','LineWidth',3);
hold on
Y = ones(1,365)*33;
plot(X,Y,'k-','LineWidth',3);
hold on
%Plot DARR for annual distribution --
plot(M_PVSITE_INFO.DARR,'r-','LineWidth',2)
hold on


xlabel('Day of Year (DoY)','fontweight','bold','fontsize',12);
ylabel('Daily Aggregate Ramp Rate (DARR)','fontweight','bold','fontsize',12);
axis([0 365 0 80]);

figure(2);
hist(M_PVSITE_INFO.VI,20);
h(2) = findobj(gca,'Type','patch');
set(h(2),'FaceColor',[0 0.75 0.75]);
xlabel('VI Magnitude Group','fontweight','bold','fontsize',12);
ylabel('Number of Days','fontweight','bold','fontsize',12);
axis([0 40 0 100]);

figure(3);
hist(M_PVSITE_INFO.CI,20,'g')
clear h(2)
h(3) = findobj(gca,'Type','patch');
set(h(3),'FaceColor',[0.2 0.8 0.2]);
xlabel('CI Magnitude Group','fontweight','bold','fontsize',12);
ylabel('Number of Days','fontweight','bold','fontsize',12);
axis([0 1.1 0 40]);
