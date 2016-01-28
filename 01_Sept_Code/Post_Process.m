n = 100;
DONE = 0;
jj = 1;
ii=1;

inc = (length(sort_Results_1)/100) - 1;

%while ii<length(sort_Results)-200
while ii < length(sort_Results_1)-1
    %Obtain group of simresults:
    %   SUMMER_MIN Loading Condition --
    SM.(['PU_',num2str(n)]) = sort_Results_1(ii:ii+inc,2); %1:200 then 201:400
    SM.(['THRM_',num2str(n)]) = sort_Results_1(ii:ii+inc,4);
    SM.(['PU_',num2str(n)]) = sort(SM.(['PU_',num2str(n)])(:,1));
    SM.(['THRM_',num2str(n)]) = sort(SM.(['THRM_',num2str(n)])(:,1));
    %   WINTER_MIN Loading Condition --
    SM1.(['PU_',num2str(n)]) = sort_Results_2(ii:ii+inc,2); %1:200 then 201:400
    SM1.(['THRM_',num2str(n)]) = sort_Results_2(ii:ii+inc,4);
    SM1.(['PU_',num2str(n)]) = sort(SM1.(['PU_',num2str(n)])(:,1));
    SM1.(['THRM_',num2str(n)]) = sort(SM1.(['THRM_',num2str(n)])(:,1));
    %   Summer mean Loading Condition --
    SM2.(['PU_',num2str(n)]) = sort_Results_3(ii:ii+inc,2); %1:200 then 201:400
    SM2.(['THRM_',num2str(n)]) = sort_Results_3(ii:ii+inc,4);
    SM2.(['PU_',num2str(n)]) = sort(SM2.(['PU_',num2str(n)])(:,1));
    SM2.(['THRM_',num2str(n)]) = sort(SM2.(['THRM_',num2str(n)])(:,1));
    
    %fprintf('hit!!\n');
    ii = ii + inc + 1;
    n = n + 100;
    %SM.(pv_size{n+1,1}).A(m,1) = sort_RESULTS(ii,4);
end

%
%The object of this while loop is to calculate the interquat
%
%Worker variables:
n = 100;
i = 1;
m = 1;
ii = 1;
%Stat variables:
agg = 0;
agg1 = 0;
index = 0;
Q_V = zeros(101,10);
Q_I = zeros(101,10);
%Q_Vv = zeros(51,10);
%Q_Ii = zeros(51,10);
if ckt_num == 1
    %Bell
    nn = 389;%--
elseif ckt_num == 2
    %Common
    nn = 208;%--
elseif ckt_num == 3
    %Flay
    nn = 344;
elseif ckt_num == 4
    %ROX
    nn = 428;
elseif ckt_num == 5
    %HOLLY
    nn = 261;
elseif ckt_num == 6
    %ERAL
    nn = 113;%--
elseif ckt_num == 7
    nn = 199; %samples
end
PERC = [0,0.05,0.10,0.25,0.5,0.75,0.9,0.95,1];

while n < 10100
    %{
    %aggregate each set of ALL locations under same PV_kw:
    while m < 201
        
        agg = agg + SM.(['PU_',num2str(n)])(m,1);
        agg1 = agg1 + SM.(['THRM_',num2str(n)])(m,1);

        m = m + 1;
    end
    %}
    %Voltage Profiles:
    %Select which set for quartiles:
    if sim_type == 1
        SM_SLT=SM;
    elseif sim_type == 2
        SM_SLT=SM1;
    elseif sim_type == 3
        SM_SLT=SM2;
    end
    
    for j=1:1:9
        index = round(nn*PERC(1,j));
        if index == 0 %This is the bottom of Q1
            index = 1;
        end
        Q_V(i,j) = SM_SLT.(['PU_',num2str(n)])(index,1);
        Q_I(i,j) = SM_SLT.(['THRM_',num2str(n)])(index,1);
    end
    Q_V(i,10) = mean(SM_SLT.(['PU_',num2str(n)])(:,1));
    Q_I(i,10) = mean(SM_SLT.(['THRM_',num2str(n)])(:,1));
    
    %Refresh Variables:
    n = n + 100;
    i = i + 1;
end

%%

%
%Visualize the results:
% PLOT!!!
pv_size = zeros(101,9);
n = 0;
m = 1;
%sort_Results = sort(RESULTS);
while n<10100
    for k=1:1:9
        pv_size(m,k) = n;
    end
    n = n + 100;
    m = m + 1;
end
%
%Declare color RGB:
COLOR= zeros(9,3);
COLOR(1,:) = [0.0 1.0 1.0]; %below
COLOR(2,:) = [0.0 0.8 1.0]; %5th
COLOR(3,:) = [0.0 0.6 1.0]; %10th
COLOR(4,:) = [0.0 0.0 0.6]; %25th
COLOR(5,:) = [1.0 0.0 0.2]; %Median--
COLOR(6,:) = [0.0 0.0 0.6]; %50th
COLOR(7,:) = [0.0 0.6 1.0]; %75th
COLOR(8,:) = [0.0 0.8 1.0]; %90th
COLOR(9,:) = [0.0 1.0 1.0]; %95th & above

%
% "Effect of PV Size on max BUS VOLTAGE under 50% Load"
fig = 0;

if plot_type == 1
    fig = fig + 1;
    figure(fig);
    fprintf('before plot\n');

    %Hardcode way:
    X = zeros(200,2);
    Y = zeros(200,2);
    %C = zeros(1,3);
    %~~~~~~~~~~~~~~~~~
    j = 1;
    C = COLOR(j,:);
    y = Q_V(1:100,j);
    x = pv_size(2:101,1)/1000;
    h(1)=plot(x,y,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y1 = Q_V(1:100,j);
    C = COLOR(j,:);
    h(3)=plot(x,y1,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y2 = Q_V(1:100,j);
    C = COLOR(j,:);
    h(5)=plot(x,y2,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y3 = Q_V(1:100,j);
    C = COLOR(j,:);
    h(7)=plot(x,y3,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y4 = Q_V(1:100,j);
    C = COLOR(j,:);
    h(9)=plot(x,y4,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y5 = Q_V(1:100,j);
    C = COLOR(j,:);
    h(11)=plot(x,y5,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y6 = Q_V(1:100,j);
    C = COLOR(j,:);
    h(13)=plot(x,y6,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y7 = Q_V(1:100,j);
    C = COLOR(j,:);
    h(15)=plot(x,y7,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y8 = Q_V(1:100,j);
    C = COLOR(j,:);
    h(17)=plot(x,y8,'Color',C); %
    hold on
    j = j + 1;

    %Join horizontal vectors together---------------------------------

    x2 = flipud(x);
    X(1:200,1)=[x;x2];
    %~~~~~~~~~~~~~~~~~~~~~~~

    %Now lets fill inbetween Lines:
    %2) y1 & y2:
    Y(1:200,1)=[y1;flipud(y2)];
    C = COLOR(2,:);
    h(4)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none','LineWidth',2);
    hold on
    %1) y & y1:
    Y(1:200,1)=[y;flipud(y1)];
    C = COLOR(1,:);
    h(2)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none','LineWidth',5);
    hold on

    %3) y2 & y3:
    Y(1:200,1)=[y2;flipud(y3)];
    C = COLOR(3,:);
    h(6)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %4,6) y3 & y5:
    Y(1:200,1)=[y3;flipud(y5)];
    C = COLOR(4,:);
    h(10)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %7) y5 & y6:
    Y(1:200,1)=[y5;flipud(y6)];
    C = COLOR(7,:);
    h(14)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %8) y6 & y7:
    Y(1:200,1)=[y6;flipud(y7)];
    C = COLOR(8,:);
    h(16)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %9) y7 & y8:
    Y(1:200,1)=[y7;flipud(y8)];
    C = COLOR(9,:);
    h(18)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %5) y4:
    C = COLOR(5,:);
    plot(x,y4,'Color',C,'LineWidth',3);
    hold on

    %Voltage ANSI Limit:
    ansi(:,1)=0:100:10000;
    ansi(:,2)=ones(101,1).*1.05;
    plot(ansi(:,1),ansi(:,2),'k--','LineWidth',4);
    if ckt_num == 7
        axis([0 10 1.03 1.11]);
    elseif ckt_num == 2 || ckt_num == 1
        axis([0 10 1.02 1.11]);
    else
        axis([0 10 1.03 1.08]);
    end
    grid on
    legend([h(9),h(18),h(16),h(14),h(10),h(10),h(6),h(4),h(2)],{'Median','95th & up','90th to 95th','75th to 90th','50th to 75th','25th to 50','10th to 25th','5th to 10th','5th and below'},'Location','NorthWest');
    ylabel('Max Bus Voltage in Each Scenario(PU)','FontWeight','bold');
    xlabel('PV Size (MW)','FontWeight','bold');
    if sim_type == 1
        LVL_NM='SMR-2S';
    elseif sim_type == 2
        LVL_NM='WTR-2S';
    elseif sim_type == 3
        LVL_NM='SMR';
    end
    title(sprintf('Effect of PV size on max bus voltage under %s Load for %s',LVL_NM,feeder_name),'FontWeight','bold');
    set(gca,'FontWeight','bold');
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % "Effect of PV size on max LINE loading under 50% load"
    % 
    fig = fig + 1;
    figure(fig);
    %
    %Declare color RGB:
    COLOR= zeros(9,3);
    COLOR(1,:) = [0.0 1.0 0.0]; %below
    COLOR(2,:) = [0.0 0.8 0.0]; %5th
    COLOR(3,:) = [0.0 0.6 0.0]; %10th
    COLOR(4,:) = [0.0 0.2 0.0]; %25th
    COLOR(5,:) = [1.0 0.0 0.2]; %Median--
    COLOR(6,:) = [0.0 0.2 0.0]; %50th
    COLOR(7,:) = [0.0 0.6 0.0]; %75th
    COLOR(8,:) = [0.0 0.8 0.0]; %90th
    COLOR(9,:) = [0.0 1.0 0.0]; %95th & above


    %Hardcode way:
    X = zeros(200,2);
    Y = zeros(200,2);
    %C = zeros(1,3);
    %~~~~~~~~~~~~~~~~~
    j = 1;

    C = COLOR(j,:);
    y = Q_I(1:100,j);
    x = pv_size(2:101,1)/1000;
    h(1)=plot(x,y,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y1 = Q_I(1:100,j);
    C = COLOR(j,:);
    h(3)=plot(x,y1,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y2 = Q_I(1:100,j);
    C = COLOR(j,:);
    h(5)=plot(x,y2,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y3 = Q_I(1:100,j);
    C = COLOR(j,:);
    h(7)=plot(x,y3,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y4 = Q_I(1:100,j);
    C = COLOR(j,:);
    h(9)=plot(x,y4,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y5 = Q_I(1:100,j);
    C = COLOR(j,:);
    h(11)=plot(x,y5,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y6 = Q_I(1:100,j);
    C = COLOR(j,:);
    h(13)=plot(x,y6,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y7 = Q_I(1:100,j);
    C = COLOR(j,:);
    h(15)=plot(x,y7,'Color',C);
    hold on
    j = j + 1;
    %~~~~~~~~~~~~~~~~~
    y8 = Q_I(1:100,j);
    C = COLOR(j,:);
    h(17)=plot(x,y8,'Color',C); %
    hold on
    j = j + 1;

    %Join horizontal vectors together---------------------------------

    x2 = flipud(x);
    X(1:200,1)=[x;x2];
    %~~~~~~~~~~~~~~~~~~~~~~~

    %Now lets fill inbetween Lines:
    %1) y & y1:
    Y(1:200,1)=[y;flipud(y1)];
    C = COLOR(1,:);
    h(2)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %2) y1 & y2:
    Y(1:200,1)=[y1;flipud(y2)];
    C = COLOR(2,:);
    h(4)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %3) y2 & y3:
    Y(1:200,1)=[y2;flipud(y3)];
    C = COLOR(3,:);
    h(6)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %4,6) y3 & y5:
    Y(1:200,1)=[y3;flipud(y5)];
    C = COLOR(4,:);
    h(10)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %7) y5 & y6:
    Y(1:200,1)=[y5;flipud(y6)];
    C = COLOR(7,:);
    h(14)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %8) y6 & y7:
    Y(1:200,1)=[y6;flipud(y7)];
    C = COLOR(8,:);
    h(16)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %9) y7 & y8:
    Y(1:200,1)=[y7;flipud(y8)];
    C = COLOR(9,:);
    h(18)=fill(X(1:200,1),Y(1:200,1),C,'EdgeColor','none');
    hold on
    %5) y4:
    C = COLOR(5,:);
    plot(x,y4,'Color',C,'LineWidth',3);
    hold on
    %}
    %Thermal Rating:
    ansi(:,1)=0:100:10000;
    ansi(:,2)=ones(101,1).*100;
    plot(ansi(:,1),ansi(:,2),'k--','LineWidth',4);

    axis([0 10 0 350]);
    grid on
    legend([h(9),h(18),h(16),h(14),h(10),h(10),h(6),h(4),h(2)],{'Median','95th & up','90th to 95th','75th to 90th','50th to 75th','25th to 50','10th to 25th','5th to 10th','5th and below'},'Location','NorthWest');
    ylabel('Max Line Loadings in Each Scenario(%)','FontWeight','bold');
    xlabel('PV Size (MW)','FontWeight','bold');
    
    title(sprintf('Effect of PV size on max line loading under %s Load for %s',LVL_NM,feeder_name),'FontWeight','bold');
    set(gca,'FontWeight','bold');
end

%{
%testing: %Thermal Rating --
fig = fig + 1;
figure(fig);
for j=1:1:9
    scatter(pv_size(1:51,j),Q_I(1:51,j))
    hold on
end
%}
%{
pull=sort_Results(2801:3801,1:8);
fig = fig + 1;
figure(fig);
x1=pull(:,1);
y1=pull(:,8); %kVAR of CAP2
y2=pull(:,2); %max Bus Voltage
line(x1,y1,'Color','r');
ax1 = gca;
set(ax1,'XColor','r');
set(ax1,'YColor','r');
ax1_pos = get(gca,'Position');
ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none');
line(x1,y2);
%}
%%
if plot_type == 2
    %Create Fig. 7 by calc. the %violations out of all locations:
    count_v = 0;
    count_i = 0;
    n = 100;
    m = 1;
    violations = zeros(100,4); %totalV | V_vio | I_vio | PV_KW
    for i=1:1:3
        %Select which set of sims for violations:
        if i==1
            SMk=SM;
        elseif i==2
            SMk=SM1;
        elseif i==3
            SMk=SM2;
        end  

        while n < 10100
            %Voltage Profiles:
            for j=1:1:nn
                if SMk.(['PU_',num2str(n)])(j,1) > 1.05
                    count_v = count_v + 1;
                end

                if SMk.(['THRM_',num2str(n)])(j,1) > 100
                    count_i = count_i + 1;
                end
            end

            violations(m,1) = 100*(count_v+count_i)/(nn*2); %total violations
            violations(m,2) = 100*(count_v/nn); %voltage violations
            violations(m,3) = 100*(count_i/nn); %current violations
            violations(m,4) = n;

            %Refresh Variables:
            n = n + 100;
            m = m + 1;
            count_v = 0;
            count_i = 0;
        end
        %Reset outer variables:
        if i==1
            vio.SU_2S=violations;
            violations = zeros(100,4);
        elseif i==2
            vio.WT_2S=violations;
            violations = zeros(100,4);
        elseif i==3
            vio.SU=violations;
            violations = zeros(100,4);
        end
        n=100;
        m=1;
        count_v = 0;
        count_i = 0;


    end
    %Plot results:
    fig = fig + 1;
    figure(fig)
    %Loading condition #1
    h(1) = plot(vio.SU_2S(:,4),vio.SU_2S(:,2),'b.','LineWidth',6);
    hold on
    h(2) = plot(vio.SU_2S(:,4),vio.SU_2S(:,2),'b-','LineWidth',1);
    hold on
    h(3) = plot(vio.SU_2S(:,4),vio.SU_2S(:,3),'go','LineWidth',3);
    hold on
    h(4) = plot(interp(vio.SU_2S(:,4),20),interp(vio.SU_2S(:,3),20),'g.','LineWidth',0.5);
    %Loading condition #2
    h(5) = plot(vio.WT_2S(:,4),vio.WT_2S(:,2),'k.','LineWidth',6);
    hold on
    h(6) = plot(vio.WT_2S(:,4),vio.WT_2S(:,2),'k-','LineWidth',1);
    hold on
    h(7) = plot(vio.WT_2S(:,4),vio.WT_2S(:,3),'co','LineWidth',3);
    hold on
    h(8) = plot(interp(vio.WT_2S(:,4),20),interp(vio.WT_2S(:,3),20),'c.','LineWidth',0.5);



    legend([h(1),h(5),h(3),h(7)],'Voltage Violations (SU-2S)','Voltage Violations (WT-2S)','Line Loading Violations (SU-2S)','Line Loading Violations (WT-2S)','Location','NorthWest');
    axis([0 10000 0 140]);
    ylabel('Scenarios at Each PV Size With Violations [%]','FontWeight','bold','FontSize',12);
    xlabel('PV Capacity (P_{pv }) [kW]','FontWeight','bold','FontSize',12);
    title(sprintf('Percent of PV Scenerioes with violations at 2 load levels for: %s',feeder_name),'FontWeight','bold');
    set(gca,'FontWeight','bold');
    grid on
end