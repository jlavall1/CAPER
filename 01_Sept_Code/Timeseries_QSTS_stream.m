%Timeseries Analyses:
clear
clc
close all
s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
%addpath(strcat(s_b,'\01_Sept_Code'));
tic
%Setup the COM server
%{
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%}
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
time_int        = gui_response{1,14};%timestep length
QSTS_select     = gui_response{1,15};%selective timeseries run:
PV_ON_OFF       = gui_response{1,16};%1=off & 2=on;
%PV_pmpp         = gui_response{1,17};%kw
PV_location     = gui_response{1,18};
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

% 1. Add paths of background files:
path = strcat(base_path,'\01_Sept_Code');
addpath(path);
path = strcat(base_path,'\04_DSCADA');
addpath(path);


% 2. Generate Real Power & PV loadshape files:
if QSTS_select == 4
    %main algorithm to come!
else
    PV_Loadshape_generation
    feeder_Loadshape_generation_Dynamic %ckt_direct_prime (generated)

    %
    % 3. Compile the user selected circuit:
    location = cd;
    %Setup the COM server
    [DSSCircObj, DSSText, gridpvPath] = DSSStartup;
    DSSCircuit = DSSCircObj.ActiveCircuit;
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
        DSSText.command=sprintf('set mode=daily stepsize=%s number=%s',time_int,sim_num); %stepsize is now 1minute (60s)
        % Turn the overload report on:
        DSSText.command='Set overloadreport=true';
        DSSText.command='Set voltexcept=true';
        % Solve QSTS Solution:
        DSSText.command='solve';
        DSSText.command='show eventlog';
        toc
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
end
    