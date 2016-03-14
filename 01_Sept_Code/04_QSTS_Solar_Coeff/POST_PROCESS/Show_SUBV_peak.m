%Show_SUBV_peak
%reference: PEAK_DOY
n = 1;
addpath(path1);
if Feeder == 2
    load YR_SIM_SUBV_CMNW_00.mat    %YEAR_SUB
    load YR_SIM_OLTC_CMNW_00.mat    %YEAR_LTC
    load YR_SIM_P_CMNW_00.mat       %YEAR_SIM_P
    load YR_SIM_Q_2_CMNW_00.mat       %YEAR_SIM_Q_2
    RUN(n).YEAR_SIM_Q(61:120) = YEAR_SIM_Q_2(61:120);
    clear YEAR_SIM_Q_2
    
elseif Feeder == 3
    load YR_SIM_SUBV_FLAY_00.mat    %YEAR_SUB
    load YR_SIM_OLTC_FLAY_00.mat    %YEAR_LTC
    load YR_SIM_P_FLAY_00.mat       %YEAR_SIM_P
end
RUN(n).FDR_V = YEAR_SUB(PEAK_DOY);
RUN(n).SUB_LTC = YEAR_LTC(PEAK_DOY);
RUN(n).SUB_P = YEAR_SIM_P(PEAK_DOY);
clear YEAR_SUB YEAR_LTC YEAR_SIM_P

n = 2;
addpath(path2);
if Feeder == 2
    load YR_SIM_SUBV_CMNW_025.mat    %YEAR_SUB
    load YR_SIM_OLTC_CMNW_025.mat    %YEAR_LTC
    load YR_SIM_P_CMNW_025.mat       %YEAR_SIM_P
elseif Feeder == 3
    load YR_SIM_SUBV_FLAY_010.mat    %YEAR_SUB
    load YR_SIM_OLTC_FLAY_010.mat    %YEAR_LTC
    load YR_SIM_P_FLAY_010.mat       %YEAR_SIM_P
end
RUN(n).FDR_V = YEAR_SUB(PEAK_DOY);
RUN(n).SUB_LTC = YEAR_LTC(PEAK_DOY);
RUN(n).SUB_P = YEAR_SIM_P(PEAK_DOY);
clear YEAR_SUB YEAR_LTC YEAR_SIM_P

n = 3;
addpath(path3);
if Feeder == 2
    load YR_SIM_SUBV_CMNW_050.mat    %YEAR_SUB
    load YR_SIM_OLTC_CMNW_050.mat    %YEAR_LTC
    load YR_SIM_P_CMNW_050.mat       %YEAR_SIM_P
elseif Feeder == 3
    load YR_SIM_SUBV_FLAY_025.mat    %YEAR_SUB
    load YR_SIM_OLTC_FLAY_025.mat    %YEAR_LTC
    load YR_SIM_P_FLAY_025.mat       %YEAR_SIM_P
end
RUN(n).FDR_V = YEAR_SUB(PEAK_DOY);
RUN(n).SUB_LTC = YEAR_LTC(PEAK_DOY);
RUN(n).SUB_P = YEAR_SIM_P(PEAK_DOY);
clear YEAR_SUB YEAR_LTC YEAR_SIM_P
%%
%Show 3-phase & 1-phase(faint) of three cases.
fig = fig + 1;
figure(fig)
n=1;
X=[1/3600:1/3600:24]';
M=RUN(n).SUB_P.DSS_SUB(:,1)+RUN(n).SUB_P.DSS_SUB(:,2)+RUN(n).SUB_P.DSS_SUB(:,3);
plot(X,M,'b-','LineWidth',3);
hold on
n=n+1;
M=RUN(n).SUB_P.DSS_SUB(:,1)+RUN(n).SUB_P.DSS_SUB(:,2)+RUN(n).SUB_P.DSS_SUB(:,3);
plot(X,M,'g-','LineWidth',3);
hold on
n=n+1;
M=RUN(n).SUB_P.DSS_SUB(:,1)+RUN(n).SUB_P.DSS_SUB(:,2)+RUN(n).SUB_P.DSS_SUB(:,3);
plot(X,M,'r-','LineWidth',3);
hold on
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC 3-ph Real Power (P) [kW]','FontSize',12,'FontWeight','bold');
axis([0 24 -4000 4000]);
%7100,4500];
if Feeder == 2
    legend('No DER-PV','7.1MW @ POI1','4.5MW @ POI2','Location','SouthWest');
end
set(gca,'XTick',[0:2:24])
grid on
set(gca,'FontWeight','bold');
%%
fig = 0;
%Show OLTC Voltage Impact:
fig = fig + 1;
figure(fig)
n=1;
M=RUN(n).FDR_V.V(:,1:3)/60;
h1=plot(X,M,'b-','LineWidth',3);
hold on
n=2;
M=RUN(n).FDR_V.V(:,1:3)/60;
h2=plot(X,M,'g-','LineWidth',3);
hold on
n=3;
M=RUN(n).FDR_V.V(:,1:3)/60;
h3=plot(X,M,'r-','LineWidth',3);
M=ones(86400,1)*124;
hold on
plot(X,M,'k-','LineWidth',1.5);
hold on
plot(X,M+0.5,'k--','LineWidth',1.5);
hold on
plot(X,M-0.5,'k--','LineWidth',1.5);
hold on
txt1= 'Q Data Quality \rightarrow';
text(7,124.1,txt1,'HorizontalAlignment','right','FontWeight','bold')
hold on
%txt1= 'S.C. Opened \rightarrow';
%text(7,124.1,txt1,'HorizontalAlignment','right','FontWeight','bold')

if Feeder == 2
    legend([h1(1) h2(1) h3(1)],'No DER-PV','7.1MW @ POI1','4.5MW @ POI2','Location','NorthEast');
end
set(gca,'XTick',[0:2:24])
set(gca,'YTick',[123.4:.1:124.6]);
axis([0 24 123.4 124.6])
set(gca,'FontWeight','bold');
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC Voltage-120V Base (V_{L-N} ) [V]','FontSize',12,'FontWeight','bold');








    