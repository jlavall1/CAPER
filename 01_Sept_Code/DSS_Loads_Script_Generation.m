%Read in a Loads.DSS and insert either LS_PhaseA LS_PhaseB LS_PhaseC
clear
clc
close all
fileloc_base='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff');
%USER_INPUT --
feeder_NUM=3;

if feeder_NUM == 0
    fileloc=strcat(fileloc_base,'\Bellhaven_Circuit_Opendss');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('Loads_Text.xlsx', 'Loads_BASE');
    
elseif feeder_NUM == 1
    fileloc=strcat(fileloc_base,'\Commonwealth_Circuit_Opendss');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('Loads_Text.xlsx', 'Loads_NCSU');
    volts='7.19976905311778';
    
elseif feeder_NUM == 2
    fileloc=strcat(fileloc_base,'\Flay_Circuit_Opendss');
    
elseif feeder_NUM == 3
    fileloc=strcat(fileloc_base,'\Roxboro_Circuit_Opendss');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('Loads_Text.xlsx', 'Loads_NCSU');
    volts='13.2040';
    load P_MULT_60s_ROX.mat
    load Q_MULT_60s_ROX.mat
    load Loads_Peak.mat %Loads_save
    load Loads_Total.mat %LoadTotals
    XKVA=[11547.333,12424.833,12044.833];
    
elseif feeder_NUM == 8
    fileloc=strcat(fileloc_base,'EPRI_ckt24');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('Loads_Text.xlsx', 'Loads_BASE');
end
%--------------
%Find annual single phase kW & kVAR:
max_kW=zeros(1,3);
max_kVAR=zeros(1,3);
min_PF=ones(1,3)*0.99;
for DOY=1:1:364
    for m=1:1:1440
        for ph=1:1:3
            PF_SAVE(DOY).DSS(m,ph) = CAP_OPS_STEP2(DOY).kW(m,ph)/(sqrt((CAP_OPS_STEP2(DOY).kW(m,ph)^2)+(CAP_OPS(DOY).DSS(m,ph)^2)));
            if CAP_OPS(DOY).DSS(m,ph) > max_kVAR(1,ph)
                max_kVAR(1,ph) = CAP_OPS(DOY).DSS(m,ph);
            end
            if CAP_OPS_STEP2(DOY).kW(m,ph) > max_kW(1,ph)
                max_kW(1,ph) = CAP_OPS_STEP2(DOY).kW(m,ph);
            end
            if PF_SAVE(DOY).DSS(m,ph) < min_PF(1,ph)
                min_PF(1,ph) = PF_SAVE(DOY).DSS(m,ph);
            end
        end
    end
end
%%
    

output_text = cell(length(CELL),1);
for i=1:1:length(CELL)
    [startIndex,endIndex]=regexp(CELL{i,5},'.','match');
    n = length(CELL{i,5});
    ref = CELL{i,5}(n-1:n);
    m = length(CELL{i,8});
    kVA = str2double(CELL{i,8}(7:m));
    if strcmp(ref,'.1')==1
        LS_txt = 'daily=LS_PhaseA';
        TOT_KW = LoadTotals.kWA;
        TOT_KVAR = LoadTotals.kVARA;
    elseif strcmp(ref,'.2')==1
        LS_txt = 'daily=LS_PhaseB';
        TOT_KW = LoadTotals.kWB;
        TOT_KVAR = LoadTotals.kVARB;
    elseif strcmp(ref,'.3')==1
        LS_txt = 'daily=LS_PhaseC';
        TOT_KW = LoadTotals.kWC;
        TOT_KVAR = LoadTotals.kVARC;
    else
        fprintf('Ruh ohhh here: %d\n',i);
    end
    kw = Loads_save(i).kW;%/TOT_KW;
    kVAR = Loads_save(i).kVAR;%/TOT_KVAR;
    %--------------
    %Load Name:
    output_text{i,1}=strcat(CELL{i,1},sprintf(' %s',CELL{i,2}));
    %Phases:
    output_text{i,1}=strcat(output_text{i,1},sprintf(' %s1',CELL{i,3}));
    %Bus:
    output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',CELL{i,5}));
    %kV:
    output_text{i,1}=strcat(output_text{i,1},sprintf(' kV=%s',volts));
    %kW:
    output_text{i,1}=strcat(output_text{i,1},sprintf(' kW=%s',num2str(kw)));
    %kVAR:
    output_text{i,1}=strcat(output_text{i,1},sprintf(' kVAR=%s',num2str(kVAR)));
    %QSTS:
    output_text{i,1}=strcat(output_text{i,1},' status=variable Vminpu=0.7');
    output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',LS_txt));
    %--------------
end

%Export strings to .txt file:
filename=strcat(fileloc,'\Loads_text.txt');
fileID=fopen(filename,'w');
for j=1:1:length(output_text)
    fprintf(fileID,'%s\r\n',output_text{j,1});
end
fclose(fileID);

fprintf('The new loads.dss text file has been generated!\n');
%}
