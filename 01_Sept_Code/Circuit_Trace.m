%********************************
%DSS Circuit Trace
%Script to trace a circuit back to the nearest Voltage regulator
%********************************

%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%Compile the circuit
DSSText.command = 'compile C:\Users\dotso_000\Documents\OpenDSS\Roxboro_Circuit_Opendss\Run_Master_Allocate.DSS';

DSSText.command = 'solve';

%Setup a pointer fo the active circuit
DSSCircuit = DSSCircObj.ActiveCircuit;

%The trace creates a data structure with the fields of all connected buses,
%and lines until the it reaches a bus with a Voltage Regulator. 

Buses = getBusInfo(DSSCircObj);

Transformers = getTransformerInfo(DSSCircObj);


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
                Transformer_busone = regexprep({Transformer_busone},'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
                Transformer_bustwo = regexprep({Transformer_bustwo},'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
                
                %Getting these values for later
                Transformer_busonebase = Transformers(iii).bus1kVBase;
                Transformer_bustwobase = Transformers(iii).bus2kVBase;
        if (strcmp(UpstreamBus,Transformer_busone)) || (strcmp(UpstreamBus,Transformer_bustwo))
            %If the transformer is a voltage regulator, end the iiteration
            Deb = 1;
            if isequal(Transformer_busonebase, Transformer_bustwobase)
                Deb = 1;
                   
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
   







