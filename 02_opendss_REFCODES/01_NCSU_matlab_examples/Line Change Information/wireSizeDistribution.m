%%**************************************%
%       Wire Size Distribution          %
%***************************************%

%This is a script that is meant to be run after the LineChangeStudy script.
%It takes data from the wireSizeChangeInfo data structure and provides
%statistical information about parent wires and child wires. It should
%create a distribution of data

%Initialize arrays to hold information about parentLineCodes and
%childLineCodes
parentLineCodes = {};
childLineCodes = {};
%Initialize a count for each array
parentCount = 0;
childCount = 0;

%For each object in the cell array wireSizeChangeInfo, compare the Parent
%and Child line codes to the line codes in each array. 
for i = 1:length(wireSizeChangeInfo)
     %If the parent line code has not been stored in parentLineCodes, store
     %the line code
     if (not(ismember(wireSizeChangeInfo{i}.parentLineCode, parentLineCodes)))
         parentCount = parentCount+1;
              parentLineCodes{parentCount, 1} = wireSizeChangeInfo{i}.parentLineCode;
              %Initialize a counter to hold the total number of instances
              %of the parent line code
              parentLineCodeCounter{parentCount,1} = 1;
     else if ismember(wireSizeChangeInfo{i}.parentLineCode, parentLineCodes)
              ii = find(strcmp(parentLineCodes, wireSizeChangeInfo{i}.parentLineCode));
              parentLineCodeCounter{ii,1} = parentLineCodeCounter{ii,1} + 1;
         end
              
      end
      %If the child Line code has not been stored in childLineCodes, store
      %the line code
      if not(ismember(wireSizeChangeInfo{i}.childLineCode, childLineCodes))
          childCount = childCount + 1;
          childLineCodes{childCount} = wireSizeChangeInfo{i}.childLineCode;
          %Initialize a counter to hold the total number of instances of
          %the child line code
          childLineCodeCounter{childCount,1} = 1;
      else if ismember(wireSizeChangeInfo{i}.childLineCode, childLineCodes)
                ii = find(strcmp(childLineCodes,wireSizeChangeInfo{i}.childLineCode));
                childLineCodeCounter{ii,1} = childLineCodeCounter{ii,1} + 1;
          end
      end
end