%This is the header file for either Post_Process or Post_Process_2:
clear
clc
close all
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis')
%User Menus:

plot_type1=menu('For What?','Individual Runs','Chapter 3');
while plot_type1<1
    plot_type1=menumenu('For What?','Individual Runs','Chapter 3');
end

if plot_type1 == 1
    %Individuals
    ckt_num=menu('Which Circuit?','1)Bellhaven','2)Commonwealth','3)Flay','4)Roxboro','5)Hollysprings','6)E.Raleigh','7)EPRI 7','8)ALLLLLL');
    while ckt_num<1
        ckt_num=menu('Which Circuit?','1)Bellhaven','2)Commonwealth','3)Flay','4)Roxboro','5)Hollysprings','6)E.Raleigh','7)EPRI 7','8)ALLLLLL');
    end
    
    plot_type=menu('What kind of plot?','Quartiles','Violation Percentages','Color Display of all Data','max PV vs. Rsc (Location)');
    while plot_type<1
        plot_type=menu('What kind of plot?','Quartiles','Violation Percentages','Color Display of all Data','max PV vs. Rsc (Location)');
    end
    if plot_type < 4
        sim_type=menu('Load Level:','summer-2s','winter-2s','summer','winter','ALL');
        while sim_type<1
            sim_type=menu('Load Level:','summer-2s','winter-2s','summer','winter','ALL');
        end
    else
        sim_type=1;
    end
    
    if plot_type < 3
        Post_Process_DATA       %Loads in result files
        Post_Process            %Figures 3 -> 5
    elseif plot_type < 5
       Post_Process_DATA        %Loads in result files
       Post_Process_2           %Figure 9
    end
elseif plot_type1 == 2
    %Thesis Report
    Post_Process_3              %Figure
end
   