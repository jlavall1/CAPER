%This algorithm will calculate the DARRmin

%clear
%clc
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles');
%Import Dynamic Datasets:
%Ask user which site do they want?
%{
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
%}
%
PV1_MW.DARR = M_PVSITE_SC(:,6);
PV1_MW.VI = M_PVSITE_SC(:,4);
PV1_MW.CI = M_PVSITE_SC(:,5);
PV1_MW.DATE = M_PVSITE_SC(:,1:3);
PV1_MW.RR_distrib.Cat1(1,1:4) = zeros(1,4);
PV1_MW.RR_distrib.Cat1_O(1,1:4) = zeros(1,4);
PV1_MW.RR_distrib.Cat2(1,1:4) = zeros(1,4);
PV1_MW.RR_distrib.Cat3(1,1:4) = zeros(1,4);
PV1_MW.RR_distrib.Cat4(1,1:4) = zeros(1,4);
PV1_MW.RR_distrib.Cat5(1,1:4) = zeros(1,4);
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
    %Obtain dynamic variables:
    DARR = PV1_MW.DARR(i,1);
    CI = PV1_MW.CI(i,1);
    TIME = PV1_MW.DATE(i,1:3);
    
    %Categorize DARR Days:
    %
    %Category 1 -
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
    %Category 2 -
    elseif DARR >= 3 && DARR < 13
        PV1_MW.RR_distrib.Cat2(k,1:3) = TIME;
        PV1_MW.RR_distrib.Cat2(k,4) = DARR;
        k = k + 1;
        COUNT = COUNT + 1;
    %Category 2 -
    elseif DARR >= 13 && DARR < 23
        PV1_MW.RR_distrib.Cat3(l,1:3) = TIME;
        PV1_MW.RR_distrib.Cat3(l,4) = DARR;
        l = l + 1;
        COUNT = COUNT + 1;
    %Category 3 -
    elseif DARR >= 23 && DARR < 33
        PV1_MW.RR_distrib.Cat4(m,1:3) = TIME;
        PV1_MW.RR_distrib.Cat4(m,4) = DARR;
        m = m + 1;
        COUNT = COUNT + 1;
    %Category 4 -
    elseif DARR >= 33
        PV1_MW.RR_distrib.Cat5(n,1:3) = TIME;
        PV1_MW.RR_distrib.Cat5(n,4) = DARR;
        PV1_MW.RR_distrib.Cat5(n,5) = CI;
        n = n + 1;
        COUNT = COUNT + 1;
    end
end
%The COUNT Variables tells us how many days we have data for the yr 2014.
fprintf('\t %s\n\n',sprintf('%0.1f MW Farm in %s,NC',PV1_MW.kW/1e3,PV1_MW.name));
%fprintf('Capacity in MW_{ac}:\t %0.1f\n',PV1_MW.kW/1e3);
CAT = zeros(1,6);
CAT(1,1) = (length(PV1_MW.RR_distrib.Cat1(:,1))/COUNT)*100;
if CAT(1,1) == 1 && PV1_MW.RR_distrib.Cat1(1,1)==0
    CAT(1,1) = 0;
end
CAT(1,2) = (length(PV1_MW.RR_distrib.Cat1_O(:,1))/COUNT)*100;
if CAT(1,2) == 1 && PV1_MW.RR_distrib.Cat1_O(1,1)==0
    CAT(1,2) = 0;
end
CAT(1,3) = (length(PV1_MW.RR_distrib.Cat2(:,1))/COUNT)*100;
if CAT(1,3) == 1 && PV1_MW.RR_distrib.Cat2(1,1)==0
    CAT(1,3) = 0;
end
CAT(1,4) = (length(PV1_MW.RR_distrib.Cat3(:,1))/COUNT)*100;
if CAT(1,4) == 1 && PV1_MW.RR_distrib.Cat3(1,1)==0
    CAT(1,4) = 0;
end
CAT(1,5) = (length(PV1_MW.RR_distrib.Cat4(:,1))/COUNT)*100;
if CAT(1,5) == 1 && PV1_MW.RR_distrib.Cat4(1,1)==0
    CAT(1,5) = 0;
end
CAT(1,6) = (length(PV1_MW.RR_distrib.Cat5(:,1))/COUNT)*100;
if CAT(1,6) == 1 && PV1_MW.RR_distrib.Cat5(1,1)==0
    CAT(1,6) = 0;
end

fprintf('Category 1 clearsky:\t %0.2f%%\n',CAT(1,1));
fprintf('Category 1 overcast:\t %0.2f%%\n',CAT(1,2));
fprintf('Category 2:\t\t %0.2f%%\n',CAT(1,3));
fprintf('Category 3:\t\t %0.2f%%\n',CAT(1,4));
fprintf('Category 4:\t\t %0.2f%%\n',CAT(1,5));
fprintf('Category 5:\t\t %0.2f%%\n',CAT(1,6));
fprintf('Total Days:\t\t %0.0f\n',COUNT);

%%
%Pull from DOY, MONTH, & DAY ---    PV1_1MW.RR_distrib.Cat5(n,1:3)
%Ramp Rates were calculted already and located here: M_PVSITE
%M_PVSITE(MNTH).DAY(time2int(D_S,0,0):time2int(D_S,23,59),1),'b-');
RR_max = 0;
RR_min = 0;
for S_DAY=1:1:length(PV1_MW.RR_distrib.Cat5(:,1))
    %Obtain MNTH, DAY of category 5 DARR:
    MNTH = PV1_MW.RR_distrib.Cat5(S_DAY,2);
    D_S = PV1_MW.RR_distrib.Cat5(S_DAY,3);
    %Now find maximum "up-Ramp" RR for that day:
    RR_max = max(M_PVSITE(MNTH).RR_1MIN(time2int(D_S,0,0):time2int(D_S,23,59),1));
    %Now find maximum "down-Ramp" RR for that day:
    RR_min = min(M_PVSITE(MNTH).RR_1MIN(time2int(D_S,0,0):time2int(D_S,23,59),1));
    %Save in struct:
    PV1_MW.RR_distrib.Cat5(S_DAY,6) = RR_max/PV1_MW.kW; %Now in P.U.
    PV1_MW.RR_distrib.Cat5(S_DAY,7) = RR_min/PV1_MW.kW; %Now in P.U.
    %M_PVSITE(MNTH).GHI; 
end
%%
%Lets create daily RR avg ; RR 95% ; RR 99% % Place in M_PVSITE_SC
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
MNTH = 1;
DAY = 1;
DOY = 1;
hr = 0;
min = 1;
COUNT = 0;
RR_Sigma = 0;
while MNTH < 13
    while DAY < MTH_LN(1,MNTH)+1
        %Find RR Summation & Count:
        while hr < 24
            while min < 60
                %Filter any datapoint when sun was not over horizon
                if M_PVSITE(MNTH).DAY(time2int(DAY,hr,min),4) > 0
                    RR = M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),1);
                    RR_Sigma = RR_Sigma + abs(RR)/PV1_MW.kW;
                    COUNT = COUNT + 1;
                end
                min = min + 1;
            end
            min = 1;
            hr = hr + 1;
        end
        %Calculate & save RR_avg:
        M_PVSITE_SC(DOY,7) = RR_Sigma/COUNT;
        %Reset Variables --
            RR_Sigma = 0;
            COUNT = 0;
            hr = 0;
            min = 1;
                    
        %Obtain 95th & 99th percentiles of 1min RRs:
        x = M_PVSITE(MNTH).RR_1MIN(time2int(DAY,0,0):time2int(DAY,23,59),1);
        M_PVSITE_SC(DOY,8) = quantile(x,0.95)/1000;
        M_PVSITE_SC(DOY,9) = quantile(x,0.99)/1000;
        
        %Increment Day:
        DAY = DAY + 1;
        DOY = DOY + 1;
    end
    MNTH = MNTH + 1;
    DAY = 1;
end

%%
%Plotting
fig = 0;
if FIG_type == 1 || FIG_type == 3
    fig = fig + 1;
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
    xlabel('Variability Index (VI)','FontSize',14,'FontWeight','bold');
    ylabel('Daily Aggregate Ramp Rate (DARR)','FontSize',14,'FontWeight','bold');
    title(sprintf('Correlation between daily VI & DARR at %s',PV1_MW.name),'FontSize',14,'FontWeight','bold');
    set(gca,'FontWeight','bold');
end
if FIG_type == 2 || FIG_type == 3
    %Plot (2):
    fig = fig + 1;
    figure(fig);
    h(1) = plot(M_PVSITE_SC(:,4),M_PVSITE_SC(:,7),'bo');
    hold on
    h(3) = plot(M_PVSITE_SC(:,4),M_PVSITE_SC(:,8),'go');
    hold on
    h(5) = plot(M_PVSITE_SC(:,4),M_PVSITE_SC(:,9),'ro');
    %plot Settings:
    xlabel('VI','FontSize',14,'FontWeight','bold');
    ylabel('1-min PV-Farm Ramp Rate (P.U.)','FontSize',14,'FontWeight','bold');
    title(sprintf('Irradiance Changes vs. VI at %s',PV1_MW.name),'FontSize',14,'FontWeight','bold');
    legend('Mean Irradiance Change','95% Irradiance Change','99% Irradiance Change');
    axis([0 30 0 1]);
    set(gca,'FontWeight','bold');
end

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
%%
%   Save Results:
if sim_type == 1
    if PV_Site == 1
        %   Shelby,NC
        M_SHELBY_INFO = PV1_MW;
        filename = strcat(PV_Site_path1,'\M_SHELBY_INFO.mat');
        delete(filename);
        save(filename,'M_SHELBY_INFO');
        %   Solar Constants:
        M_SHELBY_SC = M_PVSITE_SC;
        filename = strcat(PV_Site_path1,'\M_SHELBY_SC.mat');
        delete(filename);
        save(filename,'M_SHELBY_SC');
    elseif PV_Site == 2
        %   Murphy,NC
        M_MURPHY_INFO = PV1_MW;
        filename = strcat(PV_Site_path2,'\M_MURPHY_INFO.mat');
        delete(filename);
        save(filename,'M_MURPHY_INFO');
        %   Solar Constants:
        for i=1:1:365
            %Filter out missing datapoints (DOY=234 to 240; 7Day Gap)
            if i >= 234 && i <= 240
                M_PVSITE_SC(i,4:6) = [0,0,0];
            end
        end
        M_MURPHY_SC = M_PVSITE_SC;
        filename = strcat(PV_Site_path2,'\M_MURPHY_SC.mat');
        delete(filename);
        save(filename,'M_MURPHY_SC');
    elseif PV_Site == 3
        %   Taylorsville,NC
        M_TAYLOR_INFO = PV1_MW;
        filename = strcat(PV_Site_path3,'\M_TAYLOR_INFO.mat');
        delete(filename);
        save(filename,'M_TAYLOR_INFO');
        %Solar Constants
        M_TAYLOR_SC = M_PVSITE_SC;
        filename = strcat(PV_Site_path3,'\M_TAYLOR_SC.mat');
        delete(filename);
        save(filename,'M_TAYLOR_SC');
    end
    
elseif sim_type == 2
    if PV_Site == 1
        %   4.5MW - Mocksville Solar Farm
        M_MOCKS_INFO = PV1_MW;
        filename = strcat(PV_Site_path4,'\M_MOCKS_INFO.mat');
        delete(filename);
        save(filename,'M_MOCKS_INFO');
        %   Solar Constants:
        M_MOCKS_SC = M_PVSITE_SC;
        filename = strcat(PV_Site_path4,'\M_MOCKS_SC.mat');
        delete(filename);
        save(filename,'M_MOCKS_SC');
        
    elseif PV_Site == 2
        %   3.5MW - Ararat Rock Solar Farm
        M_AROCK_INFO = PV1_MW;
        filename = strcat(PV_Site_path5,'\M_AROCK_INFO.mat');
        delete(filename);
        save(filename,'M_AROCK_INFO');
        %   Solar Constants
        M_AROCK_SC = M_PVSITE_SC;
        filename = strcat(PV_Site_path5,'\M_AROCK_SC.mat');
        delete(filename);
        save(filename,'M_AROCK_SC');
        
    elseif PV_Site == 3
        %   1.5MW - Old Dominion Solar Farm (ODOM)
        M_ODOM_INFO = PV1_MW;
        filename = strcat(PV_Site_path6,'\M_ODOM_INFO.mat');
        delete(filename);
        save(filename,'M_ODOM_INFO');
        %   Solar Constants
        M_ODOM_SC = M_PVSITE_SC;
        filename = strcat(PV_Site_path6,'\M_ODOM_SC.mat');
        delete(filename);
        save(filename,'M_ODOM_SC');
        
    elseif PV_Site == 4
        %   1.0MW - Mayberry Solar Farm (MAYB)
        M_MAYB_INFO = PV1_MW;
        filename = strcat(PV_Site_path7,'\M_MAYB_INFO.mat');
        delete(filename);
        save(filename,'M_MAYB_INFO');
        %   Solar Constants
        M_MAYB_SC = M_PVSITE_SC;
        filename = strcat(PV_Site_path7,'\M_MAYB_SC.mat');
        delete(filename);
        save(filename,'M_MAYB_SC');
        
    end
end
