function STRING_0 = GUI_openDSS_Locations()

UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);
%This function will prompt the user where they are working.

comp_choice=menu('What Location are you working from?','JML Home Desktop','JML Laptop','Brians Laptop','RTPIS_7','RTPIS_9');
%set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);
while comp_choice<1
    comp_choice=menu('What Location are you working from?','JML Home Desktop','JML Laptop','Brians Laptop','RTPIS_7','RTPIS_9');
    %set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);
end

cat_choice=menu('What Category of circuit are you working on?','DEC','DEP','EPRI','IEEE','other');
%set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);
while cat_choice<1
    cat_choice=menu('What Category of circuit are you working on?','DEC','DEP','EPRI','IEEE','other');
end





%scen_cat=menu

%%
% -- Now respond to user info --
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

%Now add the specific circuit:
    
    
if cat_choice==1
    %DEC Circuits:
    ckt_choice=menu('Name of Circuit:','Bellhaven 12-04','Commonwealth 12-05','Flay 12-01');
    while ckt_choice<1
        ckt_choice=menu('Name of Circuit:','Bellhaven 12-04','Commonwealth 12-05','Flay 12-01');
    end
    if ckt_choice == 1
        s2 = '\Bellhaven_Circuit_Opendss\';
        ckt_num = 0;
    elseif ckt_choice == 2
        s2 = '\Commonwealth_Circuit_Opendss\Run_Master_Allocate.dss';
        ckt_num = 1;
    elseif ckt_choice == 3
        s2 = '\Flay_Circuit_Opendss\';
        ckt_num = 2;
    end
    STRING = strcat(s1,s2);
elseif cat_choice==2
    %DEP Circuit:
    ckt_choice=menu('Name of Circuit:','Roxboro','HollySprings','ERaleigh');
    while ckt_choice<1
        ckt_choice=menu('Name of Circuit:','Roxboro','HollySprings','ERaleigh');
    end
    if ckt_choice == 1
        s2 = '\Roxboro_Circuit_Opendss\Run_Master_Allocate.dss';
        ckt_num = 3;
    elseif ckt_choice == 2
        s2 = '\HollySprings_Circuit_Opendss\';
        ckt_num = 4;
    elseif ckt_choice == 3
        s2 = '\ERaleigh_Circuit_Opendss\';
        ckt_num = 5;
    end
    STRING = strcat(s1,s2);
elseif cat_choice==3
    %EPRI Circuit:
    ckt_choice=menu('Name of Circuit:','ckt5','ckt7','ckt24');
    while ckt_choice<1
        ckt_choice=menu('Name of Circuit:','ckt5','ckt7','ckt24');
    end
    if ckt_choice == 1
        s2 = '\EPRI_ckt5\Master.dss';
        ckt_num = 6;
    elseif ckt_choice == 2
        s2 = '\EPRI_ckt7\Master.dss';
        ckt_num = 7;
    elseif ckt_choice == 3
        s2 = '\EPRI_ckt24\Master.dss';
        ckt_num = 8;
    end
    STRING = strcat(s1,s2);
elseif cat_choice==4
    %IEEE Circuit:
    ckt_choice=menu('Name of Circuit:','123Bus','8500-Node');
    while ckt_choice<1
        ckt_choice=menu('Name of Circuit:','123Bus','8500-Node');
    end
    if ckt_choice == 1
        s2 = '\123Bus\';
        ckt_num = 9;
    elseif ckt_choice == 2
        s2 = '\8500-Node\';
        ckt_num = 10;
    end
    STRING = strcat(s1,s2);
elseif cat_choice==5
    %other:
end

%Now lets ask about what kind of simulation they want to run:
%{
sim_cat=menu('Scenerio:','VREG_DEVICES','Ramping Factors');
%set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);
while sim_cat<1
    sim_cat=menu('Scenerio:','VREG_DEVICES','Ramping Factors');
    %set(0, 'DefaultUIControlFontSize', UIControl_FontSize_bak);
end
%}
sim_type=menu('Specifics:','1]TOP of acceptable Vband','2]BOT of acceptable Vband','3]Steady State','4]pv UP ramping','5]pv DOWN ramping');
while sim_type<1
    sim_type=menu('Specifics:','1]TOP of acceptable Vband','2]BOT of acceptable Vband','3]Steady State','4]pv UP ramping','5]pv DOWN ramping');
end

    %{
    if sim_type == 1
        scenerio = 1;
    elseif sim_type == 2
        scenerio = 2;
    elseif sim_type == 3
        scenerio = 3;
    elseif sim_type == 4
        scenerio = 4;
    elseif sim_type == 5
        scenerio = 5;
    end
    %}










    %STRING_0 = cell{1,2};
    STRING_0{1,1} = STRING;
    STRING_0{1,2} = ckt_num;
    STRING_0{1,3} = sim_type;
    STRING_0{1,4} = s_b;

end
    