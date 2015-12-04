%Plotting Function that will have the following Options:

%1]     Check Commanded VS. Actual Simulation Power Consumption
%2]     Check Commanded VS. Actual Simulation Current Drawn
%3]     Check if Feeder voltage is sound
%4]     
%----------------------------------------------------------
close all

UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);

action=menu('Which Plot would you like to initiate?','Validation Plots','Parameter VS. Distance','Parameter VS. Time','QSTS Simulation','Compiled','Capacitor Ops','ALL');
while action<1
    action=menu('Which Plot would you like to initiate?','Validation Plots','Parameter VS. Distance','Parameter VS. Time','QSTS Simulation','Compiled','Capacitor Ops','ALL');
end
%%
%action = 6;
ALL = 7;
fig = 0;
%----------------------------------------------------------
if action == 1 || action == ALL
    %SUBPLOT1
    fig = fig + 1;
    figure(fig);
    
    %-DSS
    plot(DATA_SAVE(1).phaseP(:,1),'r-','linewidth',2)
    hold on
    plot(DATA_SAVE(1).phaseP(:,2),'r--','linewidth',2)
    hold on
    plot(DATA_SAVE(1).phaseP(:,3),'r-.','linewidth',2)
    hold on
    %-DSCADA
    plot(LOAD_ACTUAL(:,1),'b-','linewidth',2)
    hold on
    plot(LOAD_ACTUAL(:,2),'b--','linewidth',2)
    hold on
    plot(LOAD_ACTUAL(:,3),'b-.','linewidth',2)
    hold on
    %  Calculate difference:
    for i=1:1:length(DATA_SAVE(1).phaseP)
        DIFF_KW(i,1)=(DATA_SAVE(1).phaseP(i,1)-LOAD_ACTUAL(i,1))/LOAD_ACTUAL(i,1);
        DIFF_KW(i,2)=(DATA_SAVE(1).phaseP(i,2)-LOAD_ACTUAL(i,2))/LOAD_ACTUAL(i,2);
        DIFF_KW(i,3)=(DATA_SAVE(1).phaseP(i,3)-LOAD_ACTUAL(i,3))/LOAD_ACTUAL(i,3);
    end
    %  Settings:
    title('Command vs. actual CHECK','FontSize',14);
    legend('(DSS) Phase A','(DSS) Phase B','(DSS) Phase C','(DSCADA) Phase A','(DSCADA) Phase B','(DSCADA) Phase C');
    xlabel('Time (t) [min]','FontSize',12,'FontWeight','bold');
    ylabel('Real Power per Phase','FontSize',12,'FontWeight','bold');
    grid on
    set(gca,'FontWeight','bold');
    %
    %SUBPLOT2
    fig = fig + 1;
    figure(fig);
    plot(DIFF_KW(:,1)*100,'r-','Linewidth',3);
    hold on
    plot(DIFF_KW(:,2)*100,'g-','Linewidth',3);
    hold on
    plot(DIFF_KW(:,3)*100,'b-','Linewidth',3);
    %  Settings:
    title('Comparison between openDSS & Commanded','FontWeight','bold','FontSize',14);
    legend('Phase A %ERROR','Phase B %ERROR','Phase C %ERROR');
    axis([0 length(DATA_SAVE(1).phaseP) 0 3]);
    ylabel('Percent Error (PE) [%]','FontSize',12,'FontWeight','bold');
    xlabel('Time Interval','FontSize',12,'FontWeight','bold');
    grid on
    set(gca,'FontWeight','bold');
    %
    
    %
    %SUBPLOT4: Check of Currents
    %{
    fig = fig + 1;
    figure(fig);
    for i=1:1:3
        if i==1
            plot(LS_PhaseA*peak_current(1,i),'r-')
            hold on
            plot(DATA_SAVE(2).phaseI(:,i),'r--')
            hold on
        elseif i==2
            plot(LS_PhaseB*peak_current(1,i),'b-')
            hold on
            plot(DATA_SAVE(2).phaseI(:,i),'b--')
            hold on
        elseif i==3
            plot(LS_PhaseC*peak_current(1,i),'g-')
            hold on
            plot(DATA_SAVE(2).phaseI(:,i),'g--')
            hold on
        end
    end
    %  Settings:
    xlabel('Time Interval (t) [1m]','FontSize',12,'FontWeight','bold');
    ylabel('Phase Current (I) [A]','FontSize',12,'FontWeight','bold');
    title('Comparison between Loadshape & Measurements','FontSize',12,'FontWeight','bold');
    legend('LS-phA','DSS-phA','LS-phB','DSS-phB','LS-phC','DSS-phC','Location','NorthWest');
    grid on
    set(gca,'FontWeight','bold');
    %}
    %
    %SUBPLOT4: Plot Current %diff
    %{
    fig = fig + 1;
    figure(fig);
    %  Calculate difference:
    for i=1:1:length(DATA_SAVE(1).phaseP)
        DIFF_AMP(i,1)=(DATA_SAVE(2).phaseI(i,1)-(LS_PhaseA(i,1)*peak_current(1,1)))/(LS_PhaseA(i,1)*peak_current(1,1));
        DIFF_AMP(i,2)=(DATA_SAVE(2).phaseI(i,2)-(LS_PhaseB(i,1)*peak_current(1,2)))/(LS_PhaseB(i,1)*peak_current(1,2));
        DIFF_AMP(i,3)=(DATA_SAVE(2).phaseI(i,3)-(LS_PhaseC(i,1)*peak_current(1,3)))/(LS_PhaseC(i,1)*peak_current(1,3));
    end
    plot(DIFF_AMP(:,1)*100,'r-','Linewidth',3);
    hold on
    plot(DIFF_AMP(:,2)*100,'g-','Linewidth',3);
    hold on
    plot(DIFF_AMP(:,3)*100,'b-','Linewidth',3);
    %  Settings:
    title('Comparison between openDSS & Commanded','FontWeight','bold','FontSize',14);
    legend('Phase A %ERROR','Phase B %ERROR','Phase C %ERROR');
    axis([0 length(DATA_SAVE(2).phaseI) -5 10]);
    ylabel('Percent Error (PE) [%]','FontSize',12,'FontWeight','bold');
    xlabel('Time Interval','FontSize',12,'FontWeight','bold');
    grid on
    set(gca,'FontWeight','bold');
    
    
    %SUBPLOT5: Vbase & Vstatic
    fig = fig + 1;
    figure(fig);
    plot([DATA_SAVE(2:211).Vbase],'b-')
    hold on
    plot([DATA_SAVE(2:211).Vstatic],'r-')
    hold off
    % Settings:
    title('CHECK to see if Voltages are correct across feeder','FontWeight','bold','FontSize',14);
    legend('Simulation Base','Static Check');
    xlabel('Monitors sorted by Distance','FontSize',12,'FontWeight','bold');
    ylabel('Phase Voltage (V) [V_{LN}]','FontSize',12,'FontWeight','bold');
    grid on
    set(gca,'FontWeight','bold');
    %}
    if feeder_NUM == 2
        %SUBPLOT of Capacitor bus.
        for i=1:1:length(DATA_SAVE(:))
            if strcmp('259126903',DATA_SAVE(i).Name) == 1
                cap_pos=i;
            end
        end
    end
    fig = fig + 1;
    figure(fig);
    plot(DATA_SAVE(cap_pos).phaseQ(:,1),'r-');
    hold on
    plot(DATA_SAVE(cap_pos).phaseQ(:,2),'g-');
    hold on
    plot(DATA_SAVE(cap_pos).phaseQ(:,3),'b-');
    title('Capacitor Reactive Power');
        
    
end
%%
if action == 2 || action == ALL
    %SUBPLOT1
    fig = fig + 1;
    figure(fig);
    for i=2:1:length(DATA_SAVE)
        if DATA_SAVE(i).Vbase == 7.199557856794634e+03

            plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseV(720,1)/7.199557856794634e+03,'ro','linewidth',4);
            hold on
            plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseV(720,2)/7.199557856794634e+03,'bo','linewidth',4);
            hold on
            plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseV(720,3)/7.199557856794634e+03,'go','linewidth',4);
            hold on
        end
    end
    %  Settings:
    xlabel('Distance from SUB (d) [km]','FontWeight','bold');
    ylabel('Phase A Voltage Profile (V) [P.U.]','FontWeight','bold');
    title('AT noon sample','FontWeight','bold');
    legend('Phase A Voltage','Phase B Voltage','Phase C Voltage');
    axis([0 14 1 1.05]);
    grid on
    set(gca,'FontWeight','bold');
    
    %SUBPLOT2
    fig = fig + 1;
    figure(fig);
    for i=2:1:length(DATA_SAVE)
        if DATA_SAVE(i).Vbase > 7000
            plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseP(720,1),'ro','linewidth',3);
            hold on
            plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseP(720,2),'bo','linewidth',3);
            hold on
            plot(DATA_SAVE(i).distance,DATA_SAVE(i).phaseP(720,3),'go','linewidth',3);
            hold on
        end
    end
    %  Settings:
    xlabel('Distance from SUB (d) [km]','FontWeight','bold');
    ylabel('Phase Real Power Profile (P) [kW]','FontWeight','bold');
    title('AT noon sample','FontWeight','bold');
    axis([0 14 -50 1000]);
    grid on
    set(gca,'FontWeight','bold');
end
%%
if action == 3 || action == ALL
    %SUBPLOT1 -- Powers
    fig = fig +  1;
    figure(fig);
    plot(DATA_SAVE(1).phaseP(:,1),'r-','linewidth',3);
    hold on
    plot(DATA_SAVE(1).phaseP(:,2),'b-','linewidth',3);
    hold on
    plot(DATA_SAVE(1).phaseP(:,3),'g-','linewidth',3);
    %  Settings:
    xlabel('Time Interval (t) [1min]');
    ylabel('Phase Real Power Profile (P) [kW]');
    title('Feeder load profile');
    legend('Phase A','Phase B','Phase C','Location','SouthEast');
    grid on
    set(gca,'FontWeight','bold');
    %axis([0 15 -50 1000]);
    %
    %SUBPLOT2 -- Voltage at Substation
    fig = fig + 1;
    figure(fig);
    plot(DATA_SAVE(2).phaseV(:,1)/7.199557856794634e+03,'r-','linewidth',3);
    hold on
    plot(DATA_SAVE(2).phaseV(:,2)/7.199557856794634e+03,'b-','linewidth',3);
    hold on
    plot(DATA_SAVE(2).phaseV(:,3)/7.199557856794634e+03,'g-','linewidth',3);
    %  Settings:
    xlabel('Time Interval (t) [1min]');
    ylabel('Phase Voltage Profile (V) [P.U.]');
    title('Feeder Substation LTC Regulated side');
    legend('Phase A','Phase B','Phase C','Location','SouthEast');
    grid on
    set(gca,'FontWeight','bold');
    
    %SUBPLOT3 -- LTC Operation / Tap position.
    fig = fig + 1;
    figure(fig);
    plot(MyLTC.data(:,end),'linewidth',3)
    xlabel('Time Interval (t) [1m]');
    ylabel('LTC Tap Position');
    axis([0 1440 0.96 1.06]);
    grid on
    set(gca,'FontWeight','bold');
end
if action == 4 || action == ALL
    %----------------------------------------------
    %SUBPLOT1 -- Simulation time
    fig = fig + 1;
    figure(fig);
    Dx = [6,24,7*24,30*24];
    Dgroup = [3600,60,30,5];
    Dy = [9.76,11.08,12.13,16.74; ...
        10.52,12.18,14.29,37.28; ...
        16.34, 34.22,45.66,182.75];
    D_monit = [7.53,11.79,15.09,39.52; ...
        7.81,19.49,30.66,119.53; ...
        10.43,71.27,135.58,667.82];
    for i=1:1:3
        plot(Dx,Dy(i,1),'ro','LineWidth',3);
        hold on
        plot(Dx,Dy(i,2),'go','LineWidth',3);
        hold on
        plot(Dx,Dy(i,3),'bo','LineWidth',3);
        hold on
        plot(Dx,Dy(i,4),'co','LineWidth',3);
        hold on
        plot(Dx,Dy(i,1:4),'k-.');
        hold on
        plot(Dx,D_monit(i,1),'ro','LineWidth',3);
        hold on
        plot(Dx,D_monit(i,2),'go','LineWidth',3);
        hold on
        plot(Dx,D_monit(i,3),'bo','LineWidth',3);
        hold on
        plot(Dx,D_monit(i,4),'co','LineWidth',3);
        hold on
        plot(Dx,D_monit(i,1:4),'k--');
    end
    %----------------------------------------------
    %SUBPLOT2 -- Voltage Deviation
    fig = fig + 1;
    figure(fig);
    TVD=TVD_Calc(DATA_SAVE);
    plot(TVD(:,1),'r-');
    hold on
    plot(TVD(:,2),'g-');
    hold on
    plot(TVD(:,3),'b-');
    %  Settings:
    xlabel('Time Interval (t) [1min]');
    ylabel('Voltage Deviation Index (TVD) [P.U.^{2}]');
    title('Feeder voltage deviation index throughout day');
    legend('Phase A','Phase B','Phase C','Location','NorthEast');
    grid on
    set(gca,'FontWeight','bold');
    %----------------------------------------------
    %SUBPLOT3 -- LTC Cummalitve OperationsC
    fig = fig + 1;
    figure(fig);
    OPS=CUM_TapCount(DATA_SAVE);
    plot(OPS(:,1),'b-','LineWidth',3);
    title('Cummaltive Load Tap Changer Operations');
    xlabel('Time Interval (t) [1min]');
    ylabel('Voltage Deviation Index (TVD) [P.U.^{2}]');
    grid on
    set(gca,'FontWeight','bold');
end
if action == 5 || action == ALL
    %----------------------------------------------
    %SUBPLOT1 -- Comparison between things:
    sim_names=['10','20','30','40','60','70','80','90'];
    addpath(strcat(base_path,'\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Results'));
    n = 1;
    load 10_Imped.mat
    LTC_CUMM_OPS(:,n)=DATA_PV(1).settings.LTCops(:,1);
    n = n +1;
    load 20_Imped.mat
    LTC_CUMM_OPS(:,n)=DATA_PV(1).settings.LTCops(:,1);
    n = n +1;
    load 30_Imped.mat
    LTC_CUMM_OPS(:,n)=DATA_PV(1).settings.LTCops(:,1);
    n = n +1;
    load 40_Imped.mat
    LTC_CUMM_OPS(:,n)=DATA_PV(1).settings.LTCops(:,1);
    n = n + 1;
    load 60_Imped.mat
    LTC_CUMM_OPS(:,n)=DATA_PV(1).settings.LTCops(:,1);
    n = n + 1;
    load 70_Imped.mat
    LTC_CUMM_OPS(:,n)=DATA_PV(1).settings.LTCops(:,1);
    n = n + 1;
    load 80_Imped.mat
    LTC_CUMM_OPS(:,n)=DATA_PV(1).settings.LTCops(:,1);
    n = n + 1;
    load 90_Imped.mat
    LTC_CUMM_OPS(:,n)=DATA_PV(1).settings.LTCops(:,1);
    
    for i=1:1:8
        plot(LTC_CUMM_OPS(:,i),'LineWidth',2);
        hold on
    end
    legend('10% of maxImp_Bus','20% of maxImp_Bus','30% of maxImp_Bus','40%','60%','70%','80%','90%');
    
        
    
        
end
%%
if action == 6 || action == ALL
    %SUBPLOT1:  Compare SCADA / DSS
    fig = fig + 1;
    figure(fig);
    %-DSS
    plot(DATA_SAVE(1).phaseQ(:,1),'r-','linewidth',2)
    hold on
    plot(DATA_SAVE(1).phaseQ(:,2),'r--','linewidth',2)
    hold on
    plot(DATA_SAVE(1).phaseQ(:,3),'r-.','linewidth',2)
    hold on
    %-DSCADA
    plot(KVAR_ACTUAL.data(:,1),'b-','linewidth',2)
    hold on
    plot(KVAR_ACTUAL.data(:,2),'b--','linewidth',2)
    hold on
    plot(KVAR_ACTUAL.data(:,3),'b-.','linewidth',2)
    hold on
    %-CAP_DSS
    plot([MEAS.CAP_Q_PhA],'k-','LineWidth',3)
    hold on
    plot([MEAS.CAP_Q_PhB],'k-','LineWidth',3)
    hold on
    plot([MEAS.CAP_Q_PhC],'k-','LineWidth',3)
    hold on
    
    
    title('Command vs. actual CHECK of Q','FontSize',14);
    legend('(DSS) Phase A','(DSS) Phase B','(DSS) Phase C','(DSCADA) Phase A','(DSCADA) Phase B','(DSCADA) Phase C','(DSS) Cap_{phA}','(DSS) Cap_{phB}','(DSS) Cap_{phC}');
    xlabel('Time (t) [min]','FontSize',12,'FontWeight','bold');
    ylabel('Reactive Power/Phase (Q) [kVAR]','FontSize',12,'FontWeight','bold');
    grid on
    set(gca,'FontWeight','bold');
    %
    %SUBPLOT:  Calculated PF from SCADA
    fig = fig +1;
    figure(fig);
    for i=1:1:length(KVAR_ACTUAL.data(:,1))
        for ph=1:1:3
            % PF_ACTUAL(i,ph) = LOAD_ACTUAL(i,ph)/(sqrt((LOAD_ACTUAL(i,ph)^2)+(KVAR_ACTUAL(i,ph)^2)));
            PF_ACTUAL(i,ph) = KVAR_ACTUAL.data(i,6);
            PF_openDSS(i,ph) = DATA_SAVE(1).phaseP(i,ph)/(sqrt((DATA_SAVE(1).phaseP(i,ph)^2)+(DATA_SAVE(1).phaseQ(i,ph)^2)));
            DIFF_KVAR(i,ph)=(DATA_SAVE(1).phaseQ(i,ph)-KVAR_ACTUAL.data(i,ph));%/KVAR_ACTUAL.data(i,ph);
        end
    end
    plot(PF_ACTUAL(:,1),'r-','Linewidth',3);
    hold on
    plot(PF_ACTUAL(:,2),'g-','Linewidth',3);
    hold on
    plot(PF_ACTUAL(:,3),'b-','Linewidth',3);
    hold on
    %DSS---
    plot(PF_openDSS(:,1),'r--','Linewidth',2);
    hold on
    plot(PF_openDSS(:,2),'g--','Linewidth',2);
    hold on
    plot(PF_openDSS(:,3),'b--','Linewidth',2);
    hold off
    title('Measured PF at SUB');
    grid on
    %
    %SUBPLOT:  Percent Error!
    fig = fig + 1;
    figure(fig);
    plot(DIFF_KVAR(:,1),'r-','Linewidth',3);
    hold on
    plot(DIFF_KVAR(:,2),'g-','Linewidth',3);
    hold on
    plot(DIFF_KVAR(:,3),'b-','Linewidth',3);
    %  Settings:
    title('Comparison between openDSS & SCADA Reactive Powers','FontWeight','bold','FontSize',14);
    legend('Phase A %ERROR','Phase B %ERROR','Phase C %ERROR');
    %axis([0 length(DATA_SAVE(1).phaseQ) 0 3]);
    ylabel('Percent Error (PE) [%]','FontSize',12,'FontWeight','bold');
    xlabel('Time Interval','FontSize',12,'FontWeight','bold');
    grid on
    set(gca,'FontWeight','bold');
end



%%
%These are just leftovers:
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