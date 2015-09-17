%**********************************************%
%Holly Springs Circuit                         %
%**********************************************%


%Simulation of Holly Springs Circuit. Identify residential and commercial
%nodes



%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%Compile the circuit
DSSText.command = 'compile C:\Users\dotso_000\Documents\OpenDSS\HollySprings_Circuit_Opendss\Run_Master_Allocate.DSS';

DSSText.command = 'solve';

%Setup a pointer fo the active circuit
DSSCircuit = DSSCircObj.ActiveCircuit;

xfmrNames = DSSCircuit.Transformers.AllNames;

%Get line names and set up structure
lineNames = DSSCircuit.Lines.AllNames;

Lines = getLineInfo(DSSCircObj);

Loads = getLoadInfo(DSSCircObj);

Transformers = getTransformerInfo(DSSCircObj);

Classifications = cell(length(Loads), 1);

Buses = getBusInfo(DSSCircObj);

for ii = 1:1:length(Loads)
   if (Loads(ii).xfkVA < 100)
       Classifications{ii} = 'Residential';
   else
       Classifications{ii} = 'Commercial';
   end
end




plotCircuitLinesOptions(DSSCircObj);

