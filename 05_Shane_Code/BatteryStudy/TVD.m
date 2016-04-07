function ret = TVD(DSSCircObj,BusIDs)
% TVD calculates the Voltage Deviation Index for the circuit defined by
%  DSSCircObj. Optionally, the Buses to be included in the calculation can
%  be defined by Buses. Any non-3 phase buses in Buses will be ignored. If
%  there is no Buses defined, the default is to include all 3 phase buses.

% Define DSS Variables
DSSCircuit = DSSCircObj.ActiveCircuit;
DSSText = DSSCircObj.Text;

if nargin < 2
    % Default to all 3 phase Buses
    BusIDs = DSSCircuit.AllBusNames;
end


Buses = struct('ID',BusIDs);
rmv = [];
for i = 1:length(Buses)
    DSSCircuit.SetActiveBus(Buses(i).ID);
    if DSSCircuit.ActiveBus.NumNodes==3
        Voltages = DSSCircuit.ActiveBus.VmagAng;
        Buses(i).Va = Voltages(1);
        Buses(i).Vb = Voltages(3);
        Buses(i).Vc = Voltages(5);
    else
        rmv = [rmv,i]; % Remove all non-3phase Buses
    end
end
Buses(rmv) = [];
