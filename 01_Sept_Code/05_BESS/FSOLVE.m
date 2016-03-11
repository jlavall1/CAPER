clear
clc
close all
%This is to try and solve for:
T_ON=10;
T_OFF=16;
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
T_ON_1=17;
T_OFF_1=21;
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






