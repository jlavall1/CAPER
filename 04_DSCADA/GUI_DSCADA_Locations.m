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

%DEC Circuits:
ckt_choice=menu('Name of Circuit:','Bellhaven 12-04','Commonwealth 12-05','Flay 12-01','Roxboro','HollySprings','ERaleigh');
while ckt_choice<1
    ckt_choice=menu('Name of Circuit:','Bellhaven 12-04','Commonwealth 12-05','Flay 12-01','Roxboro','HollySprings','ERaleigh');
end
if ckt_choice == 1
    s2 = '\Bellhaven_Circuit_Opendss\Run_Master_Allocate.dss';
    ckt_num = 0;
elseif ckt_choice == 2
    s2 = '\Commonwealth_Circuit_Opendss\Run_Master_Allocate.dss';
    ckt_num = 1;
elseif ckt_choice == 3
    s2 = '\Flay_Circuit_Opendss\Run_Master_Allocate.dss';
    ckt_num = 2;
elseif ckt_choice == 4
    s2 = '\Roxboro_Circuit_Opendss\Run_Master_Allocate.dss';
    ckt_num = 3;
elseif ckt_choice == 5
    s2 = '\HollySprings_Circuit_Opendss\Run_Master_Allocate.dss';
    ckt_num = 4;
elseif ckt_choice == 6
    s2 = '\ERaleigh_Circuit_Opendss\Run_Master_Allocate.dss';
    ckt_num = 5;
end
%What action would you like to do?
action=menu('What would you like to do with DSCADA data?','Create struct','Timestamp CHECK','Filter & plot/export/save','ALL (3)');
while action<1
    action=menu('What would you like to do with DSCADA data?','Create struct','filter with plot','export/save','ALL (3)');
end


STRING = strcat(s1,s2);
%output user results:
STRING_0{1,1} = STRING;
STRING_0{1,2} = ckt_num;
STRING_0{1,3} = action;%1=create struct 2=filter 3=export/save 4=all
STRING_0{1,4} = s_b;

end
    