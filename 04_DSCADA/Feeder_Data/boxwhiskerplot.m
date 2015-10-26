clear
clc
close all
load FLAY.mat
load Annual_daytime_load.mat
fig = 0;
%%
t=0;
%DATAKW = [FLAY.kW.A,FLAY.kW.B,FLAY.kW.C]
tt =0;
sum = 0;
% Calculate the average by month for only 10am - 4pm
months = [31,28,31,30,31,30,31,31,30,31,30,31];
for i=1:12
    x=60*6*months(i);
    for ii=tt+1:x+tt
        if isnan(WINDOW.KW.A(ii,1))
            %fprintf('fuck you\n');
        else
            sum = WINDOW.KW.A(ii,1) + sum;
        end
    end
    tt = tt+x;
    WINDOW.MONTH.KW.A(i,3) = sum/x;
    sum = 0;
end
fig = fig + 1;
figure(fig);
n = 1;
%p1=bar(WINDOW.MONTH.KW.A(1:12,3));

%set(p1,'FaceColor','blue')
%
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
title('Monthly Average Demand during Solar Peak Interval')
xlabel('Month of Year','Fontsize',12,'FontWeight','bold');
ylabel('Average Monthly Real Power (P_{avg}) [kW]','Fontsize',12,'FontWeight','bold');
%axis([0 1200 1 12]);
    



%%
%%%%% Add all three phases???
for k=1:length(FLAY.kW.A)/1440
    WINDOW.MONTH.KW.A(k,1) = 100000;
    WINDOW.MONTH.KW.A(k,2) = 0;
    WINDOW.MONTH.KW.B(k,1) = 100000;
    WINDOW.MONTH.KW.B(k,2) = 0;
    WINDOW.MONTH.KW.C(k,1) = 100000;
    WINDOW.MONTH.KW.C(k,2) = 0;
    for i=t+1:1440+t
        
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
    t = t+1399;
end

% Plot of Max and mins per day for all of 2014
fig = fig + 1;
figure(fig);
plot(WINDOW.MONTH.KW.A(:,1))
hold on
plot(WINDOW.MONTH.KW.A(:,2))
title('Daily Maximum and Minimum Annual Loadshape')
xlabel('Day of Year (DOY)','Fontsize',12,'FontWeight','bold')
ylabel('Real Power (P) [kW]','Fontsize',12,'FontWeight','bold')
legend('Daily minimums','Daily maximums')


% Plot of only points between 8am-6pm for all of 2014
fig = fig + 1;
figure(fig);
hour = (8:18);
bar(WINDOW.DAYTIME.KW.A(:,1))
title('Cummulative Distribution during Solar Peak Interval')
xlabel('Data Point','Fontsize',12,'FontWeight','bold')
ylabel('Real Power (P) [kW]','Fontsize',12,'FontWeight','bold')

%%

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
title('Seasonal Comparison during Peak Solar Interval')
xlabel('Season and Phase','Fontsize',12,'FontWeight','bold')
ylabel('Load [kW]','Fontsize',12,'FontWeight','bold')

figure(4)
boxplot(dataV,charV)
title('Seasonal Comparison during Peak Solar Interval')
xlabel('Season and Phase','Fontsize',12,'FontWeight','bold')
ylabel('Load [kVAR]','Fontsize',12,'FontWeight','bold')

%%

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
title('Frequency during Peak Solar Interval')
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
title('Frequency during Peak Solar Interval')
xlabel('Range of Power (Q) [kVAR]','Fontsize',12,'FontWeight','bold')
%ylabel('Frequency of Range','Fontsize',12,'FontWeight','bold')
subplot(1,3,3)
hist(WINDOW.KVAR.C(:,2))
h = findobj(gca,'Type','patch');
h.FaceColor = [1 0 0];
%title('kVAR - Phase C')
%xlabel('Range of kVAR','Fontsize',12,'FontWeight','bold')
%ylabel('Frequency of Range','Fontsize',12,'FontWeight','bold')

%%

% Normal Distribution Plot
for j=1:1:3
    if j == 1
        W = WINDOW.KW.A(:,2);
    elseif j == 2
        W = WINDOW.KW.B(:,2);
    elseif j == 3
        W = WINDOW.KW.C(:,2);
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
















