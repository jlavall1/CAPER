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
xlabel('Conductor Temperature, degress Celsius');
ylabel('Current, A');
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

xlabel('Ambient Temperature, degress Celsius');
ylabel('Approximate Ampacity Rating (A)');
%axis([50 200 100 2000])
%set(gca,'XTick',50:25:200);
grid on
set(gca,'FontWeight','bold');
legend('336 ACSR, wind','336 ACSR, no wind','477 AAC,   wind','477 AAC,   no wind');



