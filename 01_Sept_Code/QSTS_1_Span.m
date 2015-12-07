% 2. Generate Real Power & PV loadshape files:
PV_Loadshape_generation
feeder_Loadshape_generation_Dynamic %ckt_direct_prime (generated)
figure(1)
plot(KVAR_ACTUAL.data(:,5),'r-');
hold on
plot(KVAR_ACTUAL.data(:,4)*-1*Caps.Swtch*3,'b-');
figure(2)
plot(KVAR_ACTUAL.data(:,6),'r-');
hold on
plot(KVAR_ACTUAL.data(:,4),'b-');

%
% 3. Compile the user selected circuit:
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
%Sort Lines into closest from PCC --
%[~,index] = sortrows([Lines_Base.bus1Distance].'); 
%Lines_Distance = Lines_Base(index); 
%clear index
%----------------------------------
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
    %---------------------------------
%%
%---------------------------------
%Plot / observe simulation results:
shift=0;
h_st=0;
h_fin=23;
if timeseries_span == 1
    %(1) peakPV RUN
    shift=10;
    h_st = 10;
    h_fin= 15;
    DOY_fin = 0;
    %start openDSS ---------------------------

    % Run 6hr simulation at some interval:
    DSSText.command=sprintf('set mode=daily stepsize=%s number=%s',time_int,sim_num); %stepsize is now 1minute (60s)
    % Turn the overload report on:
    DSSText.command='Set overloadreport=true';
    DSSText.command='Set voltexcept=true';
    % Solve QSTS Solution:
    DSSText.command='solve';
    DSSText.command='show eventlog';
    toc
elseif timeseries_span == 2
    %(1) DAY, 24hr
    DOY_fin = 0;
    %start openDSS ---------------------------

    % Run 1-day simulation at 1minute interval:
    %DSSText.command=sprintf('set mode=daily stepsize=%s number=%s',time_int,sim_num); %stepsize is now 1minute (60s)
    %DSSText.command='show eventlog';

    % Solve QSTS Solution:
    DSSText.command=sprintf('set mode=daily stepsize=%s number=%s',time_int,'1');
    DSSCircuit.Solution.dblHour = 0.0;
    for t = 1:1:str2num(sim_num)
        % Solve at current time step
        DSSCircuit.Solution.Solve
        % Switching Capacitor Control
        Cap_Control_1
    end
elseif timeseries_span == 3
    %(1) WEEK
    DOY_fin = 6;
    %start openDSS ---------------------------

    % Run 1-day simulation at 1minute interval:
    DSSText.command=sprintf('set mode=yearly stepsize=%s number=%s',time_int,sim_num); %stepsize is now 1minute (60s)
    % Turn the overload report on:
    DSSText.command='Set overloadreport=true';
    DSSText.command='Set voltexcept=true';
    % Solve QSTS Solution:
    DSSText.command='solve';
    DSSText.command='show eventlog';
    toc    
elseif timeseries_span == 4
    %(1) MONTH
    MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
    MTH_DY(2,1:12) = [1,32,60,91,121,152,182,213,244,274,305,335];
    DOY_fin = MTH_DY(2,monthly_span);
    %start openDSS ---------------------------

    % Run 1-day simulation at 1minute interval:
    DSSText.command=sprintf('set mode=yearly stepsize=%s number=%s',time_int,sim_num); %stepsize is now 1minute (60s)
    % Turn the overload report on:
    DSSText.command='Set overloadreport=true';
    DSSText.command='Set voltexcept=true';
    % Solve QSTS Solution:
    DSSText.command='solve';
    DSSText.command='show eventlog';
    toc    

elseif timeseries_span == 5
    %(1) YEAR
    DOY = 1;
    DOY_fin = 365;

end
%%
tic
Export_Monitors_timeseries
toc
Plotting_Functions

    