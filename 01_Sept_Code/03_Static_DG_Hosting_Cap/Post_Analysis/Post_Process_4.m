%This will plot Min Hosting Cap results per feeder

%DSS Open:
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSText.command = ['Compile "',mainFile];
DSSText.command = sprintf('New EnergyMeter.CircuitMeter LINE.%s terminal=1 option=R PhaseVoltageReport=yes',energy_line);
DSSText.command = sprintf('EnergyMeter.CircuitMeter.peakcurrent=[  %s   %s   %s  ]',num2str(peak_current(1,1)),num2str(peak_current(1,2)),num2str(peak_current(1,3)));
DSSText.command = 'Disable Capacitor.*';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'Enable Capacitor.*';

%Run at desired Load Level:
DSSText.command ='solve loadmult=0.5';
Buses =getBusInfo(DSSCircObj);
addBuses=legal_buses;
Bus2add =getBusInfo(DSSCircObj,addBuses,1);
BusesCoords = reshape([Bus2add.coordinates],2,[])';

%Start to plot the Circuit:
hf1 = figure(1);
ax1 = axes('Parent',hf1);
hold on;
gcf=plotCircuitLines(DSSCircObj,'Coloring','numPhases','MappingBackground','none');
set(gca,'xtick',[]);
set(gca,'ytick',[]);

%{
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
    %}
%Select desired season results:
if sim_type == 1
    max_PV_Select=MAX_PV.SU_MIN;
elseif sim_type == 2
    max_PV_Select=MAX_PV.WN_MIN;
elseif sim_type == 3
    max_PV_Select=MAX_PV.SU_AVG;
elseif sim_type == 4
    max_PV_Select=MAX_PV.WN_AVG;
end
%Collect needed parameters from general 'max_PV_Select':
max_PVkw(:,1)=max_PV_Select(:,1);
max_PVkw(:,2)=max_PV_Select(:,9);

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
COLOR(6,:) = [1.0 0.0 0.0]; % >6



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
%Insert text box explaining colors:
%%
if ckt_num == 2
    x = 0.13;
    y = 0.865;
    w = 0.19;
    h = 0.06;
    annotation('textbox',[x,y,w,h],'String','0.0MW : 3.0MW','Color',COLOR(1,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    annotation('textbox',[x,y-h,w,h],'String','3.0MW : 3.5MW','Color',COLOR(2,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    annotation('textbox',[x,y-2*h,w,h],'String','3.5MW : 4.0MW','Color',COLOR(3,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    annotation('textbox',[x,y-3*h,w,h],'String','4.0MW : 4.5MW','Color',COLOR(4,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    annotation('textbox',[x,y-4*h,w,h],'String','4.5MW : 6.0MW','Color',COLOR(5,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    annotation('textbox',[x,y-5*h,w,h],'String','6.0MW : 10MW','Color',COLOR(6,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
elseif ckt_num == 3
    x = 0.714;
    y = 0.865;
    w = 0.19;
    h = 0.06;
    annotation('textbox',[x,y,w,h],'String','0.0MW : 3.0MW','Color',COLOR(1,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    annotation('textbox',[x,y-h,w,h],'String','3.0MW : 3.5MW','Color',COLOR(2,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    annotation('textbox',[x,y-2*h,w,h],'String','3.5MW : 4.0MW','Color',COLOR(3,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    annotation('textbox',[x,y-3*h,w,h],'String','4.0MW : 4.5MW','Color',COLOR(4,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    annotation('textbox',[x,y-4*h,w,h],'String','4.5MW : 6.0MW','Color',COLOR(5,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
    annotation('textbox',[x,y-5*h,w,h],'String','6.0MW : 10MW','Color',COLOR(6,:),'FontSize',9,'BackgroundColor',[0.8,0.8,0.8]);
end
