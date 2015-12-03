clear
clc
%This function will generate plots depending on what user desires:
%Focuses on interp simulation data:
plot_choice=menu('How would you like to see the PV_PCCs?','By Distance','By Iteration #','maxPV_Cap');
while plot_choice<1
    plot_choice=menu('How would you like to see the PV_PCCs?','By Distance','By Iteration #','maxPV_Cap');
end
user_def = zeros(1,2); %LOWER_BOUND | UPPPER_BOUND
if plot_choice==1
    cat_choice=menu('What Range?','0.00km  -  1.00km','1.01km  -  1.75km','1.76km  -  2.5km','2.51km  -  3.00km','3.01km  -  3.50km','3.51 <');
    while cat_choice<1
        cat_choice=menu('What Range?','0.00km  -  1.00km','1.01km  -  1.75km','1.76km  -  2.5km','2.51km  -  3.00km','3.01km  -  3.50km','3.51 <');
    end
    if cat_choice == 1
        user_def(1,1) = 0;
        user_def(1,2) = 1;
    elseif cat_choice == 2
        user_def(1,1) = 1.01;
        user_def(1,2) = 1.75;
    elseif cat_choice == 3
        user_def(1,1) = 1.76;
        user_def(1,2) = 2.50;
    elseif cat_choice == 4
        user_def(1,1) = 2.51;
        user_def(1,2) = 3.00;
    elseif cat_choice == 5
        user_def(1,1) = 3.01;
        user_def(1,2) = 3.50;
    elseif cat_choice == 6
        user_def(1,1) = 3.51;
        user_def(1,2) = 4.5;
    end       
elseif plot_choice==2
    prompt = 'Please Enter lower bound of Position Iteration # (0 -> 200)';
    lb = input(prompt);
    if lb < 0 || lb > 200
        prompt = 'Please RE-ENTER lower bound:';
        lb = input(prompt);
    end
    prompt = 'Now ENTER upper bound (0:200)';
    ub = input(prompt);
    %update matrix:
    user_def(1,1) = lb;
    user_def(1,2) = ub;
end
%%
%After Simulation, Lets show where all the locations were w/ distance from
%substation.

%Add this part of script if you don't want to run sim"
%
%Setup the COM server:
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
%Find directory of Circuit:
DER_Planning_GUI_1
%UIWAIT(1)
gui_response = STRING_0;
%gui_response = GUI_openDSS_Locations();
%Declare name of basecase .dss file:
%master = 'Master_ckt7.dss';
%basecaseFile = strcat(mainFile,master);
%basecaseFile=mainFile;
mainFile = gui_response{1,1};
ckt_num = gui_response{1,2};
%basecaseFile = 'R:\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\Run_Master_Allocate.dss';
DSSText.command = ['Compile "',mainFile];


%Capacitors(1,1).enable
%DSSText.command = 'edit capacitor.cp-nr-613 switching=0';
%DSSText.command = 'edit capacitor.cp-85w-900 enable=0'; 
DSSText.command ='solve loadmult=0.5';
%DSSText.command = 'Set mode=snapshot';
%DSSText.command = 'Set controlmode = static';
%DSSText.command = 'solve';
%Get Capacitor Information
Capacitors = getCapacitorInfo(DSSCircObj);

%Enable/Disable capacitor

%
%"PLOT BASE CASE (to see that I am wrong ha.ha."
figure(1);
%plotKWProfile(DSSCircObj);
%plotVoltageProfile(DSSCircObj,'SecondarySystem','off');
%plotAmpProfile(DSSCircObj,'157345');
%plotKVARProfile(DSSCircObj,'Only3Phase','on');
%%


Buses =getBusInfo(DSSCircObj);
%Import desired Buses based on user selection:
if ckt_num == 1 %commonwealth
    load config_LEGALBUSES_CMNWLTH.mat
    load config_LEGALDISTANCE_CMNWLTH.mat %legal_distances
elseif ckt_num == 7 %EPRI-7
    load config_LEGALBUSES_CKT7.mat
    load config_LEGALDISTANCE_CKT7.mat
elseif ckt_num == 2 %Flay
    load config_LEGALBUSES_FLAY.mat
    load config_LEGALDISTANCE_FLAY.mat
    peak_current = [196.597331353572,186.718068471483,238.090235458346];
    energy_line = '259363665';
end
j = 1;
for i=1:1:length(legal_buses);
    %BY Distance:
    if plot_choice == 1
        if legal_distances(i,1) >= user_def(1,1) && legal_distances(i,1) <= user_def(1,2)
            addBuses{j,1} = legal_buses{i,1};
            j = j + 1;
        end
    %BY Interation #:
    elseif plot_choice == 2
        if i >= user_def(1,1) && i <= user_def(1,2)
            addBuses{j,1} = legal_buses{i,1};
            j = j + 1;
        end
    %BY maxPV_KW:
    elseif plot_choice == 3
        %to show all buses:
        user_def(1,1)=2;
        user_def(1,2)=200;
        if i >= user_def(1,1) && i <= user_def(1,2)
            addBuses{j,1} = legal_buses{i,1};
            j = j + 1;
        end
    end
end

%addBuses = [legal_buses];


if plot_choice == 1
    titlestring=sprintf('PV-PCC''s DISTANCE range from SUB: %1.2f to %1.2f km ',user_def(1,1),user_def(1,2));
elseif plot_choice == 2
    titlestring=sprintf('PV-PCC''s Interation # range from: %1.2f to %1.2f km ',user_def(1,1),user_def(1,2));
elseif plot_choice == 3
    titlestring=sprintf('PV-PCC''s Interation # range from: %1.2f to %1.2f km ',user_def(1,1),user_def(1,2));
end


DSSText.command = sprintf('New EnergyMeter.CircuitMeter LINE.%s terminal=1 option=R PhaseVoltageReport=yes',energy_line);
%DSSText.command = 'EnergyMeter.CircuitMeter.peakcurrent=[  196.597331353572   186.718068471483   238.090235458346  ]';
DSSText.command = sprintf('EnergyMeter.CircuitMeter.peakcurrent=[  %s   %s   %s  ]',num2str(peak_current(1,1)),num2str(peak_current(1,2)),num2str(peak_current(1,3)));
DSSText.command = 'solve';




%This is to print the feeder
hf1 = figure(2);

%plotCircuitLines(DSSCircObj,'Coloring','lineLoading','PVMarker','on','MappingBackground','none');
ax1 = axes('Parent',hf1);
hold on;
gcf=plotCircuitLines(DSSCircObj,'Coloring','numPhases','MappingBackground','none');
title(titlestring);

%PV_PCC buses

Bus2add =getBusInfo(DSSCircObj,addBuses,1);
BusesCoords = reshape([Bus2add.coordinates],2,[])';
%now lets add onto plot:
%   B = repmat(A,r1,r2): specs a list of scalars (rN) that describes how
%   copies of A are arranged in each dimension
if plot_choice == 1 || plot_choice == 2
    busHandle = plot(repmat(BusesCoords(:,2)',2,1),repmat(BusesCoords(:,1)',2,1),'ko','MarkerSize',10,'MarkerFaceColor','c','LineStyle','none','DisplayName','Bottleneck');
    legend([gcf.legendHandles,busHandle'],[gcf.legendText,'PV_{PCC} Locations'] )
elseif plot_choice == 3
    %Import Results from 50% Load:
    load RESULTS_9_14_2015.mat
    %
    %Find max allowed kW before a violation:
    num_loc = 199;
    num_kws = 10e3/100;
    max_PVkw = zeros(199,4);
    i = 102; %skip bus3 b/c distance to sub = 0km
    n = 1;
    while i < 20002
        location = RESULTS(i:i+99,1:9);
        j = 1;
        while j < 101
            if location(j,2) > 1.05
                max_PVkw(n,1) = location(j,1); %PV_KW
                max_PVkw(n,2) = str2double(cell2mat(legal_buses(n+1,1))); %BUS#
                %Store voltage of violation:
                max_PVkw(n,3) = location(j,2); %max3phV
                max_PVkw(n,4) = location(j,9); %km

                %Reset Variables;
                n = n + 1;
                j = 202;
            elseif location(j,4) > 100
                max_PVkw(n,1) = location(j,1); %PV_KW
                max_PVkw(n,2) = str2double(cell2mat(legal_buses(n+1,1))); %BUS#
                %max_PVkw(n,2) = legal_buses(n+1,1); %BUS#
                %Store voltage of violation:
                max_PVkw(n,3) = location(j,4); %max%THERM
                max_PVkw(n,4) = location(j,9); %km
                %Reset Variables;
                n = n + 1;
                j = 202;
            elseif j == 100
                max_PVkw(n,1) = location(j,1); %PV_KW
                max_PVkw(n,2) = str2double(cell2mat(legal_buses(n+1,1))); %BUS#
                %max_PVkw(n,2) = legal_buses(n+1,1); %BUS#
                max_PVkw(n,4) = location(j,9); %km
                n = n + 1;
            end
            j = j + 1;
        end
        i = i + 100;
    end
    
    %Alter Color:
    %colormap('jet');
    %cmap = colormap;
    COLOR= zeros(9,3);
    %{
    COLOR(1,:) = [1.0 1.0 0.0]; %0-1
    COLOR(2,:) = [1.0 0.8 0.0]; %1-2
    COLOR(3,:) = [1.0 0.6 0.0]; %2-3
    COLOR(4,:) = [1.0 0.4 0.0]; %3-4
    COLOR(5,:) = [1.0 0.2 0.0]; %4-5
    COLOR(6,:) = [1.0 0.0 0.0]; % >5
    %}
    COLOR(1,:) = [0.0 0.0 1.0]; %0-3
    COLOR(2,:) = [0.0 0.6 1.0]; %3-3.5
    COLOR(3,:) = [0.0 0.8 0.6]; %3.5-4
    COLOR(4,:) = [1.0 0.4 0.0]; %4-4.5
    COLOR(5,:) = [1.0 1.0 0.0]; %4.5-6
    COLOR(6,:) = [1.0 0.2 0.0]; % >6
    %max_PV(kw(199,1)
    %Now lets plot results:
    for i=1:1:length(BusesCoords)
        %circ_size = (max_PVkw(i,1)/10e3)*15;
        
        if max_PVkw(i,1) <= 3e3
            C = COLOR(1,:);
            circ_size = 2;
            h_1 = plot(repmat(BusesCoords(i,2)',2,1),repmat(BusesCoords(i,1)',2,1),'ko','MarkerSize',circ_size,'MarkerFaceColor',C,'LineStyle','none','DisplayName','Bottleneck');
        elseif max_PVkw(i,1) > 3e3 && max_PVkw(i,1) <= 3.5e3
            C = COLOR(2,:);
            circ_size = 4;
            h(2) = plot(repmat(BusesCoords(i,2)',2,1),repmat(BusesCoords(i,1)',2,1),'ko','MarkerSize',circ_size,'MarkerFaceColor',C,'LineStyle','none','DisplayName','Bottleneck');
        elseif max_PVkw(i,1) > 3.5e3 && max_PVkw(i,1) <= 4e3
            C = COLOR(3,:);
            circ_size = 6;
            h(3) = plot(repmat(BusesCoords(i,2)',2,1),repmat(BusesCoords(i,1)',2,1),'ko','MarkerSize',circ_size,'MarkerFaceColor',C,'LineStyle','none','DisplayName','Bottleneck');
        elseif max_PVkw(i,1) > 4e3 && max_PVkw(i,1) <= 4.5e3
            C = COLOR(4,:);
            circ_size = 8;
            h(4) = plot(repmat(BusesCoords(i,2)',2,1),repmat(BusesCoords(i,1)',2,1),'ko','MarkerSize',circ_size,'MarkerFaceColor',C,'LineStyle','none','DisplayName','Bottleneck');
        elseif max_PVkw(i,1) > 4.5e3 && max_PVkw(i,1) <= 6e3
            C = COLOR(5,:);
            circ_size = 10;
            h(5) = plot(repmat(BusesCoords(i,2)',2,1),repmat(BusesCoords(i,1)',2,1),'ko','MarkerSize',circ_size,'MarkerFaceColor',C,'LineStyle','none','DisplayName','Bottleneck');
        elseif max_PVkw(i,1) > 6e3
            C = COLOR(6,:);
            circ_size = 14;
            h(6) = plot(repmat(BusesCoords(i,2)',2,1),repmat(BusesCoords(i,1)',2,1),'ko','MarkerSize',circ_size,'MarkerFaceColor',C,'LineStyle','none','DisplayName','Bottleneck');
        end
        %plot(repmat(BusesCoords(i,2)',2,1),repmat(BusesCoords(i,1)',2,1),'ko','MarkerSize',circ_size,'MarkerFaceColor',C,'LineStyle','none','DisplayName','Bottleneck');
        %plot(repmat(BusesCoords(:,2)',2,1),repmat(BusesCoords(:,1)',2,1),'ko','MarkerSize',10,'MarkerFaceColor','c','LineStyle','none','DisplayName','Bottleneck');
    end
    
    %mTextBox = uicontrol('style','text');
    %set(mTextBox,'String','hi','Position',[0.714,0.81,0.175,0.086*4]);
    %%
    if ckt_num == 7
        x = 0.714;
        y = 0.71;
        w = 0.19;
        h = 0.06;
        annotation('textbox',[x,y,w,h],'String','0.0MW : 3.0MW','Color',COLOR(1,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
        annotation('textbox',[x,y-h,w,h],'String','3.0MW : 3.5MW','Color',COLOR(2,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
        annotation('textbox',[x,y-2*h,w,h],'String','3.5MW : 4.0MW','Color',COLOR(3,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
        annotation('textbox',[x,y-3*h,w,h],'String','4.0MW : 4.5MW','Color',COLOR(4,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
        annotation('textbox',[x,y-4*h,w,h],'String','4.5MW : 6.0MW','Color',COLOR(5,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
        annotation('textbox',[x,y-5*h,w,h],'String','6.0MW : 10MW','Color',COLOR(6,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);    
    elseif ckt_num == 1
        x = 0.714;
        y = 0.42;
        w = 0.19;
        h = 0.06;
        annotation('textbox',[x,y,w,h],'String','0.0MW : 3.0MW','Color',COLOR(1,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
        annotation('textbox',[x,y-h,w,h],'String','3.0MW : 3.5MW','Color',COLOR(2,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
        annotation('textbox',[x,y-2*h,w,h],'String','3.5MW : 4.0MW','Color',COLOR(3,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
        annotation('textbox',[x,y-3*h,w,h],'String','4.0MW : 4.5MW','Color',COLOR(4,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
        annotation('textbox',[x,y-4*h,w,h],'String','4.5MW : 6.0MW','Color',COLOR(5,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
        annotation('textbox',[x,y-5*h,w,h],'String','6.0MW : 10MW','Color',COLOR(6,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    end
    %legend([gcf.legendHandles],[gcf.legendText,'PV_{PCC} Locations'] )
    %legend([gcf.legendHandles,h(1)'],[gcf.legendText,[h(1),h(2),h(3),h(4),h(5),h(6),],'0MW - 1MW','1MW-2MW','2MW-3MW','4MW-5MW','5MW-10MW'])
    %l_handle2 = legend([h(1),h(2),h(3),h(4),h(5),h(6)],'0-1','1-2','2-3','3-4','4-5','5-');
    %set(l_handle2,'Color','none');
end
    
    


