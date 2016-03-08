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
    LC=3;
    
    %POI_loc=[63,184,771];   %   10%,25%,50%
    POI_loc=[183,183,120,27]; 
    Zsc_loc=[00,10,25,50];
    POI_pmpp=[0,10000,7100,4500];
    PV_bus=MAX_PV.SU_MIN(POI_loc(LC),9); %258903893
    PV_pmpp=POI_pmpp(LC);
    fprintf('%0.1f kW PV, %0.3f km away from sub\n',PV_pmpp,MAX_PV.SU_MIN(POI_loc(LC),6));
    if PV_ON_OFF == 1
        LC=1;
    end
    
elseif feeder_NUM == 2
    %FLAY
    load HOSTING_CAP_FLAY.mat %SU_MIN ; WN_MIN ; SU_AVG ; WN_AVG;
    %Now set where PV Farm is located:
    %PV_ON_OFF=2;
    LC=3;
    %POI Selection -- 
    POI_loc=[0,142,163,45];
    POI_pmpp=[0,3700,1000,400];
    Zsc_loc=[00,10,25,50];
    PV_bus=MAX_PV.SU_MIN(POI_loc(LC),9);
    PV_pmpp=POI_pmpp(LC);
    fprintf('%0.1f kW PV, %0.0f away from sub\n',PV_pmpp,MAX_PV.SU_MIN(POI_loc(LC),6));
    if PV_ON_OFF == 1
        LC=1;
    end
    
elseif feeder_NUM == 3
    %ROX
    load HOSTING_CAP_FLAY.mat %SU_MIN ; WN_MIN ; SU_AVG ; WN_AVG;
    %This needs to change ?!?
    LC=2;
    %POI Selection -- 
    %POI_loc=[0,142,163,45];
    POI_pmpp=[0,2000,0,0];
    Zsc_loc=[00,10,0,0];
    PV_bus=1599464;
    PV_pmpp=POI_pmpp(LC);
    %fprintf('%0.1f kW PV, %0.0f away from sub\n',PV_pmpp,MAX_PV.SU_MIN(POI_loc(LC),6));
    if PV_ON_OFF == 1
        LC=1;
    end
    
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
