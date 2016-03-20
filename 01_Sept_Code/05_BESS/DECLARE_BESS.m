%Declare Battery at certain Bus:
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
fprintf('BESS # %d was placed at bus %s rated %s kW\n',BESS_NUM,num2str(BESS_bus),num2str(KW_RATE));

%%
%Declare through OpenDSS:
DSSText.command=sprintf('New Storage.BESS1 Bus1=%s Phases=3 kV=12.47 kWRated=%s kWhRated=%s %reserve=%s %EffCharge=93 %EffDischarge=96.7 State=IDLING',num2str(BESS_bus),num2str(KW_RATE),num2str(KWh_RATE),num2str(PERC_RESERVE));
fprintf('Edit\n');
DSSText.command='Edit Storage.BESS1 %stored=100';    
    

