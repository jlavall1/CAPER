%Plotting Monitor locations:
clear
clc
close all
%Circuit Directory:
str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Master_24hr_60sec.DSS';
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSText.command = ['Compile "',str]; 
DSSText.command ='solve loadmult=0.5';
%Pull data through COMM:
Lines_Base = getLineInfo(DSSCircObj);
Buses_Base = getBusInfo(DSSCircObj);
Loads_Base = getLoadInfo(DSSCircObj);
%Plot feeder:
hf1=figure(1);
ax1 = axes('Parent',hf1);
hold on;
gcf=plotCircuitLines(DSSCircObj,'Coloring','numPhases','MappingBackground','none');
title('Working Monitor Locations');
% --- Load Monitor locations that work ---
load DATA_SAVE1.mat
%%
j = 1;
for i=2:1:length(DATA_SAVE1)
    if DATA_SAVE1{i,2} ~= 0
        addBuses{j,1}= DATA_SAVE1{i,1}(1:end-6);
        j = j + 1;
    end
end
%%
%Find monitor coordinates:
Bus2add =getBusInfo(DSSCircObj,addBuses,1);
BusesCoords = reshape([Bus2add.coordinates],2,[])';
busHandle = plot(repmat(BusesCoords(:,2)',2,1),repmat(BusesCoords(:,1)',2,1),'ro','MarkerSize',10,'MarkerFaceColor','c','LineStyle','none','DisplayName','Bottleneck');
legend([gcf.legendHandles,busHandle'],[gcf.legendText,'Monitor Locations'] )

