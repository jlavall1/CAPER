%Read in a Loads.DSS and insert either LS_PhaseA LS_PhaseB LS_PhaseC
clear
clc
close all
fileloc_base='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
%USER_INPUT --
feeder_NUM=8;

if feeder_NUM == 0
    fileloc=strcat(fileloc_base,'\Bellhaven_Circuit_Opendss');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('Loads_Text.xlsx', 'Loads_BASE');
elseif feeder_NUM == 1
    fileloc=strcat(fileloc_base,'\Commonwealth_Circuit_Opendss');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('Loads_Text.xlsx', 'Loads_NCSU');
elseif feeder_NUM == 2
    fileloc=strcat(fileloc_base,'\Flay_Circuit_Opendss');
elseif feeder_NUM == 8
    fileloc=strcat(fileloc_base,'EPRI_ckt24');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('Loads_Text.xlsx', 'Loads_BASE');
end
    

output_text = cell(length(CELL),1);
for i=1:1:length(CELL)
    [startIndex,endIndex]=regexp(CELL{i,5},'.');
    n = length(CELL{1,5});
    ref = CELL{i,5}(n-1:n);
    if strcmp(ref,'.1')==1
        LS_txt = 'duty=LS_PhaseA';
    elseif strcmp(ref,'.2')==1
        LS_txt = 'duty=LS_PhaseB';
    elseif strcmp(ref,'.3')==1
        LS_txt = 'duty=LS_PhaseC';
    else
        fprintf('fuck here %d\n',i);
    end
    output_text{i,1}=strcat(CELL{i,1},sprintf(' %s',CELL{i,2}));
    output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',LS_txt));
    
    for j=3:1:8
        if j==3 || j==5 || j==6 
            output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',CELL{i,j}));
        elseif j == 7
            %to be exact 12.47/sqrt(3)
            output_text{i,1}=strcat(output_text{i,1},sprintf('%s','7.19976905311778'));
        elseif j == 8
            %Seperate XFKVA & PF:
            k = strfind(CELL{i,j},'PF=');
            insert = CELL{i,j}(1:k-1);
            output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',insert));
            output_text{i,1}=strcat(output_text{i,1},sprintf(' %s','PF=0.98'));
            
        else %j==4
            output_text{i,1}=strcat(output_text{i,1},sprintf('%s',num2str(CELL{i,j})));
        end
    end
end
%%
%Export strings to .txt file:
filename=strcat(fileloc,'\Loads_text.txt');
fileID=fopen(filename,'w');
for j=1:1:length(output_text)
    fprintf(fileID,'%s\r\n',output_text{j,1});
end
fclose(fileID);

fprintf('The new loads.dss text file has been generated!\n');
%}
