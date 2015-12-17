% 1. Generate Real Power & PV loadshape files:
PV_Loadshape_generation
cap_pos=1;
feeder_Loadshape_generation_Dynamic %ckt_direct_prime (generated)

%
% 2. Compile the user selected circuit:
location = cd;
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
DSSText.command = ['Compile ',ckt_direct_prime]; %_prime gen in:
Cap_info = getCapacitorInfo(DSSCircObj);
Lines_info = getLineInfo(DSSCircObj);
[~,index] = sortrows([Lines_info.bus1Distance].');
Lines_info = Lines_info(index);
Buses_info = getBusInfo(DSSCircObj);
Loads_info = getLoadInfo(DSSCircObj);
%%   
cd(location);
%
% 3. Compile PV system to a location:
%-------------------------------------
if PV_ON_OFF == 2
    %Add PV Plant:
    str = ckt_direct;
    idx = strfind(str,'\');
    str = str(1:idx(8)-1);
    %  ***root & root1 gen. in feeder_Loadshape_generation***
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
    DSSText.command = sprintf('Compile (%s)',solarfilename); %add solar scenario
    DSSText.command = sprintf('edit pvsystem.PV bus1=%s pmpp=%s kVA=%s',PV_bus,num2str(PV_pmpp),num2str(PV_pmpp*1.1));
end
%%
% 4. Main Loop
%---------------------------------
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
DAY = 1;
MNTH = 1;
for DOY=1:1:365 %365
    tic
    if DAY > MTH_LN(MNTH)
        MNTH = MNTH + 1;
        DAY = 1;
    end
    %Update Irradiance/PV_KW
    fprintf('\nQSTS Simulation: DOY= %d\n',DOY);
    PV1_loadshape_daily = M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
    PV_loadshape_daily = interp(PV1_loadshape_daily(:,1),60); %go down to 1 second dataset --
    s_pv_txt = '\LS_PVdaily.txt';
    s_pv = strcat(s,s_pv_txt);
    csvwrite(s_pv,PV_loadshape_daily)
    %Update Feeder KW & KVAR
    feeder_Loadshape_generation_Dynamic
    DSSText.command = ['Compile ',ckt_direct_prime];
    
    %Run QSTS 24hr sim:
    if timeseries_span == 2
        %(1) DAY, 24hr
        % Solve QSTS Solution:
        DSSText.command=sprintf('set mode=daily stepsize=%s number=%s',time_int,'1');
        DSSCircuit.Solution.dblHour = 0.0;
        for t = 1:1:str2num(sim_num)
            % Solve at current time step
            DSSCircuit.Solution.Solve
            % Switching Capacitor Control
            Cap_Control_1
        end
    end
    Export_Monitors_timeseries
    DAY = DAY + 1;
    toc
end
%Plotting_Functions


    