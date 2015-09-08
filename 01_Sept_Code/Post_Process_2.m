%Post_Process --PART II--
%Coding to replicate Figure 5 & Figure 6:

%%
clear
clc
%import numpy as np
%import matplotlib.pyplot as plt

% "PV size & distance effect on max bus voltage under 50% load"
load RESULTS_9_3_2015.mat
sort_Results = xlsread('RESULTS_SORTED.xlsx');
load DISTANCE.mat
load config_LOADNAMES.mat
load config_LINENAMES.mat
load config_XFMRNAMES.mat
load config_BUSNAMES.mat
load config_LINESBASE.mat
%Find where bus hits legal bus & distance from substation:
j = 1;
PV_LOC = zeros(201,2);
ii = 5;
while ii< length(Buses) %length(Buses)
    s1 = Buses(ii,1).name;
    s2 = '.1.2.3';
    s = strcat(s1,'.1.2.3');
    
    %Skip BUS if not 3-ph & connected to 12.47:
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).voltage > 6000
        for i=1:1:length(Lines_Base)
            if strcmp(Lines_Base(i,1).bus1,s) == 1 %Bus name matches:
                if Lines_Base(i,1).numPhases == 3
                    PV_LOC(j,1) = i;
                    PV_LOC(j,2) = DISTANCE(i,1);
                    j = j + 1;
                end
            end
        end
    end
    ii = ii + 1;
end
j = 1;
m = 1;
n = 1;
for i=1:1:10000
    RESULTS(i,7) = PV_LOC(n,2);
    if m == 50
        %move onto next bus:
        m = 1;
        n = n + 1;
    else
        m = m + 1;
    end  
end

%%
%Plot Fig. 6:
fig = 1;
figure(fig);
x = RESULTS(1:10000,7);
y = RESULTS(1:10000,3);
x_pv = RESULTS(1:10000,1);

colormap('jet');
cmap = colormap;
lineHandles = scatter(x,y,10,x_pv);
%Create & edit colorbar:
c = colorbar('location','eastoutside');
% pos1 = get(c,'position');
%p = [x,y,width]
% pos1(1,1) = pos1(1,1);
% set(c,'position',pos1);

%Edit title string:
set(get(c,'title'),'string','PV Size (kW)','Rotation',90.0,'FontWeight','bold');
pos = get(get(c,'title'),'position');
pos(1,1) = pos(1,1)+2.5;
pos(1,2) = pos(1,2)*0.5;
set(get(c,'title'),'position',pos);


%Other params:
xlabel('PV Distance (km)','FontWeight','bold');
ylabel('Max Bus Voltage in Each Scenerio(pu)','FontWeight','bold');
axis([0 4.25 1.02 1.1]);
grid on
%%
%
%
%Figure 6.
    
    
    
    

