clear
clc
close all
%This is to try and solve for:
%T_ON=10;
%T_OFF=16;
%Try to find correct T_ON & T_OFF:
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
load M_MOCKS.mat

load P_Mult_60s_Flay.mat

%One day run on 6/1:
DAY = 1;
MNTH = 6;
DOY=calc_DOY(MNTH,DAY);



%-----------------
CSI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
BncI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
%convert to P.U.
CSI=CSI/max(CSI);
BncI=BncI/max(BncI);
CSI_TH=0.2;
ON = 0;
OFF = 0;

for m=1:1:length(CSI)
    if CSI(m,1) > 0.2 && ON == 0
        T_ON=round((m/1440)*24);
        ON = 1;
    elseif CSI(m,1) < 0.2 && ON == 1 && OFF == 0
        T_OFF=round((m/1440)*24);
        OFF = 1;
    end
end
%=======================
%   Attempting to find Discharge Interval...
P_DAY1=CAP_OPS_STEP2(DOY).kW(:,1)+CAP_OPS_STEP2(DOY).kW(:,2)+CAP_OPS_STEP2(DOY).kW(:,3);
P_DAY2=CAP_OPS_STEP2(DOY+1).kW(:,1)+CAP_OPS_STEP2(DOY+1).kW(:,2)+CAP_OPS_STEP2(DOY+1).kW(:,3);
hr=1;
sum1=0;
sum2=0;
P_max=zeros(2,2);
for m=1:1:length(P_DAY1)
    if m < hr*60
        sum1=sum1+P_DAY1(m);
        sum2=sum2+P_DAY2(m);
    elseif m == hr*60
        sum1=sum1+P_DAY1(m);
        sum2=sum2+P_DAY2(m);
        E_kWh(hr,1)=sum1/60;
        E_kWh(hr,2)=sum2/60;
        hr = hr + 1;
        sum1 = 0;
        sum2 = 0;
    end
    E_DAY1(m,1)=P_DAY1(m)/(1440/60);
    E_DAY2(m,1)=P_DAY2(m)/(1440/60);
    %now look for maximums:
    if P_DAY1(m) > P_max(1,1)
        P_max(1,1) = P_DAY1(m);
        P_max(2,1) = m;
    end
    if P_DAY2(m) > P_max(1,2)
        P_max(1,2) = P_DAY2(m);
        P_max(2,2) = m;
    end
end
%%
if P_max(2,2)/60 < 9
    %then we have a peak during the morning, save energy!
    t_max=P_max(2,2)+24*60; %hours
else
    t_max=P_max(2,1);
end
fprintf('Target peak kth min: %0.2f\n',t_max);

%Initial conditions:
sigma=0.05;
bat_en = 500; %kWh available (estimate then actual after CR period over.
j =1;
t_A = 16*60;
t_B = 18*60;
end_loop = 0;

while end_loop ~= 1
    %Find new time interval:
    peak(j).t_A = t_A;
    peak(j).t_B = t_B;
    time=t_A:1:t_B;
    %Find energy under curve (discrete)
    peak(j).top = trapz(time,P_DAY1(time))/60;

    %Now find bottom energy:
    P_DAY1_bot(1,1)=P_DAY1(t_A);
    P_DAY1_srt = P_DAY1_bot(1,1);
    P_DAY1_bot(1,2)=t_A;
    for i=2:1:(t_B-t_A+1)
        %P_DAY1_bot(i,1)=P_DAY1_bot(i-1)+(P_DAY1(t_B)-P_DAY1(t_A))/(t_B-t_A+1);
        if P_DAY1_srt > P_DAY1(t_A+i-1)
            %this means the actual load dipped below starting kW:
            P_DAY1_bot(i,1) = P_DAY1(t_A+i-1);
        else
            P_DAY1_bot(i,1) = P_DAY1_srt;
        end
        P_DAY1_bot(i,2)=t_A+i-1;
    end
    peak(j).bot = trapz(P_DAY1_bot(:,2),P_DAY1_bot(:,1))/60; %kWh
    
    %Find energy that will be covered:
    peak(j).en = peak(j).top - peak(j).bot;

    %Find Energy Error:
    peak(j).error = peak(j).en - bat_en;
    if peak(j).error < -1*bat_en*sigma
        %not enough energy covered, need to increase time span:
        if j ~= 1
            if peak(j-1).error > peak(j).error
                t_A = t_A + 1;
            else
                t_B = t_B + 1;
            end
        end
    elseif peak(j).error > bat_en*sigma
        %too much energy covered, decrement time span:
        if j ~= 1
            if peak(j-1).error < peak(j).error
                t_A = t_A - 1;
            else
                t_B = t_B - 1;
            end
        end
    else
        end_loop = 1;
        %stop iterations:
    end
    j = j + 1;
end


        
%%


T=T_OFF-T_ON;

DoD_max=0.2;
C=8000; %kWh
h_1=DoD_max*C/T;
ToS1=0.85;
ToS2=0.9;

f=@(x)solve_SCR_h2(x,T,C,h_1,ToS1,ToS2);
x0=[h_1,0.1];
[x_e,fval]=fsolve(f,x0);
fprintf('Amount of increase in the constant charging rate to recover lost E: h_2 = %0.2f\n',x_e(1));
h_2=x_e(1);
SCR=x_e(2);
fprintf('SCR=%0.4f\n',x_e(1));

t_1 = ((h_1)/SCR)+T_ON;
t_2 = ((h_1+h_2)/SCR)+T_ON

t_3 = T_OFF+(h_1+h_2)/(-1*SCR)
t_4 = T_OFF+(h_1)/(-1*SCR)
t_5 = t_4-(h_1)/(-1*SCR)

t=[T_ON,t_1,t_2,t_3,t_4,t_5];
CR=[0,h_1,h_1+h_2,h_1+h_2,h_1,0];
plot(t,-1*CR,'b-')
hold on
%Try to convert this to 1sec:
t_int=3600;
CR_m(1,1)=0;
i =2;
for t=T_ON*t_int+1:1:T_OFF*t_int
    if t < t_2*t_int
        CR_m(i,1)=CR_m(i-1,1)+SCR/(1*t_int);
    elseif t >= t_2*t_int && t <= t_3*t_int
        CR_m(i,1)=h_1+h_2;
    elseif t > t_3*t_int && t < T_OFF*t_int
        CR_m(i,1)=CR_m(i-1,1)-SCR/(1*t_int);
    else
        CR_m(i,1)=0;
    end
    i = i + 1;
end

%%
%Now lets calc Discharge:
C=bat_en;

T_ON_1=peak(j-1).t_A/60;
T_OFF_1=peak(j-1).t_B/60;
%Estimate:
%T_ON_1=17;
%T_OFF_1=21;
T_D=T_OFF_1-T_ON_1;
ToS2=0.9;
ToS1=0.83;
h_1=DoD_max*C/abs(T_D);

f=@(x)solve_SCR_h2(x,T_D,C,h_1,ToS1,ToS2);
x0=[h_1,0.1];
[x_e_1,fval]=fsolve(f,x0);
h_2=x_e_1(1);
SDR=x_e_1(2);

t_1 = ((h_1)/SDR)+T_ON_1;
t_2 = ((h_1+h_2)/SDR)+T_ON_1

t_3 = T_OFF_1+(h_1+h_2)/(-1*SDR)
t_4 = T_OFF_1+(h_1)/(-1*SDR)
t_5 = t_4-(h_1)/(-1*SDR)

t=[T_ON_1,t_1,t_2,t_3,t_4,t_5];
DR=[0,h_1,h_1+h_2,h_1+h_2,h_1,0];
plot(t,1*DR,'r-')
grid on
xlabel('Hour of Day');
ylabel('Charge/Discharge Rate (kW)');
%%
% Load Forecasting:
figure(2);
subplot(1,2,1);
X=1:1:1440;
plot(X,P_DAY1,'b-','LineWidth',3);
hold on
plot(P_max(2,1),P_max(1,1),'bo','LineWidth',3);
hold on

%Show DR period:
plot(P_DAY1_bot(:,2),P_DAY1_bot(:,1),'c-','LineWidth',1.5);
hold on
plot([peak(j-1).t_A],P_DAY1([peak(j-1).t_A],1),'c.','LineWidth',6);
hold on
plot([peak(j-1).t_B],P_DAY1([peak(j-1).t_B],1),'c.','LineWidth',6);
hold on

X=X+1440;
plot(X,P_DAY2,'r-');
hold on
plot(P_max(2,2)+1440,P_max(1,2),'ro','LineWidth',3);
hold on
%Settings:
xlabel('Minute of Day');
ylabel('3PH KW');
axis([1 2880 0 2500])
subplot(1,2,2);
X=1:1:24;
bar(X,E_kWh(:,1),'b')
X=X+24;
hold on
bar(X,E_kWh(:,2),'r')
xlabel('Hour of Day');
ylabel('Energy (kWh)');
axis([1 49 0 2500]);
%%
figure(3)
X=1:1:1440;
plot(X,CSI)




