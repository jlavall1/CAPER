%%************************%
%   Connected KVA Summer  %
%*************************%

%%This is a script to find the connected KVA downstream of a selected bus
%Wire table
tic
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%Compile the circuit
DSSText.command = 'compile C:\Users\dotso_000\Documents\OpenDSS\Roxboro_Circuit_Opendss\Run_Master_Allocate.DSS';

DSSText.command = 'solve'; 

Lines = getLineInfo(DSSCircObj);
Loads = getLoadInfo(DSSCircObj);
Buses  = getBusInfo(DSSCircObj);
%KVA counter
cumulativeKVA = 0;
%Select the Bus
myBus = Buses(1).name;

downstreamBuses = findDownstreamBuses(DSSCircObj, myBus);

%Loop through all of the transformers in the circuit
for i = 1:length(Loads)
   %Select an active bus
   activeBus =  regexprep({Loads(i).busName},'(\.[0-9]+)','');
   %Loop through all of the downstreambuses
    for ii = 1:length(downstreamBuses)
        if strcmp(downstreamBuses(ii), activeBus)
            cumulativeKVA = cumulativeKVA + Loads(i).xfkVA;
            break
        end
    end
end
toc