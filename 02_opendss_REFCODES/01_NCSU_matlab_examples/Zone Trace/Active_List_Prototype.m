%Now that a list of all buses downstream of the regulators has been made, 
%it is necessary to truncate the list of buses from each VREG so that the 
%bus lists don't overlap. 

%Starting at the end of the circuit, do an upstream trace to find the VREG
%farthest out from the substation

%Initialize flag array to false to identify zones that have been simulated
zoneFlags = cell(length(zoneLists), 2);
for i = 1:length(zoneFlags)
   zoneFlags{i} = false;
end

%Initialize a debugging counter
deb = 0;


%Initialize a flag to signal when the iterations may stop
loopFlag = false;

zoneIndex = 1;
while loopFlag == false
        activeList = zoneLists{1,1}(1);
        activeZoneList = zoneLists{zoneIndex, 1};
    
        %Compare all buses in the zoneList to all of the VREG names. If one is
        %found, stop looking for additional buses and switch VREGS.
        for ii = 1:length(activeList)
            for iii = 1:length(activeZoneList)
                for iiii = 1:length(activeZoneList{iii})
                    if strcmp(char(activeList{ii}), char(activeZoneList{iii}(iiii))) & (zoneFlags{zoneIndex} == false)
                        activeList = zoneLists(iii);
                        break
                    end
                end
                if strcmp(char(activeList{ii}), char(activeZoneList{iii}(iiii))) & (zoneFlags{zoneIndex} == false);
                        break
                end
            end
            if strcmp(char(activeList{ii}), char(activeZoneList{iii}(iiii))) & (zoneFlags{i} == false);
                   break
            end
        end
        deb = deb + 1;
        
        %Set the indexed zoneFlag to true
        zoneFlags{iii,1} = true;
        %Loop to find which order the active list has been listed
        for i=1:length(zoneLists)
            if strcmp(zoneLists{i}(1), activeList{1,1}(1))
                zoneFlags{i, 2} = deb;
                break
            end
        
        
        end
        
    %Initialize a counter to show how which zones have been listed
    loopCounter = 0;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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
    
    
