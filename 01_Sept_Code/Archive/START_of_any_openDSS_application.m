%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START OF ANY openDSS Circuit Analysis:
%(Comment out any COM interactions that are not needed)

%1) Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%2) Compile the Circuit:
DSSText.command = 'compile C:\Users\jlavall\Documents\00_CAPER_SYSTEM\05_OpenDSS_Circuits\Roxboro_Circuit_Opendss\Run_Master_Allocate.DSS';
DSSText.command = 'solve';

%3) Setup a pointer of the active circuit:
DSSCircuit = DSSCircObj.ActiveCircuit;

%4) Obtain Component Names:
xfmrNames = DSSCircuit.Transformers.AllNames;
lineNames = DSSCircuit.Lines.AllNames;
loadNames = DSSCircuit.Loads.AllNames;
busNames = DSSCircuit.Buses.AllNames;
%5) Obtain Component Structs:
Capacitors = getCapacitorInfo(DSSCircObj);
Loads = getLoadInfo(DSSCircObj);
Buses = getBusInfo(DSSCircObj);
Transformers = getTransformerInfo(DSSCircObj);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start of personalize algorithm.