%This script will select DER-PV point of common coupling (PCC) location.

%Based on results of:
%       HOSTING_CAP_FEEDER.mat
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);
PV_SCEN=menu('What PV Scenerio','NO PV','PV1 (2-3MW)','PV2 (0.5MW)','BOTH PVs');
while section<1
    PV_SCEN=menu('What PV Scenerio','NO PV','PV1 (2-3MW)','PV2 (0.5MW)','BOTH PVs');
end
    
    

%FLAY
load HOSTING_CAP_FLAY.mat %SU_MIN ; WN_MIN ; SU_AVG ; WN_AVG;
%MAX_PV.headers={'MHC','Bus # Index in Lines Distance','Reason for
%Violation (1.05=HV & >100=Thermal)','km','Rsc','Zsc','Ampacity of
%immediate upstream line from POI','kW thru power','Bus Name'}
%Now set where PV Farm is located:

%POI saved locations:
POI_loc=[143,164,46,46]; %BESS, PV1, PV2
Zsc_loc=[00,10,25,50];
%FNC=1; %1=Chapter4 2=Chapter 5


if PV_SCEN == 1
    %BASE CASE
    LC=1;
    POI_pmpp=[5,3000,500,400]; %5kW default when not running PV (was 4MW but wayyy too big)
    PV_pmpp=POI_pmpp(LC);
    PV1_bus=MAX_PV.SU_MIN(POI_loc(LC),9);
    fprintf('BASE: %0.1f kW PV, %0.3f km away from sub\n',PV_pmpp,MAX_PV.SU_MIN(POI_loc(LC),6));
    fprintf('file ending: %s\n',num2str(Zsc_loc(LC)));
elseif PV_SCEN == 2
    %Only PV1
    LC=2;
    POI_pmpp=[5,3000,500,400];
    PV1_pmpp=POI_pmpp(LC);
    PV1_bus=MAX_PV.SU_MIN(POI_loc(LC),9);
    fprintf('%0.1f kW PV, %0.3f km away from sub\n',PV1_pmpp,MAX_PV.SU_MIN(POI_loc(LC),6));
    fprintf('At Bus=%d\n',PV1_bus);
    fprintf('file ending: %s\n',num2str(Zsc_loc(LC)));
elseif PV_SCEN == 3
    %Only PV2
    LC=3;
    POI_pmpp=[5,3000,500,400];
    PV2_pmpp=POI_pmpp(LC);
    PV2_bus=MAX_PV.SU_MIN(POI_loc(LC),9);
    fprintf('%0.1f kW PV, %0.3f km away from sub\n',PV2_pmpp,MAX_PV.SU_MIN(POI_loc(LC),6));
    fprintf('At Bus=%d\n',PV2_bus);
    fprintf('file ending: %s\n',num2str(Zsc_loc(LC)));
elseif PV_SCEN == 4
    %BESS, PV1, & PV2
    BESS_bus=(MAX_PV.WN_MIN(POI_loc(1),9));
    PV1_bus=(MAX_PV.WN_MIN(POI_loc(2),9));
    PV2_bus=(MAX_PV.WN_MIN(POI_loc(3),9));
    
    POI_pmpp=[1000,4000,500,0]; %1000kW BESS, 4MW PV1, 0.5MW PV2
    fprintf('BESS,PV1,PV2 connected\n');
end
    
    

