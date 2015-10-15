%Max Function
clear
clc

gui_response = GUI_DSCADA_Locations;
feeder_NUM = gui_response{1,2}; %0 to 8 (1-9)
action = gui_response{1,3};
maindir = gui_response{1,4};
maindir=strcat(maindir,'\04_DSCADA');
addpath(maindir);
path = strcat(base_path,'\04_DSCADA\Feeder_Data');
addpath(path);

%%
if feeder_NUM == 0
    load BELL.mat
    FEEDER = BELL;
    clearvars BELL
    kW_peak = [0,0,0];
elseif feeder_NUM == 1
    load COMN.mat
    FEEDER = COMN;
    clearvars COMN
    kW_peak = [2.475021572579630e+03,2.609588847297235e+03,2.086659558753901e+03];
elseif feeder_NUM == 2
    load FLAY.mat
    FEEDER = FLAY;
    clearvars FLAY
    kW_peak = [1.424871573296857e+03,1.347528364235151e+03,1.716422704604557e+03];
elseif feeder_NUM == 3
    load ROX.mat
    FEEDER = ROX;
    clearvars ROX
    kW_peak = [3.189154306704542e+03,3.319270338767296e+03,3.254908188719974e+03];
elseif feeder_NUM == 4
    load HOLLY.mat
elseif feeder_NUM == 5
    load ERalh.mat
end

%%
% what is the format for the max functions??
MAX.YEAR.KW.A = max();
MAX.YEAR.KW.B = max();
MAX.YEAR.KW.C = max();
MAX.YEAR.KVAR.A = max();
MAX.YEAR.KVAR.B = max();
MAX.YEAR.KVAR.C = max();

% Several loops for each max for the month??
interval = length(FEEDER) / 14;
MAX.MONTH.KW.A = FEEDER(1);

i=1;
j=1;

for i=1:interval:length(FEEDER)
    for j=1:i
        if FEEDER(j) > MAX.MONTH.KW.A
            MAX.MONTH.KW.A = FEEDER(j);
        end
    end
end

























