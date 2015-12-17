%Timeseries Analyses:
clear
clc
close all
s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
%addpath(strcat(s_b,'\01_Sept_Code'));
tic
%Setup the COM server
%{
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%}
%Find directory of Circuit:
% 1. Obtain user's choice of simulation:
%{
Import_PV_Farm_Datasets
DER_Planning_GUI_1
Delete_PV_Farm_Datasets
gui_response = STRING_0;
%}
%load time_60s_base_Flay.mat
load time_60s_base_Annual_Flay.mat
gui_response = STRING_0;
ckt_direct      = gui_response{1,1}; %entire directory string of where the cktfile is locatted
feeder_NUM      = gui_response{1,2};
scenerio_NUM    = gui_response{1,3}; %1=VREG-top ; 2=VREG-bot ; 3=steadystate ; 4=RR_up ; 5=RR_down
base_path       = gui_response{1,4};  %github directory based on user's selected comp. choice;
cat_choice      = gui_response{1,5}; %DEC DEP EPRI;
PV_Site         = gui_response{1,7}; %( 1 - 7) site#s;
PV_Site_path    = gui_response{1,8}; %directory to PV kW file:
timeseries_span = gui_response{1,9}; %(1) day ; (1) week ; (1) year ; etc.
monthly_span    = gui_response{1,10};%(1) Month selected ; 1=JAN 12=DEC.
DARR_category   = gui_response{1,11};%(1)Stabe through (5)Unstable.
VI_USER_span    = gui_response{1,12};
CI_USER_slt     = gui_response{1,13};
time_int        = gui_response{1,14};%timestep length
QSTS_select     = gui_response{1,15};%selective timeseries run:
PV_ON_OFF       = gui_response{1,16};%1=off & 2=on;
%PV_pmpp         = gui_response{1,17};%kw
PV_location     = gui_response{1,18};
%{ 
STRING_0{1,1} = STRING;
STRING_0{1,2} = ckt_num;
STRING_0{1,3} = sim_type;
STRING_0{1,4} = s_b;
STRING_0{1,5} = cat_choice;
STRING_0{1,6} = section_type;
STRING_0{1,7} = PV_location;
STRING_0{1,8} = PV_dir;
STRING_0{1,9} = time_select;
STRING_0{1,10} = mnth_select;
STRING_0{1,11} = DARR_cat;
STRING_0{1,12} = VI;
%}

% 1. Add paths of background files:
path = strcat(base_path,'\01_Sept_Code');
addpath(path);
path = strcat(base_path,'\04_DSCADA');
addpath(path);


% 2. Generate Real Power & PV loadshape files:
if QSTS_select == 0
    %Algorithm will only conduct one simulation span not multiple:
    QSTS_1_Span
elseif QSTS_select == 4
    %Pre-main Algo:
    Pre_QSTS_365_Span
    %Annual run of base case for LTC operations:
    QSTS_365_Span %just added _Quick
end
    
    