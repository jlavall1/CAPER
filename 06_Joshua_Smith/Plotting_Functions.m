%Plotting Function that will have the following Options:

%1]     Check Commanded VS. Actual Simulation Power Consumption
%2]     Check Commanded VS. Actual Simulation Current Drawn
%3]     Check if Feeder voltage is sound
%4]     
%----------------------------------------------------------
close all

UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);

action=menu('Which Plot would you like to initiate?','Validation Plots','Parameter VS. Distance','Parameter VS. Time','QSTS Simulation','Compiled','Capacitor Ops','CAPER Report','Circuit Topology','ALL');
while action<1
    action=menu('Which Plot would you like to initiate?','Validation Plots','Parameter VS. Distance','Parameter VS. Time','QSTS Simulation','Compiled','Capacitor Ops','CAPER Report','Circuit Topology','ALL');
end
%%
%action = 6;
ALL = 9;
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
if action == 7 || action == ALL
    addpath('C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Results');
    %load DOY_1_364_BASE.mat
    load DOY_1_364_PV2.mat
    CAP_OPS_1=CAP_OPS;
    load DOY_1_364_PV3.mat
    CAP_OPS_2=CAP_OPS;
    %load DOY_1_364_POST.mat
    load DOY_1_364_BASE_N
%SUBPLOT1:  Compare SCADA / DSS
    fig = fig + 1;
    figure(fig);
    %-DSS
    for DOY=1:1:364
        plot([DOY,DOY,DOY],CAP_OPS(DOY).PE_avg(1,1:3),'bo','LineWidth',2);
        hold on
        plot([DOY,DOY,DOY],CAP_OPS(DOY).PE_avg(1,4:6),'ro','LineWidth',2);
        hold on
    end
    %  Settings:
    xlabel('Day of Year (DAY) [24hr sim]','FontWeight','bold','FontSize',12);
    ylabel('Error Magnitude in Powers (P, Q) [kW, kVAR]','FontWeight','bold','FontSize',12);
    title('Difference between DSCADA measurements & DSS Results','FontWeight','bold','FontSize',12);
    legend('1-ph Real Powers (P)','1-ph Reactive Power (Q)','Location','NorthEast');
    grid on
    set(gca,'FontWeight','bold');
    
%SUBPLOT2:  Capacitor Ops from original data:
    fig = fig + 1;
    figure(fig);
    s = 1;
    for i=1:1:364
        Y = CAP_OPS(i).data(1:1440,4);
        X = [s:1:1440+s-1]';
        X = X/1440;
        %plot(s+j,CAP_OPS(i).data(j,4));
        plot(X,Y,'k-','LineWidth',3)
        hold on
        s = s + 1440;
    end
    %  Settings:
    axis([0 365 -0.5 1.5])
    title('State of 450kVAR Swtch Cap. on Feeder 3','FontWeight','bold','FontSize',14);
    xlabel('Day of Year (DOY)','FontWeight','bold','FontSize',14);
    ylabel('1=Closed & 0=Opened','FontWeight','bold','FontSize',14);
    grid on
    set(gca,'FontWeight','bold');
%SUBPLOT3:  Compare PV Scenerio w/ CAPS
    fig = fig + 1;
    figure(fig);
    MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
    MNTH= 1;
    DAY = 1;
    DOY = 1;
    LTC_AG=zeros(12,4);
    LTC_AG_1=zeros(12,4);
    LTC_AG_2=zeros(12,4);
    CAP_AG=zeros(12,4);
    CAP_AG_1=zeros(12,4);
    CAP_AG_2=zeros(12,4);
    while MNTH < 13
        while DAY < MTH_LN(1,MNTH)+1
            if DOY < 365
                %Base case:
                LTC_AG(MNTH) = LTC_AG(MNTH) + CAP_OPS(DOY).LTC_OP_NUM;
                CAP_AG(MNTH) = CAP_AG(MNTH) + CAP_OPS(DOY).oper; %Should be: CAP_OP_NUM
                %Case 1:
                LTC_AG_1(MNTH) = LTC_AG_1(MNTH) + CAP_OPS_1(DOY).LTC_OP_NUM;
                CAP_AG_1(MNTH) = CAP_AG_1(MNTH) + CAP_OPS_1(DOY).CAP_OP_NUM;
                %Case 2:
                LTC_AG_2(MNTH) = LTC_AG_2(MNTH) + CAP_OPS_2(DOY).LTC_OP_NUM;
                CAP_AG_2(MNTH) = CAP_AG_2(MNTH) + CAP_OPS_2(DOY).CAP_OP_NUM;
                
                DOY = DOY + 1;
                DAY = DAY + 1;
            elseif DOY == 365
                DAY = 40;
            end
        end
        DAY = 1;
        MNTH = MNTH + 1;
    end
    combined = [LTC_AG(:,1),LTC_AG_1(:,1),LTC_AG_2(:,1)];
    xdata=[1,2,3,4,5,6,7,8,9,10,11,12];
    hb = bar(xdata,combined,'grouped');
    %  Settings:
    %axis([0 13 0 50])
    %set(gca,'Ylabel','Number of Operations');
    title('LTC Operations: Base Case & With PV','FontWeight','bold','FontSize',14);
    ylabel('Number of Operations','FontWeight','bold','FontSize',14);
    set(gca,'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'});
    set(gca,'FontWeight','bold');
    legend('Base Case','PV @ 0.25*Rsc_{max}','PV @ 0.50*Rsc_{max}');
%SUBPLOT4:  Compare PV Scenerio w/ LTC
    fig = fig + 1;
    figure(fig);
    combined = [CAP_AG(:,1),CAP_AG_1(:,1)];
    xdata=[1,2,3,4,5,6,7,8,9,10,11,12];
    hb1 = bar(xdata,combined,'grouped');
    %  Settings:
    title('Capacitor Operations: Base Case & With PV','FontWeight','bold','FontSize',14);
    ylabel('Number of Operations','FontWeight','bold','FontSize',14);
    set(gca,'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'});
    set(gca,'FontWeight','bold');
    legend('Base Case');
%SUBPLOT5:  Find worst day & display
    fig = fig + 1;
    %{
    max_op_inc=zeros(1,2);
    for i=1:1:364
        diff = CAP_OPS(i).LTC_OP_NUM-CAP_OPS_1(i).LTC_OP_NUM;
        if diff > max_op_inc(1,1)
            max_op_inc(1,1)=diff;
            max_op_inc(1,2)=i;
        end
    end
    %}
    %DAY_S=max_op_inc(1,2);
    DAY_S=50;  %50== Worst case:
    for DAY_S=30:1:60
        figure(fig);
        
        X=[1:1:1440]';
        X=X/60;
        h(1:3)=plot(X,CAP_OPS(DAY_S).DSS_LTC_V(:,1:3)/60,'b-','LineWidth',3);
        hold on
        h(4:6)=plot(X,CAP_OPS_1(DAY_S).DSS_LTC_V(:,1:3)/60,'r-','LineWidth',3);
        hold on
        plot(X,CAP_OPS(DAY_S).DSS_LTC_V(:,1:3)/60,'b-','LineWidth',3);
        BW_U=ones(1440,1)*(124.5);
        BW_L=ones(1440,1)*(123.5);
        h(7:9)=plot(X,BW_U,'k--','LineWidth',2);
        hold on
        plot(X,BW_L,'k--','LineWidth',2);
        %  Settings:
        axis([0 24 123 125]);
        title('2/9 (VI=23.6 & CI=0.39)','FontWeight','bold','FontSize',14);
        ylabel('Voltage (120 V Base)','FontWeight','bold','FontSize',14);
        xlabel('Hour of Day (h) [Hr]','FontWeight','bold','FontSize',14);
        set(gca,'FontWeight','bold');
        legend([h(1),h(4),h(7)],'Base Case','PV @ 0.25*Rsc_{max}','LTC B.W.');
        %grid on
        
        fig = fig + 1;
    end
end
%%
if action == 8 || action == ALL
    fig = fig + 1;
    figure(fig);
    for fdr=1:1:7
        %subplot(3,2,fdr);
        if fdr == 1
            fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Bellhaven_Circuit_Opendss';
            peak_current = [424.489787369243,385.714277946091,446.938766508963];
            energy_line = '258839833';
        elseif fdr == 2
            fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss';
            peak_current = [345.492818586166,362.418979727275,291.727365549702];
            energy_line = '259355408';
        elseif fdr == 3
            fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss';
            peak_current = [196.597331353572,186.718068471483,238.090235458346];
            energy_line = '259363665';
        elseif fdr == 4 || fdr == 7
            fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Roxboro_Circuit_Opendss';
            peak_current = [232.766663065503,242.994085721044,238.029663479192];
            energy_line = 'PH997__2571841';
        elseif fdr == 5
            fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\HollySprings_Circuit_Opendss';
            peak_current = [263.73641240095,296.245661392728,201.389207853812];
            energy_line = '10EF34__2663676';
        elseif fdr == 6
            fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\ERaleigh_Circuit_1';
            peak_current = [214.80136594272,223.211693408696,217.825750072964];
            energy_line = 'PDP28__2843462';
        end
        str = strcat(fileloc,'\Master.DSS');
        [DSSCircObj, DSSText] = DSSStartup; 
        DSSText.command = ['Compile ' str]; 
        DSSText.command = sprintf('New EnergyMeter.CircuitMeter LINE.%s terminal=1 option=R PhaseVoltageReport=yes',energy_line);
        DSSText.command = sprintf('EnergyMeter.CircuitMeter.peakcurrent=[  %s   %s   %s  ]',num2str(peak_current(1,1)),num2str(peak_current(1,2)),num2str(peak_current(1,3)));
        DSSText.command = 'Disable Capacitor.*';
        DSSText.command = 'AllocateLoad';
        DSSText.command = 'AllocateLoad';
        DSSText.command = 'AllocateLoad';
        DSSText.command = 'Enable Capacitor.*';
        DSSText.command = 'Solve Loadmult=1.0';
        %Plot Topology
        plotCircuitLines(DSSCircObj,'Coloring','perPhase','MappingBackground','none');
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        if fdr ~= 7
            legend('hide')
        end
        title('');
        %set(gca,'legend','position','SouthEast');
        
        %set(gca,'legendLocation','SouthWest');
        if fdr == 1
            xlabel('(a) Feeder 01','FontSize',14);
        elseif fdr == 2
            xlabel('(b) Feeder 02','FontSize',14);
        elseif fdr == 3
            xlabel('(c) Feeder 03','FontSize',14);
        elseif fdr == 4
            xlabel('(d) Feeder 04','FontSize',14);
        elseif fdr == 5
            xlabel('(e) Feeder 05','FontSize',14);
        elseif fdr == 6
            xlabel('(f) Feeder 06','FontSize',14);
        end
        fig = fig + 1;
        figure(fig);
    end
    plot(1,1,'r-','LineWidth',3)
    hold on
    plot(1,2,'g-','LineWidth',3)
    hold on
    plot(1,3,'b-','LineWidth',3)
    hold on
    plot(1,4,'y-','LineWidth',3)
    hold on
    plot(1,5,'m-','LineWidth',3)
    hold on
    plot(1,6,'c-','LineWidth',3)
    hold on
    plot(1,7,'k-','LineWidth',3)
    legend('Phase A','Phase B','Phase C','Phase AB','Phase AC','Phase BC','Phase ABC')
    set(gca,'FontSize',12,'FontWeight','bold');
end
        
    
    %{
    
    %}
    
%%
%These are just leftovers:
%{
figure(1);
plotCircuitLines(DSSCircObj,'Coloring','lineLoading','PVMarker','on','MappingBackground','none');
figure(2);
plotCircuitLines(DSSCircObj,'Coloring','voltage120','PVMarker','on','MappingBackground','none');
%}

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