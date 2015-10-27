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

%try    
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
%kVBases = DSSCircuit.Settings.VoltageBases;
%kVBases = [kVBases kVBases/sqrt(3)]; % kvBases are only LL, adding LN

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
    
    currents = DSSCircuit.ActiveCktElement.Currents; %complex currents
    currents = reshape(currents,2,[]); %two rows for real and reactive
    currents = hypot(currents(1,:),currents(2,:)); %magnitude
    

    bus1PhaseCurrent = zeros(1,3);

    if sum(phases) == DSSCircuit.ActiveCktElement.NumPhases %assignment does not work if the bus phases does not match the line phases
        bus1PhaseCurrent(phases) = currents(1:DSSCircuit.ActiveCktElement.NumPhases);
        
    else %fill with data on the first phases, but return warning
        bus1PhaseCurrent(1:DSSCircuit.ActiveCktElement.NumPhases) = currents(1:DSSCircuit.ActiveCktElement.NumPhases);
        warning('Error with line.%s.  \nNumber of phases does not match the number of phases on the attached bus.  \nUse circuitCheck to diagnose the circuit.  \nRun warnSt=circuitCheck(DSSCircObj); and look at warnSt.InvalidLineBusName for more information.  \nInvalid data returned.\n',Lines(ii).name);
    end
    %
    %Save phase currents calculated for export:
    Lines(ii).bus1PhaseCurrent = bus1PhaseCurrent;
    Lines(ii).lineRating = DSSCircuit.ActiveElement.NormalAmps;
    %Obtain power losses:
    losses = DSSCircuit.ActiveCktElement.Losses;
    Lines(ii).losses = losses(1)/1000; %kw %+ 1i*losses(2)/1000;
   
    %losses = DSSCircuit.ActiveCktElement.PhaseLosses;
    %losses = reshape(losses,2,[]);
    %Lines(ii).phaseLosses = losses(1,:) + 1i*losses(2,:);
    %numPhases = DSSCircuit.ActiveElement.NumPhases;
    %Lines(ii).numPhases = numPhases;
    %
    %nodes = DSSCircuit.ActiveElement.nodeOrder;
    %numCond = DSSCircuit.ActiveElement.numConductors; % get numConductors for 2 element fields
    %nodes1 = nodes(1:numCond);
    %nodes1 = nodes1(nodes1~=0);
    %busPhaseVoltages = zeros(1,3);
    %phaseVoltages = zeros(1,3);
    
    voltages = DSSCircuit.ActiveBus.Voltages; %complex voltages
    %compVoltages =  voltages(1:2:end) + 1j*voltages(2:2:end);
    voltages = reshape(voltages,2,[]); %two rows for real and reactive
    %refAngle = [0,-2*pi/3,2*pi/3,zeros(1,50)];
    %Lines(ii).bus1VoltageAngle = mean(refAngle(DSSCircuit.ActiveBus.Nodes) - angle(voltages(1,:)+1i*voltages(2,:)));
    voltages = hypot(voltages(1,:),voltages(2,:)); %voltage magnitude
    
    
    %Lines(ii).bus1Voltage = mean(voltages(1:DSSCircuit.ActiveBus.NumNodes));
    Lines(ii).bus1Voltage = max(voltages);
    
    %busPhaseVoltages(DSSCircuit.ActiveBus.Nodes) = voltages;
    %phaseVoltages(nodes1) = busPhaseVoltages(nodes1);
    %Export:
    %Lines(ii).bus1PhaseVoltages = phaseVoltages;
    %%
    % bus 1
    DSSCircuit.SetActiveBus(Lines(ii).bus1);
    if isempty(DSSCircuit.ActiveBus.Name)
        generalName = regexprep(Lines(ii).bus1,'(\.[0-9]+)',''); %take out the phase numbers on buses if they have them
        DSSCircuit.SetActiveBus(generalName);
    end
    if isempty(DSSCircuit.ActiveBus.Name)
        error('busName:notfound',sprintf('Bus ''%s'' of Line ''%s'' is not found in the circuit.  Check that this is a bus in the compiled circuit.',Lines(ii).bus1, Lines(ii).name))
    end
    

    % find parent (upstream) object from current active line
    DSSCircuit.ParentPDElement; %move cursor to upstream parent
    Lines(ii).parentObject = get(DSSCircuit.ActiveDSSElement,'Name');
    
end

%{
%% Remove lines that are not enabled if no names were input to the function
condition = [Lines.enabled]==0;
if ~isempty(varargin) && any(condition) %if the user specified the line names, return warning for that line not being enabled
    warning(sprintf('Line %s is not enabled\n',Lines(condition).name));
else
    Lines = Lines(~condition);
end


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
%}
%end

%end