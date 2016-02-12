%Import Substation Data, re-structure, check for NaN:
maindir = 'C:\Users\jlavall\Documents\GitHub\CAPER';
maindir = strcat(maindir,'\04_DSCADA\MOCKS');
addpath(maindir);
[MSVL_2401, Time, ~] = xlsread('MocksvilleMn_2401.xlsx', 'MocksvilleMn_2401');



for j=1:1:1
    if j == 1
        MSVL=MSVL_2401;
    elseif j == 2
        MSVL=MSVL_2402;
    end
    %Restructure:
    FEED.KW(:,1) = MSVL(:,1);
    FEED.KW(:,2) = MSVL(:,3);
    FEED.KW(:,3) = MSVL(:,5);
    FEED.KVAR(:,1) = MSVL(:,2);
    FEED.KVAR(:,2) = MSVL(:,4);
    FEED.KVAR(:,3) = MSVL(:,6);
    FEED.AMPS(:,1) = MSVL(:,7);
    FEED.AMPS(:,2) = MSVL(:,8);
    FEED.AMPS(:,3) = MSVL(:,9);
    FEED.PI_time = MSVL(:,10);
    FEED.TIME = Time(3:end,1);
end
    
        