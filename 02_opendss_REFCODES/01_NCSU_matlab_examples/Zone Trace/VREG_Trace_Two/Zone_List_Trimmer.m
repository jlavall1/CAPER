%%*******************************%
%          List Trimmer          %
%********************************%

%This script will take the activeList from the
%"NEW_Active_List_Prototype.m"
%script, trim any other zones of the buses that it shares with the
%activeList. It will also set the zoneFlags{zoneFlagIndex} of the
%activeList to true, so that the same operation is not carried out on the
%same activeZone twice.

%Initialize a comparisonList to hold all of the finished zones. DO NOT PUT
%THIS IN A LOOP. IT WILL RE-INITIALIZE EVERY TIME, AND PRODUCE NO END
%RESULT!!!!!
%comparisonLists = zoneLists;

%Loop to remove the buses from the activeZone from each list. If the
%activeList is being compared to itself, skip that iteration.
%

for i = 1:length(comparisonLists)
    %If the activeList is being compared to itself, or if the activeList is 
    %being compared to a list that has already been trimmed of its 
    %downstreamBuses, the index i should be equal to the zoneFlagIndex, or 
    %the index i should be equal to a list that has been flagged in 
    %zoneFlags. Skip the iteration
    if (i ~= zoneFlagIndex) & (zoneFlags{i,1} == false)
        %Initialize a comparisonList to hold the value in comparisonLists
        comparisonList = comparisonLists{i,1};
        for ii = 1:length(comparisonLists{i,1}) 
            for iii = 1:length(activeZone)
                %Compare the indexed activeZone bus with the indexed
                %comparisonList bus. If the two are equal, remove the entry
                %in comparisonLists
                if strcmp(activeZone{iii},comparisonLists{i,1}(ii))
                    comparisonList(ii) = {0};
                end
                
            end
        end
        %Remove the empty cells from the comparisonLists
        %find empty cells
        emptyCells = cellfun(@(x) isequal(0,x), comparisonList);
        %remove empty cells
        comparisonList(emptyCells) = [];
        %Save the comparisonList back into the comparisonLists
        comparisonLists{i, 1} = comparisonList;
    end
end


zoneFlags{zoneFlagIndex} = true;





%Remove the empty zones from comparisonLists
%find empty cells
emptyCells = cellfun(@isempty, comparisonLists);
%remove empty cells
comparisonLists(emptyCells) = [];