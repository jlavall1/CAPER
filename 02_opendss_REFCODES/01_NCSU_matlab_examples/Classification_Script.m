%**********************************************%
%          Roxboro Circuit         %
%**********************************************%
%Simulation of Roxboro Circuit. 
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%Compile the circuit
DSSText.command = 'compile C:\Users\jlavall\Documents\00_CAPER_SYSTEM\05_OpenDSS_Circuits\Roxboro_Circuit_Opendss\Run_Master_Allocate.DSS';
DSSText.command = 'solve';

%Setup a pointer of the active circuit:
DSSCircuit = DSSCircObj.ActiveCircuit;
xfmrNames = DSSCircuit.Transformers.AllNames;
Capacitors = getCapacitorInfo(DSSCircObj);
Loads = getLoadInfo(DSSCircObj);
%Get line names:
lineNames = DSSCircuit.Lines.AllNames;

%%
%Additional Work:
Classifications = cell(length(Loads), 2);


for ii = 1:1:length(Loads)
   Transfer_Bus = Loads(ii).busName;
   Classifications{ii, 2} = Transfer_Bus;
   
   %Sorting:
   if (Loads(ii).xfkVA < 100)
       Classifications{ii} = 'Residential';
   else
       Classifications{ii} = 'Commercial';
   end
end




%plotCircuitLines(DSSCircObj);

