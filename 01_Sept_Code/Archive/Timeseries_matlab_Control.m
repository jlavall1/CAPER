%Interative timeseries analysis so we can integrate control:
clear
clc
close all
s_b ='C:\Users\jlavall\Documents\GitHub\CAPER';
%addpath(strcat(s_b,'\01_Sept_Code'));
tic
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%Find directory of Circuit:
% 1. Obtain user's choice of simulation:
Import_PV_Farm_Datasets
DER_Planning_GUI_1
Delete_PV_Farm_Datasets
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
%%
% 1. Add paths of background files:
path = strcat(base_path,'\01_Sept_Code');
addpath(path);
path = strcat(base_path,'\04_DSCADA');
addpath(path);

% 2. Generate Real Power & PV loadshape files:
PV_Loadshape_generation
feeder_Loadshape_generation

% 3. Add PV .dss name:
str = ckt_direct;
idx = strfind(str,'\');
str = str(1:idx(8)-1);
%Make .dss name specific to what feeder you are simulating:
if feeder_NUM == 0
    %Bellhaven
    root = 'Bell';
    root1= 'Bell';
elseif feeder_NUM == 1
    %Commonwealth
    root = 'Common';
    root1= 'Common';
elseif feeder_NUM == 2
    %Flay 13.27km long --
    root = 'Flay';
    root1= 'Flay';
end

if timeseries_span == 1
    s_pv_txt = sprintf('%s_CentralPV_6hr.dss',root);
elseif timeseries_span == 2
    s_pv_txt = sprintf('%s_CentralPV_24hr.dss',root); %just added the 2
elseif timeseries_span == 3
    s_pv_txt = sprintf('%s_CentralPV_168hr.dss',root);
elseif timeseries_span == 4
    if shift+1 == 28
        s_pv_txt = sprintf('%s_CentralPV_1mnth28.dss',root);
    elseif shift+1 == 30
        s_pv_txt = sprintf('%s_CentralPV_1mnth30.dss',root);
    elseif shift+1 == 31
        s_pv_txt = sprintf('%s_CentralPV_1mnth31.dss',root);
    end
elseif timeseries_span == 5
    s_pv_txt = sprintf('%s_CentralPV_365dy.dss',root);
end
solarfilename = strcat(s,s_pv_txt);

% 4. Run Simulation:
%DSSText.command('solve mode=snap');
%DSSEnergyMeters = DSSCircuit.Meters;

%DSSText.command = 'Set Controlmode=TIME';
DSSText.command = ['Compile ',ckt_direct_prime];
DSSText.command = 'set mode = duty';
DSSCircuit.Solution.Number = 1;
DSSCircuit.Solution.Stepsize = 1;

%DSSText.command = sprintf('Set mode=duty number=1  hour=0  h=%s sec=0',num2str(FEEDER.SIM.npts),num2str(FEEDER.SIM.stepsize)); 
%DSSText.command = sprintf('Set mode=duty number=%s  stepsize=1s',num2str(FEEDER.SIM.npts));
DSSCircuit.Solution.dblHour = 0.0;
present_step = 1;
while(present_step <= FEEDER.SIM.npts)
    DSSCircuit.Solution.Solve;
    Line_Names %pull all info per time_step.
    
    
    
    
    present_step = present_step + 1
end
    
    
