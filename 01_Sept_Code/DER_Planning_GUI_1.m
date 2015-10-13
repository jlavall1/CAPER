function varargout = DER_Planning_GUI_1(varargin)
%Purpose:   This .m file will prompt the user with what kind of simulation
%they would like to run.
% Begin initialization code - DO NOT EDIT
myGUI=[];
%Create Figure:
%position=[1400 100 800 1600];
close all
bk_color = [0.953 0.871 0.733];
h.f = figure('units','normalized','toolbar','none','menu','none',...
    'Color',bk_color,'Position',[-1.1 0.1 1.0 0.7]); %[258 14 126.6 57]);
%%
%Add all text:
h.st(1) = uicontrol('style','text','unit','normalized','position',[0.01 0.944 0.17 0.038],...
    'min',0,'max',1,'fontsize',12,'string','Name of Running Machine:',...
    'backgroundColor',[0.973 0.973 0.973],'FontAngle','italic');
h.st(2) = uicontrol('style','text','unit','normalized','position',[0.01 0.893 0.068 0.036],...
    'min',0,'max',1,'fontsize',12,'string','DEC:',...
    'backgroundColor',[0.973 0.973 0.973],'FontWeight','bold');
h.st(3) = uicontrol('style','text','unit','normalized','position',[0.01 0.75 0.068 0.036],...
    'min',0,'max',1,'fontsize',12,'string','DEP:',...
    'backgroundColor',[0.973 0.973 0.973],'FontWeight','bold');
h.st(4) = uicontrol('style','text','unit','normalized','position',[0.01 0.608 0.068 0.036],...
    'min',0,'max',1,'fontsize',12,'string','EPRI:',...
    'backgroundColor',[0.973 0.973 0.973],'FontWeight','bold');
h.st(5) = uicontrol('style','text','unit','normalized','position',[0.641 0.947 0.351 0.036],...
    'min',0,'max',1,'fontsize',8,'string','Center for Advanced Power Engineering  CAPER  2014-2016',...
    'backgroundColor',bk_color,'FontWeight','bold','FontAngle','italic');
h.st(6) = uicontrol('style','text','unit','normalized','position',[0.486 0.815 0.157 0.036],...
    'min',0,'max',1,'fontsize',10,'string','(DARR) Daily Aggregate RR',...
    'backgroundColor',[0.973 0.973 0.973],'FontWeight','bold');
h.st(7) = uicontrol('style','text','unit','normalized','position',[0.656 0.815 0.157 0.036],...
    'min',0,'max',1,'fontsize',10,'string','(VI) Variability Index',...
    'backgroundColor',[0.973 0.973 0.973],'FontWeight','bold');
h.st(8) = uicontrol('style','text','unit','normalized','position',[0.827 0.815 0.157 0.036],...
    'min',0,'max',1,'fontsize',10,'string','(CI) Clearsky Index',...
    'backgroundColor',[0.973 0.973 0.973],'FontWeight','bold');
%%
%Add all popupmenu:
h.ppm(1) = uicontrol('style','popup','units','normalized','position',[0.185 0.746 0.235 0.237],...
    'fontsize',12,'string',{'JML''s Home Computer','JML''s Laptop Computer','Brian''s Computer','Shane''s Computer'},...
    'BackgroundColor',[1 1 1]);
    %'callback',@setmap);
%DER Hosting Capacity:
h.ppm(2) = uicontrol('style','popup','units','normalized',...
     'position',[0.037 .162 0.235 0.155],'string',{'Top of Voltage band on caps/vregs','Bottom of Voltage band on caps/vregs','Steady-State','Extreme UP-ramping','Extreme DOWN-ramping'},...
     'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);
h.ppm(3) = uicontrol('style','popup','units','normalized',...
     'position',[0.037 0.169 0.235 0.106],'string',{'hold','hold'},...
     'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);
 
%PV Loadshapce selection:
h.ppm(4) = uicontrol('style','popup','units','normalized',...
     'position',[0.752 0.704 0.235 0.223],'string',{'1MW Shelby,NC','1MW Murphy,NC','1MW Taylorsville,NC','5.0MW Mocksville','3.5MW Ararat Rock','1.5MW Old Dominion','1MW Mayberry'},...
     'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);
 
%Timeseries Analysis:
h.ppm(5) = uicontrol('style','popup','units','normalized',...
    'position',[0.037 -0.001 0.235 0.155],'string',{'(1) Day, 10:00 to 16:00','(1) Day, 0:00 - 23:59','(1) Week','(1) Month','(1) Year'},...
    'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);
h.ppm(6) = uicontrol('style','popup','units','normalized',...
    'position',[0.037 0.006 0.235 0.106],'string',{'hold','hold'},...
    'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);

%Selective Timeseries Analysis:
h.ppm(7) = uicontrol('style','popup','units','normalized',...
    'position',[0.351 0.162 0.235 0.155],'string',{'hold','hold'},...
    'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);
h.ppm(8) = uicontrol('style','popup','units','normalized',...
     'position',[0.351 0.169 0.235 0.106],'string',{'hold','hold'},...
     'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12); 

%Extra Option for future use:
h.ppm(9) = uicontrol('style','popup','units','normalized',...
    'position',[0.351 -0.001 0.235 0.155],'string',{'hold','hold'},...
    'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);
h.ppm(10) = uicontrol('style','popup','units','normalized',...
     'position',[0.351 0.006 0.235 0.106],'string',{'hold','hold'},...
     'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12); 

%%
%Add all radiobutton:
h.rb(1) = uicontrol('style','radiobutton','units','normalized','fontsize',10,...
    'position',[0.038 0.851 0.139 0.032],'string','Bellhaven 12-04','backgroundcolor',bk_color);
h.rb(2) = uicontrol('style','radiobutton','units','normalized','fontsize',10,...
    'position',[0.038 0.82 0.139 0.032],'string','Commonwealth 12-05','backgroundcolor',bk_color);
h.rb(3) = uicontrol('style','radiobutton','units','normalized','fontsize',10,...
    'position',[0.038 0.789 0.139 0.032],'string','Flay 12-01','backgroundcolor',bk_color);
h.rb(4) = uicontrol('style','radiobutton','units','normalized','fontsize',10,...
    'position',[0.038 0.713 0.139 0.032],'string','Roxboro','backgroundcolor',bk_color);
h.rb(5) = uicontrol('style','radiobutton','units','normalized','fontsize',10,...
    'position',[0.038 0.682 0.139 0.032],'string','HollySprings','backgroundcolor',bk_color);
h.rb(6) = uicontrol('style','radiobutton','units','normalized','fontsize',10,...
    'position',[0.038 0.65 0.139 0.032],'string','East Raleigh','backgroundcolor',bk_color);
h.rb(7) = uicontrol('style','radiobutton','units','normalized','fontsize',10,...
    'position',[0.038 0.573 0.139 0.032],'string','Circuit #5','backgroundcolor',bk_color);
h.rb(8) = uicontrol('style','radiobutton','units','normalized','fontsize',10,...
    'position',[0.038 0.543 0.139 0.032],'string','Circuit #7','backgroundcolor',bk_color);
h.rb(9) = uicontrol('style','radiobutton','units','normalized','fontsize',10,...
    'position',[0.038 0.51 0.139 0.032],'string','Circuit #24','backgroundcolor',bk_color);

%%
%Add all checkboxes:
h.ckbx(1) = uicontrol('style','checkbox','units','normalized',...
    'position',[0.037 0.324 0.235 0.047],'string','DER Static Hosting Capacity:',...
    'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
    'Fontsize',12);
h.ckbx(2) = uicontrol('style','checkbox','units','normalized',...
     'position',[0.506 0.888 0.235 0.047],'string','Irradiance & PV Output Analysis:',...
     'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
     'Fontsize',12);
h.ckbx(3) = uicontrol('style','checkbox','units','normalized',...
     'position',[0.037 0.16 0.235 0.047],'string','Timeseries at various durations:',...
     'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
     'Fontsize',12);
h.ckbx(4) = uicontrol('style','checkbox','units','normalized',...
     'position',[0.351 0.324 0.235 0.047],'string','Selective Timeseries Analysis:',...
     'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
     'Fontsize',12);
h.ckbx(5) = uicontrol('style','checkbox','units','normalized',...
     'position',[0.351 0.16 0.235 0.047],'string','(hold)',...
     'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
     'Fontsize',12);
%%
%Add all pushbuttons:
h.push(1) = uicontrol('style','pushbutton','units','normalized',...
    'position',[0.398 0.441 0.07 0.05],'string','RUN',...
    'callback',@p_run,'fontsize',16,'ForegroundColor',[0.973 0.973 0.973],...
    'BackgroundColor',[0 1 0],'FontWeight','bold');
h.push(2) = uicontrol('style','pushbutton','units','normalized',...
    'position',[0.398 0.389 0.07 0.05],'string','Cancel',...
    'callback',@p_cancel,'fontsize',16,'ForegroundColor',[0.502 0.502 0.502],...
    'BackgroundColor',[0.941 0.941 0.941]);
h.push(3) = uicontrol('style','pushbutton','units','normalized',...
    'position',[0.195 0.441 0.195 0.05],'string','Plot Selected Feeder',...
    'callback',@p_plot,'fontsize',16,'ForegroundColor',[1 1 1],...
    'BackgroundColor',[0.871 0.49 0]);
h.push(4) = uicontrol('style','pushbutton','units','normalized',...
    'position',[0.195 0.389 0.195 0.05],'string','Make Settings Default',...
    'callback',@p_reset,'fontsize',16,'ForegroundColor',[1 1 1],...
    'BackgroundColor',[0.831 0.816 0.784]);
%%
%Add Sliders:
%   for solar coefficients
h.slide(1) = uicontrol('style','slider','units','normalized',...
    'position',[0.486 0.767 0.157 0.024],'fontsize',8);
h.slide(2) = uicontrol('style','slider','units','normalized',...
    'position',[0.656 0.767 0.157 0.024],'fontsize',8);
h.slide(3) = uicontrol('style','slider','units','normalized',...
    'position',[0.827 0.767 0.157 0.024],'fontsize',8);

%%
%Add axis plot:
%   the axes for plotting selected plot
hPlotAxes=axes('Parent',h.f,'Units','normalized',...
    'HandleVisibility','callback','Position',[0.195 0.509 0.274 0.403],...
    'YTick',[],'XTick',[]);
hPlotAxes1=axes('Parent',h.f,'Units','normalized',...
    'HandleVisibility','callback','Position',[0.487 0.51 0.156 0.236],...
    'YTick',[],'XTick',[]);
hPlotAxes2=axes('Parent',h.f,'Units','normalized',...
    'HandleVisibility','callback','Position',[0.657 0.51 0.156 0.236],...
    'YTick',[],'XTick',[]);
hPlotAxes3=axes('Parent',h.f,'Units','normalized',...
    'HandleVisibility','callback','Position',[0.828 0.51 0.156 0.236],...
    'YTick',[],'XTick',[]);

%%
%Set Defaults:
    set(h.ckbx(1),'Value',0);   %DER hosting capacity   -- OFF
    set(h.ckbx(2),'Value',1);   %PV loadshape           -- ON
    set(h.ckbx(3),'Value',1);   %timeseries simulation  -- ON
    set(h.rb(3),'Value',1);     %ckt choice             -- Flay
    set(h.ppm(5),'Value',2);    %timeseries DROPDOWN    -- 24hr
    
    
    uiwait(gcf);
%%





%Add macros for pushbuttons:
function m=p_run(varargin)
    %vals = get(h.ppm,'Value');
    %checked = find([vals{:}]);
    %{
    if isempty(checked)
        checked = 'none';
        fprintf('You did not select the settings for your test. Please use checkboxes to select your test and click Okay.');
    end
    %}
    %%
    comp_choice = get(h.ppm(1),'Value');
    assignin('base', 'comp_choice', 1);
    %Update main directory to folder w/ circuits:
    if comp_choice==1
        %JML Home Desktop
        s1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
        s_b = 'C:\Users\jlavall\Documents\GitHub\CAPER';
    elseif comp_choice==2
        %JML Laptop
        s1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
        s_b = 'C:\Users\jlavall\Documents\GitHub\CAPER';
    elseif comp_choice==3
        %Brians Comp
        s1 = 'C:\Users\Brian\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
        s_b = 'C:\Users\Brian\Documents\GitHub\CAPER';
    elseif comp_choice==4
        %RTPIS_7
        s1 = 'C:';
    elseif comp_choice==5
        s1 = 'C:';
    end
    %%
    checked = get(h.rb,'Value');
    [n m]=size(checked);
    if isempty(checked)
        checked = 'none';
        msgbox('You did not select the settings for your test. Please use checkboxes to select your test and click Okay.');
    elseif m ~= 0
    COUNT = 0;
        %See what circuit:
        if checked{1} == 1
            s2 = '\Bellhaven_Circuit_Opendss\Run_Master_Allocate.dss';
            ckt_num = 0;
            COUNT = COUNT + 1;
            cat_choice = 1;
        end
        if checked{2} == 1
            s2 = '\Commonwealth_Circuit_Opendss\Run_Master_Allocate.dss';
            ckt_num = 1;
            COUNT = COUNT + 1;
            cat_choice = 1;
        end
        if checked{3} == 1
            s2 = '\Flay_Circuit_Opendss\Run_Master_Allocate.dss';
            ckt_num = 2;
            COUNT = COUNT + 1;
            cat_choice = 1;
        end
        if checked{4} == 1
            s2 = '\Roxboro_Circuit_Opendss\Run_Master_Allocate.dss';
            ckt_num = 3;
            COUNT = COUNT + 1;
            cat_choice = 2;
        end
        if checked{5} == 1
            s2 = '\HollySprings_Circuit_Opendss\Run_Master_Allocate.dss';
            ckt_num = 4;
            COUNT = COUNT + 1;
            cat_choice = 2;
        end
        if checked{6} == 1
            s2 = '\ERaleigh_Circuit_Opendss\Run_Master_Allocate.dss';
            ckt_num = 5;
            COUNT = COUNT + 1;
            cat_choice = 2;
        end
        if checked{7} == 1
            s2 = '\EPRI_ckt5\Master.dss';
            ckt_num = 6;
            COUNT = COUNT + 1;
            cat_choice = 3;
        end
        if checked{8} == 1
            s2 = '\EPRI_ckt7\Master.dss';
            ckt_num = 7;
            COUNT = COUNT + 1;
            cat_choice = 3;
        end
        if checked{9} == 1
            s2 = '\EPRI_ckt24\Master.dss';
            ckt_num = 8;
            COUNT = COUNT + 1;
            cat_choice = 3;
        end
    end   
    %Lets see what kind of sim they want to do:   
    COUNT_1 = 0;
    %---- DER Static hosting capacity:
    section_type = get(h.ckbx(1),'Value');
    if section_type == 1
        select = get(h.ppm(2),'Value');
        %Check:
        if isempty(select)
            select = 'none';
            msgbox('You did not select the settings for your test. Please use checkboxes to select your test and click Okay.');
        else
            %save dropdown menu:
            sim_type = select;
            time_select = 0;
        end
    end
    %---- PV loadshape generation:
    PV_type = get(h.ckbx(2),'Value');
    if PV_type == 1
        PV_select = get(h.ppm(4),'Value');
        PV_location = PV_select;
        if PV_location == 1
            PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\01_Shelby_NC');
        elseif PV_location == 2
            PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\02_Murphy_NC');
        elseif PV_location == 3
            PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\03_Taylorsville_NC');
        elseif PV_location == 4
            PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
        elseif PV_location == 5
            PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\05_AraratRock_NC');
        elseif PV_location == 6
            PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\06_OldDominion_NC');
        elseif PV_location == 7
            PV_dir = strcat(s_b,'\04_DSCADA\VI_CI_IrradianceDailyProfiles\07_MayBerry_NC');
        end 
    else
        msgbox('no PV loadshape was selected');
    end
    %---- Timeseries analysis choices:
    time_type = get(h.ckbx(3),'Value');
    if time_type == 1
        time_select = get(h.ppm(5),'Value');
        sim_type = 0;
        %time_select choices:
        %1)  10:00 - 16:00
        %2)  (1) WEEK
    end

    %Check if multiple selections & then string combine if OK.
    if COUNT > 1
        msgbox('More than 1 feeder was selected.');
    elseif COUNT_1 > 1
        msgbox('More than 1 simulation category selected.');
    else
    STRING = strcat(s1,s2);
    %%
    %Save user's selection:
    STRING_0{1,1} = STRING;
    STRING_0{1,2} = ckt_num;
    
    STRING_0{1,3} = sim_type;
    STRING_0{1,4} = s_b;
    STRING_0{1,5} = cat_choice;
    STRING_0{1,6} = section_type;
    STRING_0{1,7} = PV_location;
    STRING_0{1,8} = PV_dir;
    STRING_0{1,9} = time_select;
    
    %assignin('base', 'cat_choice', cat_choice);
    %assignin('base', 'ckt_num', ckt_num);
    %assignin('base', 'STRING', STRING);
    assignin('base', 'STRING_0', STRING_0);
    close(h.f);
    end
end
function p_reset(varargin)
    cat1 = get(h.rb,'Value');
    for i=1:1:length(cat1)
        set(h.rb(i),'Value',0);
    end
    
    cat2 = get(h.ckbx,'Value');
    for i=1:1:length(cat2)
        set(h.ckbx(i),'Value',0);
    end
end

function p_cancel(varargin)
    close(h.f);
end

function p_plot(varargin)
    %Extract computer directory:
    comp_choice = get(h.ppm(1),'Value');
    if comp_choice==1
        %JML Home Desktop
        s1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
        s_b = 'C:\Users\jlavall\Documents\GitHub\CAPER';
    elseif comp_choice==2
        %JML Laptop
        s1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
        s_b = 'C:\Users\jlavall\Documents\GitHub\CAPER';
    elseif comp_choice==3
        %Brians Comp
        s1 = 'C:\Users\Brian\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
        s_b = 'C:\Users\Brian\Documents\GitHub\CAPER';
    elseif comp_choice==4
        %RTPIS_7
        s1 = 'C:';
    elseif comp_choice==5
        s1 = 'C:';
    end
    %Extract feeder type:
    checked = get(h.rb,'Value');
    [n m]=size(checked);
    if isempty(checked)
        checked = 'none';
        msgbox('You did not select the settings for your test. Please use checkboxes to select your test and click Okay.');
    elseif m ~= 0
    COUNT = 0;
        %See what circuit:
        if checked{1} == 1
            s2 = '\Bellhaven_Circuit_Opendss\Run_Master_Allocate.dss';
        end
        if checked{2} == 1
            s2 = '\Commonwealth_Circuit_Opendss\Run_Master_Allocate.dss';
        end
        if checked{3} == 1
            s2 = '\Flay_Circuit_Opendss\Run_Master_Allocate.dss';
        end
        if checked{4} == 1
            s2 = '\Roxboro_Circuit_Opendss\Run_Master_Allocate.dss';
        end
        if checked{5} == 1
            s2 = '\HollySprings_Circuit_Opendss\Run_Master_Allocate.dss';
        end
        if checked{6} == 1
            s2 = '\ERaleigh_Circuit_Opendss\Run_Master_Allocate.dss';
        end
        if checked{7} == 1
            s2 = '\EPRI_ckt5\Master.dss';
        end
        if checked{8} == 1
            s2 = '\EPRI_ckt7\Master.dss';
        end
        if checked{9} == 1
            s2 = '\EPRI_ckt24\Master.dss';
        end
    end
    STRING = strcat(s1,s2);
    cla(hPlotAxes);
    [DSSCircObj, DSSText, gridpvPath] = DSSStartup;
    mainFile = STRING;
    DSSText.command = ['Compile "',mainFile];
    DSSText.command ='solve loadmult=0.5';
    plotCircuitLines(DSSCircObj,'Coloring','numPhases','MappingBackground','none')%(hPlotAxes);
    set(hPlotAxes,'Ytick',[],'Xtick',[]);
    %title(titlestring);

end


end
%}


