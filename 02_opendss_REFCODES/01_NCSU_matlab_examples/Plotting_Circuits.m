%4.4] Plotting Tutorial:
clear
clc
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%Compile the circuit
%DSSText.command = 'Compile R:\00_CAPER_SYSTEM\05_OpenDSS_Circuits\Roxboro_Circuit_Opendss\Master.DSS'; 
DSSText.command = ['Compile "', gridpvPath,'ExampleCircuit\master_Ckt24.dss"'];
%%
%Plotting Circuits:
DSSText.command = 'Set mode=duty number=10 hour=13 h=1 sec=1800';
DSSText.command = 'Set controlmode = static';
DSSText.command = 'solve';

%3) Setup a pointer of the active circuit:
DSSCircuit = DSSCircObj.ActiveCircuit;
%5) Obtain Component Structs:
Buses = getBusInfo(DSSCircObj);
Loads = getLoadInfo(DSSCircObj);
%%
%{ 
% Add PV in the form of a generator object:
DSSText.command = 'new generator.PV bus1= n292757 phases=3 kv=34.5 kw=500 pf=1 enabled=true';
% Set it as the active element and view its bus information
DSSCircuit.SetActiveElement('generator.pv');

%---------------------------------------------
Iterate PV bus1 location throughout Circuit 24.
i = 3;
while i<length(Buses)
    if Buses(i,1).numPhases == 3
        %Only connect a Central PV station to a 3-phase bus.
        % Now change it to another bus and observe the change
        DSSText.command = sprintf('edit generator.PV bus1=%s kv=13.2',Buses(i,1).name);
        %DSSCommand = sprintf('New Tshape
        DSSCircuit.ActiveElement.BusNames
    end
    i = i + 1;
end
%}
%{
%This is to print the feeder
figure(1);
plotCircuitLines(DSSCircObj,'Coloring','voltage120','Thickness','current','MappingBackground','hybrid');
%}       
        
