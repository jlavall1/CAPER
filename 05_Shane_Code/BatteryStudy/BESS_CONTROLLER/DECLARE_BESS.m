%Declare Battery at certain Bus:
% Battery info:
if BESS_TYPE == 1
    %High Capacity:
    BESS.Prated=1000;
    BESS.Crated=10000; %8000kWh
    BESS.DoD_max=0.80;
    BESS.Eff_DR=.967;
    BESS.Eff_CR=.93;
elseif BESS_TYPE == 2
    %Adv. Lead Acid Bat. Utility T&D
    %S15:
    BESS.Prated=1000;
    BESS.Crated=12121; %4000kWh
    BESS.DoD_max=0.33;
    BESS.Eff_DR=.967;
    BESS.Eff_CR=.93;
elseif BESS_TYPE == 3
    %Adv. Lead Acid Bat. Utility T&D
    %S15:
    BESS.Prated=1000;
    BESS.Crated=3030;
    BESS.DoD_max=0.33; %1000kWh
    BESS.Eff_DR=.967;
    BESS.Eff_CR=.93;
end
PERC_RESERVE = 100-BESS.DoD_max*100;
%{
BESS_NUM=1;

if BESS_NUM == 1
    KW_RATE = 1000; %kW
    KWh_RATE = 10000; %kWh
    PERC_STORE = 100;
    MAX_DOD = 80;
    %calc:
    PERC_RESERVE = 100-MAX_DOD;
elseif BESS_NUM == 2
    KW_RATE = 1000; %kW
    KWh_RATE = 10000; %kWh
    PERC_STORE = 100;
    MAX_DOD = 80;
end
%}
fprintf('BESS # %d was placed at bus %s rated %s kW\n',BESS_TYPE,num2str(BESS_bus),num2str(BESS.Prated));

%%
%Declare through OpenDSS:
DSSText.command=sprintf('New Storage.BESS1 Bus1=%s Phases=3 kV=12.47 kWRated=%s kWhRated=%s %reserve=%s %EffCharge=93 %EffDischarge=96.7 %Charge=0 %Discharge=0 State=IDLING',num2str(BESS_bus),num2str(BESS.Prated),num2str(BESS.Crated),num2str(PERC_RESERVE));
fprintf('Edit\n');
%DSSText.command='Edit Storage.BESS1 %stored=20';    
    

