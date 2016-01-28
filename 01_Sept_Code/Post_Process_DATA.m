%   Load dataset results:


if ckt_num == 1
    %Bellhaven:
    feeder_name = 'BELL';
    %   1]
    load RESULTS_BELL_048.mat
    RESULTS_SU_MIN=RESULTS;     %RESULTS_SU_MIN
    sort_Results_1 = xlsread('RESULTS_BELL.xlsx','BELL_048');
    %   2]
    load RESULTS_BELL_043.mat
    RESULTS_WN_MIN=RESULTS;     %RESULTS_WN_MIN
    sort_Results_2 = xlsread('RESULTS_BELL.xlsx','BELL_043');
    %   3]
    load RESULTS_BELL_070.mat
    RESULTS_SU=RESULTS;         %RESULTS_SU
    sort_Results_3 = xlsread('RESULTS_BELL.xlsx','BELL_070');
    %Feeder component files:
    load config_LOADNAMES_BELL.mat
    load config_LINENAMES_BELL.mat
    load config_XFMRNAMES_BELL.mat
    if plot_type > 2
        %Post_Process_2 background data:
        load config_DISTANCE_BELL.mat    %distance
        load config_LINESBASE_BELL.mat   %Lines_Base
        load config_LEGALBUSES_BELL.mat      %legal_buses
        load config_LEGALDISTANCE_BELL.mat  %legal_distances
        load config_BUSESBASE_BELL.mat   %Buses_Base
        begin_M = 2;
        i = 2; %skip bus3 b/c distance to sub = 0km
        ii = 2;
        n = 1;
        k = 1; %use all --
    end
    
elseif ckt_num == 2
    %Commonwealth:
    feeder_name = 'CMNW';
    %   1]
    load RESULTS_CMNW_045.mat
    RESULTS_SU_MIN=RESULTS;
    sort_Results_1 = xlsread('RESULTS_CMNW.xlsx','CMNW_045');
    %   2]
    load RESULTS_CMNW_040.mat
    RESULTS_WN_MIN=RESULTS;
    sort_Results_2 = xlsread('RESULTS_CMNW.xlsx','CMNW_040');
    %   3]
    load RESULTS_CMNW_065.mat
    RESULTS_SU=RESULTS;
    sort_Results_3 = xlsread('RESULTS_CMNW.xlsx','CMNW_065');
        
    %load RESULTS_9_18_2015.mat
    %load DISTANCE_CMNWLTH.mat
    load config_LOADNAMES_CMNWLTH.mat
    load config_LINENAMES_CMNWLTH.mat
    load config_XFMRNAMES_CMNWLTH.mat
    if plot_type > 2
        %Post_Process_2 background data:
        load config_DISTANCE_CMNWLTH.mat    %distance
        load config_LINESBASE_CMNWLTH.mat   %Lines_Base
        load config_LEGALBUSES_CMNWLTH.mat
        load config_LEGALDISTANCE_CMNWLTH.mat
        load config_BUSESBASE_CMNWLTH.mat   %Buses_Base
        begin_M = 2;
        i = 2; %skip bus3 b/c distance to sub = 0km
        ii = 2;
        n = 1;
        k = 1; %use all --
    end
elseif ckt_num == 3
    %FLAY:
    feeder_name = 'FLAY';
    %   1]
    load RESULTS_FLAY_030.mat
    RESULTS_SU_MIN=RESULTS;
    sort_Results_1 = xlsread('RESULTS_FLAY.xlsx','FLAY_030');
    %   2]
    load RESULTS_FLAY_025.mat
    RESULTS_WN_MIN=RESULTS;
    sort_Results_2 = xlsread('RESULTS_FLAY.xlsx','FLAY_025');
    %   3]
    load RESULTS_FLAY_SS_1.mat
    RESULTS_SU=RESULTS;
    sort_Results_3 = xlsread('RESULTS_FLAY.xlsx','FLAY_062');
    
    %configs:
    load config_LOADNAMES_FLAY.mat
    load config_LINENAMES_FLAY.mat
    load config_XFMRNAMES_FLAY.mat
    if plot_type > 2
        %Post_Process_2 background data:
        load config_DISTANCE_FLAY.mat
        load config_LINESBASE_FLAY.mat
        load config_LEGALBUSES_FLAY.mat
        load config_LEGALDISTANCE_FLAY.mat
        load config_BUSESBASE_FLAY.mat
        begin_M = 2;
        i = 2; %where you want to start in RESULTS
        ii = 2;
        n = 1;
        k = 1; 
    end 
elseif ckt_num == 4
    %ROX:
    feeder_name = 'ROX';
    %   1]
    %load RESULTS_ROX_042.mat
    load RESULTS_ROX_040.mat
    for n=2:1:length(RESULTS)
        if RESULTS(n,2) == 0
            RESULTS(n,2)=1.06;
            RESULTS(n,4)=RESULTS(n-1,4);
        end
    end
    RESULTS_SU_MIN=RESULTS;
    sort_Results_1 = xlsread('RESULTS_ROX.xlsx','ROX_040');
    %   2]
    load RESULTS_ROX_040.mat
    for n=2:1:length(RESULTS)
        if RESULTS(n,2) == 0
            RESULTS(n,2)=1.06;
            RESULTS(n,4)=RESULTS(n-1,4);
        end
    end
    RESULTS_WN_MIN=RESULTS;
    sort_Results_2 = xlsread('RESULTS_ROX.xlsx','ROX_040');
    %   3]
    load RESULTS_ROX_062.mat
    for n=2:1:length(RESULTS)
        if RESULTS(n,2) == 0
            RESULTS(n,2)=1.06;
            RESULTS(n,4)=RESULTS(n-1,4);
        end
    end
    RESULTS_SU=RESULTS;
    sort_Results_3 = xlsread('RESULTS_ROX.xlsx','ROX_062');
elseif ckt_num == 5
    %HOLLYSPRINGS:
    feeder_name = 'HLLY';
    %   1]
    load RESULTS_HLLY_025.mat
    RESULTS_SU_MIN=RESULTS;
    sort_Results_1 = xlsread('RESULTS_HLLY.xlsx','HLLY_025');
    %   2]
    load RESULTS_HLLY_020.mat
    RESULTS_WN_MIN=RESULTS;
    sort_Results_2 = xlsread('RESULTS_HLLY.xlsx','HLLY_020');
    %   3]
    load RESULTS_HLLY_054.mat
    RESULTS_SU=RESULTS;
    sort_Results_3 = xlsread('RESULTS_HLLY.xlsx','HLLY_054');
    
    %configs:
    load config_LOADNAMES_HLLY.mat
    load config_LINENAMES_HLLY.mat
    load config_XFMRNAMES_HLLY.mat
    if plot_type > 2
        %Post_Process_2 background data:
        load config_DISTANCE_HLLY.mat
        load config_LINESBASE_HLLY.mat
        load config_LEGALBUSES_HLLY.mat
        load config_LEGALDISTANCE_HLLY.mat
        load config_BUSESBASE_HLLY.mat
        load config_Zsc_HLLY.mat    %SC_Imped
        begin_M = 2;
        i = 2; %where you want to start in RESULTS
        ii = 2;
        n = 1;
        k = 1; 
    end 
elseif ckt_num == 6
    %ERALEIGH:
    feeder_name = 'ERAL';
    %   1]
    load RESULTS_ERAL_056.mat
    RESULTS_SU_MIN=RESULTS;
    sort_Results_1 = xlsread('RESULTS_ERAL.xlsx','ERAL_056');
    %   2]
    load RESULTS_ERAL_050.mat
    RESULTS_WN_MIN=RESULTS;
    sort_Results_2 = xlsread('RESULTS_ERAL.xlsx','ERAL_050');
    %   3]
    load RESULTS_ERAL_075.mat
    RESULTS_SU=RESULTS;
    sort_Results_3 = xlsread('RESULTS_ERAL.xlsx','ERAL_075');
    
    %configs:
    load config_LOADNAMES_ERAL.mat
    load config_LINENAMES_ERAL.mat
    load config_XFMRNAMES_ERAL.mat
    if plot_type > 2
        %Post_Process_2 background data:
        load config_DISTANCE_ERAL.mat
        load config_LINESBASE_ERAL.mat
        load config_LEGALBUSES_ERAL.mat
        load config_LEGALDISTANCE_ERAL.mat
        load config_BUSESBASE_ERAL.mat
        load config_Zsc_ERAL.mat    %SC_Imped
        begin_M = 2;
        i = 2; %where you want to start in RESULTS
        ii = 2;
        n = 1;
        k = 1; 
    end 
elseif ckt_num == 7
    load RESULTS_9_14_2015.mat
    load DISTANCE.mat
    load config_LOADNAMES_CKT7.mat
    load config_LINENAMES_CKT7.mat
    load config_XFMRNAMES_CKT7.mat
    sort_Results = xlsread('RESULTS_SORTED.xlsx','9_14_1');
end