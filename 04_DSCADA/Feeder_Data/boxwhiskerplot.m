clear
clc
close all
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);

action=menu('Which Plot would you like to initiate?','Monthly averages during PV peak','Yearly distrib. of daily max/mins','box plot of seasons','Histograms of avgs.','W&S mu+/-1.5s');
while action<1
    action=menu('Which Plot would you like to initiate?','Monthly averages during PV peak','Yearly distrib. of daily max/mins','box plot of seasons','Histograms of avgs.','W&S mu+/-1.5s');
end

feeder_NUM=menu('Which feeder','Bellhaven','Flay','Commonwealth','Roxboro');
while feeder_NUM<1
    feeder_NUM=menu('Which feeder','Bellhaven','Flay','Commonwealth','Roxboro');
end
if feeder_NUM == 1
    %Bell
elseif feeder_NUM == 2
    %Flay
    kW_peak = [1.424871573296857e+03,1.347528364235151e+03,1.716422704604557e+03];
    kW_peak_3ph = sum(kW_peak(1,:));
    load FLAY.mat
    load Annual_daytime_load.mat
    addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC');
    load M_SHELBY.mat
    M_PVSITE=M_SHELBY;
    clear M_SHELBY;
end

fig = 0;
t_w=0;  
tt =0;
sum = 0;
%%
if action == 1
    %DATAKW = [FLAY.kW.A,FLAY.kW.B,FLAY.kW.C]
    % Calculate the average by month for only 10am - 4pm
    months = [31,28,31,30,31,30,31,31,30,31,30,31];
    for i=1:12
        x_w=60*6*months(i);
        for ii=tt+1:x_w+tt
            if isnan(WINDOW.KW.A(ii,1))
                %fprintf('fuck you\n');
            else
                sum = WINDOW.KW.A(ii,1) + sum;
            end
        end
        tt = tt+x_w;
        WINDOW.MONTH.KW.A(i,3) = sum/x_w;
        sum = 0;
    end
    fig = fig + 1;
    figure(fig);
    n = 1;
    p1=bar(WINDOW.MONTH.KW.A(1:12,3));
    %set(p1,'FaceColor','blue')
    %{
    for n=1:1:12
        if n < 5 || n > 10
            p1 = bar(n,WINDOW.MONTH.KW.A(n,3));
            set(p1,'FaceColor','blue');
            %set(p1,'XTick',n);

        else
            p2 = bar(n,WINDOW.MONTH.KW.A(n,3));
            set(p2,'FaceColor','red');
        end
        hold on
    end
    %}
    title('Monthly Average Demand during Solar Peak Interval','Fontsize',14,'FontWeight','bold')
    xlabel('Month of Year','Fontsize',12,'FontWeight','bold');
    ylabel('Average Monthly Real Power (P_{avg}) [kW]','Fontsize',12,'FontWeight','bold');
    %axis([0 1200 1 12]);
end
    



%%
%%%%% Add all three phases???
for k=1:length(FLAY.kW.A)/1440
    WINDOW.MONTH.KW.A(k,1) = 100000;
    WINDOW.MONTH.KW.A(k,2) = 0;
    WINDOW.MONTH.KW.B(k,1) = 100000;
    WINDOW.MONTH.KW.B(k,2) = 0;
    WINDOW.MONTH.KW.C(k,1) = 100000;
    WINDOW.MONTH.KW.C(k,2) = 0;
    for i=t_w+1:1440+t_w

        if FLAY.kW.A(i,1) < WINDOW.MONTH.KW.A(k,1)
            WINDOW.MONTH.KW.A(k,1) = FLAY.kW.A(i,1);
        end
        if FLAY.kW.A(i,1) > WINDOW.MONTH.KW.A(k,2)
            WINDOW.MONTH.KW.A(k,2) = FLAY.kW.A(i,1);
        end
        if FLAY.kW.B(i,1) < WINDOW.MONTH.KW.B(k,1)
            WINDOW.MONTH.KW.B(k,1) = FLAY.kW.B(i,1);
        end
        if FLAY.kW.B(i,1) > WINDOW.MONTH.KW.B(k,2)
            WINDOW.MONTH.KW.B(k,2) = FLAY.kW.B(i,1);
        end
        if FLAY.kW.C(i,1) < WINDOW.MONTH.KW.C(k,1)
            WINDOW.MONTH.KW.C(k,1) = FLAY.kW.C(i,1);
        end
        if FLAY.kW.C(i,1) > WINDOW.MONTH.KW.C(k,2)
            WINDOW.MONTH.KW.C(k,2) = FLAY.kW.C(i,1);
        end
    end
    t_w = t_w+1399;
end

if action == 2
    % Plot of Max and mins per day for all of 2014
    fig = fig + 1;
    figure(fig);
    plot(WINDOW.MONTH.KW.A(:,1),'r-','LineWidth',3)
    hold on
    plot(WINDOW.MONTH.KW.A(:,2),'b-','LineWidth',3)
    title('Daily Maximum and Minimum Annual Loadshape','Fontsize',14,'FontWeight','bold')
    xlabel('Day of Year (DOY)','Fontsize',12,'FontWeight','bold')
    ylabel('Real Power (P) [kW]','Fontsize',12,'FontWeight','bold')
    legend('Daily minimums','Daily maximums')


    % Plot of only points between 8am-6pm for all of 2014
    fig = fig + 1;
    figure(fig);
    hour = (8:18);
    bar(WINDOW.DAYTIME.KW.A(:,1))
    title('Cummulative Distribution during Solar Peak Interval','Fontsize',14,'FontWeight','bold')
    xlabel('Data Point','Fontsize',12,'FontWeight','bold')
    ylabel('Real Power (P) [kW]','Fontsize',12,'FontWeight','bold')
end

%%
if action == 3
    % Data for P
    dataW = [WINDOW.WINT.KW.A(:,1); WINDOW.SUM.KW.A(:,1);...
            WINDOW.WINT.KW.B(:,1); WINDOW.SUM.KW.B(:,1);...
            WINDOW.WINT.KW.C(:,1); WINDOW.SUM.KW.C(:,1)];
    TOT = 0;    
    L = length(WINDOW.WINT.KW.A); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'Winter-A'};
    end
    TOT = TOT+L;
    L = length(WINDOW.SUM.KW.A); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'Summer-A'};
    end
    TOT = TOT+L;
    L = length(WINDOW.WINT.KW.B); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'Winter-B'};
    end
    TOT = TOT+L;
    L = length(WINDOW.SUM.KW.B); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'Summer-B'};
    end
    TOT = TOT+L;
    L = length(WINDOW.WINT.KW.C); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'Winter-C'};
    end
    TOT = TOT+L;
    L = length(WINDOW.SUM.KW.C); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'Summer-C'};
    end

    % Data for Q
    dataV = [WINDOW.WINT.KVAR.A(:,1); WINDOW.SUM.KVAR.A(:,1);...
            WINDOW.WINT.KVAR.B(:,1); WINDOW.SUM.KVAR.B(:,1);...
            WINDOW.WINT.KVAR.C(:,1); WINDOW.SUM.KVAR.C(:,1)];
    TOT = 0;   
    L = length(WINDOW.WINT.KVAR.A); 
    for i =TOT+1:1:L+TOT
        charV(i) = {'Winter-A'};
    end
    TOT = TOT+L;
    L = length(WINDOW.SUM.KVAR.A); 
    for i =TOT+1:1:L+TOT
        charV(i) = {'Summer-A'};
    end
    TOT = TOT+L;
    L = length(WINDOW.WINT.KVAR.B); 
    for i =TOT+1:1:L+TOT
        charV(i) = {'Winter-B'};
    end
    TOT = TOT+L;
    L = length(WINDOW.SUM.KVAR.B); 
    for i =TOT+1:1:L+TOT
        charV(i) = {'Summer-B'};
    end
    TOT = TOT+L;
    L = length(WINDOW.WINT.KVAR.C); 
    for i =TOT+1:1:L+TOT
        charV(i) = {'Winter-C'};
    end
    TOT = TOT+L;
    L = length(WINDOW.SUM.KVAR.C); 
    for i =TOT+1:1:L+TOT
        charV(i) = {'Summer-C'};
    end

    % Box and Whisker plots
    fig = fig + 1;
    figure(fig);
    boxplot(dataW,charW)
    title('Seasonal Comparison during Peak Solar Interval','Fontsize',14,'FontWeight','bold')
    xlabel('Season and Phase','Fontsize',12,'FontWeight','bold')
    ylabel('Load [kW]','Fontsize',12,'FontWeight','bold')

    figure(4)
    boxplot(dataV,charV)
    title('Seasonal Comparison during Peak Solar Interval','Fontsize',14,'FontWeight','bold')
    xlabel('Season and Phase','Fontsize',12,'FontWeight','bold')
    ylabel('Load [kVAR]','Fontsize',12,'FontWeight','bold')
end
%%
if action == 4
    % Histogram plots
    fig = fig + 1;
    figure(fig);
    subplot(1,3,1)
    hist(WINDOW.KW.A(:,2))
    h = findobj(gca,'Type','patch');
    h.FaceColor = [0 0 1];
    %title('kW - Phase A')
    %xlabel('Range of kW','Fontsize',12,'FontWeight','bold')
    ylabel('Number of Occurrences','Fontsize',12,'FontWeight','bold')
    axis([0 1500 0 50000]);
    subplot(1,3,2)
    hist(WINDOW.KW.B(:,2))
    h = findobj(gca,'Type','patch');
    h.FaceColor = [0 0 1];
    title('Frequency during Peak Solar Interval','Fontsize',14,'FontWeight','bold')
    xlabel('Range of Power (P) [kW]','Fontsize',12,'FontWeight','bold')
    %ylabel('Frequency of Range','Fontsize',12,'FontWeight','bold')
    axis([0 1500 0 50000]);
    subplot(1,3,3)
    hist(WINDOW.KW.C(:,2))
    h = findobj(gca,'Type','patch');
    h.FaceColor = [0 0 1];
    %title('kW - Phase C')
    axis([0 1500 0 50000]);
    %xlabel('Range of kW','Fontsize',12,'FontWeight','bold')
    %ylabel('Frequency of Range','Fontsize',12,'FontWeight','bold')

    fig = fig + 1;
    figure(fig);
    subplot(1,3,1)
    hist(WINDOW.KVAR.A(:,2))
    h = findobj(gca,'Type','patch');
    h.FaceColor = [1 0 0];
    %title('kVAR - Phase A')
    %xlabel('Range of kVAR','Fontsize',12,'FontWeight','bold')
    ylabel('Number of Occurrences','Fontsize',12,'FontWeight','bold')
    subplot(1,3,2)
    hist(WINDOW.KVAR.B(:,2))
    h = findobj(gca,'Type','patch');
    h.FaceColor = [1 0 0];
    title('Frequency during Peak Solar Interval','Fontsize',14,'FontWeight','bold')
    xlabel('Range of Power (Q) [kVAR]','Fontsize',12,'FontWeight','bold')
    %ylabel('Frequency of Range','Fontsize',12,'FontWeight','bold')
    subplot(1,3,3)
    hist(WINDOW.KVAR.C(:,2))
    h = findobj(gca,'Type','patch');
    h.FaceColor = [1 0 0];
    %title('kVAR - Phase C')
    %xlabel('Range of kVAR','Fontsize',12,'FontWeight','bold')
    %ylabel('Frequency of Range','Fontsize',12,'FontWeight','bold')
end
%%
if action == 5
    % Plotting seasonal with std. dev.
    W_w = [WINDOW.WINT.KW.A+WINDOW.WINT.KW.B+WINDOW.WINT.KW.C];
    S = [WINDOW.SUM.KW.A+WINDOW.SUM.KW.B+WINDOW.SUM.KW.C];
    % y_bar_w = zeros(length(W_w)/30,1);
    % y_bar_s = zeros(length(S)/30,1);
    t_w = 0;
    y_sum_w = 0;
    t_s = 0;
    y_sum_s = 0;
    k=1;
    %181 days with 360 datapoint blocks
    for ii = 1:2
        if ii==1
            W = W_w;
            DAY=181;
        else
            W = S;
            DAY = 365-181;
        end

        for j=1:1:length(W)/DAY
            k=j;
            while k<length(W)-360+1
                %go through each day, 
                if isnan(W(k))
                else
                    y_w = W(k);
                    y_sum_w = y_sum_w + y_w;
                end
                k=k+360;

            end
            mu_w(j,ii) = y_sum_w/DAY;
            k=j;
            while k<length(W)-360+1
                %go through each day, 
                if isnan(W(k))
                else
                    y_bar_w = W(k);
                    sum = sum + (y_bar_w-mu_w(j,ii))^2;
                end
                k=k+360;

            end

            var_w(j,ii) = sum/360;
            SD_w(j,ii) = sqrt(var_w(j,ii));

            % reset vars

            y_sum_w =0;
            sum = 0;
            %count var

        end
        k=1;
    end
    %Find GHI_clearsky for first/last days of each season.
    %Calculations:
    MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
    MNTH = 1;
    DAY = 1;
    min = 0; % +1 inc. b/c referencing 
    hr = 10;
    i = 1;
    j = 1;
    for i=1:1:4
        if i==1
            %Winter
            DAY=30;
            MNTH=4;
        elseif i==2
            %Winter
            DAY=1;
            MNTH=11;
        elseif i==3
            %SUMMER
            DAY=1;
            MNTH=5;
        elseif i==4
            %Summer
            DAY=31;
            MNTH=10;
        end
        %Now grab each minute from 10:00 to 16:00
        while hr < 16
            while min < 60
                CSI_k(j,i) = M_PVSITE(MNTH).GHI(time2int(DAY,hr,min),3);
                CSI_k(j,5) = hr;
                CSI_k(j,6) = min;
                %Inc:
                min = min + 1;
                j = j + 1;
            end
            hr = hr + 1;
            min = 0;
        end
        %Reset VARS;
        hr = 10;
        min = 0;
        j = 1;
    end
    
    %Now lets plot Results:
    X=10:1/60:15+59/60;
    fig = fig + 1;
    figure(fig);
    %Winter:
    plot(X,mu_w(:,1)/kW_peak_3ph,'b-','LineWidth',3);
    hold on
    plot(X,(mu_w(:,1)+1.5*SD_w(:,1))/kW_peak_3ph,'b--','LineWidth',2);
    hold on
    plot(X,(mu_w(:,1)-1.5*SD_w(:,1))/kW_peak_3ph,'b--','LineWidth',2);
    hold on
    plot(X,(CSI_k(:,1)/1000),'k-.','LineWidth',2);
    hold on
    plot(X,(CSI_k(:,2)/1000),'k-.','LineWidth',2);
    hold on
    line([X(206) X(206)],[0 1.3]);
    %Plot settings:
    axis([10 16 0 1.4]);
    legend('Avg. (Winter)','+1.5s (Winter)','-1.5s (Winter)','4/30','11/1','Location','NorthEast');
    xlabel('Hour of Day (H) [hr]','Fontsize',12,'FontWeight','bold')
    ylabel('Real Power (P) [p.u.]','Fontsize',12,'FontWeight','bold')
    title('Seasonal Shift in Loadshape','Fontsize',14,'FontWeight','bold');
    grid on
    
    
    %Summer:
    fig = fig + 1;
    figure(fig);
    plot(X,mu_w(:,2)/kW_peak_3ph,'r-','LineWidth',3);
    hold on
    plot(X,(mu_w(:,2)+1.5*SD_w(:,2))/kW_peak_3ph,'r--','LineWidth',2);
    hold on
    plot(X,(mu_w(:,2)-1.5*SD_w(:,2))/kW_peak_3ph,'r--','LineWidth',2);
    hold on
    plot(X,(CSI_k(:,3)/1000),'k-.','LineWidth',2);
    hold on
    plot(X,(CSI_k(:,4)/1000),'k-.','LineWidth',2);
    %plot(X(
    axis([10 16 0 1.4]);
    legend('Avg. (Summer)','+1.5s (Summer)','-1.5s (Summer)','5/1','10/31','Location','NorthEast');
    xlabel('Hour of Day (H) [hr]','Fontsize',12,'FontWeight','bold')
    ylabel('Real Power (P) [p.u.]','Fontsize',12,'FontWeight','bold')
    title('Seasonal Shift in Loadshape','Fontsize',14,'FontWeight','bold');
    grid on
    
    %
    % SAVE average profiles!
    maindir = 'C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\Feeder_Data';
    filename = strcat(maindir,'\FLAY_Seasonal_AVGs.mat');
    delete(filename);
    SEASON.MU = mu_w;
    SEASON.SD = SD_w;
    save(filename,'SEASON');
end
%%





%%
%{
% Normal Distribution Plot
for j=1:1:3
    if j == 1
        W = WINDOW.WINT.KW.A(:,2);
    elseif j == 2
        W = WINDOW.WINT.KW.B(:,2);
    elseif j == 3
        W = WINDOW.WINT.KW.C(:,2);
    end
    
    y_bar = zeros(length(W)/30,1);
    t = 0;
    y_sum = 0;
    for k=1:1:length(W)/30

        for i=t+1:1:30+t
            y = W(i);
            y_sum = y_sum + y;
            %disp(i)
        end
        y_bar(k) = y_sum/30;
        t = t + 29;
        y_sum = 0;
        %now we have (1) 30min avg. kW
    end
    mu(j) = mean(y_bar(:));
    %now lets find variance then s:
    y_bar_p = y_bar(:)-mu(j);
    sum = 0;
    for i=1:1:length(y_bar)
        sum = sum + (y_bar(i,1)-mu(j))^2;
    end
    var(j) = sum/(length(y_bar)-1);
    %var = sum(y_bar(:))^2/(length(y_bar)-1)
    SD(j) = sqrt(var(j));
    %make norm distrib
    %mu = 0;
    x(:,j) = y_bar_p(:);
    pd = makedist('Normal',0,SD(j));
    y = pdf(pd,x(:,j));
    y_mine(:,j) = y.';
end

fig = fig + 1;
figure(fig);

plot(x(:,1),y_mine(:,1))
hold on
plot(x(:,2),y_mine(:,2))
hold on
plot(x(:,3),y_mine(:,3))
hold off
title('Normal Distribution of Three Phases Power')
xlabel('\mu')
ylabel('Percentage')
legend('A','B','C')
%}

















