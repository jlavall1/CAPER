%Initialize a list to hold all the counts for the number of buses between
%the voltage regulator and the substation
zoneSize = cell(length(VREG), 1);


%Find the downstream buses of each voltage regulator
for i=1:1:length(VREG)
    
    
    %Find the first VREG bus
    for ii=1:1:length(downstreamBuses)
        if strcmp(downstreamBuses{ii}, VREG{i})
            firstBus = downstreamBuses{ii};
            index = ii;
            break
        end
    end
    
    %Determine the size of the zone
    zoneSize{i, 1} = length(downstreamBuses) - length(downstreamBuses(1:index));
    

end