%Now that a list of all buses downstream of the regulators has been made, 
%it is necessary to truncate the list of buses from each VREG so that the 
%bus lists don't overlap. 

%Starting at the end of the circuit, do an upstream trace to find the VREG
%farthest out from the substation

%Initialize a proxy zone list
comparisonLists = zoneLists;

%Initialize flag array to false to identify zones that have been simulated
zoneFlags = cell(length(comparisonLists), 2);

for i = 1:length(zoneFlags)
   zoneFlags{i,1} = false;
end

%Initialize a debugging counter 
deb = 0;

%Initialize a flag to signal when the iterations may stop
loopFlag = false;

for i = 1:length(comparisonLists)
    %Find the farthest zone from the substation that has not yet been
    %simulated
    aList = comparisonLists(1);
    activeList = aList{1,1};
    
    %Compare all buses in the active zoneList to all of the VREG names. If one is
    %found, stop looking for additional buses and switch zone lists.
    for ii = 1:length(activeList)
        %Search the other zoneLists for buses 
        for iii = 1:length(comparisonLists)
            activeZoneList = comparisonLists{iii, 1};
            
            if strcmp(char(activeList{ii}), char(activeZoneList{iii})) & (zoneFlags{iii} == false)
                break
            end
        end
        if strcmp(char(activeList{ii}), char(activeZoneList{iii})) & (zoneFlags{iii} == false)                
                aList = comparisonLists(iii);
                activeList = aList{1, 1};
            break
        end
    end
    %End of active list location script
    deb = deb+1;
    
    %Set the indexed zoneFlag to true
    zoneFlags{iii, 1} = true;
    zoneFlags{iii, 2} = deb;
    %Initialize a counter to show how which zones have been listed
    loopCounter = 0;
    
    %Compare all of the lists to the active list, which has all of its own
    %buses in its zone and none from any other zone


    %Set the active zone equal to the farthest zone from the substation that
    %hasn't been analysed yet


    %Iterate through all of the zone lists
    for iiii = 1:length(comparisonLists)
        comparisonList = comparisonLists{iiii,1};
        %If the zone has not been simulated, compare all of the buses in the current zone to all of the buses in
        %the active zone
        if zoneFlags{iiii} == false  
            %If the active list and the compared list are the same list, then
            %do not compare them
            if not(strcmp(activeList{1}, comparisonList{1})) 
                for ii = 1:length(activeList)
                    %If the activeList reaches a VREG, break the iterations
                    if strcmp(comparisonList{1}, activeList{ii})
                        break
                    end
                        for iii = 1:length(comparisonList)
                            if strcmp(activeList{ii}, comparisonList{iii})
                                comparisonList{iii} = [];
                            end   
                        end
                end
                %find empty cells
                emptyCells = cellfun(@isempty, comparisonList);
                %remove empty cells
                comparisonList(emptyCells) = [];
                comparisonLists{iiii, 1} = comparisonList;
            end
        end
    end
    %End of zone list comparison
    
    %This loop will determine when the while loop will end
    for ii = 1:length(zoneFlags)
        %Iterate the counter for every zone that has been listed
        if zoneFlags{ii} == true
            loopCounter=loopCounter+1;
        end
        %If the value in loopCounter is equal to the number of zoneLists,
        %then all lists have been identified. Set loopFlag to false to end
        %the script
        if loopCounter == length(zoneFlags)
            loopFlag = true;
            break
        end
    end
end
    
    
