%Plot results of feeder:
clear
clc
feeder_NUM=2;
if feeder_NUM == 0
    %Bellhaven --
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Bellhaven_Circuit_Opendss';
    addpath(temp_dir)
elseif feeder_NUM == 1
    %Commonwealth --
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss';
    addpath(temp_dir)
elseif feeder_NUM == 2
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss';
    addpath(temp_dir)
    load Lines_Monitor.mat %Lines_Distance
end
load TIME_RESULTS.mat %Lines_Distance
fig = 0;
%%
fig = fig + 1;
figure(fig);
t = 1;
D_ones = ones(length(DATA_SAVE),1);
for i=1:1:length(DATA_SAVE)
    
    plot(DATA_SAVE(i,1).distance,DATA_SAVE(i,1).phaseV(t,1),'r-');
    hold on
    plot(DATA_SAVE(i,1).distance,DATA_SAVE(i,1).phaseV(t,2),'g-');
    hold on
    plot(DATA_SAVE(i,1).distance,DATA_SAVE(i,1).phaseV(t,3),'b-');
    hold on
end
    