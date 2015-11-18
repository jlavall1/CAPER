%Timeseries Analyses:
clear
clc
close all
s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
%addpath(strcat(s_b,'\01_Sept_Code'));
tic
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%Find directory of Circuit:
% 1. Obtain user's choice of simulation:
Import_PV_Farm_Datasets
DER_Planning_GUI_1
Delete_PV_Farm_Datasets
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
DARR_category   = gui_response{1,11};%(1)Stabe through (5)Unstable.
VI_USER_span    = gui_response{1,12};
CI_USER_slt     = gui_response{1,13};
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
STRING_0{1,11} = DARR_cat;
STRING_0{1,12} = VI;
%}
%%
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
DSSText.command = ['Compile ',ckt_direct_prime]; %_prime gen in: 
%{
Lines_Base = getLineInfo(DSSCircObj);
Buses_Base = getBusInfo(DSSCircObj);
Loads_Base = getLoadInfo(DSSCircObj);
%}
%Xfmr_Base = get
cd(location);
%%
%Sort Lines into closest from PCC --
%[~,index] = sortrows([Lines_Base.bus1Distance].'); 
%Lines_Distance = Lines_Base(index); 
%clear index
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
elseif feeder_NUM == 8
    %EPRI Circuit 24
    root = 'ckt24';
    root1 = 'ckt24';
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
%DSSText.command = sprintf('Compile (%s)',solarfilename); %add solar scenario
%DSSText.command = 'solve';
%cd(location);
%---------------------------------

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
    %(1) DAY, 24hr
    shift=0;
    h_st = 0;
    h_fin= 23;
    DOY_fin = 0;
    %start openDSS ---------------------------
    
    % Run 1-day simulation at 1minute interval:
    DSSText.command='set mode=daily stepsize=1m number=1440'; %stepsize is now 1minute (60s)
    % Turn the overload report on:
    DSSText.command='Set overloadreport=true';
    DSSText.command='Set voltexcept=true';
    % Solve QSTS Solution:
    DSSText.command='solve';
    DSSText.command='show eventlog';
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
%%
Export_Monitors_timeseries
%%
%{
%   Feeder Power
DSSfilename=ckt_direct_prime;
fileNameNoPath = DSSfilename(find(DSSfilename=='\',1,'last')+1:end-4);
%plotMonitor(DSSCircObj,sprintf('fdr_%s_Mon_PQ',root1));
DSSText.Command = sprintf('export mon fdr_%s_Mon_PQ',root1);
monitorFile = DSSText.Result;
MyCSV = importdata(monitorFile);
delete(monitorFile);
Hour = MyCSV.data(:,1); Second = MyCSV.data(:,2);
subPowers = MyCSV.data(:,3:2:7);
subReact = MyCSV.data(:,4:2:8);
plot(Hour+shift+Second/3600,subPowers,'LineWidth',1.5);
hold on
plot(Hour+shift+Second/3600,subReact,'LineWidth',1.5);
hold on
ylabel('Power (kW,kVar)','FontSize',12,'FontWeight','bold');
xlabel('Hour of Simulation (H)','FontSize',12,'FontWeight','bold');
%title([strrep(fileNameNoPath,'_',' '),' Net Feeder 05410 Load'],'FontSize',12,'FontWeight','bold')
title('Feeder-03''s Substation Phase P & Q','FontSize',12,'FontWeight','bold')
legend('P_{A}','P_{B}','P_{C}','Q_{A}','Q_{B}','Q_{C}','Location','NorthWest');
set(gca,'FontSize',10,'FontWeight','bold')
axis([0 168 -1500 2000]);

%%
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
plot(Hour+shift+Second/3600,subVoltages(:,1)/((12.47e3)/sqrt(3)),'b-','LineWidth',2);
hold on
plot(Hour+shift+Second/3600,subVoltages(:,2)/((12.47e3)/sqrt(3)),'g-','LineWidth',2);
hold on
plot(Hour+shift+Second/3600,subVoltages(:,3)/((12.47e3)/sqrt(3)),'r-','LineWidth',2);
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
xlabel('Hour of Simulation (H)','FontSize',12,'FontWeight','bold')
ylabel('Voltage (V) [P.U.]','FontSize',12,'FontWeight','bold')
axis([0 Hour(end,1)+shift+Second(end,1)/3600 V_DOWN-0.01 1.055]);
%legend('V_{phA}-sim','V_{phB}-sim','V_{phC}-sim','V_{phA}-nonREG','V_{phB}-nonREG','V_{phC}-nonREG');
legend('V_{phA}','V_{phB}','V_{phC}','Upper B.W.','Lower B.W.');
title('Feeder-03''s Substation Phase Voltages','FontSize',12,'FontWeight','bold')
saveas(gcf,[DSSfilename(1:end-4),'_Sub_Voltage.fig'])
%
%------------------
figure(3);
plot(Hour+shift+Second/3600,subCurrents);
set(gca,'FontSize',10,'FontWeight','bold')
xlabel('Hour','FontSize',12,'FontWeight','bold')
ylabel('Current (A)','FontSize',12,'FontWeight','bold')
legend('I_{A}','I_{B}','I_{C}');


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
%}
%%
figure(4);
for i=1:1:159
    if DATA_SAVE(i).Vbase == 7.199557856794634e+03
        
        plot(DATA_SAVE(i).phaseV(:,1));
        hold on
    end
end
figure(5);
for i=1:1:159
    if DATA_SAVE(i).Vbase == 7.199557856794634e+03
        
        plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseV(720,1)/7.199557856794634e+03,'ro','linewidth',4);
        hold on
        plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseV(720,2)/7.199557856794634e+03,'bo','linewidth',4);
        hold on
        plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseV(720,3)/7.199557856794634e+03,'go','linewidth',4);
        hold on
    end
end
xlabel('Distance from SUB (d) [km]');
ylabel('Phase A Voltage Profile (V) [P.U.]');
title('AT noon sample');
grid on
%
figure(6);
for i=1:1:159
    if DATA_SAVE(i).Vbase == 7.199557856794634e+03
        plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseP(720,1),'ro','linewidth',3);
        hold on
        plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseP(720,2),'bo','linewidth',3);
        hold on
        plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseP(720,3),'go','linewidth',3);
        hold on
    end
end
xlabel('Distance from SUB (d) [km]');
ylabel('Phase A Real Power Profile (P) [kW]');
title('AT noon sample');
grid on
axis([0 8 -50 550]);

    