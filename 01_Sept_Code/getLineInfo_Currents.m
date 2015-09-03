%% getLineInfo
% Gets the information for all lines in the circuit
%
%% Syntax
%  Lines = getLineInfo(DSSCircObj);
%  Lines = getLineInfo(DSSCircObj, lineNames);
%
%% Description
% Function to get the information about the lines in the circuit and
% return a structure with the information. If the optional input of
% lineNames is filled, the function returns information for the specified
% subset of lines excluding the miscellaneous parameters mentioned in the
% outputs below.
%
%% Inputs
% * *|DSSCircObj|* - link to OpenDSS active circuit and command text (from DSSStartup)
% * *|lineNames|* - optional cell array of line names to get information for
%
%% Outputs
% *|Lines|* is a structure with all the parameters for the
% lines in the active circuit.  Fields are:
%
% * _name_ - Name of the line.
% * _bus1_ - Name of the starting bus.
% * _bus2_ - Name of the ending bus.
% * _enabled_ - {1|0} indicates whether this element is enabled in the
% simulation.
% * _bus1PhasePowerReal_ - 3-element array of the real components of each
% phase's complex power at bus 1. Phases that are not present will return 0.
% * _bus1PhasePowerReactive_ - 3-element array of the imaginary components of each
% phase's complex power at bus 1. Phases that are not present will return 0.
% * _bus2PhasePowerReal_ - 3-element array of the real components of each
% phase's complex power at bus 2. Phases that are not present will return 0.
% * _bus2PhasePowerReactive_ - 3-element array of the imaginary components of each
% phase's complex power at bus 2. Phases that are not present will return 0.
% * _bus1PowerReal_ - Total real component at bus 1 of all present phases.
% * _bus1PowerReactive_ - Total imaginary component at bus 1 of all present phases.
% * _bus2PowerReal_ - Total real component at bus 2 of all present phases.
% * _bus2PowerReactive_ - Total imaginary component at bus 2 of all present phases.
% * _bus1Current_ - Average current magnitude for all included phases on bus 1.
% * _bus2Current_ - Average current magnitude for all included phases on bus 2.
% * _bus1PhaseCurrent_ - Current magnitude for each included phases on bus 1.
% * _bus2PhaseCurrent_ - Current magnitude for each included phases on bus 2.
% * _numPhases_ - Number of phases associated with the line.
% * _numConductors_ - Number of conductors associated with the line.
% * _lineRating_ - The line's current rating.
% * _losses_ - total real and imaginary power losses
% * _phaseLosses_ - real and imaginary power losses
% * _bus1NodeOrder_, _bus1Coordinates_, _bus1Distance_, _bus1PhaseVoltages_,
%  _bus1PhaseVoltagesPU_, _bus1Voltage_, _bus1VoltagePU_, _bus1VoltagePhasors_,
%  _bus1PhaseVoltagesLL_, _bus1PhaseVoltagesLLPU_, - Information
% regarding the starting bus. All obtained from the corresponding fields of
% the structure returned by getBusInfo when called with 'bus1' as an
% input.
% * _bus2NodeOrder_, _bus2Coordinates_, _bus2Distance_, _bus2PhaseVoltages_,
%  _bus2PhaseVoltagesPU_, _bus2Voltage_, _bus2VoltagePU_, _bus2VoltagePhasors_, 
% _bus2PhaseVoltagePhasorsPU_, _bus2PhaseVoltagePhasorsPU_, _bus2PhaseVoltagesLL_,
% _bus2PhaseVoltagesLLPU_ - Information
% regarding the ending bus. All obtained from the corresponding fields of
% the structure returned by getBusInfo when called with 'bus2' as an
% input. 
% * _parentObject_ - name of the line or object directly upstream (parent) of the line
% * _lineCode_, _length_, _R1_, _X1_, _R0_, _X0_, _C1_, _C0_, _Rmatrix_,
% _Xmatrix_, _Cmatrix_, _emergAmps_, _geometry_, _Rg_, _Xg_, _Rho_,
% _Yprim_, _numCust_, _totalCust_, _spacing_ - OpenDSS line object properties
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
% Returns line information in the circuit
%%
% [DSSCircObj, DSSText, gridpvPath] = DSSStartup;
% DSSText.command = ['Compile "' gridpvPath 'ExampleCircuit\master_Ckt24.dss"'];
% DSSText.command = 'solve';
% Lines = getLineInfo(DSSCircObj) %Get information for all lines
% Lines = getLineInfo(DSSCircObj,DSSCircObj.ActiveCircuit.Lines.AllNames) %Get information for all lines
% Lines = getLineInfo(DSSCircObj, {'g2102cg5800_n284428_sec_1'}); %Get information for a single line
% Lines = getLineInfo(DSSCircObj,[{'05410_8168450ug'};{'05410_52308181oh'}]); %Get info for two lines
%

function Lines = getLineInfo_Currents(DSSCircObj, varargin)
%% Parse inputs
p = inputParser; %setup parse structure
p.addRequired('DSSCircObj', @isinterfaceOpenDSS);
p.addOptional('lineNames', 'noInput', @iscellstr);

p.parse(DSSCircObj, varargin{:}); %parse inputs

allFields = fieldnames(p.Results); %set all parsed inputs to workspace variables
for ii=1:length(allFields)
    eval([allFields{ii}, ' = ', 'p.Results.',allFields{ii},';']);
end

try    
%% Define the circuit
DSSCircuit = DSSCircObj.ActiveCircuit;

if strcmp(lineNames, 'noInput')
    lineNames = DSSCircuit.Lines.AllNames;
end

Lines = struct('name',lineNames);

% Return if there are no lines in the circuit
if strcmp(lineNames,'NONE')
    return;
end

% Get voltage bases
kVBases = DSSCircuit.Settings.VoltageBases;
kVBases = [kVBases kVBases/sqrt(3)]; % kvBases are only LL, adding LN

%% Get all info
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
    
    %bus1PhasePowerReal = zeros(1,3);
    %bus1PhasePowerReactive = zeros(1,3);
    %bus2PhasePowerReal = zeros(1,3);
    %bus2PhasePowerReactive = zeros(1,3);
    bus1PhaseCurrent = zeros(1,3);
    bus2PhaseCurrent = zeros(1,3);
    
    if sum(phases) == DSSCircuit.ActiveCktElement.NumPhases %assignment does not work if the bus phases does not match the line phases
        %bus1PhasePowerReal(phases) = power(1,1:DSSCircuit.ActiveCktElement.NumPhases);
        %bus1PhasePowerReactive(phases) = power(2,1:DSSCircuit.ActiveCktElement.NumPhases);
        %bus2PhasePowerReal(phases) = power(1,DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases);
        %bus2PhasePowerReactive(phases) = power(2,DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases);
        bus1PhaseCurrent(phases) = currents(1:DSSCircuit.ActiveCktElement.NumPhases);
        bus2PhaseCurrent(phases) = currents(DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases);
    else %fill with data on the first phases, but return warning
        %bus1PhasePowerReal(1:DSSCircuit.ActiveCktElement.NumPhases) = power(1,1:DSSCircuit.ActiveCktElement.NumPhases);
        %bus1PhasePowerReactive(1:DSSCircuit.ActiveCktElement.NumPhases) = power(2,1:DSSCircuit.ActiveCktElement.NumPhases);
        %bus2PhasePowerReal(1:DSSCircuit.ActiveCktElement.NumPhases) = power(1,1:DSSCircuit.ActiveCktElement.NumPhases);
        %bus2PhasePowerReal(1:DSSCircuit.ActiveCktElement.NumPhases) = power(2,1:DSSCircuit.ActiveCktElement.NumPhases);
        bus1PhaseCurrent(1:DSSCircuit.ActiveCktElement.NumPhases) = currents(1:DSSCircuit.ActiveCktElement.NumPhases);
        bus2PhaseCurrent(1:DSSCircuit.ActiveCktElement.NumPhases) = currents(DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases);
        warning('Error with line.%s.  \nNumber of phases does not match the number of phases on the attached bus.  \nUse circuitCheck to diagnose the circuit.  \nRun warnSt=circuitCheck(DSSCircObj); and look at warnSt.InvalidLineBusName for more information.  \nInvalid data returned.\n',Lines(ii).name);
    end
    %Lines(ii).bus1PhasePowerReal = bus1PhasePowerReal;
    %Lines(ii).bus1PhasePowerReactive = bus1PhasePowerReactive;
    %Lines(ii).bus2PhasePowerReal = bus2PhasePowerReal;
    %Lines(ii).bus2PhasePowerReactive = bus2PhasePowerReactive;
    
    %Lines(ii).bus1PowerReal = sum(power(1,1:DSSCircuit.ActiveCktElement.NumPhases));
    %Lines(ii).bus1PowerReactive = sum(power(2,1:DSSCircuit.ActiveCktElement.NumPhases));
    %Lines(ii).bus2PowerReal = sum(power(1,DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases));
    %Lines(ii).bus2PowerReactive = sum(power(2,DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases));
    
    Lines(ii).bus1Current = mean(currents(1:DSSCircuit.ActiveCktElement.NumPhases));
    %Lines(ii).bus2Current = mean(currents(DSSCircuit.ActiveCktElement.NumConductors+1:DSSCircuit.ActiveCktElement.NumConductors+DSSCircuit.ActiveCktElement.NumPhases));
    Lines(ii).bus1PhaseCurrent = bus1PhaseCurrent;
    Lines(ii).bus2PhaseCurrent = bus2PhaseCurrent;
    
    %numPhases = DSSCircuit.ActiveElement.NumPhases;
    %Lines(ii).numPhases = numPhases;
    %Lines(ii).numConductors = DSSCircuit.ActiveElement.NumConductors;
    
    Lines(ii).lineRating = DSSCircuit.ActiveElement.NormalAmps;
    %{
    losses = DSSCircuit.ActiveCktElement.Losses;
    Lines(ii).losses = losses(1)/1000 + 1i*losses(2)/1000;
    
    losses = DSSCircuit.ActiveCktElement.PhaseLosses;
    losses = reshape(losses,2,[]);
    Lines(ii).phaseLosses = losses(1,:) + 1i*losses(2,:);
    %}
    nodes = DSSCircuit.ActiveElement.nodeOrder;
    numCond = DSSCircuit.ActiveElement.numConductors; % get numConductors for 2 element fields
    nodes1 = nodes(1:numCond);
    nodes1 = nodes1(nodes1~=0);
    nodes2 = nodes(numCond+1:numCond*2);
    nodes2 = nodes2(nodes2~=0);
    %{
    Lines(ii).bus1NodeOrder = nodes1;
    Lines(ii).bus2NodeOrder = nodes2;
    %}
    % bus 1
    DSSCircuit.SetActiveBus(Lines(ii).bus1);
    if isempty(DSSCircuit.ActiveBus.Name)
        generalName = regexprep(Lines(ii).bus1,'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
        DSSCircuit.SetActiveBus(generalName);
    end
    if isempty(DSSCircuit.ActiveBus.Name)
        error('busName:notfound',sprintf('Bus ''%s'' of Line ''%s'' is not found in the circuit.  Check that this is a bus in the compiled circuit.',Lines(ii).bus1, Lines(ii).name))
    end
    %{
    Lines(ii).bus1Coordinates = [DSSCircuit.ActiveBus.y, DSSCircuit.ActiveBus.x];
    Lines(ii).bus1Distance = DSSCircuit.ActiveBus.Distance;
    Lines(ii).bus1CoordDefined = DSSCircuit.ActiveBus.Coorddefined;
    %}
    voltages = DSSCircuit.ActiveBus.Voltages; %complex voltages
    %compVoltages =  voltages(1:2:end) + 1j*voltages(2:2:end);
    voltages = reshape(voltages,2,[]); %two rows for real and reactive
    %refAngle = [0,-2*pi/3,2*pi/3,zeros(1,50)];
    %Lines(ii).bus1VoltageAngle = mean(refAngle(DSSCircuit.ActiveBus.Nodes) - angle(voltages(1,:)+1i*voltages(2,:)));
    
    voltages = hypot(voltages(1,:),voltages(2,:)); %voltage magnitude
    Lines(ii).bus1Voltage = mean(voltages(1:DSSCircuit.ActiveBus.NumNodes));
    %New addition:
    Lines(ii).bus2Voltage = Lines(ii).bus1Voltage;
    %}
    
    %Only need bus1PhaseVoltagesPU (JML 9/2/2015)
    voltagesPU = DSSCircuit.ActiveBus.puVoltages; %complex voltages
    voltagesPU = reshape(voltagesPU,2,[]); %two rows for real and reactive
    voltagesPU = hypot(voltagesPU(1,:),voltagesPU(2,:)); %voltage magnitude
    %{
    compVoltagesPU =  voltagesPU(1:2:end) + 1j*voltagesPU(2:2:end);
    Lines(ii).bus1VoltagePU = mean(voltagesPU(1:DSSCircuit.ActiveBus.NumNodes));
    %}
    %busPhaseVoltages = zeros(1,3);
    phaseVoltages = zeros(1,3);
    busPhaseVoltagesPU = zeros(1,3);
    phaseVoltagesPU = zeros(1,3);
    %busPhaseVoltagePhasors = zeros(1,3);
    %phaseVoltagePhasors = zeros(1,3);
    %busPhaseVoltagePhasorsPU = zeros(1,3);
    %phaseVoltagePhasorsPU = zeros(1,3);
    %{
    
    busPhaseVoltages(DSSCircuit.ActiveBus.Nodes) = voltages;
    phaseVoltages(nodes1) = busPhaseVoltages(nodes1);
    %}
    busPhaseVoltagesPU(DSSCircuit.ActiveBus.Nodes) = voltagesPU;
    phaseVoltagesPU(nodes1) = busPhaseVoltagesPU(nodes1);
    %busPhaseVoltagePhasors(DSSCircuit.ActiveBus.Nodes) = compVoltages;
    %phaseVoltagePhasors(nodes1) = busPhaseVoltagePhasors(nodes1);
    %busPhaseVoltagePhasorsPU(DSSCircuit.ActiveBus.Nodes) = compVoltagesPU;
    %phaseVoltagePhasorsPU(nodes1) = busPhaseVoltagePhasorsPU(nodes1);
    
    Lines(ii).bus1PhaseVoltages = phaseVoltages;
    Lines(ii).bus1PhaseVoltagesPU = phaseVoltagesPU;
    
    %Lines(ii).bus1PhaseVoltagePhasors = phaseVoltagePhasors;
    %Lines(ii).bus1PhaseVoltagePhasorsPU = phaseVoltagePhasorsPU;
    %{
    phaseVoltagesLN = abs(phaseVoltagePhasors);
    sngPhBus = sum(phaseVoltagesLN~=0, 2) == 1;
    phaseVoltagesLL = phaseVoltagesLN;
    if ~sngPhBus
        phaseVoltagesLL = abs([phaseVoltagePhasors(1) - phaseVoltagePhasors(2), ...
            phaseVoltagePhasors(2) - phaseVoltagePhasors(3), phaseVoltagePhasors(3) - phaseVoltagePhasors(1)] .* ...
            [phaseVoltagesLN(1) & phaseVoltagesLN(2), phaseVoltagesLN(2) & phaseVoltagesLN(3)...
            phaseVoltagesLN(3) & phaseVoltagesLN(1)]);
    end
    
    Lines(ii).bus1PhaseVoltagesLL = phaseVoltagesLL;
    %}
    % get pu
    %{
    phaseVoltagesLLAvg = sum(phaseVoltagesLL)./sum(phaseVoltagesLL~=0);
    baseDiff = kVBases - phaseVoltagesLLAvg/1000;
    [~, ind] = min(abs(baseDiff), [], 2);
    phaseVoltagesLLPU = phaseVoltagesLL./kVBases(ind)' / 1000;
    Lines(ii).bus1PhaseVoltagesLLPU = phaseVoltagesLLPU;
    
    % avg line to line voltages
    Lines(ii).bus1VoltageLL = phaseVoltagesLLAvg;
    Lines(ii).bus1VoltageLLPU = phaseVoltagesLLAvg/kVBases(ind)' / 1000;
    
    Lines(ii).bus1kVBase = DSSCircuit.ActiveBus.kVBase;
    %}
    %Lines(ii).bus1Zsc1 = DSSCircuit.ActiveBus.Zsc1;
    %Lines(ii).bus1Zsc0 = DSSCircuit.ActiveBus.Zsc0;
    
    % bus 2
    %{
    DSSCircuit.SetActiveBus(Lines(ii).bus2);
    if isempty(DSSCircuit.ActiveBus.Name)
        generalName = regexprep(Lines(ii).bus2,'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
        DSSCircuit.SetActiveBus(generalName);
    end
    if isempty(DSSCircuit.ActiveBus.Name)
        error('busName:notfound',sprintf('Bus ''%s'' of Line ''%s'' is not found in the circuit.  Check that this is a bus in the compiled circuit.',Lines(ii).bus2, Lines(ii).name))
    end
    Lines(ii).bus2Coordinates = [DSSCircuit.ActiveBus.y, DSSCircuit.ActiveBus.x];
    Lines(ii).bus2Distance = DSSCircuit.ActiveBus.Distance;
    Lines(ii).bus2CoordDefined = DSSCircuit.ActiveBus.Coorddefined;
    
    voltages = DSSCircuit.ActiveBus.Voltages; %complex voltages
    compVoltages = voltages(1:2:end) + 1j*voltages(2:2:end);
    voltages = reshape(voltages,2,[]); %two rows for real and reactive
    Lines(ii).bus2VoltageAngle = mean(refAngle(DSSCircuit.ActiveBus.Nodes) - angle(voltages(1,:)+1i*voltages(2,:)));
    voltages = hypot(voltages(1,:),voltages(2,:)); %voltage magnitude
    Lines(ii).bus2Voltage = mean(voltages(1:DSSCircuit.ActiveBus.NumNodes));
    
    voltagesPU = DSSCircuit.ActiveBus.puVoltages; %complex voltages
    compVoltagesPU =  voltagesPU(1:2:end) + 1j*voltagesPU(2:2:end);
    voltagesPU = reshape(voltagesPU,2,[]); %two rows for real and reactive
    voltagesPU = hypot(voltagesPU(1,:),voltagesPU(2,:)); %voltage magnitude
    Lines(ii).bus2VoltagePU = mean(voltagesPU(1:DSSCircuit.ActiveBus.NumNodes));
    
    busPhaseVoltages = zeros(1,3);
    phaseVoltages = zeros(1,3);
    busPhaseVoltagesPU = zeros(1,3);
    phaseVoltagesPU = zeros(1,3);
    busPhaseVoltagePhasors = zeros(1,3);
    phaseVoltagePhasors = zeros(1,3);
    busPhaseVoltagePhasorsPU = zeros(1,3);
    phaseVoltagePhasorsPU = zeros(1,3);
    
    busPhaseVoltages(DSSCircuit.ActiveBus.Nodes) = voltages;
    phaseVoltages(nodes2) = busPhaseVoltages(nodes2);
    busPhaseVoltagesPU(DSSCircuit.ActiveBus.Nodes) = voltagesPU;
    phaseVoltagesPU(nodes2) = busPhaseVoltagesPU(nodes2);
    busPhaseVoltagePhasors(DSSCircuit.ActiveBus.Nodes) = compVoltages;
    phaseVoltagePhasors(nodes2) = busPhaseVoltagePhasors(nodes2);
    busPhaseVoltagePhasorsPU(DSSCircuit.ActiveBus.Nodes) = compVoltagesPU;
    phaseVoltagePhasorsPU(nodes2) = busPhaseVoltagePhasorsPU(nodes2);
    
    Lines(ii).bus2PhaseVoltages = phaseVoltages;
    Lines(ii).bus2PhaseVoltagesPU = phaseVoltagesPU;
    Lines(ii).bus2PhaseVoltagePhasors = phaseVoltagePhasors;
    Lines(ii).bus2PhaseVoltagePhasorsPU = phaseVoltagePhasorsPU;
    
    phaseVoltagesLN = abs(phaseVoltagePhasors);
    sngPhBus = sum(phaseVoltagesLN~=0, 2) == 1;
    
    phaseVoltagesLL = phaseVoltagesLN;
    if ~sngPhBus
        phaseVoltagesLL = abs([phaseVoltagePhasors(1) - phaseVoltagePhasors(2), ...
            phaseVoltagePhasors(2) - phaseVoltagePhasors(3), phaseVoltagePhasors(3) - phaseVoltagePhasors(1)] .* ...
            [phaseVoltagesLN(1) & phaseVoltagesLN(2), phaseVoltagesLN(2) & phaseVoltagesLN(3)...
            phaseVoltagesLN(3) & phaseVoltagesLN(1)]);
    end
    
    Lines(ii).bus2PhaseVoltagesLL = phaseVoltagesLL;
    %}
    % get pu
    %{
    phaseVoltagesLLAvg = sum(phaseVoltagesLL)./sum(phaseVoltagesLL~=0);
    baseDiff = kVBases - phaseVoltagesLLAvg/1000;
    [~, ind] = min(abs(baseDiff), [], 2);
    phaseVoltagesLLPU = phaseVoltagesLL./kVBases(ind)' / 1000;
    Lines(ii).bus2PhaseVoltagesLLPU = phaseVoltagesLLPU;
    
    % avg line to line voltages
    Lines(ii).bus2VoltageLL = phaseVoltagesLLAvg;
    Lines(ii).bus2VoltageLLPU = phaseVoltagesLLAvg/kVBases(ind)' / 1000;
    
    Lines(ii).bus2kVBase = DSSCircuit.ActiveBus.kVBase;
    
    Lines(ii).bus2Zsc1 = DSSCircuit.ActiveBus.Zsc1;
    Lines(ii).bus2Zsc0 = DSSCircuit.ActiveBus.Zsc0;
    %}
    
    % find parent (upstream) object from current active line
    DSSCircuit.ParentPDElement; %move cursor to upstream parent
    Lines(ii).parentObject = get(DSSCircuit.ActiveDSSElement,'Name');
    
end


%% Remove lines that are not enabled if no names were input to the function
condition = [Lines.enabled]==0;
if ~isempty(varargin) && any(condition) %if the user specified the line names, return warning for that line not being enabled
    warning(sprintf('Line %s is not enabled\n',Lines(condition).name));
else
    Lines = Lines(~condition);
end


%% Get the line parameters
%{
for ii=1:length(Lines)
    DSSCircuit.Lines.name = Lines(ii).name;
    Lines(ii).lineCode = get(DSSCircuit.Lines, 'LineCode');
    Lines(ii).length = get(DSSCircuit.Lines, 'Length');
    Lines(ii).R1 = get(DSSCircuit.Lines, 'R1');
    Lines(ii).X1 = get(DSSCircuit.Lines, 'X1');
    Lines(ii).R0 = get(DSSCircuit.Lines, 'R0');
    Lines(ii).X0 = get(DSSCircuit.Lines, 'X0');
    Lines(ii).C1 = get(DSSCircuit.Lines, 'C1');
    Lines(ii).C0 = get(DSSCircuit.Lines, 'C0');
    Lines(ii).Rmatrix = get(DSSCircuit.Lines, 'Rmatrix');
    Lines(ii).Xmatrix = get(DSSCircuit.Lines, 'Xmatrix');
    Lines(ii).Cmatrix = get(DSSCircuit.Lines, 'Cmatrix');
    Lines(ii).emergAmps = get(DSSCircuit.Lines, 'EmergAmps');
    Lines(ii).geometry = get(DSSCircuit.Lines, 'Geometry');
    Lines(ii).Rg = get(DSSCircuit.Lines, 'Rg');
    Lines(ii).Xg = get(DSSCircuit.Lines, 'Xg');
    Lines(ii).Rho = get(DSSCircuit.Lines, 'Rho');
    Lines(ii).Yprim = get(DSSCircuit.Lines, 'Yprim');
    Lines(ii).numCust = get(DSSCircuit.Lines, 'NumCust');
    Lines(ii).totalCust = get(DSSCircuit.Lines, 'TotalCust');
    Lines(ii).spacing = get(DSSCircuit.Lines, 'Spacing');
    units = {'mi','kft','km','m','ft','in','cm'};
    unitIndex = get(DSSCircuit.Lines, 'Units');
    if unitIndex
        Lines(ii).units = units{unitIndex};
    else
        Lines(ii).units = '';
    end
end
%}

%% As long as you are not in faultstudy mode, remove all lines that have zero volts on either side (not disabled but are isolated from the circuit)
if ~isempty(Lines) && isempty(varargin) && ~strcmp(DSSCircuit.Solution.ModeID,'Faultstudy')
    condition = [Lines.bus1Voltage]>100 & [Lines.bus2Voltage]>100;
    Lines = Lines(condition);
end

catch err
    if ~strcmp(err.identifier,'lineName:notfound') %if the only problem was not finding the line name, do not run circuit checker, user probably just specified a bad line
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