clear
clc
close all
fig = 0;
maindir = 'C:\Users\jlavall\Documents\GitHub\CAPER';
addpath(strcat(maindir,'\04_DSCADA\Feeder_Data'));
maindir = strcat(maindir,'\04_DSCADA\MOCKS');
addpath(maindir);
%Load DSCADA data:
load MOCKS.mat

%Make sure there are no holes:
for n=1:1:4
    for t=1:1:8760
        for ph=1:1:3
            if isnan(MOCK_2014.Feeder(n).KW_1PH(t,ph)) == 1
                fprintf('Feeder %d: Hour=%d\n',n,t);
                MOCK_2014.Feeder(n).KW_1PH(t,ph)=(MOCK_2014.Feeder(n).KW_1PH(t-1,ph)+MOCK_2014.Feeder(n).KW_1PH(t+1,ph))/2;
            end
        end
    end
end
fprintf('Second Check\n');
for n=1:1:4
    for t=1:1:8760
        for ph=1:1:3
            if isnan(MOCK_2014.Feeder(n).KW_1PH(t,ph)) == 1
                fprintf('Feeder %d: Hour=%d\n',n,t);
                %MOCK_2014.Feeder(n).KW_1PH(t,ph)=(MOCK_2014.Feeder(n).KW_1PH(t-1,ph)+MOCK_2014.Feeder(n).KW_1PH(t+1,ph))/2;
            end
        end
    end
end
            


