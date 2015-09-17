%%*********************************%
%       Active Zone Locator        %
%**********************************%

%This is a script to find the longest distance zone from the substation. It
%will flag the bus, and then iterate to the next longest distance zone from
%the substation. IT WORKS. DO NOT CHANGE ANYTHING.


%Initialize a flag for each zoneList to false and a zoneFlagIndex for the
%activeZone being simulated.
zoneFlags = cell(length(zoneLists), 1);
zoneFlagIndex = 1;

for i = 1:length(zoneFlags)
    zoneFlags{i} = false;
end


%Select a zone from the zoneLists, "activeZone," which will hold the zone
%to be passed to the next zoneComparison script. activeZone will hold the
%value of the substation zone initially, but its final value will be a zone
%with no downstream zones
activeZone = zoneLists{1, 1};

%For each VREG in zoneLists, conpare the buses to the activeZone buses. If
%a VREG is found the activeZone buses, then there is a downstream zone from
%the activeZone. Set the activeZone equal to the downstream zone, and
%continue iterating until you get to the farthest downstream bus.


%DEBUGGING TOOLS***************************
%zoneFlags{3} = true;
%zoneFlags{4} = true;
%zoneFlags{5} = true;
%zoneFlags{6} = true;
%zoneFlags{7} = true;
%******************************************

for i = 1:length(zoneLists)
    %Find the index in zoneFlags that correlates to the zone numbet of the
    %active zone
        comparisonVREG = zoneLists{i, 1}(1);
        for ii = 1:length(activeZone)
        %If the activeZone has a downstream zone and that zone hasn't been 
        %flagged in zoneFlags, change the activeZone to the downstream zone,
        %and set a zoneFlagIndex to equal .
            if strcmp(activeZone{ii}, comparisonVREG) & (zoneFlags{i} == false)
                activeZone = zoneLists{i,1};
                zoneFlagIndex = i;
                break
            end
        end
end

%The next script will compare the take the activeBus and trim its buses
%from all of the other zones in the zoneList, an save them to a seperate
%comparisonList for reference
