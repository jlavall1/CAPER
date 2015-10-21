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

