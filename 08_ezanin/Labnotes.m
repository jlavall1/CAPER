% Notes from Lab meeting with Joe in Dr. Makram Lab
% Solar capacities based on town, keep address, date installed, and
% capacity 
% uses struct
% make 3D based on location
clear
clc
close all

[sort_Results,~,cell] = xlsread('Compiled_NUG_Requests.xlsx','Sales_Force');
%%
PV.County=cell(:,2);
%%
PV.kW=cell(:,20);
PV.ter=cell(:,15);
kW_sum = 0;
for i = 1:length(PV.kW)
    if strcmp(PV.ter{i,1},'Carolinas')==1 && isnan(PV.kW{i,1})==0
        kW_sum = kW_sum + PV.kW{i,1};
    end
end
disp(kW_sum)
        
