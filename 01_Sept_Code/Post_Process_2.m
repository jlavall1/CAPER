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
%Plot Fig. 
if plot_type == 3
    
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
    fig = 0;
    %Figure 8 "Max Allowed PV size at a single bus under 50% Load"
    
    
    %num_loc = 199;
    end_M = length(RESULTS);
    x = RESULTS(begin_M:end_M,9); %DISTANCE
    num_loc = length(legal_distances)-1;
    num_kws = 10e3/100;
    max_PVkw = zeros(199,4);
    %Connect km & Rsc to RESULTS_XX_XXX (Check_inv(i,3) &&
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
                                    Check_inv(ij,4) = SC_Imped(jjj).Zsc1(1,1);
                                    Check_inv(ij,5) = SC_Imped(jjj).Zsc1(1,2);
                                    Check_inv(ij,6) = jjj;
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
    
    %Attach dependent variables to KW_MIN_HOSTING
    for k=1:1:3
        %dummary variables
        iij = 1;
        hold_1 = 1;
        for iii=2:1:length(RESULTS_SU_MIN)
            if k==1
                RESULTS_SU_MIN(iii,9)=Check_inv(hold_1,3); %kM
                RESULTS_SU_MIN(iii,10)=Check_inv(hold_1,4); %Rsc
            elseif k==2
                RESULTS_WN_MIN(iii,9)=Check_inv(hold_1,3); %kM
                RESULTS_WN_MIN(iii,10)=Check_inv(hold_1,4); %Rsc
            elseif k == 3
                RESULTS_SU(iii,9)=Check_inv(hold_1,3); %kM
                RESULTS_SU(iii,10)=Check_inv(hold_1,4); %Rsc
            end
            
            if iij == 100
                iij = 1;
                hold_1 = hold_1 + 1;
            else
                iij = iij + 1;
            end
        end
    end

    
    %i = 102; %skip bus3 b/c distance to sub = 0km
    %n = 1;
    disp(i)
    for k=1:1:3
        while i < length(x)+1%20002
            if k==1
                location = RESULTS_SU_MIN(i:i+99,1:10);
            elseif k==2
                location = RESULTS_WN_MIN(i:i+99,1:10);
            elseif k==3
                location = RESULTS_SU(i:i+99,1:10);
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
                    max_PVkw(n,5) = location(j,10); %Rsc

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
                    max_PVkw(n,5) = location(j,10); %Rsc
                    %Reset Variables;
                    n = n + 1;
                    j = 202;
                elseif j == 100
                    max_PVkw(n,1) = location(j,1); %PV_KW
                    %max_PVkw(n,2) = str2double(cell2mat(legal_buses(n,1))); %BUS#
                    max_PVkw(n,2) = location(j,6); %Bus ref
                    %max_PVkw(n,2) = legal_buses(n+1,1); %BUS#
                    max_PVkw(n,4) = location(j,9); %km
                    max_PVkw(n,5) = location(j,10); %Rsc
                    n = n + 1;
                end
                j = j + 1;
                display(n)
            end
            i = i + 100;
        end
        if k == 1
            MAX_PV.SU_MIN = max_PVkw;
        elseif k == 2
            MAX_PV.WN_MIN = max_PVkw;
        elseif k == 3
            MAX_PV.SU_AVG = max_PVkw;
        end
        i = 2;
        n = 2;
    end
    %%
    fig = fig + 1;
    figure(fig);
    plot(MAX_PV.SU_MIN(:,4),MAX_PV.SU_MIN(:,1),'bo') %distance VS maxKW
    hold on
    plot(MAX_PV.WN_MIN(:,4),MAX_PV.WN_MIN(:,1),'ro') %distance VS maxKW
    hold on
    plot(MAX_PV.SU_AVG(:,4),MAX_PV.SU_AVG(:,1),'go') %distance VS maxKW
    
    title(sprintf('Minimum Hosting Capacity for %s',feeder_name),'FontWeight','Bold');
    max_distance=0;
    for i=1:1:length(legal_distances)
        if legal_distances{i,1} > max_distance
            max_distance = legal_distances{i,1};
        end
    end
    %Settings:
    axis([0 max_distance+1 0 14000])
    xlabel('PV Distance (km)','FontWeight','bold','FontSize',12);
    ylabel('Max Central PV Size (kW)','FontWeight','bold','FontSize',12);   
    legend('SMR-2S','WTR-2S','SUMMER');
    grid on
    set(gca,'FontWeight','bold');  
    %%
    %NEXT FIGURE ---
    fig = fig + 1;
    figure(fig)
    plot(MAX_PV.SU_MIN(:,5),MAX_PV.SU_MIN(:,1),'bo') %Rsc VS maxKW
    hold on
    plot(MAX_PV.WN_MIN(:,5),MAX_PV.WN_MIN(:,1),'ro') %Rsc VS maxKW
    hold on
    plot(MAX_PV.SU_AVG(:,5),MAX_PV.SU_AVG(:,1),'go') %Rsc VS maxKW
    xlabel('Upstream Resistance (Rsc) [/{omega}]','FontWeight','bold','FontSize',12);
    ylabel('Max Central PV Size (kW)','FontWeight','bold','FontSize',12);   
    legend('SMR-2S','WTR-2S','SUMMER');
    grid on
    set(gca,'FontWeight','bold');  
    
end
    

