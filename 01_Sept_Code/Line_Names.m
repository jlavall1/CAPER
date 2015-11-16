%Obtain feeder results:
if strcmp(lineNames, 'noInput')
    lineNames = DSSCircuit.Lines.AllNames;
end
Lines = struct('name',lineNames);

for ii=1:length(Lines)
    DSSCircuit.SetActiveElement(['line.' Lines(ii).name]);
    if ~strcmpi(DSSCircuit.ActiveElement.Name,['line.' Lines(ii).name])
        error('lineName:notfound',sprintf('Line Name %s not found in the circuit.  Check that this is a line in the compiled circuit.',Lines(ii).name))
    end
    
    lineBusNames = DSSCircuit.ActiveElement.BusNames;
    Lines(ii).bus1 = lineBusNames{1};
    Lines(ii).bus2 = lineBusNames{2};
    
    Lines(ii).enabled = DSSCircuit.ActiveElement.Enabled;
    if ~Lines(ii).enabled % line is not enabled, so much of the active element properties will return errors
        continue;
    end
    
    phases = [~isempty(regexp(Lines(ii).bus1,'.^?(\.1)','Tokens')),~isempty(regexp(Lines(ii).bus1,'.^?(\.2)','Tokens')),~isempty(regexp(Lines(ii).bus1,'.^?(\.3)','Tokens'))];
    if ~any(phases ~= 0) %If all phases are blank (ie they were not put into OpenDSS), then default to all 3 phases
        phases = [true true true];
    end
    
    %power = DSSCircuit.ActiveCktElement.Powers; %complex
    %power = reshape(power,2,[]); %two rows for real and reactive
    
    currents = DSSCircuit.ActiveCktElement.Currents; %complex currents
    currents = reshape(currents,2,[]); %two rows for real and reactive
    currents = hypot(currents(1,:),currents(2,:)); %magnitude
    
    bus1PhasePowerReal = zeros(1,3);
    bus1PhasePowerReactive = zeros(1,3);

    bus1PhaseCurrent = zeros(1,3);
    bus2PhaseCurrent = zeros(1,3);
    
    if sum(phases) == DSSCircuit.ActiveCktElement.NumPhases %assignment does not work if the bus phases does not match the line phases
        bus1PhasePowerReal(phases) = power(1,1:DSSCircuit.ActiveCktElement.NumPhases);
        bus1PhasePowerReactive(phases) = power(2,1:DSSCircuit.ActiveCktElement.NumPhases);
        %bus2PhasePowerReal(phases) = power(1,DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases);
        %bus2PhasePowerReactive(phases) = power(2,DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases);
        bus1PhaseCurrent(phases) = currents(1:DSSCircuit.ActiveCktElement.NumPhases);
        bus2PhaseCurrent(phases) = currents(DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases);
    else %fill with data on the first phases, but return warning
        bus1PhasePowerReal(1:DSSCircuit.ActiveCktElement.NumPhases) = power(1,1:DSSCircuit.ActiveCktElement.NumPhases);
        bus1PhasePowerReactive(1:DSSCircuit.ActiveCktElement.NumPhases) = power(2,1:DSSCircuit.ActiveCktElement.NumPhases);
        %bus2PhasePowerReal(1:DSSCircuit.ActiveCktElement.NumPhases) = power(1,1:DSSCircuit.ActiveCktElement.NumPhases);
        %bus2PhasePowerReal(1:DSSCircuit.ActiveCktElement.NumPhases) = power(2,1:DSSCircuit.ActiveCktElement.NumPhases);
        bus1PhaseCurrent(1:DSSCircuit.ActiveCktElement.NumPhases) = currents(1:DSSCircuit.ActiveCktElement.NumPhases);
        bus2PhaseCurrent(1:DSSCircuit.ActiveCktElement.NumPhases) = currents(DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases);
        warning('Error with line.%s.  \nNumber of phases does not match the number of phases on the attached bus.  \nUse circuitCheck to diagnose the circuit.  \nRun warnSt=circuitCheck(DSSCircObj); and look at warnSt.InvalidLineBusName for more information.  \nInvalid data returned.\n',Lines(ii).name);
    end
    Lines(ii).bus1PhasePowerReal = bus1PhasePowerReal;
    Lines(ii).bus1PhasePowerReactive = bus1PhasePowerReactive;
    %Lines(ii).bus2PhasePowerReal = bus2PhasePowerReal;
    %Lines(ii).bus2PhasePowerReactive = bus2PhasePowerReactive;
    
    Lines(ii).bus1PowerReal = sum(power(1,1:DSSCircuit.ActiveCktElement.NumPhases));
    Lines(ii).bus1PowerReactive = sum(power(2,1:DSSCircuit.ActiveCktElement.NumPhases));
end

    %1. P.U. voltages:
    Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
    Voltages=Voltages';
    DATA_SAVE(present_step,1).Vpu = Voltages;
    %2. P & Q thru lines: