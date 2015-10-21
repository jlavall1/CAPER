%% getBusInfo
% Gets the information for all Bus in busNames
%
%% Syntax
%  Buses = getBusInfo(DSSCircObj);
%  Buses = getBusInfo(DSSCircObj,busNames);
%  Buses = getBusInfo(DSSCircObj,busNames,forceFindCoords);
%
%% Description
% Function to get the information for buses in the OpenDSS circuit.  If optional input busNames
% contains a cell array, the function will return a structure for each busName, otherwise Buses will
% contain all buses in the circuit.
%
%% Inputs
% * *|DSSCircObj|* - link to OpenDSS active circuit and command text (from DSSStartup)
% * *|busNames|* - optional cell array of bus names to get information for
% * *|forceFindCoords|* - optional input to force the function to try to
% find the coordinates for the busNames by searching for other connected
% buses that do have coordinates
%
%% Outputs
% *|Buses|* is a structure with all the parameters for the
% buses in busNames.  Fields are:
%
% * _name_ - The busname acquired from the busNames input.
% * _numPhases_ - Returns the number of nodes on the bus.
% * _nodes_ - Returns the nodes at the bus.
% * _voltageAngle_ - Average difference in angle from each voltage phase to a standard reference frame.
% * _voltage_ - Average voltage magnitude of all phases
% * _voltagePU_ - Average per unit voltage magnitude of all phases.
% * _phaseVoltages_ - Value of voltage magnitudes calculated from the complex voltage returned by OpenDSS. Length is always 3, returning 0 for phases not on the bus.
% * _phaseVoltagesPU_ - Per-unit value of voltage magnitudes calculated from the complex per-unit voltage returned by OpenDSS. Length is always 3, returning 0 for phases not on the bus.
% * _distance_ - Line distance from the bus to the substation.
% * _kVBase_ - The bus's base voltage in kV.
% * _seqVoltages_ - Sequence voltage magnitude for zero, positive, negative.
% * _cplxSeqVoltages_ - Sequence voltage phasors with real and imaginary zero, real and imaginary positive, and real and imaginary negative.
% * _ZscMatrix_ - The impedance matrix for the phases at the bus in pairs of real and imaginary numbers combined into one row.
% * _Zsc1_ - The short circuit positive-sequence real and imaginary impedance
% * _Zsc0_ - The short circuit zero-sequence real and imaginary impedance
% * _YscMatrix_ - The admittance matrix for the phases at the bus in pairs of real and imaginary numbers combined into one row.
% * _coordinates_ - Returns coordinates stored in OpenDSS for the active bus. If coordinates do not exist and forceFindCoords is 1, it returns coordinates of the coordinates of the nearest upstream element.
%
%% Copyright 2014
% Georgia Tech Research Corporation, Atlanta, Georgia 30332
% Sandia Corporation. Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation, the U.S. Government retains certain rights in this software.
% See the license agreement for full terms and conditions.
%
% Please acknowledge any contributions of the GridPV Toolbox by citing:
% M. J. Reno and K. Coogan, "Grid Integrated Distributed PV (GridPV) Version 2," Sandia National Laboratories SAND2013-20141, 2014.
%
%% Example
% Returns bus information
%%
% [DSSCircObj, DSSText, gridpvPath] = DSSStartup;
% DSSText.command = ['Compile "' gridpvPath 'ExampleCircuit\master_Ckt24.dss"'];
% DSSText.command = 'solve';
% Buses = getBusInfo(DSSCircObj) %Get information for all buses
% Buses = getBusInfo(DSSCircObj,{'N1311915'}) %Get information for one bus
%

function Buses = getBusInfo(DSSCircObj,varargin)

%% Parse inputs
p = inputParser; %setup parse structure
p.addRequired('DSSCircObj', @isinterfaceOpenDSS);
p.addOptional('busNames', 'noInput', @iscellstr);
p.addOptional('forceFindCoords', 0,  @(x)isnumeric(x) && ((x==1) || (x==0)));

p.parse(DSSCircObj, varargin{:}); %parse inputs

allFields = fieldnames(p.Results); %set all parsed inputs to workspace variables
for ii=1:length(allFields)
    eval([allFields{ii}, ' = ', 'p.Results.',allFields{ii},';']);
end

try
%% Get circuit information
% Define the circuit
DSSCircuit = DSSCircObj.ActiveCircuit;

if strcmp(busNames,'noInput')
    busNames = DSSCircuit.AllBusNames;
end
Buses = struct('name',busNames);

% Grab Transformer and Line information because we are going to have to search for the bus coordinates
if exist('forceFindCoords') && forceFindCoords==1
    transformerName = DSSCircuit.Transformers.AllNames;
    Transformers = struct('name',transformerName);
    if ~strcmp(Transformers(1).name,'NONE')
        for jj=1:length(Transformers)
            DSSCircuit.SetActiveElement(['transformer.' Transformers(jj).name]);
            transformerBusNames = DSSCircuit.ActiveElement.BusNames;
            Transformers(jj).bus1 = transformerBusNames{1};
            Transformers(jj).bus2 = transformerBusNames{2};
        end
        transformersSecondaryBus = regexprep({Transformers.bus2},'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
    end
    
    lineName = DSSCircuit.Lines.AllNames;
    Lines = struct('name',lineName);
    for jj=1:length(Lines)
        DSSCircuit.SetActiveElement(['line.' Lines(jj).name]);
        lineBusNames = DSSCircuit.ActiveElement.BusNames;
        Lines(jj).bus1 = lineBusNames{1};
        Lines(jj).bus2 = lineBusNames{2};
    end
    linesBus2 = regexprep({Lines.bus2},'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
    [busCoordNames busCoordArray] = getBusCoordinatesArray(DSSCircObj); % to check if there are any coordinates in the circuit
end

%% Get all bus information
for ii=1:length(busNames)
    DSSCircuit.SetActiveBus(busNames{ii});
    if isempty(DSSCircuit.ActiveBus.Name)
        generalName = regexprep(busNames{ii},'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
        DSSCircuit.SetActiveBus(generalName); 
    end
    if isempty(DSSCircuit.ActiveBus.Name)
        error('busName:notfound',sprintf('Bus ''%s'' is not found in the circuit.  Check that this is a bus in the compiled circuit.',busNames{ii}))
    end
    
    Buses(ii).numPhases = DSSCircuit.ActiveBus.NumNodes;
    
    voltages = DSSCircuit.ActiveBus.Voltages; %complex voltages
    busNodes = DSSCircuit.ActiveBus.Nodes;
    nodes = busNodes(busNodes>=1 & busNodes<=3);
    Buses(ii).nodes = nodes;
    voltages = reshape(voltages,2,[]); %two rows for real and reactive
    refAngle = [0,-2*pi/3,2*pi/3];
    Buses(ii).voltageAngle = mean(refAngle(nodes) - angle(voltages(1,busNodes>=1 & busNodes<=3)+1i*voltages(2,busNodes>=1 & busNodes<=3)));
    voltages = hypot(voltages(1,:),voltages(2,:)); %voltage magnitude
    Buses(ii).voltage = mean(voltages(busNodes>=1 & busNodes<=3));
    
    voltagesPU = DSSCircuit.ActiveBus.puVoltages; %complex voltages
    voltagesPU = reshape(voltagesPU,2,[]); %two rows for real and reactive
    voltagesPU = hypot(voltagesPU(1,:),voltagesPU(2,:)); %voltage magnitude
    Buses(ii).voltagePU = mean(voltagesPU(busNodes>=1 & busNodes<=3));

    phaseVoltages = zeros(1,3);
    phaseVoltagesPU = zeros(1,3);    
    busPhaseVoltages(busNodes) = voltages;
    phaseVoltages(nodes) = busPhaseVoltages(nodes);
    busPhaseVoltagesPU(busNodes) = voltagesPU;
    phaseVoltagesPU(nodes) = busPhaseVoltagesPU(nodes);
    Buses(ii).phaseVoltages = phaseVoltages;
    Buses(ii).phaseVoltagesPU = phaseVoltagesPU;
    
    Buses(ii).distance = DSSCircuit.ActiveBus.Distance;
    Buses(ii).kVBase = DSSCircuit.ActiveBus.kVBase;
    
    Buses(ii).seqVoltages = DSSCircuit.ActiveBus.SeqVoltages;
    Buses(ii).cplxSeqVoltages = DSSCircuit.ActiveBus.CplxSeqVoltages;
    Buses(ii).ZscMatrix = DSSCircuit.ActiveBus.ZscMatrix;
    Buses(ii).Zsc1 = DSSCircuit.ActiveBus.Zsc1;
    Buses(ii).Zsc0 = DSSCircuit.ActiveBus.Zsc0;
    Buses(ii).YscMatrix = DSSCircuit.ActiveBus.YscMatrix;
    
    if exist('forceFindCoords') && forceFindCoords==1 % force find coordinates option selected
        if ~DSSCircuit.ActiveBus.Coorddefined && DSSCircuit.ActiveBus.Distance~=0 % coordinates not found, so go searching for them
            
            % find the next connected bus upstream and see if it has coordinates
            currentBus = busNames{ii};
            currentBus = regexprep(currentBus,'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
            while ~DSSCircuit.ActiveBus.Coorddefined
                
                % Find new bus by looking for connected lines
                %attachedLine = find(cellfun(@isempty,strfind(upper(linesBus2),upper(currentBus)))==0,1,'first');
                attachedLine = find(strcmpi(linesBus2,currentBus)==1,1,'first');
                if ~isempty(attachedLine)
                    newBus = Lines(attachedLine).bus1;
                    newBus = regexprep(newBus,'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
                    % Try new bus to see if it has coordinates
                    DSSCircuit.SetActiveBus(newBus);
                    currentBus = newBus;
                    
                else %didn't find a line, so try a transformer
                    attachedTransformer = find(cellfun(@isempty,strfind(upper(transformersSecondaryBus),upper(currentBus)))==0,1,'first');
                    
                    if ~isempty(attachedTransformer)
                        newBus = Transformers(attachedTransformer).bus1;
                        newBus = regexprep(newBus,'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
                        % Try new bus to see if it has coordinates
                        DSSCircuit.SetActiveBus(newBus);
                        currentBus = newBus;
                    else
                        warning(sprintf('Could not find the bus coordinates for %s.  Using the substation coordinates.',busNames{ii}));
                        break; %couldn't find something connected to line or transformer
                    end
                end
            end
        end
        if DSSCircuit.ActiveBus.Coorddefined %while loop found coordinates
            Buses(ii).coordinates = [DSSCircuit.ActiveBus.y, DSSCircuit.ActiveBus.x];
        else %while loop broke without finding coordinates
            if ~exist('substationCoords')
                substationCoords = findSubstationLocation(DSSCircObj);
            end
            Buses(ii).coordinates = substationCoords;
        end
    else
        Buses(ii).coordinates = [DSSCircuit.ActiveBus.y, DSSCircuit.ActiveBus.x];
    end

end

catch err
   
    if ~strcmp(err.identifier,'busName:notfound') %if the only problem was not finding the bus name, do not run circuit checker, user probably just specified a bad bus
        allLines = [err.stack.line];
        allNames = {err.stack.name};
        fprintf(1, ['\nThere was an error in ' allNames{end} ' in line ' num2str(allLines(end)) ':\n'])
        fprintf(1, ['"' err.message '"' '\n\n'])
        fprintf(1, ['About to run circuitCheck.m to ensure the circuit is set up correctly in OpenDSS.\n\n'])
        fprintf(1, 'If the problem persists, change the MATLAB debug mode by entering in the command window:\n >> dbstop if caught error\n\n')
        fprintf(1, 'Running circuitCheck.m ....................\n')

        warnSt = circuitCheck(DSSCircObj, 'Warnings', 'on')
        assignin('base','warnSt',warnSt);
    end
    rethrow(err);
end
end



