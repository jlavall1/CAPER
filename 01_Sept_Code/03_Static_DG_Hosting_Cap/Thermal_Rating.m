clear
clc
close all
fig = 0;

COND(1,:)=[336,75,25,520,1];
COND(2,:)=[336,75,25,356,0];
COND(3,:)=[336,100,25,468,1];
COND(4,:)=[336,100,25,635,0];

COND(5,:)=[477,75,25,640,1];
COND(6,:)=[477,75,25,447,0];
COND(7,:)=[477,100,25,784,1];
COND(8,:)=[477,100,25,588,0];

%Plot 1:
for j=1:1:8
    i = 1;
    for I=100:10:1200
        Ta_new = COND(j,3);
        Ta_old = COND(j,3);
        Tc_old = COND(j,2);
        I_old = COND(j,4);
        Tc_new(i,j)=Ta_new+((I/I_old)^2)*(Tc_old-Ta_old);
        Ic(i,1)=I;
        i = i + 1;
    end
end

fig = fig + 1;
figure(fig)
plot(Tc_new(:,1),Ic,'b-','LineWidth',2)
hold on
plot(Tc_new(:,2),Ic,'b--','LineWidth',2)
hold on
plot(Tc_new(:,5),Ic,'r-','LineWidth',2)
hold on
plot(Tc_new(:,6),Ic,'r--','LineWidth',2)
hold on
plot(COND(1,2),COND(1,4),'bo');
hold on
plot(COND(2,2),COND(2,4),'bo');
hold on
plot(COND(5,2),COND(5,4),'ro');
hold on
plot(COND(6,2),COND(6,4),'ro');
%settings
xlabel('Conductor Temperature, degress Celsius','FontWeight','bold','FontSize',12);
ylabel('Current, A','FontWeight','bold','FontSize',12);
axis([50 200 100 2000])
set(gca,'XTick',50:25:200);
grid on
set(gca,'FontWeight','bold');
legend('336 ACSR, wind','336 ACSR, no wind','477 AAC,   wind','477 AAC,   no wind');
%%
COND(1,:)=[336,75,25,520,1];
COND(2,:)=[336,75,25,356,0];
COND(3,:)=[336,100,25,468,1];
COND(4,:)=[336,100,25,635,0];

COND(5,:)=[477,75,25,640,1];
COND(6,:)=[477,75,25,447,0];
COND(7,:)=[477,100,25,784,1];
COND(8,:)=[477,100,25,588,0];

%Plot 2:

for j=1:1:8
    i=1;
    for Ta_new=-10:0.5:40
        %Ta_new = COND(j,3);
        Ta_old = COND(j,3);
        Tc_old = COND(j,2);
        Tc_new = COND(j,2);
        I_old = COND(j,4);
        
        I_new(i,j)=I_old*sqrt((Tc_new-Ta_new)/(Tc_old-Ta_old));
        Ta_new_1(i,1)=Ta_new;
        i = i + 1;
    end
end
fig = fig + 1;
figure(fig);
plot(Ta_new_1,I_new(:,1),'b-','LineWidth',2);
hold on
plot(Ta_new_1,I_new(:,2),'b--','LineWidth',2);
hold on
plot(Ta_new_1,I_new(:,5),'r-','LineWidth',2);
hold on
plot(Ta_new_1,I_new(:,6),'r--','LineWidth',2);

xlabel('Ambient Temperature, degress Celsius','FontWeight','bold','FontSize',12);
ylabel('Approximate Ampacity Rating (A)','FontWeight','bold','FontSize',12);
%axis([50 200 100 2000])
%set(gca,'XTick',50:25:200);
grid on
set(gca,'FontWeight','bold');
legend('336 ACSR, wind','336 ACSR, no wind','477 AAC,   wind','477 AAC,   no wind');
%%
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA');
Weather = xlsread('Weather_NC.xlsx','NC');
wind=Weather(:,1);
Atemp=Weather(:,2);
wind=sort(wind);
Atemp=sort(Atemp);
v_avg=3.649; %m/s

for v=0:1:30
    WB(v+1,1)=(pi*v)/(2*(v_avg^2))*exp(-1*(pi/4)*(v/v_avg)^2);
end

num_g=30;
wind_max=12;
%step=wind_max/num_g;
step=1;
%hist(wind,50)
count=zeros(num_g,2);
min=0;
max=step;
for i=1:1:length(wind)
    min=0;
    max=step;
    for b=1:1:num_g
        if wind(i,1) >= min && wind(i,1) < max
            count(b,1)=count(b,1)+1;
        end
        min=min+step;
        max=max+step;
    end
end

fig = fig + 1;
figure(fig);
%{
X=0:step:wind_max-step;
plot(X*2.23694,count(:,1)/8760,'b-','LineWidth',3);
hold on
plot([1.4 1.4],[0 0.16],'r--','LineWidth',2);
%}
v=0:1:29;
plot(v,count(:,1)/8760,'ro','LineWidth',2);
hold on
plot(v,WB(1:30,1),'b-','LineWidth',2);
xlabel('Wind Speed (m/s)','FontWeight','bold','FontSize',12);
ylabel('Probability Density','FontWeight','bold','FontSize',12);
legend('From Discrete Wind Speeds','From Rayleigh Distribution')
grid on
set(gca,'FontWeight','bold');
%%
fig = fig + 1;
figure(fig);
%   Find PDF of A temp:
Atemp = Atemp + 15;
num_g=20;
am_min=0;
am_max=52;
am = am_max-am_min;
step=am/num_g;
%hist(wind,50)
count1=zeros(num_g,2);
min=am_min;
max=step;
%Atemp=Atemp+15;
for i=1:1:length(Atemp)
    min=am_min;
    max=step;
    for b=1:1:num_g
        if Atemp(i,1) >= min && Atemp(i,1) < max
            count1(b,1)=count1(b,1)+1;
        end
        min=min+step;
        max=max+step;
    end
end
X=-15:step:am_max-15-step;
plot(X,count1(:,1)/8760,'b-','LineWidth',3);
hold on
plot([25 25],[0 0.14],'r--','LineWidth',2);
xlabel('Ambient Temperature (C)','FontWeight','bold','FontSize',12);
ylabel('Probability Density','FontWeight','bold','FontSize',12);
grid on
set(gca,'FontWeight','bold');


        
    
    





