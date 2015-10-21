%********************************%
%   Voltage Control Zone Trace   %
%********************************%

%This is a script to identify all of the voltage control zones on an
%OpenDSS feeder. It will do so by identifying nodes with VREGs on them and
%dividing the circuit at these nodes. The trace will begin at the
%substation, and create a list of VREGs with their downstreambuses

%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%Compile the circuit
DSSText.command = 'compile C:\Users\dotso_000\Documents\OpenDSS\Roxboro_Circuit_Opendss\Run_Master_Allocate.DSS';

DSSText.command = 'solve';

%Setup a pointer fo the active circuit
DSSCircuit = DSSCircObj.ActiveCircuit;

%Get downstream bus information + transformer data
Buses = getBusInfo(DSSCircObj);
downstreamBuses = findDownstreamBuses(DSSCircObj, Buses(1).name);
Transformers = getTransformerInfo(DSSCircObj);

%Initialize a list of voltage regulators
VREG = cell(length(Transformers), 1);

%Identify buses with VREGs on them
for i = 1:1:length(Transformers)
    %Initialize a cell to hold the current transformer information
    activeTransformer = Transformers(i);
    activeTransformerBusOne = regexprep({activeTransformer.bus1},'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
    activeTransformerBusOne = char(activeTransformerBusOne);
    
    %If the transformer is a voltage regulator, see if the VREG is already
    %listed in the VREG array
    if isequal(activeTransformer.bus1kVBase, activeTransformer.bus2kVBase)
        
        %Iterate through the list of VREGS. If the VREG is already in the
        %list, set a flag to false and break the iterations. Otherwise, set
        %it to true
        for ii= 1:1:length(VREG)
            if strcmp(VREG{ii}, activeTransformerBusOne)
                 %Initialize a flag to identify the VREG as already listed
                 VREG_Flag = false;
                break
            else
                %Initialize the flag to identify the VREG as not listed
                VREG_Flag = true;
            end
        end    
        if VREG_Flag
            %Insert the bus name into the VREG list
            VREG{i} = activeTransformerBusOne;
        end
    end
end
%Trim empty cells from VREG structure
%find empty cells
emptyCells = cellfun(@isempty, VREG);
%remove empty cells
VREG(emptyCells) = [];

%Allocate the space required for each voltage regulator to hold its
%downstream buses
zoneLists = cell(length(VREG)+1, 1);

%Since the first zone starts at the substation, create the list outside of
%the loop
zoneLists{1} = findDownstreamBuses(DSSCircObj, Buses(1).name);

%Find the downstream buses of each voltage regulator
for i=1:1:length(VREG)
    VREG{i} = char(VREG{i});
    zoneLists{i+1} = findDownstreamBuses(DSSCircObj, VREG{i});
end

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

%Initialize a comparisonList to hold all of the finished zones. DO NOT PUT
%THIS IN A LOOP. IT WILL RE-INITIALIZE EVERY TIME, AND PRODUCE NO END
%RESULT!!!!!
comparisonLists = zoneLists;


for ij = 1:length(zoneLists)
    


    %Select a zone from the zoneLists, "activeZone," which will hold the zone
    %to be passed to the next zoneComparison script. activeZone will hold the
    %value of the substation zone initially, but its final value will be a zone
    %with no downstream zones
    activeZone = zoneLists{1, 1};
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
end




%Remove the empty zones from comparisonLists
%find empty cells
emptyCells = cellfun(@isempty, comparisonLists);
%remove empty cells
comparisonLists(emptyCells) = [];
