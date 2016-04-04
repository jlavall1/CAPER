% Charge Schedule Example:
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
CSI_TH = 0.1;

BESS.Prated=1000;
BESS.Crated=12121; %4000kWh
BESS.DoD_max=0.33;
BESS.Eff_DR=.967;
BESS.Eff_CR=.93;
C = BESS.Crated;


MNTH=6;
DAY=1;
BncI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
CSI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
%------------------------

[ SOC_ref,CR_ref, t_CR ] = SOCref_CR(BncI,CSI,CSI_TH,BESS,C,BESS.DoD_max);
T = t_CR(1,5)-t_CR(1,1);
h1=ones(length(CR_ref),1)*(BESS.Crated*DoD_max)/T;

%construct will shapes:
i = 1;
for j=1:1:length(CR_ref)
    if CR_ref(j,1) >= h1(1,1)
        A2(i,1) = CR_ref(j,1);
        A2(i,2) = j/60; %seconds
        i = i + 1;
    end
end
A2(i,1)= h1(1,1);
A2(i,2)= t_CR(1,5)*60;
i=i+1;
A2(i,1)= h1(1,1);
A2(i,2)= t_CR(1,2)*60;


j=1;
i=1;
while CR_ref(j,1) < h1(1,1)
    if CR_ref(j,1) ~= 0
        A11(i,1) = CR_ref(j,1);
        A11(i,2) = j/60;
        i = i + 1;
    end
    j=j+1;
end
A11(i,1) = h1(1,1);
A11(i,2) = t_CR(1,2)*60;
i= i + 1;
A11(i,1) = h1(1,1);
A11(i,2) = t_CR(1,1)*60;
i= i + 1;
A11(i,1) = 0;
A11(i,2) = t_CR(1,1)*60;


j=1000*60;
i=1;
while j < length(CR_ref)
    if CR_ref(j,1) ~= 0 && CR_ref(j,1) < h1(1,1)
        A12(i,1) = CR_ref(j,1);
        A12(i,2) = j/60;
        i = i + 1;
    end
    j=j+1;
end

%A12(i,1) = 0;
%A12(i,2) = t_CR(1,6)*60;
%i= i + 1;
A12(i,1) = h1(1,1);
A12(i,2) = t_CR(1,6)*60;
i= i + 1;
A12(i,1) = h1(1,1);
A12(i,2) = t_CR(1,5)*60;
%i= i + 1;
%A12(i,1) = 0;
%A12(i,2) = t_CR(1,1)*60;



%PLOT

h(1)=fill(A2(:,2),A2(:,1),'b');
hold on
h(2)=fill(A11(:,2),A11(:,1),'r');
hold on
h(3)=fill(A12(:,2),A12(:,1),'r');
hold on

X = (1/60):(1/60):1440;
plot(X,CR_ref,'k-','LineWidth',2.5);
hold on
plot(X,h1,'k--','LineWidth',2);
hold on
plot([t_CR(1,1)*60 t_CR(1,1)*60],[0 600],'k--','LineWidth',2);
hold on
plot([t_CR(1,6)*60 t_CR(1,6)*60],[0 600],'k--','LineWidth',2);
hold on
plot([0 1440],[max(CR_ref) max(CR_ref)],'k--','LineWidth',2);
hold on
plot(42222/60,CR_ref(42222,1),'ko','LineWidth',4);
hold on
plot(62177/60,CR_ref(62177,1),'ko','LineWidth',4);

text(240,425,'h_{1}','Color','k','HorizontalAlignment','Right','FontWeight','bold','FontSize',12);
text(240,max(CR_ref)+25,'h_{2}','Color','k','HorizontalAlignment','Right','FontWeight','bold','FontSize',12);
text(790,max(CR_ref)+25,'ToS_{1} \downarrow','Color','k','HorizontalAlignment','Right','FontWeight','bold','FontSize',11);
text(930,max(CR_ref)+25,'\downarrow ToS_{2}','Color','k','HorizontalAlignment','Left','FontWeight','bold','FontSize',11);

legend([h(1) h(2) h(3)],'B  Energy','A_{1} Energy','A_{2} Energy','Location','SouthWest');
set(gca,'xtick',[0:120:1440])
set(gca,'FontWeight','bold');
xlabel('Minute of Day','FontWeight','bold','FontSize',12);
ylabel('Charge Rate Schedule ( CR_{r} ) [ kW ]','FontWeight','bold','FontSize',12);