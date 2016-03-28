%Main code to keep track of all plotting functions created:
clear
clc
close all
%================
%Select Choice--
Feeder = 3;
Plot_NUM = 2;
%1=SOC_ref & CR_ref Sampled Days  
%2=Results of impact w/ BESS on DOY34

if Plot_NUM == 1
    %CR_ref construction, sampled Days:
    Sample_RUNS
elseif Plot_NUM == 2
    %Quick example of BESS impact:
    Show_P_V_Differences
end