clear
clc
close all

addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\05_BESS');
load M_MOCKS.mat


%One day run on 6/1:
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
i =1;
DoD_max=0.33; %0.33
ToS1_min=(1-DoD_max)+0.05;
for MNTH=1:1:12
    for DAY=1:1:MTH_LN(MNTH)
        BncI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
        CSI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
        save(i,1)=max(BncI);
        save(i,2)=mean(BncI);
        save(i,3)=save(i,1)/save(i,2);
        save(i,4)=max(CSI);
        save(i,5)=mean(CSI);
        save(i,6)=save(i,4)/save(i,5);
        
        
        save(i,7)=save(i,1)-save(i,4);
        save(i,8)=save(i,3)/save(i,6); %PAR_BncI/PAR_CSI
        save(i,9)=1/save(i,8);
        i = i + 1;
    end
end

PAR_CB=save(:,9);

for i=1:1:length(PAR_CB)
    TOS1(i)=ToS1_min+(PAR_CB(i)-min(PAR_CB))*min(PAR_CB);
end

%{
DAY = 1;
MNTH = 6;
DOY=calc_DOY(MNTH,DAY);
DOY=1:1:365

    BncI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
    GHI=M_MOCKS(MNTH).kW(time2int(DAY,0,0):time2int(DAY,23,59),1)/5000; %PU
%}
%%

%Adv. Lead Acid Bat. Utility T&D
%S15:
BESS.Prated=1000;
BESS.Crated=12121; %4000kWh
BESS.DoD_max=0.33;
BESS.Eff_DR=.967;
BESS.Eff_CR=.93;
C = BESS.Crated;


%%
%Lets make some key plots:
%   Plot 1: 
close all
fig = 0;
fig = fig + 1;
figure(fig);

DOY=[1:1:365];
[AX,H1,H2]= plotyy(DOY,PAR_CB,DOY,TOS1'*100);
set(H1,'LineWidth',2);
set(H2,'LineWidth',2);
grid on
ylabel(AX(1),'PAR_{CB}','FontSize',12,'FontWeight','bold');
ylabel(AX(2),'First SOC Limit  ( ToS_{1} ) [%]','FontSize',12,'FontWeight','bold');
xlabel('Day of Year','FontSize',12,'FontWeight','bold');
legend('Daily PAR_{CB}','Daily ToS_{1}','Location','NorthEast');
set(gca,'FontWeight','bold');
set(AX,'xtick',[1:31:372])
%Plot CSI & Bnci @ min & maximum PAR_CB days...
fig = fig + 1;
figure(fig);

for i=1:1:365
    if PAR_CB(i,1) == min(PAR_CB)
        DAY1(1,1)=i;
    elseif PAR_CB(i,1) == max(PAR_CB)
        DAY2(1,1)=i;
    end
end
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];

DAY = 1;
for MNTH=1:1:12
    for DAY=1:1:MTH_LN(1,MNTH)
        DOY = calc_DOY(MNTH,DAY);
        if DOY == DAY1(1,1)
            DAY1(1,2)=DAY;
            DAY1(1,3)=MNTH;
        elseif DOY == DAY2(1,1)
            DAY2(1,2)=DAY;
            DAY2(1,3)=MNTH;
        end
    end
end
%Find time to start / finish charging period:
CSI_TH = 0.1;
CSI_PU=CSI/max(CSI);

X=1:1:1440;
BncI=M_MOCKS(DAY1(1,3)).GHI(time2int(DAY1(1,2),0,0):time2int(DAY1(1,2),23,59),1); %1minute interval:
CSI=M_MOCKS(DAY1(1,3)).GHI(time2int(DAY1(1,2),0,0):time2int(DAY1(1,2),23,59),3);
n=0;
n = n + 1;
DoD=BESS.DoD_max;
[ SOC_ref(n,:) ,CR_ref(n,:), t_CR(n,:) ] = SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD);
n = n + 1;
DoD=BESS.DoD_max/2;
[ SOC_ref(n,:) ,CR_ref(n,:), t_CR(n,:) ] = SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD);

h1=plot(X,CSI,'b-','LineWidth',3);
hold on
h2=plot(X,BncI,'b--','LineWidth',3);



%BncI_PU=BncI/max(BncI);
ON = 0;
OFF = 0;
for m=1:1:length(CSI)
    if CSI_PU(m,1) > CSI_TH && ON == 0
        T_ON=m;
        ON = 1;
    elseif CSI_PU(m,1) < CSI_TH && ON == 1 && OFF == 0
        T_OFF=m;
        OFF = 1;
    end
end
plot(T_ON,CSI(T_ON),'bo','LineWidth',3);
hold on
plot(T_OFF,CSI(T_OFF),'bo','LineWidth',3);
hold on
%--------------DAY   2 --------------------
BncI=M_MOCKS(DAY2(1,3)).GHI(time2int(DAY2(1,2),0,0):time2int(DAY2(1,2),23,59),1); %1minute interval:
CSI=M_MOCKS(DAY2(1,3)).GHI(time2int(DAY2(1,2),0,0):time2int(DAY2(1,2),23,59),3);
n = n + 1;
DoD=BESS.DoD_max;
[ SOC_ref(n,:) ,CR_ref(n,:), t_CR(n,:) ] = SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD);
n = n + 1;
DoD=BESS.DoD_max/2;
[ SOC_ref(n,:) ,CR_ref(n,:), t_CR(n,:) ] = SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD);

h3=plot(X,CSI,'r-','LineWidth',3);
hold on
h4=plot(X,BncI,'r--','LineWidth',3);
hold on
txt1= sprintf('PAR_{CB}=%0.3f',PAR_CB(DAY1(1,1)));
text(65,500,txt1,'Color','b','HorizontalAlignment','Left','FontWeight','bold','FontSize',14);
hold on
txt1= sprintf('PAR_{CB}=%0.3f',PAR_CB(DAY2(1,1)));
text(1385,1050,txt1,'Color','r','HorizontalAlignment','Right','FontWeight','bold','FontSize',14);
hold on

CSI_PU=CSI/max(CSI);
%BncI_PU=BncI/max(BncI);
ON = 0;
OFF = 0;
for m=1:1:length(CSI)
    if CSI_PU(m,1) > CSI_TH && ON == 0
        T_ON=m;
        ON = 1;
    elseif CSI_PU(m,1) < CSI_TH && ON == 1 && OFF == 0
        T_OFF=m;
        OFF = 1;
    end
end
plot(T_ON,CSI(T_ON),'ro','LineWidth',3);
hold on
plot(T_OFF,CSI(T_OFF),'ro','LineWidth',3);
hold on
text(T_ON-53,CSI(T_ON),'t_{ON} \rightarrow','HorizontalAlignment','Right','FontWeight','bold','FontSize',14,'Color','r')

grid on
%legend(sprintf('(%d/%d) CSI',DAY1(1,3),DAY1(1,2)),sprintf('(%d/%d) B_{ncI}',DAY1(1,3),DAY1(1,2)))
legend([h1 h2 h3 h4],'(12/21) CSI','(12/21) B_{ncI}','(6/21) CSI','(6/21) B_{ncI}','Location','NorthWest')
set(gca,'FontWeight','bold');
set(gca,'xtick',[0:120:1440])
axis([0 1440 0 1200])
xlabel('Minute of Day','FontWeight','bold','FontSize',12);
ylabel('Solar Irradiance ( G ) [ W/m^2 ]','FontWeight','bold','FontSize',12);
%--------------DAY   3 --------------------
% Show (2) CR / SOC reference profile cases at different levels of DoD
fig = fig + 1;
figure(fig);
subplot(1,2,1);

X = (1/60):(1/60):1440;
h1=plot(X,CR_ref(1,:),'b-','LineWidth',2.5);
hold on
h2=plot(X,CR_ref(2,:),'b--','LineWidth',2.5);
hold on
h3=plot(X,CR_ref(3,:),'r-','LineWidth',2.5);
hold on
h4=plot(X,CR_ref(4,:),'r--','LineWidth',2.5);
set(gca,'xtick',[0:120:1440])
axis([0 1440 0 800])
xlabel('Minute of Day','FontWeight','bold','FontSize',14);
ylabel('Charge Rate Schedule ( CR_{r} ) [ kW/s ]','FontWeight','bold','FontSize',14);
legend([h1 h2 h3 h4],'(12/21) DoD_{max}','(12/21) DoD_{max}*0.5','(6/21) DoD_{max}','(6/21) DoD_{max}*0.5','Location','NorthWest')
set(gca,'FontWeight','bold','FontSize',14);
grid on
%%
%----------------------------------------------
%fig = fig + 1;
%figure(fig);
subplot(1,2,2);
h1=plot(X,SOC_ref(1,:)*100,'b-','LineWidth',2.5);
hold on
h2=plot(X,SOC_ref(2,:)*100,'b--','LineWidth',2.5);
hold on
h3=plot(X,SOC_ref(3,:)*100,'r-','LineWidth',2.5);
hold on
h4=plot(X,SOC_ref(4,:)*100,'r--','LineWidth',2.5);
set(gca,'xtick',[0:120:1440])
axis([0 1440 60 110])
xlabel('Minute of Day','FontWeight','bold','FontSize',14);
ylabel('State of Charge Schedule ( SOC_{r} ) [ % ]','FontWeight','bold','FontSize',14);
%legend([h1 h2 h3 h4],'(12/21) DoD_{max}','(12/21) DoD_{max}*0.5','(6/21) DoD_{max}','(6/21) DoD_{max}*0.5','Location','SouthEast')
set(gca,'FontWeight','bold','FontSize',14);
grid on

