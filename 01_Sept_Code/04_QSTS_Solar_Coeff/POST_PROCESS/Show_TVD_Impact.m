%Show_TVD_Impact
n = 1;
addpath(path1);
if Feeder == 2
    load YR_SIM_TVD_CMNW_00.mat     %Settings
    load YR_SIM_SUBV_CMNW_00.mat    %YEAR_SUB
elseif Feeder == 3
    load YR_SIM_TVD_FLAY_00.mat
    load YR_SIM_SUBV_FLAY_00.mat
end
RUN(n).Settings = Settings;
RUN(n).TVD = YEAR_SUB;
clear Settings YEAR_SUB

n = 2;
addpath(path2);
if Feeder == 2
    load YR_SIM_TVD_CMNW_025.mat     %Settings
    load YR_SIM_SUBV_CMNW_025.mat    %YEAR_SUB
elseif Feeder == 3
    load YR_SIM_TVD_FLAY_010.mat
    load YR_SIM_SUBV_FLAY_010.mat
end
RUN(n).Settings = Settings;
RUN(n).TVD = YEAR_SUB;
clear Settings YEAR_SUB

n = 3;
addpath(path3);
if Feeder == 2
    load YR_SIM_TVD_CMNW_050.mat     %Settings
    load YR_SIM_SUBV_CMNW_050.mat    %YEAR_SUB
elseif Feeder == 3
    load YR_SIM_TVD_FLAY_025.mat
    load YR_SIM_SUBV_FLAY_025.mat
end
RUN(n).Settings = Settings;
RUN(n).TVD = YEAR_SUB;
clear Settings YEAR_SUB
%%
fig = 0;
j = 1;
h = 1;
k = 1;
for n=1:1:3
    j = 1;
    h = 1;
    k = 1;
    
    for DOY=32:1:120
        TVD(DOY).V3ph=[RUN(n).TVD(DOY).TVD_SAVE(:,1)/3];%+[RUN(n).TVD(DOY).TVD_SAVE(:,2)]+[RUN(n).TVD(DOY).TVD_SAVE(:,3)])/3;
        N(k,n) = mean([TVD(DOY).V3ph]);%this is the mean...  %mean([TVD(DOY).V3ph]);
        
        M(j:j+4319,n)=[TVD(DOY).V3ph];
        M(j:j+4319,4)=[h-1+5/3600:5/3600:6+h-1];
        
        k = k + 1;
        j = j + 4320;
        h = h + 6;
    end
end
%----------------
%plot daily average TVD:
fig = fig + 1;
figure(fig)
X=32:1:120;
plot(X,N(:,1),'b-','LineWidth',2);
hold on
plot(X,N(:,2),'g-','LineWidth',2);
hold on
plot(X,N(:,3),'r-','LineWidth',2);
if Feeder == 2
    legend('No DER-PV','7.1MW @ POI1','4.5MW @ POI2','Location','NorthWest');
elseif Feeder == 3
    legend('No DER-PV','3.0MW @ POI1','0.5MW @ POI2');
end
xlabel('Day of Year (DOY)','FontSize',12,'FontWeight','bold');
ylabel('Daytime Average TVD','FontSize',12,'FontWeight','bold');
axis([32 120 0 0.35])
set(gca,'FontWeight','bold');
set(gca,'XTick',[32:7:120])
%%
%----------------
%plot select day to show time shift of TVD:
if Feeder == 2
    DOY=110;
elseif Feeder == 3
    DOY=101;%change (45, 34, or 101
end
fig = fig + 1;
figure(fig)
X=10:5/3600:16-5/3600;
n = 1;
B=[RUN(n).TVD(DOY).TVD_SAVE(:,1)/3];%+[RUN(n).TVD(DOY).TVD_SAVE(:,2)]+[RUN(n).TVD(DOY).TVD_SAVE(:,3)])/3;
plot(X,B,'b-','LineWidth',3);
hold on
n = 2;
B=[RUN(n).TVD(DOY).TVD_SAVE(:,1)/3];%+[RUN(n).TVD(DOY).TVD_SAVE(:,2)]+[RUN(n).TVD(DOY).TVD_SAVE(:,3)])/3;
plot(X,B,'g-','LineWidth',3);
hold on
n = 3;
B=[RUN(n).TVD(DOY).TVD_SAVE(:,1)/3];%+[RUN(n).TVD(DOY).TVD_SAVE(:,2)]+[RUN(n).TVD(DOY).TVD_SAVE(:,3)])/3;
plot(X,B,'r-','LineWidth',3);
%   Settings:
if Feeder == 2
    legend('No DER-PV','7.1MW @ POI1','4.5MW @ POI2');
elseif Feeder == 3
    legend('No DER-PV','3.0MW @ POI1','0.5MW @ POI2');
end
ylabel('5 Second Average TVD','FontSize',12,'FontWeight','bold');
xlabel('Hour of Day (HoD)','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
axis([10 16 0 0.3]);
grid on
%%
%----------------





%%
%----------------
%plot TVD_pv - TVD_base vs DARR
fig = fig + 1;
figure(fig);
DARR = M_PVSITE_SC(32:120,6)/max([M_PVSITE_SC(32:120,6)]); %DARR
M1=N(:,2)-N(:,1);
plot(DARR,M1,'go','LineWidth',2);
hold on
M2=N(:,3)-N(:,1);
plot(DARR,M2,'ro','LineWidth',2);
%   Settings:
if Feeder == 2
    legend('7.1MW @ POI1','4.5MW @ POI2','Location','SouthEast');
elseif Feeder == 3
    legend('3.0MW @ POI1','0.5MW @ POI2','Location','SouthEast');
end
ylabel('Diffence between TVDs (PV-BASE)','FontSize',12,'FontWeight','bold');
xlabel('Daily Aggregate Ramp Rate (DARR) [P.U.]','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
grid on
%----------------
%plot TVD_pv - TVD_base vs CI
fig = fig + 1;
figure(fig);
CI = M_PVSITE_SC(32:120,5); %CI
M1=N(:,2)-N(:,1);
plot(CI,M1,'go','LineWidth',2);
hold on
M2=N(:,3)-N(:,1);
plot(CI,M2,'ro','LineWidth',2);
%   Settings:
if Feeder == 2
    legend('7.1MW @ POI1','4.5MW @ POI2','Location','SouthEast');
elseif Feeder == 3
    legend('3.0MW @ POI1','0.5MW @ POI2','Location','SouthEast');
end
ylabel('Diffence between TVDs (PV-BASE)','FontSize',12,'FontWeight','bold');
xlabel('Clear-sky Index (CI)','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
grid on






    
    