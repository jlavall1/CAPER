% Notes from Lab meeting with Joe in Dr. Makram Lab
% Solar capacities based on town, keep address, date installed, and
% capacity 

% make 3D based on location

% house keeping commands
clear
clc
close all

%load all data drom NUG requests
[sort_Results,~,cell] = xlsread('Compiled_NUG_Requests.xlsx','Sales_Force');

%Create PV struct
PV.County=cell(:,2);
PV.kW=cell(:,20);
PV.ter=cell(:,15);

%sum of total capacity for all NUG requests in Carolinas 
kW_sum_Carolinas = 0;
for i = 1:length(PV.kW)
    if strcmp(PV.ter{i,1},'Carolinas')==1 && isnan(PV.kW{i,1})==0
        kW_sum_Carolinas = kW_sum_Carolinas + PV.kW{i,1};
    end
end
%fprintf('The sum of the capacity in the Carolina''s is %0.4e \n',kW_sum_Carolinas)

%sum of total capacity for all NUG requests in PEC Carolinas
kW_sum_PEC_Carolinas = 0;
for i = 1:length(PV.kW)
    if strcmp(PV.ter{i,1},'PEC Carolinas')==1 && isnan(PV.kW{i,1})==0
        kW_sum_PEC_Carolinas = kW_sum_PEC_Carolinas + PV.kW{i,1};
    end
end
%fprintf('The sum of the capacity in the PEC Carolina''s is %0.4e \n',kW_sum_PEC_Carolinas)


        
