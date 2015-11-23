%feeder_Loadshape_generation: This .m file will generate the .txt single
%phase files of the desired day user define.
%%
%Temp init. vars/actions
%{
clear
clc
base_path = 'C:\Users\jlavall\Documents\GitHub\CAPER';
ckt_direct = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Run_Master_Allocate.dss';
feeder_NUM = 2;
timeseries_span = 1;
DOY = 40;
%}
%%
%As of 10/12 - user pre-defines and it is not dynamic yet.
path = strcat(base_path,'\04_DSCADA\Feeder_Data');
addpath(path);

if feeder_NUM == 0
    load BELL.mat
    FEEDER = BELL;
    clearvars BELL
    kW_peak = [2.940849617143377e+03,2.699860573083591e+03,3.092128804831415e+03];
    %AllocationFactors Terms:
    
    % -- Bellhaven --
    root = 'Bell';
    root1= 'Bell';
elseif feeder_NUM == 1
    load CMNWLTH.mat
    FEEDER = CMNWLTH;
    clearvars CMNWLTH
    kW_peak = [2.475021572579630e+03,2.609588847297235e+03,2.086659558753901e+03];
    %AllocationFactors Terms:
    
    % -- Commonwealth --
    root = 'Common';
    root1= 'Common';
elseif feeder_NUM == 2
    load FLAY.mat
    FEEDER = FLAY;
    clearvars FLAY
    kW_peak = [1.424871573296857e+03,1.347528364235151e+03,1.716422704604557e+03];
    %To be used for finding AllocationFactors for simulation:
    eff_KW(1,1) = 0.9862;
    eff_KW(1,2) = 0.993;
    eff_KW(1,3) = 0.9894;
    V_LTC = 1.03*((12.47e3)/sqrt(3));
    % -- Flay 13.27km long --
    root = 'Flay';
    root1= 'Flay';
elseif feeder_NUM == 3
    load ROX.mat
    FEEDER = ROX;
    clearvars ROX
    kW_peak = [3.189154306704542e+03,3.319270338767296e+03,3.254908188719974e+03];
elseif feeder_NUM == 4
    load HOLLY.mat
elseif feeder_NUM == 5
    load ERalh.mat
elseif feeder_NUM == 8
    load FLAY.mat
    FEEDER = FLAY;
    clearvars FLAY
    kW_peak = [1.424871573296857e+03,1.347528364235151e+03,1.716422704604557e+03];
    %EPRI Circuit 24
    root = 'ckt24';
    root1 = 'ckt24';
end
%%
%Select DOY & convert to P.U. --
%   DOY already decided from PV_Loadshape_generation.
if timeseries_span == 1
    %1] Select data from 10AM to 4PM --
    LOAD_ACTUAL_1(:,1) = FEEDER.kW.A(time2int(DOY,10,0):time2int(DOY,15,59),1);
    LOAD_ACTUAL_1(:,2) = FEEDER.kW.B(time2int(DOY,10,0):time2int(DOY,15,59),1);
    LOAD_ACTUAL_1(:,3) = FEEDER.kW.C(time2int(DOY,10,0):time2int(DOY,15,59),1);
    %2] Declare duration & timestep:
    if strcmp(time_int,'1h') == 1
        t_int=0;
        sim_num='6';
        fprintf('Sim. timestep=1hr\n');
    elseif strcmp(time_int,'1m') == 1
        t_int=1;
        sim_num='360'; %6*60
        fprintf('Sim. timestep=60s\n');
    elseif strcmp(time_int,'30s') == 1
        t_int=2;
        sim_num='720'; %6*60*2
        fprintf('Sim. timestep=30s\n');
    elseif strcmp(time_int,'5s') == 1
        t_int=12;
        sim_num='4320'; %6*60*12
        fprintf('Sim. timestep=5s\n');
    end   
    %3] Re-size original 1min data accordingly:
    if t_int ~= 0
        LOAD_ACTUAL(:,1) = interp(LOAD_ACTUAL_1(:,1),t_int);
        LOAD_ACTUAL(:,2) = interp(LOAD_ACTUAL_1(:,2),t_int);
        LOAD_ACTUAL(:,3) = interp(LOAD_ACTUAL_1(:,3),t_int);
    else
        jj=1;
        for ii=1:60:length(LOAD_ACTUAL_1)
            LOAD_ACTUAL(jj,1) = LOAD_ACTUAL_1(ii,1);
            LOAD_ACTUAL(jj,2) = LOAD_ACTUAL_1(ii,2);
            LOAD_ACTUAL(jj,3) = LOAD_ACTUAL_1(ii,3);
            jj = jj + 1;
        end
    end
    %4] Find peak kW per phase to nominalize:
    for i=1:1:3
        %peak:
        peak_KW(1,i) = max(LOAD_ACTUAL(:,i));
        peak_current(1,i) = (peak_KW(1,i)*1000)/(0.98*V_LTC*eff_KW(1,i));
        
    end
    LS_PhaseA(:,1)=LOAD_ACTUAL(:,1)./peak_KW(1,1);
    LS_PhaseB(:,1)=LOAD_ACTUAL(:,2)./peak_KW(1,2);
    LS_PhaseC(:,1)=LOAD_ACTUAL(:,3)./peak_KW(1,3);
    
elseif timeseries_span == 2
    %24HR Sim    --  Select days worth of data @ given interval:
    LOAD_ACTUAL_1(:,1) = FEEDER.kW.A(time2int(DOY,0,0):time2int(DOY,23,59),1);
    LOAD_ACTUAL_1(:,2) = FEEDER.kW.B(time2int(DOY,0,0):time2int(DOY,23,59),1);
    LOAD_ACTUAL_1(:,3) = FEEDER.kW.C(time2int(DOY,0,0):time2int(DOY,23,59),1);
    %Declare duration & timestep:
    if strcmp(time_int,'1h') == 1
        t_int=0;
        sim_num='24';
        fprintf('Sim. timestep=1hr\n');
    elseif strcmp(time_int,'1m') == 1
        t_int=1;
        sim_num='1440';
        fprintf('Sim. timestep=60s\n');
    elseif strcmp(time_int,'30s') == 1
        t_int=2;
        sim_num='2880';
        fprintf('Sim. timestep=30s\n');
    elseif strcmp(time_int,'5s') == 1
        t_int=12;
        sim_num='17280';
        fprintf('Sim. timestep=5s\n');
    end
    %Re-size original 1min data accordingly:
    if t_int ~= 0
        LOAD_ACTUAL(:,1) = interp(LOAD_ACTUAL_1(:,1),t_int);
        LOAD_ACTUAL(:,2) = interp(LOAD_ACTUAL_1(:,2),t_int);
        LOAD_ACTUAL(:,3) = interp(LOAD_ACTUAL_1(:,3),t_int);
    else
        jj=1;
        for ii=1:60:length(LOAD_ACTUAL_1)
            LOAD_ACTUAL(jj,1) = LOAD_ACTUAL_1(ii,1);
            LOAD_ACTUAL(jj,2) = LOAD_ACTUAL_1(ii,2);
            LOAD_ACTUAL(jj,3) = LOAD_ACTUAL_1(ii,3);
            jj = jj + 1;
        end
    end
    %Find peak kW per phase to nominalize:
    for i=1:1:3
        %peak:
        peak_KW(1,i) = max(LOAD_ACTUAL(:,i));
        peak_current(1,i) = (peak_KW(1,i)*1000)/(0.98*V_LTC*eff_KW(1,i));
        
    end
    %[103.495301953215,96.6441972706368,114.971409775341] %Calc
    %[105.620106708074,98.4618867738973,117.338827780071] %Sim
    
    %Find corresponding current to allocateLoad:
    %(eff_KW(1,1) = 0.9562;eff_KW(1,2) = 0.9594;eff_KW(1,3) = 0.9239;V_LTC = 1.04*((12.47e3)/sqrt(3));
    %nominalize:
    LS_PhaseA(:,1)=LOAD_ACTUAL(:,1)./peak_KW(1,1);
    LS_PhaseB(:,1)=LOAD_ACTUAL(:,2)./peak_KW(1,2);
    LS_PhaseC(:,1)=LOAD_ACTUAL(:,3)./peak_KW(1,3);
    
elseif timeseries_span == 3
    %1] Select data for 7 days:
    LOAD_ACTUAL_1(:,1) = FEEDER.kW.A(time2int(DOY,0,0):time2int(DOY+6,23,59),1);
    LOAD_ACTUAL_1(:,2) = FEEDER.kW.B(time2int(DOY,0,0):time2int(DOY+6,23,59),1);
    LOAD_ACTUAL_1(:,3) = FEEDER.kW.C(time2int(DOY,0,0):time2int(DOY+6,23,59),1);
    %2] Declare duration & timestep:
    if strcmp(time_int,'1h') == 1
        t_int=0;
        sim_num='168'; %168hrs
        fprintf('Sim. timestep=1hr\n');
    elseif strcmp(time_int,'1m') == 1
        t_int=1;
        sim_num='10080'; %168*60
        fprintf('Sim. timestep=60s\n');
    elseif strcmp(time_int,'30s') == 1
        t_int=2;
        sim_num='20160'; %168*60*2
        fprintf('Sim. timestep=30s\n');
    elseif strcmp(time_int,'5s') == 1
        t_int=12;
        sim_num='120960'; %168*60*12
        fprintf('Sim. timestep=5s\n');
    end
    %3] Re-size original 1min data accordingly:
    if t_int ~= 0
        LOAD_ACTUAL(:,1) = interp(LOAD_ACTUAL_1(:,1),t_int);
        LOAD_ACTUAL(:,2) = interp(LOAD_ACTUAL_1(:,2),t_int);
        LOAD_ACTUAL(:,3) = interp(LOAD_ACTUAL_1(:,3),t_int);
    else
        jj=1;
        for ii=1:60:length(LOAD_ACTUAL_1)
            LOAD_ACTUAL(jj,1) = LOAD_ACTUAL_1(ii,1);
            LOAD_ACTUAL(jj,2) = LOAD_ACTUAL_1(ii,2);
            LOAD_ACTUAL(jj,3) = LOAD_ACTUAL_1(ii,3);
            jj = jj + 1;
        end
    end
    %4] Find peak kW per phase to nominalize:
    for i=1:1:3
        %peak:
        peak_KW(1,i) = max(LOAD_ACTUAL(:,i));
        peak_current(1,i) = (peak_KW(1,i)*1000)/(0.98*V_LTC*eff_KW(1,i));
        
    end
    LS_PhaseA(:,1)=LOAD_ACTUAL(:,1)./peak_KW(1,1);
    LS_PhaseB(:,1)=LOAD_ACTUAL(:,2)./peak_KW(1,2);
    LS_PhaseC(:,1)=LOAD_ACTUAL(:,3)./peak_KW(1,3);

elseif timeseries_span == 4
    %1] Month Sim
    LOAD_ACTUAL_1(:,1) = FEEDER.kW.A(time2int(DOY,0,0):time2int(DOY+shift,23,59),1);
    LOAD_ACTUAL_1(:,2) = FEEDER.kW.B(time2int(DOY,0,0):time2int(DOY+shift,23,59),1);
    LOAD_ACTUAL_1(:,3) = FEEDER.kW.C(time2int(DOY,0,0):time2int(DOY+shift,23,59),1);
    %2] Declare duration & timestep:
    if strcmp(time_int,'1h') == 1
        t_int=0;
        if shift+1 == 28
            sim_num='672'; %28*24hrs
        elseif shift+1 == 30
            sim_num='720'; %30*24hrs
        elseif shift+1 == 31
            sim_num='744';  %31*24hrs
        end
        fprintf('Sim. timestep=1hr\n');
    elseif strcmp(time_int,'1m') == 1
        t_int=1;
        sim_num='10080'; %168*60
        fprintf('Sim. timestep=60s\n');
    elseif strcmp(time_int,'30s') == 1
        t_int=2;
        sim_num='20160'; %168*60*2
        fprintf('Sim. timestep=30s\n');
    elseif strcmp(time_int,'5s') == 1
        t_int=12;
        sim_num='120960'; %168*60*12
        fprintf('Sim. timestep=5s\n');
    end
    %3] Re-size original 1min data accordingly:
    if t_int ~= 0
        LOAD_ACTUAL(:,1) = interp(LOAD_ACTUAL_1(:,1),t_int);
        LOAD_ACTUAL(:,2) = interp(LOAD_ACTUAL_1(:,2),t_int);
        LOAD_ACTUAL(:,3) = interp(LOAD_ACTUAL_1(:,3),t_int);
    else
        jj=1;
        for ii=1:60:length(LOAD_ACTUAL_1)
            LOAD_ACTUAL(jj,1) = LOAD_ACTUAL_1(ii,1);
            LOAD_ACTUAL(jj,2) = LOAD_ACTUAL_1(ii,2);
            LOAD_ACTUAL(jj,3) = LOAD_ACTUAL_1(ii,3);
            jj = jj + 1;
        end
    end
    %4] Find peak kW per phase to nominalize:
    for i=1:1:3
        %peak:
        peak_KW(1,i) = max(LOAD_ACTUAL(:,i));
        peak_current(1,i) = (peak_KW(1,i)*1000)/(0.98*V_LTC*eff_KW(1,i));
        
    end
    LS_PhaseA(:,1)=LOAD_ACTUAL(:,1)./peak_KW(1,1);
    LS_PhaseB(:,1)=LOAD_ACTUAL(:,2)./peak_KW(1,2);
    LS_PhaseC(:,1)=LOAD_ACTUAL(:,3)./peak_KW(1,3);
    
elseif timeseries_span == 5
    %1 YEAR Sim -- @10min incs.
    MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
    MNTH= 1;
    DAY = 1;
    hr = 0;
    min = 0;
    i = 1;
    LS_PhaseA = zeros(365*24*60/10,1);
    LS_PhaseB = zeros(365*24*60/10,1);
    LS_PhaseC = zeros(365*24*60/10,1);
   while MNTH < 13
       while DAY < MTH_LN(1,MNTH)+1
           while hr < 24
               while min < 60
                   LS_PhaseA(i,1) = FEEDER.kW.A(time2int(DAY,hr,min),1)./kW_peak(1,1);
                   LS_PhaseB(i,1) = FEEDER.kW.B(time2int(DOY,hr,min),1)./kW_peak(1,2);
                   LS_PhaseC(i,1) = FEEDER.kW.C(time2int(DOY,hr,min),1)./kW_peak(1,3);
                   i = i + 1;
                   min = min + 10;
               end
               min = 0;
               hr = hr + 1;
           end
           hr = 0;
           DAY = DAY + 1;
       end
       DAY = 1;
       MNTH = MNTH + 1;
   end
end
%%
%Now lets find new allocation Factors:
%  Runs static powerflow 
str = strcat(s,'\Master.DSS');
[DSSCircObj, DSSText] = DSSStartup; 
DSSText.command = ['Compile ' str]; 
DSSText.command = 'New EnergyMeter.CircuitMeter LINE.259363665 terminal=1 option=R PhaseVoltageReport=yes';
%DSSText.command = 'EnergyMeter.CircuitMeter.peakcurrent=[  196.597331353572   186.718068471483   238.090235458346  ]';
DSSText.command = sprintf('EnergyMeter.CircuitMeter.peakcurrent=[  %s   %s   %s  ]',num2str(peak_current(1,1)),num2str(peak_current(1,2)),num2str(peak_current(1,3)));
DSSText.command = 'Disable Capacitor.*';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'Dump AllocationFactors';
DSSText.command = 'Enable Capacitor.*';
% 3. Solve at peak currents.
DSSText.command = 'solve loadmult=1.0';
% 4. Check solution.
DSSCircuit = DSSCircObj.ActiveCircuit;
Buses=getBusInfo(DSSCircObj);
Lines=getLineInfo(DSSCircObj);
Loads=getLoadInfo(DSSCircObj);
%%
%Save .txt per phase --
if feeder_NUM == 2
    CUTOFF=10;
else
    CUTOFF=23;
end
s = ckt_direct(1:end-CUTOFF); % <--------THIS MIGHT CHANGE PER FEEDER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
str = ckt_direct;
idx = strfind(str,'\');
str = str(1:idx(8)-1);
if timeseries_span == 1
    %10AM to 4PM, at 1minute intervals
    s_kwA = strcat(s,'LS1_PhaseA.txt');
    s_kwB = strcat(s,'LS1_PhaseB.txt');
    s_kwC = strcat(s,'LS1_PhaseC.txt');
    idx = strfind(ckt_direct,'.');
    
    %Select the correct master file for QSTS
    if strcmp(time_int,'1h') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_6hr_3600sec.dss');
    elseif strcmp(time_int,'1m') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_6hr_60sec.dss');
    elseif strcmp(time_int,'30s') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_6hr_30sec.dss');
    elseif strcmp(time_int,'5s') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_6hr_5sec.dss');
    end
    
elseif timeseries_span == 2
    %One Day simulation
    s_kwA = strcat(s,'LS2_PhaseA.txt'); %was .txt
    s_kwB = strcat(s,'LS2_PhaseB.txt');
    s_kwC = strcat(s,'LS2_PhaseC.txt');
    idx = strfind(ckt_direct,'.');
    
    %Select the correct master file for QSTS
    if strcmp(time_int,'1h') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_24hr_3600sec.dss');
    elseif strcmp(time_int,'1m') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_24hr_60sec.dss');
    elseif strcmp(time_int,'30s') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_24hr_30sec.dss');
    elseif strcmp(time_int,'5s') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_24hr_5sec.dss');
    end
    
elseif timeseries_span == 3
    %One Week simulation
    s_kwA = strcat(s,'LS3_PhaseA.txt');
    s_kwB = strcat(s,'LS3_PhaseB.txt');
    s_kwC = strcat(s,'LS3_PhaseC.txt');
    idx = strfind(ckt_direct,'.');
    
    %Select the correct master file for QSTS
    if strcmp(time_int,'1h') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_168hr_3600sec.dss');
    elseif strcmp(time_int,'1m') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_168hr_60sec.dss');
    elseif strcmp(time_int,'30s') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_168hr_30sec.dss');
    elseif strcmp(time_int,'5s') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_168hr_5sec.dss');
    end

elseif timeseries_span == 4
    %1 Month simulation
    if shift+1 == 28        %40320 datapoints
        s_kwA = strcat(s,'LS4_PhaseA.txt');
        s_kwB = strcat(s,'LS4_PhaseB.txt');
        s_kwC = strcat(s,'LS4_PhaseC.txt');
        idx = strfind(ckt_direct,'.');
        %Select the correct master file for QSTS
        if strcmp(time_int,'1h') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth28_3600sec.dss');
        elseif strcmp(time_int,'1m') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth28_60sec.dss');
        elseif strcmp(time_int,'30s') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth28_30sec.dss');
        elseif strcmp(time_int,'5s') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth28_5sec.dss');
        end
    elseif shift+1 == 30    %43200 datapoints
        s_kwA = strcat(s,'LS5_PhaseA.txt');
        s_kwB = strcat(s,'LS5_PhaseB.txt');
        s_kwC = strcat(s,'LS5_PhaseC.txt');
        idx = strfind(ckt_direct,'.');
        %Select the correct master file for QSTS
        if strcmp(time_int,'1h') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth30_3600sec.dss');
        elseif strcmp(time_int,'1m') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth30_60sec.dss');
        elseif strcmp(time_int,'30s') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth30_30sec.dss');
        elseif strcmp(time_int,'5s') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth30_5sec.dss');
        end
    
    elseif shift+1 == 31    %44640 datapoints
        s_kwA = strcat(s,'LS6_PhaseA.txt');
        s_kwB = strcat(s,'LS6_PhaseB.txt');
        s_kwC = strcat(s,'LS6_PhaseC.txt');
        idx = strfind(ckt_direct,'.');
        %Select the correct master file for QSTS
        if strcmp(time_int,'1h') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth31_3600sec.dss');
        elseif strcmp(time_int,'1m') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth31_60sec.dss');
        elseif strcmp(time_int,'30s') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth31_30sec.dss');
        elseif strcmp(time_int,'5s') == 1
            ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth31_5sec.dss');
        end
    
    end
    %{
    MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
    MTH_DY(2,1:12) = [1,32,60,91,121,152,182,213,244,274,305,335];
    DOY = MTH_DY(2,monthly_span);   %From top--> monthly_span:
    shift = MTH_LN(1,monthly_span)-1;
    %}
elseif timeseries_span == 5
    %1 YEAR simulation
    s_kwA = strcat(s,'LS7_PhaseA.txt');
    s_kwB = strcat(s,'LS7_PhaseB.txt');
    s_kwC = strcat(s,'LS7_PhaseC.txt');
    FEEDER.SIM.npts= 365*24*60/10;  %simulating full 365days
    FEEDER.SIM.stepsize = 60*10;    %10 minute intervals
    idx = strfind(ckt_direct,'.');
    %Select the correct master file for QSTS
    if strcmp(time_int,'1h') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_168hr_3600sec.dss');
    elseif strcmp(time_int,'1m') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_168hr_60sec.dss');
    elseif strcmp(time_int,'30s') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_168hr_30sec.dss');
    elseif strcmp(time_int,'5s') == 1
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_168hr_5sec.dss');
    end
end
csvwrite(s_kwA,LS_PhaseA)
csvwrite(s_kwB,LS_PhaseB)
csvwrite(s_kwC,LS_PhaseC)
