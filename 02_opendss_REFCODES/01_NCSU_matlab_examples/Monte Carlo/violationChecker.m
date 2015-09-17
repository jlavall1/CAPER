%%**************************%
%        Violation Check    %
%***************************%

%This is a script that will take the input from the Monte Carlo prototype and
%write to a .txt file a list of voltage and thermal violations at each node
%and line.


%Create a file to write to
fileID = fopen('Violations.txt', 'w');

Lines = getLineInfo(DSSCircObj);
%Create a header

fprintf(fileID, 'Holly Springs Scenario One\n');
%Loop through all of the lines
violations = cell(length(Lines),3);
for i = 1:length(Lines)
    if (Lines(i).lineRating < Lines(i).bus1Current)
        fprintf(fileID, 'Thermal Violation on Line %s\n', Lines(i).name);
        violations{i,1} = sprintf('Thermal Violaion on Line %s', Lines(i).name);
        violations{i, 2} = Lines(i).lineRating;
        violations{i, 3} = Lines(i).bus1Current;
    else
        violations{i,1} = 0;
        violations{i, 2} =0;
        violations{i, 3} =0;
    end
end
fclose('all');
emptyCells = cellfun(@(x) isequal(x,0), violations);
violations(emptyCells) = [];