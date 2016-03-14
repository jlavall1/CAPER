%Show_Worst_Tap_inv:
if Feeder == 2
    PEAK_DOY=110;
elseif Feeder == 3
    PEAK_DOY=101;
end
%-------------
n = 1;
addpath(path1);
if Feeder == 2
    load YR_SIM_SUBV_CMNW_00.mat    %YEAR_SUB
    load YR_SIM_OLTC_CMNW_00.mat    %YEAR_LTC
    load YR_SIM_CMNW_SUMTAP.mat
    load YR_SIM_CMNW_TAPPOS.mat
elseif Feeder == 3
    load YR_SIM_SUBV_FLAY_00.mat    %YEAR_SUB
    load YR_SIM_OLTC_FLAY_00.mat    %YEAR_LTC
    load YR_SIM_FLAY_SUMTAP.mat
    load YR_SIM_FLAY_TAPPOS.mat
end
RUN(n).FDR_V = YEAR_SUB(PEAK_DOY);
RUN(n).SUB_LTC = YEAR_LTC(PEAK_DOY);
clear YEAR_SUB YEAR_LTC 

n = 2;
addpath(path2);
if Feeder == 2
    load YR_SIM_SUBV_CMNW_025.mat    %YEAR_SUB
    load YR_SIM_OLTC_CMNW_025.mat    %YEAR_LTC
elseif Feeder == 3
    load YR_SIM_SUBV_FLAY_010.mat    %YEAR_SUB
    load YR_SIM_OLTC_FLAY_010.mat    %YEAR_LTC
end
RUN(n).FDR_V = YEAR_SUB(PEAK_DOY);
RUN(n).SUB_LTC = YEAR_LTC(PEAK_DOY);
clear YEAR_SUB YEAR_LTC

n = 3;
addpath(path3);
if Feeder == 2
    load YR_SIM_SUBV_CMNW_050.mat    %YEAR_SUB
    load YR_SIM_OLTC_CMNW_050.mat    %YEAR_LTC
elseif Feeder == 3
    load YR_SIM_SUBV_FLAY_025.mat    %YEAR_SUB
    load YR_SIM_OLTC_FLAY_025.mat    %YEAR_LTC
end
RUN(n).FDR_V = YEAR_SUB(PEAK_DOY);
RUN(n).SUB_LTC = YEAR_LTC(PEAK_DOY);
clear YEAR_SUB YEAR_LTC
%%
%Reference PEAK_DOY to select worst case DAY:
%   PT Control Voltage Only
fig = 0;
fig = fig + 1;
figure(fig)
X=[1/3600:1/3600:24];
if Feeder == 2
    PT_ph=3;
elseif Feeder == 3
    PT_ph=3;
end
N=RUN(1).FDR_V.V(:,PT_ph)/60;
h1=plot(X,N,'b-','LineWidth',2);
hold on
N=RUN(2).FDR_V.V(:,PT_ph)/60;
h2=plot(X,N,'r-','LineWidth',2);
hold on
N=RUN(3).FDR_V.V(:,PT_ph)/60;
h3=plot(X,N,'g-','LineWidth',2);
hold on
LIM=ones(length(N),1);
h4=plot(X,LIM*124,'k-','LineWidth',2.5);
hold on
h5=plot(X,LIM*124.5,'k--','LineWidth',3);
hold on
plot(X,LIM*123.5,'k--','LineWidth',3);
hold on


if Feeder == 2
    legend('No DER-PV','7.1MW @ POI1','4.5MW @ POI2','Location','NorthWest');
elseif Feeder == 3
    legend([h1 h2 h3 h4 h5],'No DER-PV','4.0MW @ POI1','0.5MW @ POI2','Set Voltage','BandWidth (BW)');
end
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC PT Voltage (120V BASE)','FontSize',12,'FontWeight','bold');
axis([0 24 123.25 125.25])
set(gca,'FontWeight','bold');
set(gca,'XTick',[0:4:24])
set(gca,'YTick',[123.25:.25:125.25])
grid on
%--------------------------------------------------------------------------
%   OLTC Tap Position:
fig = fig + 1;
figure(fig);
N=RUN(1).SUB_LTC.OP(:,3);
h1=plot(X,N,'b-','LineWidth',2);
hold on
N=RUN(2).SUB_LTC.OP(:,3);
h2=plot(X,N,'r-','LineWidth',3);
hold on
N=RUN(3).SUB_LTC.OP(:,3);
h3=plot(X,N,'g-','LineWidth',2);
hold on
TOP_T=1+2*(.2/32);
BOT_T=1-2*(.2/32);
axis([0 24 BOT_T TOP_T])
set(gca,'XTick',[0:4:24])
set(gca,'YTick',[BOT_T:(.2/32):TOP_T])
grid on
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
ylabel('OLTC Tap Position','FontSize',12,'FontWeight','bold');
if Feeder == 2
    legend('No DER-PV','7.1MW @ POI1','4.5MW @ POI2','Location','NorthWest');
elseif Feeder == 3
    legend([h1 h2 h3],'No DER-PV','4.0MW @ POI1','0.5MW @ POI2','Location','SouthEast');
end
set(gca,'FontWeight','bold');

