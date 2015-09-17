%**********************************************%
%          Roxboro Circuit         %
%**********************************************%


%Simulation of Holly Springs Circuit. Identify residential and commercial
%nodes



%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%Compile the circuit
DSSText.command = 'compile C:\Users\dotso_000\Documents\OpenDSS\Roxboro_Circuit_Opendss\Run_Master_Allocate.DSS';

DSSText.command = 'solve';

%Setup a pointer fo the active circuit
DSSCircuit = DSSCircObj.ActiveCircuit;

%Get all of the information available from the circuit. Much will be
%trimmed according to the needs of the script

%Get Transformer names
xfmrNames = DSSCircuit.Transformers.AllNames;
%Get line names and set up structure
lineNames = DSSCircuit.Lines.AllNames;
%Get load names
Loads = getLoadInfo(DSSCircObj);
%Get information on Transformers
Transformers = getTransformerInfo(DSSCircObj);
%Get Coordinate information
[busCoordNames, busCoordArray] = getBusCoordinatesArray(DSSCircObj);
%Get Bus information
Buses = getBusInfo(DSSCircObj);
%Get Capacitor Information
Capacitors = getCapacitorInfo(DSSCircObj);
%Get MORE Coordinate information
coordinates = getCoordinates(DSSCircObj);
%Get Information about Generators
Generators = getGeneratorInfo(DSSCircObj);

%The script operation to trace thee circuit begins here

%Selected input bus from the bus array
MYBUS = Buses(2000).name;
%Trace the circuit all the way back to the substation
UpstreamBuses = findUpstreamBuses(DSSCircObj, MYBUS);
%Initialize the cell of pointers to the buses up to the capacitor
UpToCap = cell(length(UpstreamBuses), 1);

%For each bus in UpstreamBuses, record that bus into UpToCap. Then, compare
%the busname to each of the Capacitor busnames. If a busname in
%UpstreamBuses matches a busname in Capacitors, end the loop.
for i = 1:1:length(UpstreamBuses)
      %Copy the bus information to UpToCap
      UpToCap(i) = UpstreamBuses(i);
      %Compare The busname of the Upstream bus to all of the capacitor
      %busnames
        for ii = 1:1:length(Capacitors)
            
            Capacitor_bus = Capacitors(ii).busName;
            Comparison_bus = UpstreamBuses(i);
            
            if strcmp(Capacitor_bus, Comparison_bus)
                %Debug tool
                Mission = 'success!';
                %The
                Last_bus = Capacitor_bus;
                
                break
            end
        end
        
        if strcmp(Capacitor_bus, Comparison_bus)
                Mission = 'success!';
                break
        end
end