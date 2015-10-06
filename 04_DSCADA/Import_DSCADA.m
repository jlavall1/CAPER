%Data from DEP_CAPER_FEEDER_LOADS IN THE 04_DSCADA FOLDER
%   ->Clear workspace, prompt user, and addpaths
clear
clc
close all
gui_response = GUI_DSCADA_Locations;
ckt_num = gui_response{1,2}; %0 to 8 (1-9)
action = gui_response{1,3};
maindir = gui_response{1,4};
maindir=strcat(maindir,'\04_DSCADA');
addpath(maindir);


%%
if action == 1 || action == 4
    %Import data from Excel file
    if ckt_num == 0
        [RAW_DATA, ~, ~] = xlsread('DEC_CAPER_FEEDER_LOADS.xlsx', 'Bellhaven_12_04');
    elseif ckt_num == 1
        [RAW_DATA, ~, ~] = xlsread('DEC_CAPER_FEEDER_LOADS.xlsx', 'Commonwealth_12_05');
    elseif ckt_num == 2
        [RAW_DATA, ~, ~] = xlsread('DEC_CAPER_FEEDER_LOADS.xlsx', 'Flay_12_01');
    elseif ckt_num == 3
        [RAW_DATA, ~, ~] = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'RidgeRd');
    elseif ckt_num == 4
        [RAW_DATA, ~, ~] = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'feltonsville');
    elseif ckt_num == 5
        [RAW_DATA, ~, ~] = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'Wilmington');
    end
    % Organize into structs
    n = length(RAW_DATA);
    if ckt_num > 2
        FEED.Voltage.A = RAW_DATA(:, 6);
        FEED.Voltage.B = RAW_DATA(:, 8);
        FEED.Voltage.C = RAW_DATA(:, 10);
        FEED.Amp.A = RAW_DATA(:, 7);
        FEED.Amp.B = RAW_DATA(:, 9);
        FEED.Amp.C = RAW_DATA(:, 11);
        FEED.kW.A = RAW_DATA (:, 13);
        FEED.kW.B = RAW_DATA (:, 15);
        FEED.kW.C = RAW_DATA (:, 17);
        FEED.kVAR.A = RAW_DATA (:, 14);
        FEED.kVAR.B = RAW_DATA (:, 16);
        FEED.kVAR.C = RAW_DATA (:, 18);
        FEED.PI_time = RAW_DATA(:,3);
    else
        FEED.Voltage.A = RAW_DATA(:, 17);
        FEED.Voltage.B = RAW_DATA(:, 18);
        FEED.Voltage.C = RAW_DATA(:, 19);        
        FEED.kW.A = RAW_DATA (:, 3);
        FEED.kW.B = RAW_DATA (:, 5);
        FEED.kW.C = RAW_DATA (:, 7);
        FEED.kVAR.A = RAW_DATA (:, 9);
        FEED.kVAR.B = RAW_DATA (:, 11);
        FEED.kVAR.C = RAW_DATA (:, 13);
        FEED.Amp.A = RAW_DATA (:, 27);
        FEED.Amp.B = RAW_DATA (:, 28);
        FEED.Amp.C = RAW_DATA (:, 29);
    end
end
%%
%Load exsisting Data:
if action > 1
    tic
    maindir=strcat(maindir,'\Feeder_Data');
    addpath(maindir);
    %Load desired data:
    if ckt_num == 0
        load('BELL.mat');
        V_BASE = 12.47/sqrt(3);
        FEED = BELL;
    elseif ckt_num == 1
        load('CMNWLTH.mat');
        V_BASE = 12.47/sqrt(3);
        FEED = CMNWLTH;
    elseif ckt_num == 2
        load('FLAY.mat');
        V_BASE = 12.47/sqrt(3);
        FEED = FLAY;
    elseif ckt_num == 3
        load('ROX.mat');
        V_BASE = 23.9e3/sqrt(3);
        FEED = ROX;
    elseif ckt_num == 4
        load('HOLLY.mat');
        V_BASE = 23.9e3/sqrt(3);
        FEED = HOLLY;
    elseif ckt_num == 5
        load('ERALEIGH.mat');
        V_BASE = 12.47e3/sqrt(3);
        FEED = ERALEIGH;
    end
    %Find length of dataset:
    n = length(FEED.Voltage.A);
end
%%
if action == 2
    %Timestamp Check choice:
    NAME = ({'Voltage.A'; 'Voltage.B'; 'Voltage.C'; 'Amp.A'; 'Amp.B';...
            'Amp.C'; 'kW.A'; 'kW.B'; 'kW.C'; 'kVAR.A'; 'kVAR.B'; 'kVAR.C'});%Declare NAME = cell(9,1);
    months = [31,28,31,30,31,30,31,31,30,31,30,31,31,28,31];
    ref = zeros(n,5);
    Y = 2014;
    M = 1;
    D = 1;
    H = 0;
    MIN = 0;
    tic
    % loop runs through entire set of data
    for i = 1:1:n
        ref(i,1) = M;       % updates to reference matrix
        ref(i,2) = D;
        ref(i,3) = H;
        ref(i,4) = MIN;
        ref(i,5) = datenum(Y,M,D,H,MIN,0);
       MIN=MIN+15;          % increment minute for every 15

       if MIN ==60
           MIN = 0;
           H = H + 1;           % increment hour every 60 mins
           if H == 24
               H = 0;
               D = D + 1;       % increment day every 24 hours
               if D > months(M);
                   D =1 ;
                   M = M + 1;   % increment month 
               end
           end
       end
    end
    toc
    %Check for difference between matlabtime and excel time:
    tic
    DateTime = sum(FEED.PI_time,2);
    diff = zeros(n,1);
    str = datestr(DateTime+datenum('30-Dec-1899'));
    for i=1:1:length(FEED.PI_time);
        FEED.excel_time{i,1} = cellstr(str(i,1:20));
        FEED.NUM_time(i,1) = datenum(FEED.excel_time{i,1});
        FEED.ref_time{i,1} = datestr(ref(i,5));
        if FEED.NUM_time(i,1) ~= ref(i,5)
            diff(i,1) = FEED.NUM_time(i,1) - ref(i,5);
        end
    end
    toc
    plot(diff(:,1));
end
%%
if action > 2
    %Preprocess of Filtering out Data Errors:

    HOLD = zeros(2,10); %A cache of troubled datapoints
    i = 1;
    j = 1;
    k = 1;
    POS = 1;
    struct = 1;
    E_hold = 0;
    E_count = 0;
    Errors = zeros(3,2); 

    while struct < 4
        if struct == 1
            data = FEED.Voltage.A(:,1);
        elseif struct == 2
            data = FEED.Voltage.B(:,1);
        elseif struct == 3
            data = FEED.Voltage.C(:,1);
        elseif struct == 4
            data = FEED.Amp.A(:,1);
        elseif struct == 5
            data = FEED.Amp.B(:,1);
        elseif struct == 6
            data = FEED.Amp.C(:,1);
        elseif struct == 7
            data = FEED.kW.A(:,1);
        elseif struct == 8
            data = FEED.kW.B(:,1);
        elseif struct == 9
            data = FEED.kW.C(:,1);
        elseif struct == 10
            data = FEED.kVAR.A(:,1);
        elseif struct == 11
            data = FEED.kVAR.B(:,1);
        elseif struct == 12
            data = FEED.kVAR.C(:,1);
        end
        while i < n+1

            if isnan(data) == 1
                if i ~= 1
                    HOLD(1,j+1) = j;
                    if j ==1
                        HOLD(2,j) = data(i-1,POS); %grab last real value.
                        BEGIN = HOLD(2,j);
                    end
                    j = j + 1;
                end    
            %Change  to actual reading.
            elseif data(i,POS) < V_BASE*0.75 && struct < 10
                HOLD(1,j+1) = j;
                if j == 1
                    HOLD(2,j) = data(i-1,POS); %grab last real value.
                    BEGIN = HOLD(2,j);
                end
                j = j + 1;
            elseif data(i,POS) > V_BASE*1.25 && struct < 4
                HOLD(1,j+1) = j;
                if j == 1
                    HOLD(2,j) = data(i-1,POS); %grab last real value.
                    BEGIN = HOLD(2,j);
                end
                j = j + 1;
            %A string of errors was discovred.
            elseif j ~= 1 && data(i,1) >= -20
                %ERROR String ENDED!
                HOLD(2,j+1) = data(i,POS); %grabs most recent real value.
                END = HOLD(2,j+1);
                NUM = HOLD(1,j);

                DIFF = (END-BEGIN)/(NUM+1);

                %Estimate & Replace Irradiance measurements:
                while k < NUM+1
                    HOLD(2,k+1) = HOLD(2,k)+DIFF;
                    data(i-j+k,POS) = HOLD(2,k+1); %replace exsisting:
                    k = k + 1;
                end

                %save in correct struct:
                if struct == 1
                    FEED.Voltage.A(:,1) = data(:,1);
                elseif struct == 2
                    FEED.Voltage.B(:,1) = data(:,1);
                elseif struct == 3
                    FEED.Voltage.C(:,1) = data(:,1);
                elseif struct == 4
                    FEED.Amp.A(:,1) = data(:,1);
                elseif struct == 5
                    FEED.Amp.B(:,1) = data(:,1);
                elseif struct == 6
                    FEED.Amp.CA(:,1) = data(:,1);
                elseif struct == 7
                    FEED.kW.A(:,1) = data(:,1);
                elseif struct == 8
                    FEED.kW.B(:,1) = data(:,1);
                elseif struct == 9
                    FEED.kW.C(:,1) = data(:,1);
                elseif struct == 10
                    FEED.kVAR.A(:,1) = data(:,1);
                elseif struct == 11
                    FEED.kVAR.B(:,1) = data(:,1);
                elseif struct == 12
                    FEED.kVAR.C(:,1) = data(:,1);
                end

                %Reset Variables:
                j = 1;
                k = 1;
                HOLD = zeros(2,10);
            end
            i = i+1;
        end
        i = 1;    
        struct = struct+1
    end
end
%%
if action == 1 || action == 3 || action == 4
% Save newly created variable:
    if ckt_num == 0
        filename = strcat(maindir,'\Feeder_Data\BELL.mat');
        delete(filename);
        BELL=FEED;
        save(filename,'BELL');
    elseif ckt_num == 1
        filename = strcat(maindir,'\Feeder_Data\CMNWLTH.mat');
        delete(filename);
        CMNWLTH=FEED;
        save(filename,'CMNWLTH');
    elseif ckt_num == 2
        filename = strcat(maindir,'\Feeder_Data\FLAY.mat');
        delete(filename);
        FLAY=FEED;
        save(filename,'FLAY');
    elseif ckt_num == 3
        filename = strcat(maindir,'\Feeder_Data\ROX.mat');
        delete(filename);
        ROX=FEED;
        save(filename,'ROX');
    elseif ckt_num == 4
        filename = strcat(maindir,'\Feeder_Data\HOLLY.mat');
        delete(filename);
        HOLLY=FEED;
        save(filename,'HOLLY');
    elseif ckt_num == 5
        filename = strcat(maindir,'\Feeder_Data\ERALEIGH.mat');
        delete(filename);
        ERALEIGH=FEED;
        save(filename,'ERALEIGH');
    end
end
%%
if action == 2 || action == 3 || action == 4
    fig = 1;
    figure(fig)
    subplot(2,3,1)
    plot(FEED.Voltage.A,'r-');
    xlabel('time interval');
    ylabel('Voltage (V)');
    subplot(2,3,2)
    plot(FEED.Voltage.B,'g-');
    xlabel('time interval');
    ylabel('Voltage (V)');
    subplot(2,3,3)
    plot(FEED.Voltage.C,'b-');
    xlabel('time interval');
    ylabel('Voltage (V)');
    subplot(2,3,4)
    %Current:
    plot(FEED.Amp.A,'r-');
    xlabel('time interval');
    ylabel('Current(A)');
    subplot(2,3,2)
    plot(FEED.Amp.B,'g-');
    xlabel('time interval');
    ylabel('Current (A)');
    subplot(2,3,3)
    plot(FEED.Amp.C,'b-');
    xlabel('time interval');
    ylabel('Current (A)');
    
    %Save results:
    if ckt_num == 0
        %[RAW_DATA, ~, ~] = xlsread('DEC_CAPER_FEEDER_LOADS.xlsx', 'Bellhaven_12_04');
        FEED = BELL;
    elseif ckt_num == 1
        %[RAW_DATA, ~, ~] = xlsread('DEC_CAPER_FEEDER_LOADS.xlsx', 'Commonwealth_12_05');
    elseif ckt_num == 2
        %[RAW_DATA, ~, ~] = xlsread('DEC_CAPER_FEEDER_LOADS.xlsx', 'Flay_12_01');
    elseif ckt_num == 3
        %[RAW_DATA, ~, ~] = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'RidgeRd');
    elseif ckt_num == 4
        %[RAW_DATA, ~, ~] = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'feltonsville');
    elseif ckt_num == 5
        %[RAW_DATA, ~, ~] = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'Wilmington');
    end
end



