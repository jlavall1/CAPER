% Brian was here yay
%When prompt comes up, enter in full file path to Run_Master_Allocate file
% The string entered for the prompt is usually the path and file for
% Run_Master_allocate.dss for the given circuit. 
% You may need to update the path reference in the Run_Master_allocate.dss
% file too.
prompt = 'Enter file path: ';
str = input(prompt,'s');

% 1. Start the OpenDSS COM. Needs to be done each time MATLAB is opened     
[DSSCircObj, DSSText, gridpvPath] = DSSStartup; 

% 2. Compiling the circuit     
DSSText.command = ['Compile ' str]; 

% 3. Solve the circuit. Call anytime you want the circuit to resolve     
DSSText.command = 'solve'; 

% 4. Run circuitCheck function to double-check for any errors in the circuit before using the toolbox     
warnSt = circuitCheck(DSSCircObj);

DSSCircuit=DSSCircObj.ActiveCircuit;

%Get total 3 phase miles
Lines=getLineInfo(DSSCircObj);
ThreePhaseLines=Lines([Lines.numPhases]==3);
Lengths=vertcat(ThreePhaseLines.length);
Total3Phase=sum(Lengths);
Miles3Phase=Total3Phase*0.000621371;
clear Lengths

%Get total 1 & 2 phase miles
NonThreePhaseLines=Lines([Lines.numPhases]~=3);
Lengths=vertcat(NonThreePhaseLines.length);
TotalNon3Phase =sum(Lengths);
MilesNon3Phase =TotalNon3Phase*0.000621371;
clear Lengths

%Get feeder regulation counts
XfmrInfo=getTransformerInfo(DSSCircObj);
XfmrNames=DSSCircuit.Transformers.AllNames;
XfmrCount=DSSCircuit.Transformers.Count;
Substations=XfmrInfo([XfmrInfo.bus1Distance]==0);
SubstationCount=length(Substations);
SubstationNames=cell(SubstationCount,1);

%Substations
for i = 1:SubstationCount
    holder=char(Substations(i).name);
    SubstationNames(i)={holder(1:end-1)};
end
UniqueSubstations=unique(SubstationNames);
NumberSubstations=length(UniqueSubstations);

%Regulators
for i = 1:XfmrCount
    holder = char(XfmrNames(i)); 
    XfmrNames(i) = {holder(1:end-1)};
end
UniqueXfmrNames=unique(XfmrNames);
NumberXfmrs=length(UniqueXfmrNames)-NumberSubstations;

%Capacitors
CapInfo=getCapacitorInfo(DSSCircObj);
FixedCaps=CapInfo([CapInfo.switching]==0);
SwitchCaps=CapInfo([CapInfo.switching]~=0);
NumberFixedCaps=length(FixedCaps);
NumberSwitchCaps=length(SwitchCaps);

%Get number of customers
LoadInfo=getLoadInfo(DSSCircObj);
Customers=vertcat(LoadInfo.numCust);
numCustomers=sum(Customers);

%Get feeder voltage
SubVoltages=vertcat(Substations.bus1kV);
SubVoltages=unique(SubVoltages);
FeederVoltage=zeros(length(SubVoltages),1);
for i=1:length(SubVoltages)
    FeederVoltage(i)=round(sqrt(3)*SubVoltages(i));
end

%Get peak load
kWs=sum(vertcat(LoadInfo.kW));
kVARs=sum(vertcat(LoadInfo.kvar));
PeakLoad=sqrt((kWs^2)+(kVARs^2))/1000;

%Get longest distance to node
[dist, toBus] = findLongestDistanceBus(DSSCircObj, 'perPhase');
LongestDistance=max(dist);

sprintf('Feeder Voltage: %d kV \nPeak Load: %.2f MVA \nTotal 3 Phase Miles: %.2f \nTotal 1-2 Phase Miles: %.2f \nLongest Distance: %.2f \nFeeder Regulation  \n     Substation LTC: %d  \n     Feeder Regulators: %d  \n     Fixed Capacitors: %d  \n     Switched Capacitors: %d \nTotal # of Customers: %d',FeederVoltage,PeakLoad,Miles3Phase,MilesNon3Phase,LongestDistance,NumberSubstations,NumberXfmrs,NumberFixedCaps,NumberSwitchCaps,numCustomers)