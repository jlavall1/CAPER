%Show Concept_TVD
n = 1;
addpath(path1);
if Feeder == 2
    load YR_SIM_TVD_CMNW_00.mat     %Settings
    load YR_SIM_SUBV_CMNW_00.mat    %YEAR_SUB
    load YR_SIM_FDR_V_CMNW_00.mat   %YEAR_FDR
    load BUS_INFO.mat
end
RUN(n).Settings = Settings;
RUN(n).TVD = YEAR_SUB;
RUN(n).FVT = YEAR_FDR;
clear Settings YEAR_SUB

n = 2;
addpath(path2);
if Feeder == 2
    load YR_SIM_TVD_CMNW_025.mat     %Settings
    load YR_SIM_SUBV_CMNW_025.mat    %YEAR_SUB
    load YR_SIM_FDR_V_CMNW_025.mat   %YEAR_FDR
end
RUN(n).Settings = Settings;
RUN(n).TVD = YEAR_SUB;
RUN(n).FVT = YEAR_FDR;
clear Settings YEAR_SUB

n = 3;
addpath(path3);
if Feeder == 2
    load YR_SIM_TVD_CMNW_050.mat     %Settings
    load YR_SIM_SUBV_CMNW_050.mat    %YEAR_SUB
    load YR_SIM_FDR_V_CMNW_050.mat   %YEAR_FDR
end
RUN(n).Settings = Settings;
RUN(n).TVD = YEAR_SUB;
RUN(n).FVT = YEAR_FDR;
clear Settings YEAR_SUB
%%
%Let us first construct the node matrix vs. distance:
NODE=zeros(1321,3); %
j = 1;
T_S1=1000;
T_S2=3000;
for i=1:1:length(Buses_info)
    if Buses_info(i).numPhases == 3
        NODE(j,1) = Buses_info(i).distance;
        NODE(j,2) = RUN(1).TVD(110).all_V(j,T_S1);
        NODE(j,3) = RUN(2).TVD(110).all_V(j,T_S1);
        NODE(j,4) = RUN(3).TVD(110).all_V(j,T_S1);
        NODE(j,5) = 1;
        j = j + 1;
        NODE(j,1) = Buses_info(i).distance;
        NODE(j,2) = RUN(1).TVD(110).all_V(j,T_S1);
        NODE(j,3) = RUN(2).TVD(110).all_V(j,T_S1);
        NODE(j,4) = RUN(3).TVD(110).all_V(j,T_S1);
        NODE(j,5) = 2;
        j = j + 1;
        NODE(j,1) = Buses_info(i).distance;
        NODE(j,2) = RUN(1).TVD(110).all_V(j,T_S1);
        NODE(j,3) = RUN(2).TVD(110).all_V(j,T_S1);
        NODE(j,4) = RUN(3).TVD(110).all_V(j,T_S1);
        NODE(j,5) = 3;
        j = j + 1;
    elseif Buses_info(i).numPhases == 2
        NODE(j,1) = Buses_info(i).distance;
        NODE(j,2) = RUN(1).TVD(110).all_V(j,T_S1);
        NODE(j,3) = RUN(2).TVD(110).all_V(j,T_S1);
        NODE(j,4) = RUN(3).TVD(110).all_V(j,T_S1);
        NODE(j,5) = Buses_info(i).nodes(1);
        j = j + 1;
        NODE(j,1) = Buses_info(i).distance;
        NODE(j,2) = RUN(1).TVD(110).all_V(j,T_S1);
        NODE(j,3) = RUN(2).TVD(110).all_V(j,T_S1);
        NODE(j,4) = RUN(3).TVD(110).all_V(j,T_S1);
        NODE(j,5) = Buses_info(i).nodes(2);
        j = j + 1;
    elseif Buses_info(i).numPhases == 1
        NODE(j,1) = Buses_info(i).distance;
        NODE(j,2) = RUN(1).TVD(110).all_V(j,T_S1);
        NODE(j,3) = RUN(2).TVD(110).all_V(j,T_S1);
        NODE(j,4) = RUN(3).TVD(110).all_V(j,T_S1);
        NODE(j,5) = Buses_info(i).nodes;
        j = j + 1;
    end
end
[~,index] = sortrows([NODE(:,1)]);
NODE_D = NODE(index,1:5);

%%
V_B=12470/sqrt(3);
SUB_V(1,1:3)=RUN(1).TVD(110).V(10*3600+T_S1*5,1:3)/V_B
SUB_V(2,1:3)=RUN(2).TVD(110).V(10*3600+T_S1*5,1:3)/V_B
SUB_V(3,1:3)=RUN(3).TVD(110).V(10*3600+T_S1*5,1:3)/V_B
%%
fig = fig + 1;
figure(fig)
%COL2,3,4
%COL5 = PHASE
NODE_D(6,9)=0;
NODE_D(6,10)=0;
NODE_D(6,11)=0;
for j=7:1:length(NODE_D)
    %VD
    NODE_D(j,6)=(NODE_D(j,2)-SUB_V(1,NODE_D(j,5)))^2;
    NODE_D(j,7)=(NODE_D(j,3)-SUB_V(2,NODE_D(j,5)))^2;
    NODE_D(j,8)=(NODE_D(j,4)-SUB_V(2,NODE_D(j,5)))^2;
    %SUM
    NODE_D(j,9)=NODE_D(j-1,9)+ NODE_D(j,6);
    NODE_D(j,10)=NODE_D(j-1,10)+ NODE_D(j,7);
    NODE_D(j,11)=NODE_D(j-1,11)+ NODE_D(j,8);
end
plot(NODE_D(:,1),NODE_D(:,6),'b.')
hold on
plot(NODE_D(:,1),NODE_D(:,7),'r.')
hold on
plot(NODE_D(:,1),NODE_D(:,8),'g.')

xlabel('Distance From Substation [km]','FontSize',12,'FontWeight','bold');
ylabel('Voltage Deviation Squared from Substation (P.U)','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
grid on
legend('No DER-PV','7.1MW @ POI1','4.5MW @ POI2');
%samped at 11.39hr
MM=max(NODE_D(:,6));
set(gca,'YTick',[0:MM/6:MM]);
%plot(STVD_D(:,1),STVD_D(:,2));
%
%--------------------
%Show now TVD Calc
fig = fig + 1;
figure(fig)
h1=plot(NODE_D(:,1),NODE_D(:,9),'b-','LineWidth',3);
hold on
plot(NODE_D(1321,1),NODE_D(1321,9),'bo','LineWidth',3);
hold on
h2=plot(NODE_D(:,1),NODE_D(:,10),'r-','LineWidth',3);
plot(NODE_D(1321,1),NODE_D(1321,10),'ro','LineWidth',3);
hold on
h3=plot(NODE_D(:,1),NODE_D(:,11),'g-','LineWidth',3);
plot(NODE_D(1321,1),NODE_D(1321,11),'go','LineWidth',3);

xlabel('Distance From Substation [km]','FontSize',12,'FontWeight','bold');
ylabel('TVD','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
grid on
legend([h1 h2 h3],'No DER-PV','7.1MW @ POI1','4.5MW @ POI2','Location','NorthWest');
        