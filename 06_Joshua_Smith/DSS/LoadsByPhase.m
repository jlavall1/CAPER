%% LoadsByPhase
% Gets the total kW and kVAR demand on each phase
%
%% Syntax
%  LoadTotals = getLineInfo(DSSCircObj);
%  LoadTotals = getLineInfo(DSSCircObj, LoadNames);
%
%% Inputs
% * *|DSSCircObj|* - link to OpenDSS active circuit and command text (from DSSStartup)
% * *|LoadNames|*  - optional cell array of load names to get load totals for
%
%% Outputs
% *|LoadTotals|* is a structure with kW and kVAR demands for each phase
% Fields are:
%
% * _kWA_   - Real Power Demand on Phase A.
% * _kVARA_ - Reactive Power Demand on Phase A.
% * _kWB_   - Real Power Demand on Phase B.
% * _kVARB_ - Reactive Power Demand on Phase B.
% * _kWC_   - Real Power Demand on Phase C.
% * _kVARC_ - Reactive Power Demand on Phase C.
%
function LoadTotals = LoadsByPhase(DSSCircObj,varargin)
%% Parse inputs
p = inputParser; %setup parse structure
p.addRequired('DSSCircObj', @isinterfaceOpenDSS);
p.addOptional('LoadNames', 'noInput', @iscellstr);

p.parse(DSSCircObj, varargin{:}); %parse inputs

allFields = fieldnames(p.Results); %set all parsed inputs to workspace variables
for i=1:length(allFields)
    eval([allFields{i}, ' = ', 'p.Results.',allFields{i},';']);
end
   
%% Define the circuit
DSSCircuit = DSSCircObj.ActiveCircuit;

if strcmp(LoadNames, 'noInput')
    LoadNames = DSSCircuit.Loads.AllNames;
end

Loads = struct('ID',LoadNames);

% Return if there are no lines in the circuit
if strcmp(LoadNames,'NONE')
    warning('No Loads Found')
    return;
end

for i = 1:length(LoadNames)
    % Separate out ID from Phase Designation
    Loads(i).ID = LoadNames{i};
    Phase = regexp(LoadNames{i},'(?<=[_]).*?$','match');
    switch Phase{1}
        case {'1' 'a'}
            Loads(i).Phase = 'A';
        case {'2' 'b'}
            Loads(i).Phase = 'B';
        case {'3' 'c'}
            Loads(i).Phase = 'C';
    end
    DSSCircuit.SetActiveElement(['Load.',LoadNames{i}]);
    Powers = DSSCircuit.ActiveCktElement.Powers;
    Loads(i).kW = Powers(1);
    Loads(i).kVAR = Powers(2);
end

% Find per phase demand totals
LoadTotals.kWA = sum([Loads(regexp([Loads.Phase],'A')).kW]);
LoadTotals.kWB = sum([Loads(regexp([Loads.Phase],'B')).kW]);
LoadTotals.kWC = sum([Loads(regexp([Loads.Phase],'C')).kW]);
LoadTotals.kVARA = sum([Loads(regexp([Loads.Phase],'A')).kVAR]);
LoadTotals.kVARB = sum([Loads(regexp([Loads.Phase],'B')).kVAR]);
LoadTotals.kVARC = sum([Loads(regexp([Loads.Phase],'C')).kVAR]);

end