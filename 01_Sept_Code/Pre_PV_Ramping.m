%This algorithm will calculate the DARRmin

clear
clc
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC')
load DARR_SHELBY.mat
tic
load M_SHELBY_COMPLETE.mat
toc
%DARR = Solar_C_SHELBY(:,6);
PV1_1MW.name = 'Shelby';
PV1_1MW.DARR = Solar_C_SHELBY(:,6);
PV1_1MW.VI = Solar_C_SHELBY(:,4);
PV1_1MW.CI = Solar_C_SHELBY(:,5);
PV1_1MW.DATE = Solar_C_SHELBY(:,1:3);
%%
%Calculations:
ii = 1;
j = 1;
k = 1;
l = 1;
m = 1;
n = 1;
for i=1:1:length(Solar_C_SHELBY)
    DARR = PV1_1MW.DARR(i,1);
    CI = PV1_1MW.CI(i,1);
    TIME = PV1_1MW.DATE(i,1:3);
    if DARR < 3
        if CI > 0.2
            PV1_1MW.RR_distrib.Cat1(j,1:3) = TIME;
            PV1_1MW.RR_distrib.Cat1(j,4) = DARR;
            j = j + 1;
        else
            PV1_1MW.RR_distrib.Cat1_O(ii,1:3) = TIME;
            PV1_1MW.RR_distrib.Cat1_O(ii,4) = DARR;
            ii = ii + 1;
        end
    elseif DARR >= 3 && DARR < 13
        PV1_1MW.RR_distrib.Cat2(k,1:3) = TIME;
        PV1_1MW.RR_distrib.Cat2(k,4) = DARR;
        k = k + 1;
    elseif DARR >= 13 && DARR < 23
        PV1_1MW.RR_distrib.Cat3(l,1:3) = TIME;
        PV1_1MW.RR_distrib.Cat3(l,4) = DARR;
        l = l + 1;
    elseif DARR >= 23 && DARR < 33
        PV1_1MW.RR_distrib.Cat4(m,1:3) = TIME;
        PV1_1MW.RR_distrib.Cat4(m,4) = DARR;
        m = m + 1;
    elseif DARR >= 33
        PV1_1MW.RR_distrib.Cat5(n,1:3) = TIME;
        PV1_1MW.RR_distrib.Cat5(n,4) = DARR;
        PV1_1MW.RR_distrib.Cat5(n,5) = CI;
        n = n + 1;
    end
end

fprintf('Capacity (MW_{ac})\t\t\t 1\n');
fprintf('Category 1 clearsky:\t %0.2f\n',(length(PV1_1MW.RR_distrib.Cat1(:,1))/365)*100);
fprintf('Category 1 overcast:\t %0.2f\n',(length(PV1_1MW.RR_distrib.Cat1_O(:,1))/365)*100);
fprintf('Category 2:\t\t\t\t %0.2f\n',(length(PV1_1MW.RR_distrib.Cat2(:,1))/365)*100);
fprintf('Category 3:\t\t\t\t %0.2f\n',(length(PV1_1MW.RR_distrib.Cat3(:,1))/365)*100);
fprintf('Category 4:\t\t\t\t %0.2f\n',(length(PV1_1MW.RR_distrib.Cat4(:,1))/365)*100);
fprintf('Category 5:\t\t\t\t %0.2f\n',(length(PV1_1MW.RR_distrib.Cat5(:,1))/365)*100);




%Pull from DOY, MONTH, & DAY ---    PV1_1MW.RR_distrib.Cat5(n,1:3)
RR_max = 0;
for S_DAY=1:1:length(PV1_1MW.RR_distrib.Cat5(:,1))
   MNTH = PV1_1MW.RR_distrib.Cat5(S_DAY,2);
   M_SHELBY(MNTH).GHI 
    
    
end











%%
%Plotting
fig = 1;
figure(fig);
plot(PV1_1MW.VI,PV1_1MW.DARR,'bo');
hold on
X=0:.1:30;
plot(X,3,'r--','LineWidth',3);
hold on
plot(X,13,'r-','LineWidth',5);
hold on
plot(X,23,'r-','LineWidth',7);
hold on
plot(X,33,'r-','LineWidth',10);
hold off


fig = fig + 1;
x = PV1_1MW.VI;
y = PV1_1MW.CI;
Z = ones(365,365);
for i=1:1:length(Z)
    Z(:,i) = PV1_1MW.DARR;
end

[X,Y] = meshgrid(x,y);
%Z = Z*.PV1_1MW.DARR;
%%
%Z(:,1) = PV1_1MW.DARR;
%Z(:,2) = PV1_1MW.DARR;
%Zz = Solar_C_SHELBY(:,4:6);
colormap('jet');
cmap = colormap;
C = del2(Z);
%surf(PV1_1MW.VI,PV1_1MW.CI,PV1_1MW.DARR,cmap);
surf(X,Y,Z);
%{
[X,Y] = meshgrid(-8:.5:8);
R = sqrt(X.^2 + Y.^2) + eps;
Z = sin(R)./R;
surf(X,Y,Z)
colormap hsv
colorbar
%}
