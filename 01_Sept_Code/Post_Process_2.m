%Post_Process --PART II--
%Coding to replicate Figure 5 & Figure 6:
%%
%------Find Rsc & Xsc at each legal bus:
iij = 1;
for k=1:1:length(Buses_Base)
   if Buses_Base(k,1).numPhases == 3 && Buses_Base(k,1).kVBase > vbase && Buses_Base(k,1).distance ~= 0
       Zsc(iij,1)=SC_Imped(k).Zsc1(1,1);
       Zsc(iij,2)=SC_Imped(k).Zsc1(1,2);
       iij = iij + 1;
   end
end
%%
%------Find Conductor Rating infront of each legal bus:
for i=1:1:length(legal_buses)
    for k=1:1:length(Lines_Base)
        if strcmp(Lines_Base(k,1).bus1,strcat(legal_buses{i,1},'.1.2.3')) == 1 || strcmp(Lines_Base(k,1).bus2,strcat(legal_buses{i,1},'.1.2.3')) == 1
            %Found a line
            Cond(i,1)=Lines_Base(k,1).lineRating;
            Cond(i,2)=Lines_Base(k,1).bus1PowerReal;
            k=length(Lines_Base); %kick out
        end
    end
end
        
%%
%------Attach dependent variables to KW_MIN_HOSTING
for k=1:1:4 %For each load level:
    %Dummy variables
    iij = 1;
    hold_1 = 1;
    for iii=2:1:length(RESULTS)
        KM=legal_distances{hold_1,1};
        RSC=Zsc(hold_1,1);
        XSC=Zsc(hold_1,2);
        ZSC=sqrt(RSC^2+XSC^2);
        RATE=Cond(hold_1,1);
        PEAK=Cond(hold_1,2);
        
        %Save depend. variables:
        if k==1
            RESULTS_SU_MIN(iii,9)=KM;
            RESULTS_SU_MIN(iii,10)=hold_1;
            RESULTS_SU_MIN(iii,15)=RSC;
            RESULTS_SU_MIN(iii,16)=ZSC;
            RESULTS_SU_MIN(iii,17)=RATE;
            RESULTS_SU_MIN(iii,18)=PEAK;
        elseif k==2
            RESULTS_WN_MIN(iii,9)=KM;
            RESULTS_WN_MIN(iii,10)=hold_1;
            RESULTS_WN_MIN(iii,15)=RSC;
            RESULTS_WN_MIN(iii,16)=ZSC;
            RESULTS_WN_MIN(iii,17)=RATE;
            RESULTS_WN_MIN(iii,18)=PEAK;
        elseif k == 3
            RESULTS_SU(iii,9)=KM;
            RESULTS_SU(iii,10)=hold_1;
            RESULTS_SU(iii,15)=RSC;
            RESULTS_SU(iii,16)=ZSC;
            RESULTS_SU(iii,17)=RATE;
            RESULTS_SU(iii,18)=PEAK;
        elseif k == 4
            RESULTS_WN(iii,9)=KM;
            RESULTS_WN(iii,10)=hold_1;
            RESULTS_WN(iii,15)=RSC;
            RESULTS_WN(iii,16)=ZSC;
            RESULTS_WN(iii,17)=RATE;
            RESULTS_WN(iii,18)=PEAK;
        end
        %Inc. hold_1 if nesseccary:  
        if iij == 100
            iij = 1;
            hold_1 = hold_1 + 1;
        else
            iij = iij + 1;
        end
    end
end
%%
%Select correct RESULTS set:
if sim_type == 1
    RESULTS=RESULTS_SU_MIN;
elseif sim_type == 2
    RESULTS=RESULTS_WN_MIN;
elseif sim_type == 3
    RESULTS=RESULTS_SU;
elseif sim_type == 4
    RESULTS=RESULTS_WN;
end
%%




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
    fig = 0;
    end_M = length(RESULTS);
    x = RESULTS(begin_M:end_M,9); %DISTANCE

    %Find minimum hosting capacity from results & save associated depend variables
    j = 1;
    i = 2;
    hit = 0;
    for k=1:1:4
        while i < length(x)+1%20002
            if k==1
                location = RESULTS_SU_MIN(i:i+99,:);
            elseif k==2
                location = RESULTS_WN_MIN(i:i+99,:);
            elseif k==3
                location = RESULTS_SU(i:i+99,:);
            elseif k==4
                location = RESULTS_WN(i:i+99,:);
            end

            j = 1;
            while j < 101 %100 different PV levels:
                if location(j,2) > 1.05
                    max_PVkw(n,1) = location(j,1); %PV_KW
                    %max_PVkw(n,2) = str2double(cell2mat(legal_buses(n,1))); %BUS#
                    max_PVkw(n,2) = location(j,6); %Bus ref
                    %Store voltage of violation:
                    max_PVkw(n,3) = location(j,2); %max3phV
                    %Reset Variables;
                    hit = 1;
                elseif location(j,4) > 100
                    max_PVkw(n,1) = location(j,1); %PV_KW
                    max_PVkw(n,2) = location(j,6);
                    %Store voltage of violation:
                    max_PVkw(n,3) = location(j,4); %max%THERM
                    %Reset Variables;
                    hit = 1;
                elseif j == 100
                    max_PVkw(n,1) = location(j,1); %PV_KW
                    max_PVkw(n,2) = location(j,6); %Bus ref
                    hit = 1;
                end
                if hit == 1
                    %Save static variables:
                    max_PVkw(n,4) = location(j,9);  %km
                    max_PVkw(n,5) = location(j,15); %Rsc
                    max_PVkw(n,6) = location(j,16); %Xsc
                    max_PVkw(n,7) = location(j,17); %line Rating
                    max_PVkw(n,8) = location(j,18); %kW
                    n = n + 1;
                    hit = 0;
                    j = 202;
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
        elseif k == 4
            MAX_PV.WN_AVG = max_PVkw;
        end
        i = 2;
        n = 2;
    end
    %%
    %NEXT FIGURE ---
    fig = fig + 1;
    figure(fig);
    plot(MAX_PV.SU_MIN(:,4),MAX_PV.SU_MIN(:,1),'bo') %distance VS maxKW
    hold on
    plot(MAX_PV.WN_MIN(:,4),MAX_PV.WN_MIN(:,1),'ro') %distance VS maxKW
    hold on
    plot(MAX_PV.SU_AVG(:,4),MAX_PV.SU_AVG(:,1),'go') %distance VS maxKW
    hold on 
    plot(MAX_PV.WN_AVG(:,4),MAX_PV.WN_AVG(:,1),'ko')
    
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
    legend('SMR-2S','WTR-2S','SUMMER','WINTER');
    grid on
    set(gca,'FontWeight','bold');  
    %%
    %{
    %NEXT FIGURE ---
    fig = fig + 1;
    figure(fig)
    plot(MAX_PV.SU_MIN(:,5),MAX_PV.SU_MIN(:,1),'bo') %Rsc VS maxKW
    hold on
    plot(MAX_PV.WN_MIN(:,5),MAX_PV.WN_MIN(:,1),'ro') %Rsc VS maxKW
    hold on
    plot(MAX_PV.SU_AVG(:,5),MAX_PV.SU_AVG(:,1),'go') %Rsc VS maxKW
    hold on
    plot(MAX_PV.WN_AVG(:,5),MAX_PV.WN_AVG(:,1),'ko') %Rsc VS maxKW
    
    xlabel('Upstream Resistance (Rsc) [/{omega}]','FontWeight','bold','FontSize',12);
    ylabel('Max Central PV Size (kW)','FontWeight','bold','FontSize',12);   
    legend('SMR-2S','WTR-2S','SUMMER','WINTER');
    grid on
    set(gca,'FontWeight','bold');
    %}
    %%
    %NEXT FIGURE ---
    fig = fig + 1;
    figure(fig)
    VAR = 6; %Zsc
    
    plot(MAX_PV.SU_MIN(:,VAR),MAX_PV.SU_MIN(:,1),'bo') 
    hold on
    plot(MAX_PV.WN_MIN(:,VAR),MAX_PV.WN_MIN(:,1),'ro') 
    hold on
    plot(MAX_PV.SU_AVG(:,VAR),MAX_PV.SU_AVG(:,1),'go') 
    hold on
    plot(MAX_PV.WN_AVG(:,VAR),MAX_PV.WN_AVG(:,1),'ko')
    
    xlabel('Upstream Impedance (Zsc) [/{omega}]','FontWeight','bold','FontSize',12);
    ylabel('Max Central PV Size (kW)','FontWeight','bold','FontSize',12);   
    legend('SMR-2S','WTR-2S','SUMMER','WINTER');
    grid on
    set(gca,'FontWeight','bold');
    %%
    %NEXT FIGURE ---
    fig = fig + 1;
    figure(fig)
    VAR = 7; %Zsc
    
    plot(MAX_PV.SU_MIN(:,VAR),MAX_PV.SU_MIN(:,1),'bo') 
    hold on
    plot(MAX_PV.WN_MIN(:,VAR),MAX_PV.WN_MIN(:,1),'ro') 
    hold on
    plot(MAX_PV.SU_AVG(:,VAR),MAX_PV.SU_AVG(:,1),'go') 
    hold on
    plot(MAX_PV.WN_AVG(:,VAR),MAX_PV.WN_AVG(:,1),'ko')
    
    xlabel('Upstream Line Rating','FontWeight','bold','FontSize',12);
    ylabel('Max Central PV Size (kW)','FontWeight','bold','FontSize',12);   
    legend('SMR-2S','WTR-2S','SUMMER','WINTER');
    grid on
    set(gca,'FontWeight','bold');
    %%
    %NEXT FIGURE ---
    fig = fig + 1;
    figure(fig)
    VAR = 8; %kW
    
    plot(MAX_PV.SU_MIN(:,VAR),MAX_PV.SU_MIN(:,1),'bo') 
    hold on
    plot(MAX_PV.WN_MIN(:,VAR),MAX_PV.WN_MIN(:,1),'ro') 
    hold on
    plot(MAX_PV.SU_AVG(:,VAR),MAX_PV.SU_AVG(:,1),'go') 
    hold on
    plot(MAX_PV.WN_AVG(:,VAR),MAX_PV.WN_AVG(:,1),'ko')
    
    xlabel('Peak Power]','FontWeight','bold','FontSize',12);
    ylabel('Max Central PV Size (kW)','FontWeight','bold','FontSize',12);   
    legend('SMR-2S','WTR-2S','SUMMER','WINTER');
    grid on
    set(gca,'FontWeight','bold');
    
end
    

