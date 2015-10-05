%Start Simulation & load correct datasets based on GUI:
clc
clear
close all
DER_Planning_GUI([1400 100 800 1600])
%%
% -- Now respond to user info --
%Update main directory to folder w/ circuits:
%{
if comp_choice==1
    %JML Home Desktop
    s1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
    s_b = 'C:\Users\jlavall\Documents\GitHub\CAPER';
elseif comp_choice==2
    %JML Laptop
    s1 = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
    s_b = 'C:\Users\jlavall\Documents\GitHub\CAPER';
elseif comp_choice==3
    %Brians Comp
    s1 = 'C:\Users\Brian\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
    s_b = 'C:\Users\Brian\Documents\GitHub\CAPER';
elseif comp_choice==4
    %RTPIS_7
    s1 = 'C:';
elseif comp_choice==5
    s1 = 'C:';
end
%}
%%