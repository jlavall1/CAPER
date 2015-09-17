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


MYBUS = Buses(500).name;

UpstreamBuses = findUpstreamBuses(DSSCircObj, MYBUS);

zoneTrace = cell(length(UpstreamBuses), 2);

%Initialize zone count identifier
zoneNumber = 1;
zoneTrace{1,2} = sprintf('Zone #%s', num2str(zoneNumber));
zoneNumber = zoneNumber + 1;

%Initialize a cell array to record all transformers encountered in the
%trace
encounteredTransformers = cell(length(Transformers), 1);

%Flag to identify a transformer bus that has been encountered
transformerFlag = true;

%Initialize a transformer index
transformerIndex = 1;

%iterate through all of the upstream buses
for ii =1:1:(length(UpstreamBuses))
    
    %Compare all of the bus names with the names of the buses connected to
    %transformers
    zoneTrace{ii,1}=UpstreamBuses(ii);
   for iii=1:1:length(Transformers)
        %If the bus has a transformer, confirm that that transformer is
                %a voltage regulator
                UpstreamBus = UpstreamBuses(ii);
                Transformer_busone = Transformers(iii).bus1;
                Transformer_bustwo = Transformers(iii).bus2;
                
                %Cutting the subscripts out of the transformer bus names
                Transformer_busone = regexprep({Transformer_busone},'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
                Transformer_bustwo = regexprep({Transformer_bustwo},'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
                
                %Getting these values for later comparison. If the two
                %windings have an equal base voltage, then the transformer
                %is a voltage regulator.
                Transformer_busonebase = Transformers(iii).bus1kVBase;
                Transformer_bustwobase = Transformers(iii).bus2kVBase;
        if (strcmp(UpstreamBus,Transformer_busone))
            %If the transformer is a voltage regulator, insert a zone
            %identifier into the UpToVREG array
            if isequal(Transformer_busonebase, Transformer_bustwobase)
                %Compare all of the encountered transformer buses
                for i=1:1:length(encounteredTransformers)
                    %If this VREG bus has already been identified, set the
                    %flag to true
                    if strcmp(encounteredTransformers{i}, Transformer_busone)
                        transformerFlag = false;
                        break
                    end
                end
                %If the transformerFlag is true, then the bus has not been
                %recorded in the trace. If this is the case, record the
                %zone number in the trace
                if transformerFlag
                    zoneTrace{ii,2} = sprintf('Zone #%s', num2str(zoneNumber));
                    zoneNumber = zoneNumber + 1;
                    %Enter the transformer into the encountered
                    %transformers list
                    encounteredTransformers{transformerIndex} = Transformer_busone;
                    transformerIndex = transformerIndex + 1;
                end
                %Reset the transformerFlag
                transformerFlag = true;
            end 
        end
        %End of nested loop
   end
end

zoneTrace{ii,2} = sprintf('substation');

