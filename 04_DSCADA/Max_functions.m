%Max Function
clear
clc

gui_response = GUI_DSCADA_Locations;
base_path = gui_response{1,1};
feeder_NUM = gui_response{1,2}; %0 to 8 (1-9)
action = gui_response{1,3};
maindir = gui_response{1,4};
maindir=strcat(maindir,'\04_DSCADA');
addpath(maindir);
path = strcat(maindir,'\Feeder_Data');
addpath(path);


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
% Finds max P & Q for year
MAX.YEAR.KW.A = max(FEEDER.kW.A);
MAX.YEAR.KW.B = max(FEEDER.kW.B);
MAX.YEAR.KW.C = max(FEEDER.kW.C);
MAX.YEAR.KVAR.A = max(FEEDER.kVAR.A);
MAX.YEAR.KVAR.B = max(FEEDER.kVAR.B);
MAX.YEAR.KVAR.C = max(FEEDER.kVAR.C);


months = [31,28,31,30,31,30,31,31,30,31,30,31];
Points = zeros(12,1);
Days = zeros(12,1);
MAX.MONTH.KW.A = 0;
sum = 0;

% Finds maxes for each month
for i=1:12
    MAX.MONTH.KW.A(i,1) = 0;
    Days(i) = months(i);
    Points(i) = Days(i)*60*24;
    
    for j=sum+1:Points(i)+sum
        if FEEDER.kW.A(j,1) > MAX.MONTH.KW.A(i,1)
            MAX.MONTH.KW.A(i,1) = FEEDER.kW.A(j,1);
        end

    end
    
    sum = sum + Points(i);
end

























