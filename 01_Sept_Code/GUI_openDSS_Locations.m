function STRING = GUI_openDSS_Locations()


%This function will prompt the user where they are working.

comp_choice=menu('What Location are you working from?','JML Home Desktop','JML Laptop','Brians Laptop','RTPIS_7','RTPIS_9');

while comp_choice<1
    comp_choice=menu('What Location are you working from?','JML Home Desktop','JML Laptop','Brians Laptop','RTPIS_7','RTPIS_9');
end

cat_choice=menu('What Category of circuit are you working on?','DEC','DEP','EPRI','IEEE','other');
while cat_choice<1
    cat_choice=menu('What Category of circuit are you working on?','DEC','DEP','EPRI','IEEE','other');
end



%Update main directory to folder w/ circuits:
if comp_choice==1
    %JML Home Desktop
    s1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
elseif comp_choice==2
    %JML Laptop
    s1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
elseif comp_choice==3
    %Brians Comp
    s1 = 'C:\Users\Brian\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
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
    elseif ckt_choice == 2
        s2 = '\Commonwealth_Circuit_Opendss\';
    elseif ckt_choice == 3
        s2 = '\Flay_Circuit_Opendss\';
    end
    STRING = strcat(s1,s2);
elseif cat_choice==2
    %DEP Circuit:
    ckt_choice=menu('Name of Circuit:','Roxboro','HollySprings','ERaleigh');
    while ckt_choice<1
        ckt_choice=menu('Name of Circuit:','Roxboro','HollySprings','ERaleigh');
    end
    if ckt_choice == 1
        s2 = '\Roxboro_Circuit_Opendss\';
    elseif ckt_choice == 2
        s2 = '\HollySprings_Circuit_Opendss\';
    elseif ckt_choice == 3
        s2 = '\ERaleigh_Circuit_Opendss\';
    end
    STRING = strcat(s1,s2);
elseif cat_choice==3
    %EPRI Circuit:
    ckt_choice=menu('Name of Circuit:','ckt5','ckt7','ckt24');
    while ckt_choice<1
        ckt_choice=menu('Name of Circuit:','ckt5','ckt7','ckt24');
    end
    if ckt_choice == 1
        s2 = '\EPRI_ckt5\';
    elseif ckt_choice == 2
        s2 = '\EPRI_ckt7\';
    elseif ckt_choice == 3
        s2 = '\EPRI_ckt24\';
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
    elseif ckt_choice == 2
        s2 = '\8500-Node\';
    end
    STRING = strcat(s1,s2);
elseif cat_choice==5
    %other:
end


end
    