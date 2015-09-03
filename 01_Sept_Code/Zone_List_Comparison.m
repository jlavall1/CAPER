%Compare all of the lists to the active list, which has all of its own
%bus in its zone and none from any other zone

%Debugging list
comparisonLists = zoneLists;

%Set the active zone equal to the farthest zone from the substation that
%hasn't been analysed yet
activeList = zoneLists{length(zoneLists)};

zoneFlags = cell(length(zoneLists), 1);
for i = 1:length(zoneFlags)
   zoneFlags{i} = false;
end


%Iterate through all of the zone lists
for i = 1:length(comparisonLists)
    comparisonList = comparisonLists{i,1};
    %If the zone has not been simulated, compare all of the buses in the current zone to all of the buses in
    %the active zone
    
    if zoneFlags{i} == false
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
            comparisonLists{i, 1} = comparisonList;
        end
    end
    zoneFlags{i} = true;
end
%End of zone list comparison

















