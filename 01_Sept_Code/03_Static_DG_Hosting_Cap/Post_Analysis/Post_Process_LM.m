clear
clc
close all
FDR = 3;
if FDR == 3
    load('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis\HOSTING_CAP_FLAY.mat')
    B=[ 3.064419e+03 -2.082900e+04  2.725788e+04  2.184025e-01 -1.815598e+00  1.246599e+01 -1.191669e+01  7.349932e+01 -8.239626e+01  ];
    PEAK_MW = 6.36;
    PERC = [0.25 0.5 0.4];
elseif FDR == 2
    load('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis\HOSTING_CAP_CMNW.mat')   %MAX_PV.WN_MIN & MAX_PV.SU_AVG
    B=[-7912.681445 17658.238187 -7367.804479     3.896479    -8.733485     4.655799   -27.683647   105.786805   -60.549709];
    PEAK_MW = 7.93;
    PERC=[0.5 0.65 0.55];
else
    load('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis\HOSTING_CAP_BELL.mat')   %MAX_PV.WN_MIN & MAX_PV.SU_AVG
    B=[5.916399e+03 -3.551280e+04  2.453363e+04 -9.266091e-01  7.344215e+00 -4.809867e+00  1.253246e+00 -1.147215e+01  2.212627e+01 ];
    PEAK_MW = 9.53;
    PERC=[.43 .7 .62];
end
%%
%Create datasets ---------------------------
%Winter Minimum:
X1=1./MAX_PV.WN_MIN(:,6);
X2=X1.^2;
L1=PEAK_MW*1000*PERC(1);
X1_L1=X1.*L1;
X2_L1=X2.*L1;
T=MAX_PV.WN_MIN(:,7);
X1_T=X1.*T;
X2_T=X2.*T;

PV_HC(:,1)=B(1)+B(2)*X1+B(3)*X2+B(4)*L1+B(5)*X1_L1+B(6)*X2_L1+B(7)*T+B(8)*X1_T+B(9)*X2_T;
PV_HC(:,2)=MAX_PV.WN_MIN(:,6);
PV_HC(:,3)=MAX_PV.WN_MIN(:,1);
ERROR(:,1)=PV_HC(:,1)-PV_HC(:,3);
%Summer average Load lvl:
L1=PEAK_MW*1000*PERC(2);
X1_L1=X1.*L1;
X2_L1=X2.*L1;
PV_HC(:,4)=B(1)+B(2)*X1+B(3)*X2+B(4)*L1+B(5)*X1_L1+B(6)*X2_L1+B(7)*T+B(8)*X1_T+B(9)*X2_T;
PV_HC(:,5)=MAX_PV.SU_AVG(:,1);
ERROR(:,2)=PV_HC(:,4)-PV_HC(:,5);
%Winter average Load lvl:
L1=7.93*1000*PERC(3);
X1_L1=X1.*L1;
X2_L1=X2.*L1;
PV_HC(:,6)=B(1)+B(2)*X1+B(3)*X2+B(4)*L1+B(5)*X1_L1+B(6)*X2_L1+B(7)*T+B(8)*X1_T+B(9)*X2_T;
PV_HC(:,7)=MAX_PV.WN_AVG(:,1);
ERROR(:,3)=PV_HC(:,6)-PV_HC(:,7);
ERROR(:,4)=PV_HC(:,2);
ER_1=sortrows(ERROR,4);
PV_HC(:,8)=MAX_PV.WN_AVG(:,4);
PV_HC_1=sortrows(PV_HC,2);   
%%
figure(1)
h(1)=plot(PV_HC_1(:,2),PV_HC_1(:,1),'k-','LineWidth',1.5);
hold on
h(2)=plot(PV_HC_1(:,2),PV_HC_1(:,3),'r.','LineWidth',2);
hold on
plot(PV_HC_1(:,2),PV_HC_1(:,4),'k-','LineWidth',1.5);
hold on
h(3)=plot(PV_HC_1(:,2),PV_HC_1(:,5),'g.','LineWidth',2);
%Settings--
if FDR == 1
    legend([h(1),h(2),h(3)],'Estimate','Actual MHC @4.1MW','Actual MHC @6.67MW','Location','NorthEast');
elseif FDR == 2
    legend([h(1),h(2),h(3)],'Estimate','Actual MHC @3.96MW','Actual MHC @5.15MW','Location','NorthEast');
elseif FDR == 3
    legend([h(1),h(2),h(3)],'Estimate','Actual MHC @1.59MW','Actual MHC @3.18MW','Location','NorthEast');
end

ylabel('Minimum Hosting Capacity (MHC) [kW]','FontWeight','bold','FontSize',12);
xlabel('Upstream Impedance (Zsc) [ \Omega ]','FontWeight','bold','FontSize',12);
%title(sprintf('Percent of PV Scenerioes with violations at 2 load levels for: %s',feeder_name),'FontWeight','bold');
set(gca,'FontWeight','bold');
grid on
%Now lets test on dataset I didn't fit to:
%%
figure(2)
plot(PV_HC_1(:,2),PV_HC_1(:,6),'r-','LineWidth',1.5);
hold on
plot(PV_HC_1(:,2),PV_HC_1(:,7),'b.','LineWidth',2);
%SET:
ylabel('Minimum Hosting Capacity (MHC) [kW]','FontWeight','bold','FontSize',12);
xlabel('Upstream Impedance (Zsc) [ \Omega ]','FontWeight','bold','FontSize',12);
legend('Estimate','Test Load Level');
set(gca,'FontWeight','bold');
grid on

%%
figure(3)
plot(ER_1(:,4),ER_1(:,1),'ro');
hold on
plot(ER_1(:,4),ER_1(:,2),'bo');
hold on
plot(ER_1(:,4),ER_1(:,3),'go');
%SET:
ylabel('MHC Error [kW]','FontWeight','bold','FontSize',12);
xlabel('Upstream Impedance (Zsc) [ \Omega ]','FontWeight','bold','FontSize',12);
set(gca,'FontWeight','bold');
legend('Winter Minimum','Summer Average','Winter Average','Location','SouthEast');
grid on
    

