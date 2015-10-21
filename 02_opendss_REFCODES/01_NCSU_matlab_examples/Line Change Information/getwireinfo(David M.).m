%Set a pointer for the active circuit
DSSCircuit=DSSCircObj.ActiveCircuit;

%Get total number of lines in circuit
m=DSSCircuit.Lines.count;

%Make sure pointer is set to first line in circuit
DSSCircuit.Lines.First;

%Get all line names and associate wire type
for ii=1:m
    DSSText.command=['? Line.',DSSCircuit.Lines.Name,'.wires'];
    name(ii)=cellstr(DSSCircuit.Lines.Name);
    %For overhead lines where LineCode is not defined
    if isempty(DSSCircuit.Lines.LineCode)==1
        wiretype(ii)=cellstr(DSSText.Result);
        
    %For underground lines where LineCode is defined   
    else
        wiretype(ii)=cellstr(DSSCircuit.Lines.LineCode);
        
    end 
    DSSText.command=['? Line.',DSSCircuit.Lines.Name,'.Switch'];
    
    %additional column for whether or not the line is a switched/dummy line
    SwitchStates(ii) = cellstr(DSSText.Result);
    
    %Set pointer to next line in circuit
    DSSCircuit.Lines.Next;
end

%Combine name and wire info into one set of data
combined=[name;wiretype;SwitchStates];

%Convert combined data into a structure for easier navigation
Lines=cell2struct(combined,{'LineName', 'Wire','Switch'},1);


fprintf('\n\nNumber of Lines which are actual OH or UG lines:');
sum(~cellfun(@isempty, {Lines.Wire}))

fprintf('Number of Lines which are switches or dummy lines:');
sum(strcmp({Lines.Switch}, 'True'))

%Test to determine there are any lines which are not defined UG or OH lines
% or dummy lines/switches
test=strcmp({Lines.Wire},'')&strcmp({Lines.Switch},'False');

fprintf('Number of lines which do not have defined wire and are not switches/dummy lines:')
sum(test)




