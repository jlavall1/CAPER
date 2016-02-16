function LOOPS = findLoops(SECTION)

% Find Open Points
index = find(~logical([SECTION.NormalStatus]));

for i = 1:length(index)
    System = SECTION(logical([SECTION.NormalStatus]));
    from = SECTION(index(i)).FROM;
    to   = SECTION(index(i)).TO;
    
    % find adjacent sections to "to"
    index1 = find(ismember({System.FROM},to));
    index2 = find(ismember({System.TO},to));
    adj = [{SECTION(index1).TO},{SECTION(index2)}];


end
end