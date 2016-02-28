%Timeseries Analyses:
clear
clc
close all
s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
%addpath(strcat(s_b,'\01_Sept_Code'));

%Setup the COM server
%{
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%}
%Find directory of Circuit:
% 1. Obtain user's choice of simulation:

Import_PV_Farm_Datasets
DER_Planning_GUI_1
Delete_PV_Farm_Datasets
gui_response = STRING_0;

%load SHC_CMNW.mat %gui_response
%load time_60s_base_Flay.mat
%load time_60s_base_Annual_Flay.mat % GUI response that was saved.

ckt_direct      = gui_response{1,1}; %entire directory string of where the cktfile is locatted
feeder_NUM      = gui_response{1,2};
scenerio_NUM    = gui_response{1,3}; %1=VREG-top ; 2=VREG-bot ; 3=steadystate ; 4=RR_up ; 5=RR_down; 6=SC Study
base_path       = gui_response{1,4};  %github directory based on user's selected comp. choice;
cat_choice      = gui_response{1,5}; %DEC DEP EPRI;
Static_Host     = gui_response{1,6}; %1=YES ; 0=NO
PV_Site         = gui_response{1,7}; %( 1 - 7) site#s;
PV_Site_path    = gui_response{1,8}; %directory to PV kW file:
timeseries_span = gui_response{1,9}; %(1) day ; (1) week ; (1) year ; etc.
VRR_Scheme      = gui_response{1,10};%DSS, Sequential, Time Int, V_avg
DARR_category   = gui_response{1,11};%(1)Stabe through (5)Unstable.
VI_USER_span    = gui_response{1,12}; %VI selection
CI_USER_slt     = gui_response{1,13}; %CI selection
time_int        = gui_response{1,14};%timestep length
QSTS_select     = gui_response{1,15};%selective timeseries run:
PV_ON_OFF       = gui_response{1,16};%1=off & 2=on;
%PV_pmpp         = gui_response{1,17};%kw
PV_location     = gui_response{1,18};
SHC_LoadLVL     = gui_response{1,19};
%%
% 1. Add paths of background files:
path = strcat(base_path,'\01_Sept_Code');
addpath(path);
path = strcat(base_path,'\04_DSCADA');
addpath(path);
%%
% 2. Select algo that user wants:
if Static_Host == 1
    %User wants static hosting cap. algo.
    if scenerio_NUM < 6
        path = strcat(base_path,'\01_Sept_Code\03_Static_DG_Hosting_Cap');
        addpath(path);
        Hosting_Cap_stream
    else
        Fault_Study
    end
else
    % 2. Generate Real Power & PV loadshape files:
    if QSTS_select == 0
        %Algorithm will only conduct one simulation span not multiple:
        QSTS_1_Span
    elseif QSTS_select == 4
        %Pre-main Algo:
        path = strcat(base_path,'\01_Sept_Code\04_QSTS_Solar_Coeff');
        addpath(path);
        Pre_QSTS_365_Span
        PV_SITE_DATA_import
        %Annual run of base case for LTC operations:
        QSTS_365_Span %just added _Quick
    end
end
    
    