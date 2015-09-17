%********************************
%DSS Circuit Trace
%Script to trace a circuit back to the nearest Voltage regulator
%********************************

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
%xfmrNames = DSSCircuit.Transformers.AllNames;
%lineNames = DSSCircuit.Lines.AllNames;
%loadNames = DSSCircuit.Loads.AllNames;
%busNames = DSSCircuit.Buses.AllNames;
%5) Obtain Component Structs:
%Capacitors = getCapacitorInfo(DSSCircObj);
%Loads = getLoadInfo(DSSCircObj);
Buses = getBusInfo(DSSCircObj);
Transformers = getTransformerInfo(DSSCircObj);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


MYBUS = Buses(2000).name;

UpstreamBuses = findUpstreamBuses(DSSCircObj, MYBUS);

BusesToVREG = cell(length(UpstreamBuses), 2);

%Debug
Deb=0;

%iterate through all of the upstream buses
for ii =1:1:(length(UpstreamBuses))
    
    %Compare all of the bus names with the names of the buses connected to
    %transformers
    BusesToVREG(ii)=UpstreamBuses(ii);
   for iii=1:1:length(Transformers)
        %If the bus has a transformer, confirm that that transformer is
                %a voltage regulator
                UpstreamBus = UpstreamBuses(ii);
                Transformer_busone = Transformers(iii).bus1;
                Transformer_bustwo = Transformers(iii).bus2;
                
                %Cutting the subscripts out of the transformer bus names
                %Note: regexprep(str,expression,replace) = replaces the
                %text in str that matches expression w/ the text described
                %by replace.
                Transformer_busone = regexprep({Transformer_busone},'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
                Transformer_bustwo = regexprep({Transformer_bustwo},'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
                
                %Getting these values for later comparison. If the two
                %windings have an equal base voltage, then the transformer
                %is a voltage regulator.
                Transformer_busonebase = Transformers(iii).bus1kVBase;
                Transformer_bustwobase = Transformers(iii).bus2kVBase;
        if (strcmp(UpstreamBus,Transformer_busone)) || (strcmp(UpstreamBus,Transformer_bustwo))
            %If the transformer is a voltage regulator, end the iiteration
           
            if isequal(Transformer_busonebase, Transformer_bustwobase)
                break
                   
            end 
            
        end
        %End of nested loop
   end
   if (strcmp(UpstreamBus,Transformer_busone)) || (strcmp(UpstreamBus,Transformer_bustwo))
            %If the transformer is a voltage regulator, end the iiteration
            if isequal(Transformer_busonebase, Transformer_bustwobase)
                
                   break
            end 
            
   end
end  
   