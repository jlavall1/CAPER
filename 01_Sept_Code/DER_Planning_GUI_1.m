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
h.st(3) = uicontrol('style','text','unit','normalized','position',[0.01 0.724 0.068 0.036],...
    'min',0,'max',1,'fontsize',12,'string','DEP:',...
    'backgroundColor',[0.973 0.973 0.973],'FontWeight','bold');
h.st(4) = uicontrol('style','text','unit','normalized','position',[0.01 0.558 0.068 0.036],...
    'min',0,'max',1,'fontsize',12,'string','EPRI:',...
    'backgroundColor',[0.973 0.973 0.973],'FontWeight','bold');
h.st(5) = uicontrol('style','text','unit','normalized','position',[0.641 0.947 0.351 0.036],...
    'min',0,'max',1,'fontsize',8,'string','Center for Advanced Power Engineering  CAPER  2014-2016',...
    'backgroundColor',bk_color,'FontWeight','bold','FontAngle','italic');
%%
%Add all popupmenu:
h.ppm(1) = uicontrol('style','popup','units','normalized','position',[0.185 0.746 0.235 0.237],...
    'fontsize',12,'string',{'JML''s Home Computer','JML''s Laptop Computer','Brian''s Computer','Shane''s Computer'},...
    'BackgroundColor',[1 1 1]);
    %'callback',@setmap);

h.ppm(2) = uicontrol('style','popup','units','normalized',...
     'position',[0.055 0.091 0.235 0.223],'string',{'Top of Voltage band on caps/vregs','Bottom of Voltage band on caps/vregs','Steady-State','Extreme UP-ramping','Extreme DOWN-ramping'},...
     'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);
h.ppm(3) = uicontrol('style','popup','units','normalized',...
     'position',[0.055 0.035 0.235 0.223],'string',{'hold','hold'},...
     'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);

h.ppm(3) = uicontrol('style','popup','units','normalized',...
     'position',[0.351 0.091 0.235 0.223],'string',{'Shelby,NC','Murphy,NC','Taylorsville,NC'},...
     'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);
h.ppm(4) = uicontrol('style','popup','units','normalized',...
    'position',[0.351 0.035 0.235 0.223],'string',{'hold','hold'},...
    'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);
%{
h.ppm(5) = uicontrol('style','popup','units','normalized',...
    'position',[5.8 5.769 54 5.846],'string',{'(1) Day, 10:00 to 16:00','(1) Week, 10:00 to 16:00','(1) Month','(1) Season','(1) Year'},...
    'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12);
h.ppm(6) = uicontrol('style','popup','units','normalized',...
     'position',[69.8 5.769 54 5.846],'string',{'hold','hold'},...
     'backgroundcolor',[0.973 0.973 0.973],'Fontsize',12); 
%%
%Add all radiobutton:
h.rb(1) = uicontrol('style','radiobutton','units','characters','fontsize',10,...
    'position',[9.8 44.615 35.6 1.769],'string','Bellhaven 12-04','backgroundcolor',bk_color);
h.rb(2) = uicontrol('style','radiobutton','units','characters','fontsize',10,...
    'position',[9.8 42.923 35.6 1.769],'string','Commonwealth 12-05','backgroundcolor',bk_color);
h.rb(3) = uicontrol('style','radiobutton','units','characters','fontsize',10,...
    'position',[9.8 41.231 35.6 1.769],'string','Flay 12-01','backgroundcolor',bk_color);
h.rb(4) = uicontrol('style','radiobutton','units','characters','fontsize',10,...
    'position',[9.8 36.769 35.6 1.769],'string','Roxboro','backgroundcolor',bk_color);
h.rb(5) = uicontrol('style','radiobutton','units','characters','fontsize',10,...
    'position',[9.8 35.077 35.6 1.769],'string','HollySprings','backgroundcolor',bk_color);
h.rb(6) = uicontrol('style','radiobutton','units','characters','fontsize',10,...
    'position',[9.8 33.385 35.6 1.769],'string','East Raleigh','backgroundcolor',bk_color);
h.rb(7) = uicontrol('style','radiobutton','units','characters','fontsize',10,...
    'position',[9.8 28.769 35.6 1.769],'string','Circuit #5','backgroundcolor',bk_color);
h.rb(8) = uicontrol('style','radiobutton','units','characters','fontsize',10,...
    'position',[9.8 27.077 35.6 1.769],'string','Circuit #7','backgroundcolor',bk_color);
h.rb(9) = uicontrol('style','radiobutton','units','characters','fontsize',10,...
    'position',[9.8 25.385 35.6 1.769],'string','Circuit #24','backgroundcolor',bk_color);
%%
%Add all checkboxes:
h.ckbx(1) = uicontrol('style','checkbox','units','characters',...
    'position',[3 21.538 58.8 1.615],'string','DER Static Hosting Capacity:',...
    'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
    'Fontsize',12);
h.ckbx(2) = uicontrol('style','checkbox','units','characters',...
     'position',[66 21.538 58.8 1.615],'string','Irradiance & PV Output Analysis:',...
     'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
     'Fontsize',12);
h.ckbx(3) = uicontrol('style','checkbox','units','characters',...
     'position',[3 12.231 58.8 1.615],'string','Timeseries at various durations:',...
     'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
     'Fontsize',12);
h.ckbx(4) = uicontrol('style','checkbox','units','characters',...
     'position',[66 12.231 58.8 1.615],'string','Selective Timeseries Analysis:',...
     'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
     'Fontsize',12);
h.ckbx(5) = uicontrol('style','checkbox','units','characters',...
     'position',[3 6.385 58.8 1.615],'string','(hold)',...
     'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
     'Fontsize',12);
h.ckbx(6) = uicontrol('style','checkbox','units','characters',...
     'position',[66 6.385 58.8 1.615],'string','(hold)',...
     'FontWeight','bold','backgroundcolor',[0.973 0.973 0.973],...
     'Fontsize',12);
%%
%Add all pushbuttons:
h.push(1) = uicontrol('style','pushbutton','units','characters',...
    'position',[102,26.923,17.8 2.769],'string','RUN',...
    'callback',@p_run,'fontsize',16,'ForegroundColor',[0.973 0.973 0.973],...
    'BackgroundColor',[0 1 0],'FontWeight','bold');
h.push(2) = uicontrol('style','pushbutton','units','characters',...
    'position',[102 23.692 17.8 2.769],'string','Cancel',...
    'callback',@p_cancel,'fontsize',16,'ForegroundColor',[0.502 0.502 0.502],...
    'BackgroundColor',[0.941 0.941 0.941]);
h.push(3) = uicontrol('style','pushbutton','units','characters',...
    'position',[49.8 26.923 48.6 2.769],'string','Plot Selected Feeder',...
    'callback',@p_plot,'fontsize',16,'ForegroundColor',[1 1 1],...
    'BackgroundColor',[0.871 0.49 0]);
h.push(4) = uicontrol('style','pushbutton','units','characters',...
    'position',[50 23.692 48.6 2.769],'string','Make Settings Default',...
    'callback',@p_reset,'fontsize',16,'ForegroundColor',[1 1 1],...
    'BackgroundColor',[0.831 0.816 0.784]);
%%
%Add axis plot:
%   the axes for plotting selected plot
hPlotAxes=axes('Parent',h.f,'Units','characters',...
    'HandleVisibility','callback','Position',[49.8 31.93 70 19.308],...
    'YTick',[],'XTick',[]);



%%
%Set Defaults:
    set(h.ckbx(1),'Value',1);%sim choice
    set(h.rb(2),'Value',1);%ckt choice
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
            cat_choice = 2;
        end
        if checked{5} == 1
            s2 = '\HollySprings_Circuit_Opendss\Run_Master_Allocate.dss';
            ckt_num = 4;
            cat_choice = 2;
        end
        if checked{6} == 1
            s2 = '\ERaleigh_Circuit_Opendss\Run_Master_Allocate.dss';
            ckt_num = 5;
            cat_choice = 2;
        end
        if checked{7} == 1
            s2 = '\EPRI_ckt5\Master.dss';
            ckt_num = 6;
            cat_choice = 3;
        end
        if checked{8} == 1
            s2 = '\EPRI_ckt7\Master.dss';
            ckt_num = 7;
            cat_choice = 3;
        end
        if checked{9} == 1
            s2 = '\EPRI_ckt24\Master.dss';
            ckt_num = 8;
            cat_choice = 3;
        end
    end   
    %Lets see what kind of sim they want to do:   
    COUNT_1 = 0;
    section_type = get(h.ckbx(1),'Value');
    
    if section_type == 1
        %DER Static hosting capacity:
        select = get(h.ppm(2),'Value');
        %Check:
        if isempty(select)
            select = 'none';
            msgbox('You did not select the settings for your test. Please use checkboxes to select your test and click Okay.');
        else
        %dropdown menu:
        sim_type = select;
        end
    end
    %Check if multiple selections & then string combine.
    if COUNT > 1
       msgbox('More than 1 feeder was selected.');
    elseif COUNT_1 > 1
        msgbox('More than 1 simulation category selected.');
    else
    STRING = strcat(s1,s2);
    %Save user's selection:
    STRING_0{1,1} = STRING;
    STRING_0{1,2} = ckt_num;
    
    STRING_0{1,3} = sim_type;
    STRING_0{1,4} = s_b;
    STRING_0{1,5} = cat_choice;
    STRING_0{1,6} = section_type;
    
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


