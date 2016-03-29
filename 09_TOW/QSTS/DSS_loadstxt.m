clear;
clc;
%blah blah blah

fileloc='C:\Users\ATOW\Documents\GitHub\CAPER\09_TOW\QSTS';
%cd(fileloc);
[RAW_DATA, A, CELL] = xlsread('Loads.xlsx','Sheet2');
output_text = cell(length(CELL),1);
for i=1:1:length(CELL)
    [startIndex,endIndex]=regexp(CELL(i,5),'.','match');
    n = length(CELL{i,4});
    ref = CELL{i,4}(n-1:n);
    if strcmp(ref,'.1')==1
        LS_txt = 'daily=LS_PhaseA';
    elseif strcmp(ref,'.2')==1
        LS_txt = 'daily=LS_PhaseB';
    elseif strcmp(ref,'.3')==1
        LS_txt = 'daily=LS_PhaseC';
    else
        fprintf('fuck\n');
    end
    
    %build string array
    output_text{i,1}=sprintf('%s',CELL{i,1});
    for j=2:1:8
        if j < 6
            output_text{i,j}=strcat(output_text{i,j-1},sprintf(' %s',CELL{i,j}));
        elseif j==6
            output_text{i,j}=strcat(output_text{i,j-1},sprintf(' KW=%s',num2str(CELL{i,j})));
        elseif j==7
            output_text{i,j}=strcat(output_text{i,j-1},sprintf(' KVAR=%s',num2str(CELL{i,j})));
        else
            output_text{i,j}=strcat(output_text{i,j-1},sprintf(' %s',LS_txt));
        end
    end
    output_text_final{i,1}=strcat(output_text{i,8},sprintf(' %s',LS_txt));
end

%export strings to .txt file:

filename=strcat(fileloc,'\Loads.txt');
fileID=fopen(filename,'w');
for j=1:1:length(output_text_final)
    fprintf(fileID,'%s\r\n',output_text_final{j,1});
end
fclose(fileID);
            
            
        