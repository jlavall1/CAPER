% Only one Source
DER.ID = DER.ID(1); %Line 39

% Rename Misnamed Loads
NodeIndex = find(~cellfun(@isempty,regexp(NODE.ID,'258904010')));
DSSCircuit.SetActiveElement(['Load.',Loads{i}]);
Powers = DSSCircuit.ActiveElement.Power;
NODE.DEMAND(NodeIndex,2*phase-1) = Powers(1);
NODE.DEMAND(NodeIndex,2*phase)   = Powers(2);

ind = [];
for i = 1:length(Switches)
    ind = [ind;find(~cellfun(@isempty,regexp(SECTION.ID,Switches{i})))];
end
