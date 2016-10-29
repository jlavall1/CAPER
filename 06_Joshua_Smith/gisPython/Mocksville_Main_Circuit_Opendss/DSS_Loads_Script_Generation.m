%Read in a Loads.DSS and insert either LS_PhaseA LS_PhaseB LS_PhaseC
% This is for
clear
clc
close all
%---------------------------
%USER_INPUT --
feeder_NUM=1;
%---------------------------
if feeder_NUM == 1
    [RAW_DATA, A, CELL] = xlsread('MOCKS_LOADS.xlsx', 'MOCKS_1');
    base='_MOCKS_1';
elseif feeder_NUM == 2
    [RAW_DATA, A, CELL] = xlsread('MOCKS_LOADS.xlsx', 'MOCKS_2');
    base='_MOCKS_2';
elseif feeder_NUM == 3
    [RAW_DATA, A, CELL] = xlsread('MOCKS_LOADS.xlsx', 'MOCKS_3');
    base='_MOCKS_3';
elseif feeder_NUM == 4
    [RAW_DATA, A, CELL] = xlsread('MOCKS_LOADS.xlsx', 'MOCKS_4');
    base='_MOCKS_4';
end
 %%
static = 1;
output_text = cell(length(CELL),1);
for i=1:1:length(CELL)
    [startIndex,endIndex]=regexp(CELL{i,3},'.','match');
    n = length(CELL{i,3});
    ref = CELL{i,3}(n-1:n);
    if strcmp(ref,'.1')==1
        LS_txt = strcat('duty=LS_PhaseA',base);
    elseif strcmp(ref,'.2')==1
        LS_txt = strcat('duty=LS_PhaseB',base);
    elseif strcmp(ref,'.3')==1
        LS_txt = strcat('duty=LS_PhaseC',base);
    else
        fprintf('No Phase Declaration here: %d\n',i);
    end
    output_text{i,1}=strcat(CELL{i,1},sprintf(' %s',CELL{i,2}));
    if static
    for j=3:1:7
        if j == 5
            %Change the voltage:
            output_text{i,1}=strcat(output_text{i,1},sprintf(' kV=%s','13.7987'));
        elseif j == 7
            %Change the PF
            output_text{i,1}=strcat(output_text{i,1},'PF=0.95');   
        else
            output_text{i,1}=strcat(output_text{i,1},sprintf('%s',num2str(CELL{i,j})));
        end
    end
    
    %Declare Loadshapes:
    output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',LS_txt));
    
end
%%
%{
%Export strings to .txt file:
filename=strcat(fileloc,'\Loads_text.txt');
fileID=fopen(filename,'w');
for j=1:1:length(output_text)
    fprintf(fileID,'%s\r\n',output_text{j,1});
end
fclose(fileID);

fprintf('The new loads.dss text file has been generated!\n');
%}
