%This script will select DER-PV point of common coupling (PCC) location.

%Based on results of:
%       HOSTING_CAP_FEEDER.mat

if feeder_NUM == 0
    %BELL
elseif feeder_NUM == 1
    %CMNWLTH
    load HOSTING_CAP_CMNW.mat %SU_MIN ; WN_MIN ; SU_AVG ; WN_AVG;
    %Now set where PV Farm is located:
    %PV_ON_OFF=2;
    LC=2;
    %POI_loc=[63,184,771];   %   10%,25%,50%
    POI_loc=[4,74,251]; 
    Zsc_loc=[00,10,25,272];
    POI_pmpp=[5000,5000,4000];
    PV_bus=MAX_PV.SU_MIN(POI_loc(LC),9);
    PV_pmpp=POI_pmpp(LC);
    fprintf('%0.1f kW PV at %0.0f%% of Zsc_max\n',PV_pmpp,Zsc_loc(LC));
    
elseif feeder_NUM == 2
    %FLAY
    load HOSTING_CAP_FLAY.mat %SU_MIN ; WN_MIN ; SU_AVG ; WN_AVG;
    %Now set where PV Farm is located:
    %PV_ON_OFF=2;
    LC=1;
    
    
    %POI_loc=[63,184,771];   %   10%,25%,50%
    POI_loc=[232,65,251]; 
    Zsc_loc=[00,10,25,50];
    POI_pmpp=[4000,1000,600];
    PV_bus=MAX_PV.SU_MIN(POI_loc(LC),9);
    PV_pmpp=POI_pmpp(LC);
    fprintf('%0.1f kW PV at %0.0f%% of Zsc_max\n',POI_pmpp(LC),Zsc_loc(LC));
    % 10%,25%,50% (OLD)
    %POI_loc=[232,65,251]; 
    %POI_pmpp=[4000,1000,600];
    %PV_bus=MAX_PV.SU_MIN(POI_loc(LC),9);
    %PV_pmpp=POI_pmpp(LC);
    
elseif feeder_NUM == 3
elseif feeder_NUM == 4
elseif feeder_NUM == 5
    %E.Raleigh
elseif feeder_NUM == 6
    %Mocksville 01
elseif feeder_NUM == 7
    %Mocksville 02
elseif feeder_NUM == 8
    %Mocksville 03
elseif feeder_NUM == 9
    %Mocksville 04
end
