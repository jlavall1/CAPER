%This algorithm will calculate the DARRmin

clear
clc
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles');
%Import Dynamic Datasets:
%Ask user which site do they want?

USER_DEF = GUI_PV_Locations();
sim_type = USER_DEF(1,1);
PV_Site = USER_DEF(1,2);
FIG_type = USER_DEF(1,3);

if sim_type == 1
    if PV_Site == 1
        PV_Site_path1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC';
        addpath(PV_Site_path1);
        load M_SHELBY.mat
        load M_SHELBY_SC.mat
        M_PVSITE = M_SHELBY;    %make general --
        M_PVSITE_SC = M_SHELBY_SC;
        PV1_MW.name = 'Shelby';
        PV1_MW.kW = 1000;
    elseif PV_Site == 2
        PV_Site_path2 = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\02_Murphy_NC';
        addpath(PV_Site_path2);
        load M_MURPHY.mat
        load M_MURPHY_SC.mat
        M_PVSITE = M_MURPHY;    %make general --
        M_PVSITE_SC = M_MURPHY_SC;
        PV1_MW.name = 'Murphy';
        PV1_MW.kW = 1000;
    end
elseif sim_type == 2

end
%
PV1_MW.DARR = M_PVSITE_SC(:,6);
PV1_MW.VI = M_PVSITE_SC(:,4);
PV1_MW.CI = M_PVSITE_SC(:,5);
PV1_MW.DATE = M_PVSITE_SC(:,1:3);
%
%Calculations:
ii = 1;
j = 1;
k = 1;
l = 1;
m = 1;
n = 1;
COUNT = 0;
for i=1:1:length(M_PVSITE_SC)
    DARR = PV1_MW.DARR(i,1);
    CI = PV1_MW.CI(i,1);
    TIME = PV1_MW.DATE(i,1:3);
    if DARR < 3 && DARR ~= 0
        if CI > 0.2
            PV1_MW.RR_distrib.Cat1(j,1:3) = TIME;
            PV1_MW.RR_distrib.Cat1(j,4) = DARR;
            j = j + 1;
            COUNT = COUNT + 1;
        else
            PV1_MW.RR_distrib.Cat1_O(ii,1:3) = TIME;
            PV1_MW.RR_distrib.Cat1_O(ii,4) = DARR;
            ii = ii + 1;
            COUNT = COUNT + 1;
        end
    elseif DARR >= 3 && DARR < 13
        PV1_MW.RR_distrib.Cat2(k,1:3) = TIME;
        PV1_MW.RR_distrib.Cat2(k,4) = DARR;
        k = k + 1;
        COUNT = COUNT + 1;
    elseif DARR >= 13 && DARR < 23
        PV1_MW.RR_distrib.Cat3(l,1:3) = TIME;
        PV1_MW.RR_distrib.Cat3(l,4) = DARR;
        l = l + 1;
        COUNT = COUNT + 1;
    elseif DARR >= 23 && DARR < 33
        PV1_MW.RR_distrib.Cat4(m,1:3) = TIME;
        PV1_MW.RR_distrib.Cat4(m,4) = DARR;
        m = m + 1;
        COUNT = COUNT + 1;
    elseif DARR >= 33
        PV1_MW.RR_distrib.Cat5(n,1:3) = TIME;
        PV1_MW.RR_distrib.Cat5(n,4) = DARR;
        PV1_MW.RR_distrib.Cat5(n,5) = CI;
        n = n + 1;
        COUNT = COUNT + 1;
    end
end

fprintf('Capacity in MW_{ac}:\t %0.1f\n',PV1_MW.kW/1e3);
fprintf('Category 1 clearsky:\t %0.2f\n',(length(PV1_MW.RR_distrib.Cat1(:,1))/COUNT)*100);
fprintf('Category 1 overcast:\t %0.2f\n',(length(PV1_MW.RR_distrib.Cat1_O(:,1))/COUNT)*100);
fprintf('Category 2:\t\t\t\t %0.2f\n',(length(PV1_MW.RR_distrib.Cat2(:,1))/COUNT)*100);
fprintf('Category 3:\t\t\t\t %0.2f\n',(length(PV1_MW.RR_distrib.Cat3(:,1))/COUNT)*100);
fprintf('Category 4:\t\t\t\t %0.2f\n',(length(PV1_MW.RR_distrib.Cat4(:,1))/COUNT)*100);
fprintf('Category 5:\t\t\t\t %0.2f\n',(length(PV1_MW.RR_distrib.Cat5(:,1))/COUNT)*100);
fprintf('Total Days:\t\t\t\t %0.0f\n',COUNT);




%Pull from DOY, MONTH, & DAY ---    PV1_1MW.RR_distrib.Cat5(n,1:3)
RR_max = 0;
for S_DAY=1:1:length(PV1_MW.RR_distrib.Cat5(:,1))
   MNTH = PV1_MW.RR_distrib.Cat5(S_DAY,2);
   %M_PVSITE(MNTH).GHI; 
    
    
end

%%
%Plotting
fig = 1;
figure(fig);
plot(PV1_MW.VI,PV1_MW.DARR,'bo');
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
%%
%{
fig = fig + 1;
x = PV1_MW.VI;
y = PV1_MW.CI;
Z = ones(COUNT,COUNT);
for i=1:1:length(Z)
    Z(:,i) = PV1_MW.DARR;
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

[X,Y] = meshgrid(-8:.5:8);
R = sqrt(X.^2 + Y.^2) + eps;
Z = sin(R)./R;
surf(X,Y,Z)
colormap hsv
colorbar
%}
