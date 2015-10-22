clear
clc
close all
load FLAY.mat
load Annual_daytime_load.mat
%%
months = [31,28,31,30,31,30,31,31,30,31,30,31];
tot=0;
DOY = 1;
points = zeros(12,1);
WINDOW.MAX.KW.A(:,1) = 0;
for i=1:1:12
    points(i) = 60*24*months(i);
    for jj = tot+1:points(i)+tot
        
        for DOY=1:1:365
            if FLAY.kW.A(jj,1) < WINDOW.MAX.KW.A(DOY,1) 
                WINDOW.MAX.KW.A(DOY,1) = FLAY.kW.A(jj,1);
            end
        end
    end
end
% Data for P
dataW = [WINDOW.WINT.KW.A(:,1); WINDOW.SUM.KW.A(:,1);...
        WINDOW.WINT.KW.B(:,1); WINDOW.SUM.KW.B(:,1);...
        WINDOW.WINT.KW.C(:,1); WINDOW.SUM.KW.C(:,1)];
TOT = 0;    
L = length(WINDOW.WINT.KW.A); 
for i =TOT+1:1:L+TOT
    charW(i) = {'W_A'};
end
TOT = TOT+L;
L = length(WINDOW.SUM.KW.A); 
for i =TOT+1:1:L+TOT
    charW(i) = {'S_A'};
end
TOT = TOT+L;
L = length(WINDOW.WINT.KW.B); 
for i =TOT+1:1:L+TOT
    charW(i) = {'W_B'};
end
TOT = TOT+L;
L = length(WINDOW.SUM.KW.B); 
for i =TOT+1:1:L+TOT
    charW(i) = {'S_B'};
end
TOT = TOT+L;
L = length(WINDOW.WINT.KW.C); 
for i =TOT+1:1:L+TOT
    charW(i) = {'W_C'};
end
TOT = TOT+L;
L = length(WINDOW.SUM.KW.C); 
for i =TOT+1:1:L+TOT
    charW(i) = {'S_C'};
end

% Data for Q
dataV = [WINDOW.WINT.KVAR.A(:,1); WINDOW.SUM.KVAR.A(:,1);...
        WINDOW.WINT.KVAR.B(:,1); WINDOW.SUM.KVAR.B(:,1);...
        WINDOW.WINT.KVAR.C(:,1); WINDOW.SUM.KVAR.C(:,1)];
TOT = 0;   
L = length(WINDOW.WINT.KVAR.A); 
for i =TOT+1:1:L+TOT
    charV(i) = {'W_A'};
end
TOT = TOT+L;
L = length(WINDOW.SUM.KVAR.A); 
for i =TOT+1:1:L+TOT
    charV(i) = {'S_A'};
end
TOT = TOT+L;
L = length(WINDOW.WINT.KVAR.B); 
for i =TOT+1:1:L+TOT
    charV(i) = {'W_B'};
end
TOT = TOT+L;
L = length(WINDOW.SUM.KVAR.B); 
for i =TOT+1:1:L+TOT
    charV(i) = {'S_B'};
end
TOT = TOT+L;
L = length(WINDOW.WINT.KVAR.C); 
for i =TOT+1:1:L+TOT
    charV(i) = {'W_C'};
end
TOT = TOT+L;
L = length(WINDOW.SUM.KVAR.C); 
for i =TOT+1:1:L+TOT
    charV(i) = {'S_C'};
end

% Box and Whisker plots
figure(1)
boxplot(dataW,charW)
title('Seasonal Comparison for Peak Solar Hours')
xlabel('Season and Phase')
ylabel('Load [kW]')

figure(2)
boxplot(dataV,charV)
title('Seasonal Comparison for Peak Solar Hours')
xlabel('Season and Phase')
ylabel('Load [kVAR]')

%%

% Histogram plots
figure(3)
subplot(1,3,1)
hist(WINDOW.KW.A(:,2))
h = findobj(gca,'Type','patch');
h.FaceColor = [0 0 1];
title('kW - Phase A')
xlabel('Range of kW')
ylabel('Frequency of Range')
axis([0 1500 0 50000]);
subplot(1,3,2)
hist(WINDOW.KW.B(:,2))
h = findobj(gca,'Type','patch');
h.FaceColor = [0 0 1];
title('kW - Phase B')
xlabel('Range of kW')
ylabel('Frequency of Range')
axis([0 1500 0 50000]);
subplot(1,3,3)
hist(WINDOW.KW.C(:,2))
h = findobj(gca,'Type','patch');
h.FaceColor = [0 0 1];
title('kW - Phase C')
axis([0 1500 0 50000]);
xlabel('Range of kW')
ylabel('Frequency of Range')

figure(4)
subplot(1,3,1)
hist(WINDOW.KVAR.A(:,2))
h = findobj(gca,'Type','patch');
h.FaceColor = [1 0 0];
title('kVAR - Phase A')
xlabel('Range of kVAR')
ylabel('Frequency of Range')
subplot(1,3,2)
hist(WINDOW.KVAR.B(:,2))
h = findobj(gca,'Type','patch');
h.FaceColor = [1 0 0];
title('kVAR - Phase B')
xlabel('Range of kVAR')
ylabel('Frequency of Range')
subplot(1,3,3)
hist(WINDOW.KVAR.C(:,2))
h = findobj(gca,'Type','patch');
h.FaceColor = [1 0 0];
title('kVAR - Phase C')
xlabel('Range of kVAR')
ylabel('Frequency of Range')

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

figure

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
















