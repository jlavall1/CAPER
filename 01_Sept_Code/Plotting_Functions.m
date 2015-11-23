%Plotting Function that will have the following Options:

%1]     Check Commanded VS. Actual Simulation Power Consumption
%2]     Check Commanded VS. Actual Simulation Current Drawn
%3]     Check if Feeder voltage is sound
%4]     
%----------------------------------------------------------
close all

UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);

action=menu('Which Plot would you like to initiate?','Validation Plots','Parameter VS. Distance','Parameter VS. Time','QSTS Simulation','Open','ALL');
while action<1
    action=menu('Which Plot would you like to initiate?','Validation Plots','Parameter VS. Distance','Parameter VS. Time','QSTS Simulation','Open','ALL');
end
%%
%action = 6;
fig = 0;
%----------------------------------------------------------
if action == 1 || action == 6
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
    %SUBPLOT3: Check of Currents
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
    %
    %SUBPLOT4: Plot Current %diff
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
    
    %
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
    
end
%%
if action == 2 || action == 6
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
if action == 3 || action == 6
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
if action == 4 || action == 6
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
    
    
end