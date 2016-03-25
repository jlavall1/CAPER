%plot functions only for feedback of how Energy Controller is doing...
% 
close all
fig = 0;
fig = fig + 1;
figure(fig);
subplot(1,3,1);

%t=[T_ON,t_1,t_2,t_3,t_4,t_5];
tt=[1/3600:1/3600:24]';
figure(1);
plot(tt,-1*CR_ref,'b-')
axis([0 24 -1000 0]);

hold on
%{
plot(t,1*DR,'r-')
%}
grid on
xlabel('Hour of Day');
ylabel('Charge/Discharge Rate (kW)');

subplot(1,3,2);
plot(P_DAY1_bot(:,2)/60,P_BESS,'r-','LineWidth',3)
subplot(1,3,3);

plot(tt,SOC_ref,'b-','LineWidth',2)
axis([0 24 0.65 1]);
%%
% Load Forecasting (kW) & Energy profile:
figure(2);
subplot(1,3,1);
X=1:1:1440;
plot(X,P_DAY1,'b-','LineWidth',3);
hold on
plot(P_max(2,1),P_max(1,1),'bo','LineWidth',3);
hold on
P_DAY1_bot=[peak(n).P_DAY1_bot];
%Show DR period:
plot(P_DAY1_bot(:,2),P_DAY1_bot(:,1),'c-','LineWidth',1.5);
hold on
plot([peak(n).t_A],P_DAY1([peak(n).t_A],1),'c.','LineWidth',6);
hold on
plot([peak(n).t_B],P_DAY1([peak(n).t_B],1),'c.','LineWidth',6);
hold on

X=X+1440;
plot(X,P_DAY2,'r-');
hold on
plot(P_max(2,2)+1440,P_max(1,2),'ro','LineWidth',3);
hold on
%Settings:
xlabel('Minute of Day');
ylabel('3PH KW');
axis([1 2880 900 2500])
subplot(1,3,2);
X=1:1:24;
bar(X,E_kWh(:,1),'b')
X=X+24;
hold on
bar(X,E_kWh(:,2),'r')
xlabel('Hour of Day');
ylabel('Energy (kWh)');
axis([1 49 900 2500]);

subplot(1,3,3);
X=1:1:1440;
%X=X/60;
plot(X,CSI,'b-')
hold on
T_ON=t_CR(1,1);
T_OFF=t_CR(1,7);
%plot(T_ON,CSI(T_ON*60),'bo','LineWidth',2.5);
%hold on
%plot(T_OFF,CSI(T_OFF*60),'bo','LineWidth',2.5);
%hold on
plot(X,BncI,'r-');
hold on
plot(X,GHI,'c-');
hold on
t3=tt*60;
plot(t3,CR_ref,'g-')
