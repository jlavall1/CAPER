%Produce Four (4) CDFs from Ramp Rate Datasets:
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles');
%Declare working variables:
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
MNTH = 1;
DAY = 1;
DOY = 1;
hr = 0;
min = 1;
COUNT = 0;

%
%Yearly Distribution - 
%RR_stats = zeros(sum(MTH_LN(1,:))*14*60,3);
while MNTH < 13
    while DAY < MTH_LN(1,MNTH)+1
        %Find RR Summation & Count:
        while hr < 24
            while min < 60
                %Filter any datapoint when sun was not over horizon
                if M_PVSITE(MNTH).DAY(time2int(DAY,hr,min),4) > 0
                    RR_stats(COUNT+1,1)=M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),1);
                    RR_stats(COUNT+1,2)=M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),2);
                    RR_stats(COUNT+1,3)=M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),3);
                    COUNT = COUNT + 1;
                end
                min = min + 1;
            end
            min = 1;
            hr = hr + 1;
        end
        %Reset Variables --
        hr = 0;
        min = 1;
        DAY = DAY + 1;
    end
    DAY = 1;
    MNTH = MNTH + 1
end
%RR_distrib=RR_stats(1:COUNT,1:3);
%RR_distrib = zeros(length(RR_stats(1:COUNT,3)));
RR_distrib(:,3)= sort(RR_stats(1:COUNT,3)); %Save Ramp Rate P.U. Value.
%%
% CDF generation:
for i=1:1:length(RR_distrib)
    RR_distrib(i,1)=1/COUNT; %PDF generation --
    if i == 1
        RR_distrib(i,2)=RR_distrib(i,1); %Account for first variable --
    else
        RR_distrib(i,2)=RR_distrib(i-1,2)+RR_distrib(i,1); %%Aggregate PDFs to make CDF
    end
end
%%
fprintf('CDF - By Category at selected site\n');
% By Category at selected Site:
% M_PVSITE_INFO.RR_distrib
CAT = 1;
MNTH = 1;
DAY = 1;
hr = 0;
min = 1;
COUNT = 0;
save_COUNT = zeros(1,5);
RR_cats = zeros(800,5);
while CAT <= 5
    if CAT == 1
        select = M_PVSITE_INFO.RR_distrib.Cat1;
    elseif CAT == 2
        select = M_PVSITE_INFO.RR_distrib.Cat2;
    elseif CAT == 3
        select = M_PVSITE_INFO.RR_distrib.Cat3;
    elseif CAT == 4
        select = M_PVSITE_INFO.RR_distrib.Cat4;
    elseif CAT == 5
        select = M_PVSITE_INFO.RR_distrib.Cat5;
    end
    %Now lets select R.R. values:
    for i=1:1:length(select(:,1))
        while MNTH < 13
            if select(i,2) == MNTH
                while DAY < MTH_LN(1,MNTH)+1
                    if select(i,3) == DAY
                        %We have a match in day!
                        while hr < 24
                            while min < 60
                                %Filter any datapoint when sun was not over horizon
                                if M_PVSITE(MNTH).DAY(time2int(DAY,hr,min),4) > 0
                                    %RR_cats(COUNT+1,1)=M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),1);
                                    %RR_stats(COUNT+1,2)=M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),2);
                                    
                                    %Only need the RRpu_abs:
                                    RR_cats(COUNT+1,CAT)=M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),3);
                                    COUNT = COUNT + 1;
                                end
                                min = min + 1;
                            end
                            min = 1;
                            hr = hr + 1;
                        end
                        %Reset Variables --
                        hr = 0;
                        min = 1;
                        DAY = MTH_LN(1,MNTH);
                    end
                    DAY = DAY + 1;
                end
                %Reset Vars --
                DAY = 1;
                MNTH = 12;
            end
            MNTH = MNTH + 1;
        end
        MNTH = 1;
        
    end
    save_COUNT(1,CAT) = COUNT;
    COUNT = 0;
    CAT = CAT + 1;
end
%%
%Now we have:
%   RR_cats(856:5) & save_COUNT(5,1)
%Sort:
for i=1:1:5
    RR_cats(1:save_COUNT(1,i),i)= sort(RR_cats(1:save_COUNT(1,i),i),'ascend'); %Save Ramp Rate P.U. Value.
end
%Generate CDF:
for i=1:1:5
    for j=1:1:save_COUNT(1,i)
        if j == 1
            RR_cats(j,i+5)=1/save_COUNT(1,i);
        else
            RR_cats(j,i+5)=RR_cats(j-1,i+5)+1/save_COUNT(1,i);
        end
    end
end
%%
%PLOT WHAT YOU WANT:
%Columns 5:10 are the cdfs...
fig = 1;
if FIG_type == 2 || FIG_type == 3
    figure(fig)
    fig = fig + 1;
    plot(RR_distrib(:,3),RR_distrib(:,2),'r-','LineWidth',2.5)
    axis([0 1 0.8 1]);
    grid on
    title(sprintf('Minute ramp rate CDF - %s MW %s plant',num2str(M_PVSITE_INFO.kW/1000),M_PVSITE_INFO.name),'FontWeight','bold');
    xlabel('Ramp Rate (p.u.)','FontWeight','bold');
    ylabel('Cumulative Probability','FontWeight','bold');
    set(gca,'FontWeight','bold');
end
if FIG_type == 4 || FIG_type == 3
    figure(fig)
    plot(RR_cats(1:save_COUNT(1,1),1),RR_cats(1:save_COUNT(1,1),6),'k-','LineWidth',2.5);
    hold on
    plot(RR_cats(1:save_COUNT(1,2),2),RR_cats(1:save_COUNT(1,2),7),'k--','LineWidth',2.5);
    hold on
    plot(RR_cats(1:save_COUNT(1,3),3),RR_cats(1:save_COUNT(1,3),8),'b-','LineWidth',2.5);
    hold on
    plot(RR_cats(1:save_COUNT(1,4),4),RR_cats(1:save_COUNT(1,4),9),'b--','LineWidth',2.5);
    hold on
    plot(RR_cats(1:save_COUNT(1,5),5),RR_cats(1:save_COUNT(1,5),10),'r-','LineWidth',2.5);
    if PV_Site == 1
        axis([0 1 0.99 1]);
    else
        axis([0 1.25 0.99 1]);
    end
    grid on
    d1 = length(M_PVSITE_INFO.RR_distrib.Cat1);
    d2 = length(M_PVSITE_INFO.RR_distrib.Cat2);
    d3 = length(M_PVSITE_INFO.RR_distrib.Cat3);
    d4 = length(M_PVSITE_INFO.RR_distrib.Cat4);
    d5 = length(M_PVSITE_INFO.RR_distrib.Cat5);
    if sim_type == 2 && PV_Site == 1
        legend(sprintf('Cat. 2: %s days',num2str(d2)),sprintf('Cat. 3: %s days',num2str(d3)),sprintf('Cat. 4: %s days',num2str(d4)),sprintf('Cat. 5: %s days',num2str(d5)),'Location','Southeast');
    else
        legend(sprintf('Cat. 1: %s days',num2str(d1)),sprintf('Cat. 2: %s days',num2str(d2)),sprintf('Cat. 3: %s days',num2str(d3)),sprintf('Cat. 4: %s days',num2str(d4)),sprintf('Cat. 5: %s days',num2str(d5)),'Location','Southeast');
    end
    title(sprintf('Minute ramp rate CDF by DARR category - %s MW %s plant',num2str(M_PVSITE_INFO.kW/1000),M_PVSITE_INFO.name),'FontWeight','bold');
    xlabel('Ramp Rate (p.u.)','FontWeight','bold');
    ylabel('Cumulative Probability','FontWeight','bold');
    set(gca,'FontWeight','bold');
end
%%
%SAVE WHAT YOU WANT:
%   Save Results:
if sim_type == 1
    if PV_Site == 1
        %   Shelby,NC
        M_SHELBY_INFO.CDF_annual = RR_distrib(:,1:3);
        M_SHELBY_INFO.CDF_DARRcat = RR_cats(:,1:10);
        filename = strcat(PV_Site_path1,'\M_SHELBY_INFO.mat');
        delete(filename);
        save(filename,'M_SHELBY_INFO');
    elseif PV_Site == 2
        %   Murphy,NC
        M_MURPHY_INFO.CDF_annual = RR_distrib(:,1:3);
        M_MURPHY_INFO.CDF_DARRcat = RR_cats(:,1:10);
        filename = strcat(PV_Site_path2,'\M_MURPHY_INFO.mat');
        delete(filename);
        save(filename,'M_MURPHY_INFO');
    elseif PV_Site == 3
        %   Taylorsville,NC
        M_TAYLOR_INFO.CDF_annual = RR_distrib(:,1:3);
        M_TAYLOR_INFO.CDF_DARRcat = RR_cats(:,1:10);
        filename = strcat(PV_Site_path3,'\M_TAYLOR_INFO.mat');
        delete(filename);
        save(filename,'M_TAYLOR_INFO');
    end
elseif sim_type == 2
    if PV_Site == 1
        %   4.5MW - Mocksville Solar Farm
        M_MOCKS_INFO.CDF_annual = RR_distrib(:,1:3);
        M_MOCKS_INFO.CDF_DARRcat = RR_cats(:,1:10);
        filename = strcat(PV_Site_path4,'\M_MOCKS_INFO.mat');
        delete(filename);
        save(filename,'M_MOCKS_INFO');
    elseif PV_Site == 2
        %   3.5MW - Ararat Rock Solar Farm
        M_AROCK_INFO.CDF_annual = RR_distrib(:,1:3);
        M_AROCK_INFO.CDF_DARRcat = RR_cats(:,1:10);
        filename = strcat(PV_Site_path5,'\M_AROCK_INFO.mat');
        delete(filename);
        save(filename,'M_AROCK_INFO');
    elseif PV_Site == 3
        %   1.5MW - Old Dominion PV system (ODOM)
        M_ODOM_INFO.CDF_annual = RR_distrib(:,1:3);
        M_ODOM_INFO.CDF_DARRcat = RR_cats(:,1:10);
        filename = strcat(PV_Site_path6,'\M_ODOM_INFO.mat');
        delete(filename);
        save(filename,'M_ODOM_INFO');
    elseif PV_Site == 4
        %   1.0MW - Mayberry Solar Farm (MAYB)
        M_MAYB_INFO.CDF_annual = RR_distrib(:,1:3);
        M_MAYB_INFO.CDF_DARRcat = RR_cats(:,1:10);
        filename = strcat(PV_Site_path7,'\M_MAYB_INFO.mat');
        delete(filename);
        save(filename,'M_MAYB_INFO');        
    end
end




                        
                        
                    
    
