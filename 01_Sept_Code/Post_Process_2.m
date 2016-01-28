%Post_Process --PART II--
%Coding to replicate Figure 5 & Figure 6:
%Find where bus hits legal bus & distance from substation:
%{
j = 1;
%PV_LOC = zeros(202,2);
%ii = 5;

while ii< length(Buses) %length(Buses)
    s1 = Buses(ii,1).name;
    s2 = '.1.2.3';
    s = strcat(s1,'.1.2.3');
    
    %Skip BUS if not 3-ph & connected to 12.47:
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).voltage > 6000
        for i=1:1:length(Lines_Base)
            if strcmp(Lines_Base(i,1).bus1,s) == 1 %Bus name matches:
                if Lines_Base(i,1).numPhases == 3
                    PV_LOC(j,1) = i;
                    PV_LOC(j,2) = DISTANCE(i,1);
                    j = j + 1;
                end
            end
        end
    end
    ii = ii + 1;
end
%}
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Investigate:
ijj = 1;
ij = 1;
while ijj< length(Buses_Base) %length(Buses)
    if Buses_Base(ijj,1).numPhases == 3 && Buses_Base(ijj,1).voltage > 6000
        s1 = Buses_Base(ijj,1).name;
        s2 = '.1.2.3';
        s = strcat(s1,'.1.2.3');
        for iii=1:1:length(Lines_Base)
            if strcmp(Lines_Base(iii,1).bus1,s) == 1 %Bus name matches:
                if Lines_Base(iii,1).numPhases == 3
                    B1 = Lines_Base(iii,1).bus1;
                    %take off node #'s (.1.2.3):
                    B2 = regexprep({B1},'(\.[0-9]+)','');
                    for jjj=1:1:length(Buses_Base)
                        if strcmp(B2,Buses_Base(jjj,1).name)==1 %match!
                            if Buses_Base(jjj,1).distance > 1e-4
                                %Check to see if NOT in substation.
                                PV_LOC = iii;
                                Check_inv(ij,1) = PV_LOC;
                                Check_inv(ij,2) = str2double(Buses_Base(jjj,1).name);
                                Check_inv(ij,3) = Buses_Base(jjj,1).distance;
                                ij = ij + 1;
                            end
                        end
                    end
                end
            end
        end
    end
    ijj = ijj + 1;
end

%%
%Select correct RESULTS set:
if sim_type == 1
    RESULTS=RESULTS_SU_MIN;
elseif sim_type == 2
    RESULTS=RESULTS_WN_MIN;
elseif sim_type == 3
    RESULTS=RESULTS_SU;
end
%Check for invalid:
ij = 1;
for ijj=2:100:length(RESULTS)
    Check_inv(ij,4) = RESULTS(ijj,6);
    ij = ij + 1;
    %disp(ijj)
end

%Add a distance from SUB column vector to RESULTS:
j = 1;
m = 1;
%k = 2; %skip bus in sub.

while ii < length(RESULTS)+1%20001
    if ckt_num > 2
        RESULTS(ii,9) = legal_distances{k,1};
    else 
        %RESULTS(ii,9) = legal_distances{k,1};
        for ijj=1:1:length(Check_inv)
            if RESULTS(ii,6) == Check_inv(ijj,1)
                RESULTS(ii,9) = Check_inv(ijj,3);
                RESULTS_SU_MIN(ii,9) = Check_inv(ijj,3); %distances:
                RESULTS_WN_MIN(ii,9) = Check_inv(ijj,3);
                RESULTS_SU(ii,9) = Check_inv(ijj,3);
                
            end
        end
        %RESULTS(ii,9) = Check_inv(k,3); %distances
    end
    if m == 100
        %move onto next bus:
        m = 1;
        k = k + 1;
    else
        m = m + 1;
    end  
    ii = ii + 1;
end
%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
%Sort in ascending order in respect to BUS VOLT:
VS_RESULTS = zeros(length(RESULTS(102:20001,1)),9);
[VS_RESULTS(:,2),I]=sort(RESULTS(102:20001,2),1,'descend');
for i=1:1:length(VS_RESULTS)
    for j=102:1:20001%length(RESULTS)
        if j==I(i,1) %if the index matches:
            VS_RESULTS(i,1)=RESULTS(j,1); %PV_KW
            VS_RESULTS(i,3)=RESULTS(j,2); %max_BusV
            VS_RESULTS(i,6)=RESULTS(j,6); %max_%thermal
            VS_RESULTS(i,9)=RESULTS(j,9); %
        end
    end
end
%}
%{
%This will sort by "tallest bus Vmax set"
maxsetV=zeros(200,2); %Vmax | Bus
j=1;
HOLD=1;
for i=1:1:length(VS_RESULTS)-1000
    %RESULTS(i,9)=HOLD;
    if j ~= 100 
        if RESULTS(i,2) > maxsetV(HOLD,1)
            maxsetV(HOLD,1)=RESULTS(i,2);
        end
        RESULTS(i,10)=HOLD;
        j = j + 1;
    elseif j == 100
        maxsetV(HOLD,2)=HOLD; %Hold bus index position;
        RESULTS(i,10)=HOLD;
        j = 1; %Go onto next BUS set
        HOLD=HOLD+1; %Go onto next maxV position
    end
    
end
%Now sort max(maxBUSVOLTAGES):
[maxset_sort(:,1),I]=sort(maxsetV(:,1),1,'descend');
k = 1; %counter for a set:
i = 1;
while i < length(VS_RESULTS)-1000 %end result:
    %Search through and obtain all hits of HOLD#
    for j=1:1:length(RESULTS)
        
        if RESULTS(j,10)==I(k,1) %if the index matches:
            VS_RESULTS(i,1)=RESULTS(j,1);
            VS_RESULTS(i,2)=RESULTS(j,2);
            VS_RESULTS(i,3)=RESULTS(j,3);
            VS_RESULTS(i,6)=RESULTS(j,6);
            VS_RESULTS(i,9)=RESULTS(j,9);
            VS_RESULTS(i,10)=RESULTS(j,10);
            i = i + 1; %should only hit 100 times
        end
    end
    k = k + 1; %move onto next I(k,1)
end
%}
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Plot Fig. 6:
if plot_type == 3
    fig = 1;
    figure(fig);
    %{
    x = VS_RESULTS(1:20000,9); %DISTANCE
    y = VS_RESULTS(1:20000,2); %max BUS VOLTAGE
    x_pv = VS_RESULTS(1:20000,1)/1000; %PV SIZE
    %}
    %Other Method:
    end_M = length(RESULTS);
    x = RESULTS(begin_M:end_M,9); %DISTANCE
    y = RESULTS(begin_M:end_M,2); %max BUS VOLTAGE
    x_pv = RESULTS(begin_M:end_M,1)/1000; %PV SIZE
    %}
    %
    colormap('jet');
    cmap = colormap;
    lineHandles = scatter(x,y,10,x_pv);
    %Create & edit colorbar:
    c = colorbar('location','eastoutside');
    %Edit title string:
    set(get(c,'title'),'string','PV Size (MW)','Rotation',90.0,'FontWeight','bold');
    pos = get(get(c,'title'),'position');
    pos(1,1) = pos(1,1)+50.5;
    pos(1,2) = pos(1,2)+120;
    set(get(c,'title'),'position',pos);


    %Other params:
    xlabel('PV Distance (km)','FontWeight','bold');
    ylabel('Max Bus Voltage in Each Scenerio(pu)','FontWeight','bold');
    if sim_type == 1
        LVL_NM='SMR-2S';
    elseif sim_type == 2
        LVL_NM='WTR-2S';
    elseif sim_type == 3
        LVL_NM='SMR';
    end
    title(sprintf('Impact from PV size on %s with %s Loadset',feeder_name,LVL_NM),'FontWeight','Bold');
    max_distance=0;
    for i=1:1:length(legal_distances)
        if legal_distances{i,1} > max_distance
            max_distance = legal_distances{i,1};
        end
    end
    if ckt_num == 1
        V_min_axis=1.0;
    else
        V_min_axis=1.02;
    end
    axis([0 max_distance V_min_axis 1.11]);
    grid on
    set(gca,'FontWeight','bold');
    %%
elseif plot_type == 4
    %Figure 8 "Max Allowed PV size at a single bus under 50% Load"
    %num_loc = 199;
    num_loc = length(legal_distances)-1;
    num_kws = 10e3/100;
    max_PVkw = zeros(199,4);
    %i = 102; %skip bus3 b/c distance to sub = 0km
    %n = 1;
    for k=1:1:3
        while i < length(x)+1%20002
            if k==1
                location = RESULTS(i:i+99,1:9);
            elseif k==2
                location = RESULTS_30(i:i+99,1:10);
            elseif k==3
                location = RESULTS_25(i:i+99,1:10);
            end

            j = 1;
            while j < 101 %100 different PV levels:
                if location(j,2) > 1.05
                    max_PVkw(n,1) = location(j,1); %PV_KW
                    %max_PVkw(n,2) = str2double(cell2mat(legal_buses(n,1))); %BUS#
                    max_PVkw(n,2) = location(j,6); %Bus ref
                    %Store voltage of violation:
                    max_PVkw(n,3) = location(j,2); %max3phV
                    max_PVkw(n,4) = location(j,9); %km

                    %Reset Variables;
                    n = n + 1;
                    j = 202;
                elseif location(j,4) > 100
                    max_PVkw(n,1) = location(j,1); %PV_KW
                    %max_PVkw(n,2) = str2double(cell2mat(legal_buses(n,1))); %BUS#
                    max_PVkw(n,2) = location(j,6);
                    %max_PVkw(n,2) = legal_buses(n+1,1); %BUS#
                    %Store voltage of violation:
                    max_PVkw(n,3) = location(j,4); %max%THERM
                    max_PVkw(n,4) = location(j,9); %km
                    %Reset Variables;
                    n = n + 1;
                    j = 202;
                elseif j == 100
                    max_PVkw(n,1) = location(j,1); %PV_KW
                    %max_PVkw(n,2) = str2double(cell2mat(legal_buses(n,1))); %BUS#
                    max_PVkw(n,2) = location(j,6); %Bus ref
                    %max_PVkw(n,2) = legal_buses(n+1,1); %BUS#
                    max_PVkw(n,4) = location(j,9); %km
                    n = n + 1;
                end
                j = j + 1;
                display(n)
            end
            i = i + 100;
        end
        if k == 1
            MAX_PV.L50 = max_PVkw;
        elseif k == 2
            MAX_PV.L30 = max_PVkw;
        elseif k == 3
            MAX_PV.L25 = max_PVkw;
        end
        i = 2;
        n = 2;
    end
    fig = fig + 1;
    figure(fig);
    plot(MAX_PV.L50(:,4),MAX_PV.L50(:,1),'bo') %distance VS maxKW
    hold on
    plot(MAX_PV.L30(:,4),MAX_PV.L30(:,1),'ro') %distance VS maxKW
    hold on
    plot(MAX_PV.L25(:,4),MAX_PV.L25(:,1),'go') %distance VS maxKW



    if ckt_num == 1
        axis([0 4 0 14000]);
        title('EPRI - CKT7','FontWeight','bold');
    elseif ckt_num == 2
        axis([0 5 0 14000]);
        title('DEC2 - CMNWLTH','FontWeight','bold');
    elseif ckt_num == 3
        axis([0 13 0 11000]);
        title('Feeder-03 DER Hosting Capacity','FontWeight','bold');
    end
    xlabel('PV Distance (km)','FontWeight','bold','FontSize',12);
    ylabel('Max Central PV Size (kW)','FontWeight','bold','FontSize',12);   
    legend('Avg. Summer Load (0.5)','Min. Summer Load (0.3)','Min. Winter Load (0.25)');
    grid on
    set(gca,'FontWeight','bold');    
end
    

