%********************************%
%Monte Carlo Prototype           %
%********************************%

%This  script is meantto find a hosting capacity through through iterative
%Monte Carlo Simulation.

%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%Compile the circuit
DSSText.command = 'compile C:\Users\dotso_000\Documents\OpenDSS\HollySprings_Circuit_Opendss\Run_Master_Allocate.DSS';

%Setup a pointer fo the active circuit
DSSCircuit = DSSCircObj.ActiveCircuit;

%Bus Information
Buses = getBusInfo(DSSCircObj);

%Monte Carlo method************************
%   1. Start with an initial size of PV
%   2. Run at different circuit locations using Monte Carlo
%   3. Check for violations
%   4. Increase size of PV and iterate

%Initialize PV Size

PV_kW = 1;
%For all buses
for i=1:length(Buses);
    
    %Generate a random number between 0 and 1
    Monte_Carlo_Random = rand;
    if (Monte_Carlo_Random >0.5)
    
        %Preparing all data to be entered into OpenDSS Command
        Active_Bus = Buses(i);
        Active_Bus_phases = num2str(Active_Bus.numPhases);
        Active_Bus_voltage = num2str(Active_Bus.kVBase);
        Active_Bus_kw = num2str(PV_kW);
    

        %Preparing the DSS Command
        DSS_Command = sprintf('new generator.PV bus1=%s phases=%s kv=%s kw=%s pf=1 enabled=true', Active_Bus.name, Active_Bus_phases, Active_Bus_voltage, Active_Bus_kw);
   
        % Add PV in the form of a generator object
        DSSText.command = DSS_Command;
    end
end
DSSText.command = 'solve';    
