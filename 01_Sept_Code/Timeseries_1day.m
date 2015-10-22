%Timeseries Analyses:
clear
clc
close all
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code')
tic
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%Find directory of Circuit:
% 1. Obtain user's choice of simulation:
DER_Planning_GUI_1
gui_response = STRING_0;

ckt_direct      = gui_response{1,1}; %entire directory string of where the cktfile is locatted
feeder_NUM      = gui_response{1,2};
scenerio_NUM    = gui_response{1,3}; %1=VREG-top ; 2=VREG-bot ; 3=steadystate ; 4=RR_up ; 5=RR_down
base_path       = gui_response{1,4};  %github directory based on user's selected comp. choice;
cat_choice      = gui_response{1,5}; %DEC DEP EPRI;
PV_Site         = gui_response{1,7}; %( 1 - 7) site#s;
PV_Site_path    = gui_response{1,8}; %directory to PV kW file:
timeseries_span = gui_response{1,9}; %(1) day ; (1) week ; (1) year ; etc.
monthly_span    = gui_response{1,10};%(1) Month selected ; 1=JAN 12=DEC.
%{
STRING_0{1,1} = STRING;
STRING_0{1,2} = ckt_num;
STRING_0{1,3} = sim_type;
STRING_0{1,4} = s_b;
STRING_0{1,5} = cat_choice;
STRING_0{1,6} = section_type;
STRING_0{1,7} = PV_location;
STRING_0{1,8} = PV_dir;
STRING_0{1,9} = time_select;
STRING_0{1,10} = mnth_select;
%}

% 1. Add paths of background files:
path = strcat(base_path,'\01_Sept_Code');
addpath(path);
path = strcat(base_path,'\04_DSCADA');
addpath(path);

% 2. Generate Real Power & PV loadshape files:
PV_Loadshape_generation
feeder_Loadshape_generation

% 3. Compile the user selected circuit:
location = cd;
DSSText.command = ['Compile ',ckt_direct_prime];
Lines_Base = getLineInfo(DSSCircObj);
Buses_Base = getBusInfo(DSSCircObj);
Loads_Base = getLoadInfo(DSSCircObj);
%Xfmr_Base = get
cd(location);
%%
%Sort Lines into closest from PCC --
[~,index] = sortrows([Lines_Base.bus1Distance].'); 
Lines_Distance = Lines_Base(index); 
clear index
%
% 4. Add loadshapes:
%{
DSSText.command = sprintf('new Loadshape.LS_PhaseA npts=%s minterval=%s mult=(file=%s) action=normalize',num2str(FEEDER.SIM.npts),num2str(FEEDER.SIM.minterval),s_kwA);
DSSText.command = sprintf('new Loadshape.LS_PhaseB npts=%s minterval=%s mult=(file=%s) action=normalize',num2str(FEEDER.SIM.npts),num2str(FEEDER.SIM.minterval),s_kwB);
DSSText.command = sprintf('new Loadshape.LS_PhaseC npts=%s minterval=%s mult=(file=%s) action=normalize',num2str(FEEDER.SIM.npts),num2str(FEEDER.SIM.minterval),s_kwC);

% 5. Edit loads to accominate LS_PhaseA ; LS_Phase B;
for i=1:1:length(Loads_Base)
    if Loads_Base(i,1).nodes == 1
        DSSText.command = sprintf('edit Load.%s duty=%s',Loads_Base(i,1).name,'LS_PhaseA');
    elseif Loads_Base(i,1).nodes == 2
        DSSText.command = sprintf('edit Load.%s duty=%s',Loads_Base(i,1).name,'LS_PhaseB');
    elseif Loads_Base(i,1).nodes == 3
        DSSText.command = sprintf('edit Load.%s duty=%s',Loads_Base(i,1).name,'LS_PhaseC');
    else
        fprintf('Shit, out of luck here: %d\n',i);
    end
end
%}
%DSSText.command = 'solve';
%Loads_NEW = getLoadInfo(DSSCircObj);  

% 6. Add  PV loadshapes:
%{
PV_INFO.sizeMW = 1;
USER_def_km = 1; 
%   Now lets find the closest bus to 1 km.
delta_min = 5;
for i=1:1:length(Lines_Distance)
    if Lines_Distance(i,1).numPhases == 3
        delta = abs(Lines_Distance(i,1).bus1Distance-USER_def_km);
        if delta < delta_min
            delta_min =delta;
            bus_index = i;
        end
    end
end
B1 = Lines_Distance(bus_index,1).bus1;
%take off node #'s (.1.2.3):
B2 = regexprep({B1},'(\.[0-9]+)','');    
PV_INFO.busName = B2;

if Lines_Distance(1,1).bus1Voltage > 6000 && Lines_Distance(1,1).bus1Voltage < 8000
    PV_INFO.kV = 12.47;
elseif Lines_Distance(1,1).bus1Voltage > 12.4941 && Lines_Distance(1,1).bus1Voltage < 13.9485
    PV_INFO.kV = 22.9;
elseif Lines_Distance(1,1).bus1Voltage > 13.0397 && Lines_Distance(1,1).bus1Voltage < 14.5576
    PV_INFO.kV = 23.9;
end
PV_INFO.kVA = (PV_INFO.sizeMW/1000)/0.9; %kVA
PV_INFO.pmpp = PV_INFO.sizeMW/1000; %kW
seconds=60*60*24;

%DSSText.command =sprintf('new loadshape.PV_Loadshape npts=%s sinterval=1 csvfile="%s" Pbase=%s action=normalizenew pvsystem.PV bus1=%s irradiance=1 phases=3 kv=%s kVA=%s pf=1.00 pmpp=%s duty=PV_Loadshape',seconds,s_pv_txt,PV_INFO.sizeMW,PV_INFO.busName,PV_INFO.kV,PV_INFO.kVA,PV_INFO.pmpp);
%DSSText.command =sprintf('
%}
% 7. Run Simulation:

%----------------------------------
%Add PV Plant:
str = ckt_direct;
idx = strfind(str,'\');
str = str(1:idx(8)-1);
%Make .dss name specific to what feeder you are simulating:
if feeder_NUM == 0
    %Bellhaven
    root = 'Bell';
    root1= 'Bell';
elseif feeder_NUM == 1
    %Commonwealth
    root = 'Common';
    root1= 'Common';
elseif feeder_NUM == 2
    %Flay 13.27km long --
    root = 'Flay';
    root1= 'Flay';
end

if timeseries_span == 1
    s_pv_txt = sprintf('%s_CentralPV_6hr.dss',root);
elseif timeseries_span == 2
    s_pv_txt = sprintf('%s_CentralPV_24hr.dss',root); %just added the 2
elseif timeseries_span == 3
    s_pv_txt = sprintf('%s_CentralPV_168hr.dss',root);
elseif timeseries_span == 4
    if shift+1 == 28
        s_pv_txt = sprintf('%s_CentralPV_1mnth28.dss',root);
    elseif shift+1 == 30
        s_pv_txt = sprintf('%s_CentralPV_1mnth30.dss',root);
    elseif shift+1 == 31
        s_pv_txt = sprintf('%s_CentralPV_1mnth31.dss',root);
    end
elseif timeseries_span == 5
    s_pv_txt = sprintf('%s_CentralPV_365dy.dss',root);
end
solarfilename = strcat(s,s_pv_txt);
%solarfilename = 'C:\Users\jlavall\Documents\OpenDSS\GridPV\ExampleCircuit\Ckt24_PV_Central_7_5.dss';
%%
DSSText.command = sprintf('Compile (%s)',solarfilename); %add solar scenario
DSSText.command = 'solve';
cd(location);
%---------------------------------
%Run OpenDSS simulation for 6/24/168-hr at 1-minute resolution:
%number==#solution to run; h==stepsize (s)
DSSText.command = sprintf('Set mode=duty number=%s  hour=0  h=%s sec=0',num2str(FEEDER.SIM.npts),num2str(FEEDER.SIM.stepsize)); 
DSSText.Command = 'Set Controlmode=TIME';
DSSText.command = 'solve';
toc

%%
%---------------------------------
%Plot / observe simulation results:
if timeseries_span == 1
    %(1) peakPV RUN
    shift=10;
    h_st = 10;
    h_fin= 15;
    DOY_fin = 0;
elseif timeseries_span == 2
    %(1) DAY
    shift=0;
    h_st = 0;
    h_fin= 23;
    DOY_fin = 0;
elseif timeseries_span == 3
    %(1) WEEK
    shift=0;
    h_st = 0;
    h_fin= 23;
    DOY_fin = 6;
elseif timeseries_span == 4
    %(1) MONTH
    shift=0;
    h_st = 0;
    h_fin= 23;
    MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
    MTH_DY(2,1:12) = [1,32,60,91,121,152,182,213,244,274,305,335];
    DOY_fin = MTH_DY(2,monthly_span);
elseif timeseries_span == 5
    %(1) YEAR
    shift=0;
    h_st = 0;
    h_fin = 23;
    DOY = 1;
    DOY_fin = 365;
end

%   Feeder Power
DSSfilename=ckt_direct_prime;
fileNameNoPath = DSSfilename(find(DSSfilename=='\',1,'last')+1:end-4);
plotMonitor(DSSCircObj,sprintf('fdr_%s_Mon_PQ',root1));
ylabel('Power (kW,kVar)','FontSize',12,'FontWeight','bold')
title([strrep(fileNameNoPath,'_',' '),' Net Feeder 05410 Load'],'FontSize',12,'FontWeight','bold')
%saveas(gcf,[DSSfilename(1:end-4),'_Net_Power.fig'])
DSSText.Command = sprintf('export mon fdr_%s_Mon_PQ',root1);
monitorFile = DSSText.Result;
MyLOAD = importdata(monitorFile);
delete(monitorFile);
%--------------------------------
%Substation Voltage
%DSSText.Command = 'export mon subVI';
DSSText.Command = sprintf('export mon fdr_%s_Mon_VI',root1);
monitorFile = DSSText.Result;
MyCSV = importdata(monitorFile);
delete(monitorFile);
Hour = MyCSV.data(:,1); Second = MyCSV.data(:,2);
subVoltages = MyCSV.data(:,3:2:7);
subCurrents = MyCSV.data(:,11:2:15);

figure(2);
plot(Hour+shift+Second/3600,subVoltages(:,1)/((12.47e3)/sqrt(3)),'r-','LineWidth',2);
hold on
plot(Hour+shift+Second/3600,subVoltages(:,2)/((12.47e3)/sqrt(3)),'g-','LineWidth',2);
hold on
plot(Hour+shift+Second/3600,subVoltages(:,3)/((12.47e3)/sqrt(3)),'b-','LineWidth',2);
n=length(subVoltages(:,1));
hold on
if feeder_NUM == 0
    V_120=120.000002416772;
elseif feeder_NUM == 1
    V_120=122.98315227577;
elseif feeder_NUM == 2
    V_120=123.945461370235;
end
V_PU=(V_120*59.9963154732886)/((12.47e3)/sqrt(3));
V_UP=V_PU+(0.5*59.9963154732886)/((12.47e3)/sqrt(3));
V_DOWN=V_PU-(0.5*59.9963154732886)/((12.47e3)/sqrt(3));
plot(Hour+shift+Second/3600,V_UP,'k-','LineWidth',4);
hold on
plot(Hour+shift+Second/3600,V_DOWN,'k-','LineWidth',4);
%{
hold on
plot(Hour+shift+Second/3600,FEEDER.Voltage.A(time2int(DOY,h_st,0):time2int(DOY+DOY_fin,h_fin,59),1)/((12.47e3)/sqrt(3)),'r--','LineWidth',2);
hold on
plot(Hour+shift+Second/3600,FEEDER.Voltage.B(time2int(DOY,h_st,0):time2int(DOY+DOY_fin,h_fin,59),1)/((12.47e3)/sqrt(3)),'g--','LineWidth',2);
hold on
plot(Hour+shift+Second/3600,FEEDER.Voltage.C(time2int(DOY,h_st,0):time2int(DOY+DOY_fin,h_fin,59),1)/((12.47e3)/sqrt(3)),'b--','LineWidth',2);
grid on;
%}
set(gca,'FontSize',10,'FontWeight','bold')
xlabel('Hour','FontSize',12,'FontWeight','bold')
ylabel('Voltage','FontSize',12,'FontWeight','bold')
axis([0 Hour(end,1)+shift+Second(end,1)/3600 V_DOWN-0.01 1.05]);
%legend('V_{phA}-sim','V_{phB}-sim','V_{phC}-sim','V_{phA}-nonREG','V_{phB}-nonREG','V_{phC}-nonREG');
legend('V_{phA}','V_{phB}','V_{phC}','Upper B.W.','Lower B.W.');
title([strrep(fileNameNoPath,'_',' '),' Substation Voltages'],'FontSize',12,'FontWeight','bold')
saveas(gcf,[DSSfilename(1:end-4),'_Sub_Voltage.fig'])
%
%------------------
figure(3);
plot(Hour+shift+Second/3600,subCurrents);
set(gca,'FontSize',10,'FontWeight','bold')
xlabel('Hour','FontSize',12,'FontWeight','bold')
ylabel('Current (A)','FontSize',12,'FontWeight','bold')


%{
figure(3);
DSSfilename=ckt_direct_prime;
fileNameNoPath = DSSfilename(find(DSSfilename=='\',1,'last')+1:end-4);
if feeder_NUM == 0
    plotMonitor(DSSCircObj,'
if feeder_NUM == 1
    plotMonitor(DSSCircObj,'259355403_Mon_PQ');
elseif feeder_NUM == 2
    plotMonitor(DSSCircObj,'259181477_Mon_PQ');
end
ylabel('Power (kW,kVar)','FontSize',12,'FontWeight','bold')
title([strrep(fileNameNoPath,'_',' '),' Closest Line Load'],'FontSize',12,'FontWeight','bold')
%saveas(gcf,[DSSfilename(1:end-4),'_Net_Power.fig'])
%}

    