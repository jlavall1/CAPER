%Show_Derived_Q

addpath(strcat(base_path,'\01_Sept_Code\04_QSTS_Solar_Coeff'));
load Q_Mult_60s_Flay.mat
load CAP_Mult_60s_Flay.mat
load P_Mult_60s_Flay.mat
Caps.Swtch = 450/3;
%This will be in Chapter 4
T_DAY = 152;
fig = fig + 1;
figure(fig)
plot(CAP_OPS_STEP1(T_DAY).data(:,10),'r-','LineWidth',3)
hold on
plot(CAP_OPS_STEP2(T_DAY).dP(:,4),'b-','LineWidth',1.5)
hold on
X=1:1:1440;
Y=202.5000*ones(1,1440);
plot(X,Y,'k--','LineWidth',2);
hold on
plot(X,-1*Y,'k--','LineWidth',2);
%Settings:
legend('{\Delta}Q_{3{\phi}}','{\Delta}P_{3{\phi}}','Upper Q Bound','Lower Q Bound','Location','NorthWest');
xlabel('Minute of Day','FontSize',12,'FontWeight','bold');
ylabel('Derivative of Powers (P,Q) [kW & kVAR]','FontSize',12,'FontWeight','bold')
axis([0 1440 -400 400])
set(gca,'FontWeight','bold');

fig = fig + 1;
figure(fig)
plot(CAP_OPS_STEP1(T_DAY).data(:,1),'r-','LineWidth',3)
hold on
plot(CAP_OPS_STEP1(T_DAY).data(:,2),'g-','LineWidth',3)
hold on
plot(CAP_OPS_STEP1(T_DAY).data(:,3),'b-','LineWidth',3)
hold on
plot(CAP_OPS(T_DAY).DSS(:,1),'r--','LineWidth',1.5)
hold on
plot(CAP_OPS(T_DAY).DSS(:,2),'g--','LineWidth',1.5)
hold on
plot(CAP_OPS(T_DAY).DSS(:,3),'b--','LineWidth',1.5)
hold on
plot(CAP_OPS_STEP1(T_DAY).data(:,4)*-1*Caps.Swtch,'k-','LineWidth',3);
%Settings
legend('DSCADA Qa','DSCADA Qb','DSCADA Qc','Derived Qa','Derived Qb','Derived Qc','Capacitor Q');
xlabel('Minute of Day','FontSize',12,'FontWeight','bold');
ylabel('Reactive Power (Q) [kVAR]','FontSize',12,'FontWeight','bold')
axis([0 1440 -200 800]);
set(gca,'FontWeight','bold');