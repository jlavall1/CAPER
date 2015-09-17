%Post_Process --PART II--
%Coding to replicate Figure 5 & Figure 6:

%%
clear
clc
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code')
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis')
%import numpy as np
%import matplotlib.pyplot as plt

% "PV size & distance effect on max bus voltage under 50% load"
%load RESULTS_9_3_2015.mat
%load RESULTS_9_10_2015.mat
load RESULTS_9_14_2015.mat

%sort_Results = xlsread('RESULTS_SORTED.xlsx');
%sort_Results = xlsread('RESULTS_SORTED.xlsx','9_10');
sort_Results = xlsread('RESULTS_SORTED.xlsx','9_14_1');
load DISTANCE.mat
load config_LOADNAMES_CKT7.mat
load config_LINENAMES_CKT7.mat
load config_XFMRNAMES_CKT7.mat
load config_BUSNAMES_CKT7.mat
load config_LINESBASE_CKT7.mat
load config_LEGALBUSES_CKT7.mat
load config_LEGALDISTANCE_CKT7.mat
%Find where bus hits legal bus & distance from substation:
%{
j = 1;
%PV_LOC = zeros(202,2);
%ii = 5;

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
%}

%Add a distance from SUB column vector to RESULTS:
j = 1;
m = 1;
n = 2; %skip bus in sub.
for i=102:1:20001
    RESULTS(i,9) = legal_distances(n,1);
    if m == 100
        %move onto next bus:
        m = 1;
        n = n + 1;
    else
        m = m + 1;
    end  
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%Sort in ascending order in respect to BUS VOLT:
VS_RESULTS = zeros(length(RESULTS(102:20001,1)),9);

[VS_RESULTS(:,2),I]=sort(RESULTS(102:20001,2),1,'descend');
for i=1:1:length(VS_RESULTS)
    for j=102:1:20001%length(RESULTS)
        if j==I(i,1) %if the index matches:
            VS_RESULTS(i,1)=RESULTS(j,1); %PV_KW
            VS_RESULTS(i,3)=RESULTS(j,3); %max_BusV
            VS_RESULTS(i,6)=RESULTS(j,6); %max_%thermal
            VS_RESULTS(i,9)=RESULTS(j,9); %
        end
    end
end
%}
%{
%This will sort by "tallest bus Vmax set"
maxsetV=zeros(200,2); %Vmax | Bus
j=1;
HOLD=1;
for i=1:1:length(VS_RESULTS)-1000
    %RESULTS(i,9)=HOLD;
    if j ~= 100 
        if RESULTS(i,2) > maxsetV(HOLD,1)
            maxsetV(HOLD,1)=RESULTS(i,2);
        end
        RESULTS(i,10)=HOLD;
        j = j + 1;
    elseif j == 100
        maxsetV(HOLD,2)=HOLD; %Hold bus index position;
        RESULTS(i,10)=HOLD;
        j = 1; %Go onto next BUS set
        HOLD=HOLD+1; %Go onto next maxV position
    end
    
end
%Now sort max(maxBUSVOLTAGES):
[maxset_sort(:,1),I]=sort(maxsetV(:,1),1,'descend');
k = 1; %counter for a set:
i = 1;
while i < length(VS_RESULTS)-1000 %end result:
    %Search through and obtain all hits of HOLD#
    for j=1:1:length(RESULTS)
        
        if RESULTS(j,10)==I(k,1) %if the index matches:
            VS_RESULTS(i,1)=RESULTS(j,1);
            VS_RESULTS(i,2)=RESULTS(j,2);
            VS_RESULTS(i,3)=RESULTS(j,3);
            VS_RESULTS(i,6)=RESULTS(j,6);
            VS_RESULTS(i,9)=RESULTS(j,9);
            VS_RESULTS(i,10)=RESULTS(j,10);
            i = i + 1; %should only hit 100 times
        end
    end
    k = k + 1; %move onto next I(k,1)
end
%}
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Plot Fig. 6:
fig = 1;
figure(fig);
%{
x = VS_RESULTS(1:20000,9); %DISTANCE
y = VS_RESULTS(1:20000,2); %max BUS VOLTAGE
x_pv = VS_RESULTS(1:20000,1)/1000; %PV SIZE
%}
%Other Method:
x = RESULTS(1001:21000,9); %DISTANCE
y = RESULTS(1001:21000,2); %max BUS VOLTAGE
x_pv = RESULTS(1001:21000,1)/1000; %PV SIZE
%}
%
colormap('jet');
cmap = colormap;
lineHandles = scatter(x,y,10,x_pv);
%Create & edit colorbar:
c = colorbar('location','eastoutside');
% pos1 = get(c,'position');
%p = [x,y,width]
% pos1(1,1) = pos1(1,1);
% set(c,'position',pos1);
%
%Edit title string:
set(get(c,'title'),'string','PV Size (MW)','Rotation',90.0,'FontWeight','bold');
pos = get(get(c,'title'),'position');
pos(1,1) = pos(1,1)+50.5;
pos(1,2) = pos(1,2)+120;
set(get(c,'title'),'position',pos);


%Other params:
xlabel('PV Distance (km)','FontWeight','bold');
ylabel('Max Bus Voltage in Each Scenerio(pu)','FontWeight','bold');
axis([0 4.25 1.03 1.11]);
grid on
set(gca,'FontWeight','bold');
%%
%
%
%Figure 8 "Max Allowed PV size at a single bus under 50% Load"
num_loc = 199;
num_kws = 10e3/100;
max_PVkw = zeros(199,4);
i = 102; %skip bus3 b/c distance to sub = 0km
n = 1;
while i < 20002
    location = RESULTS(i:i+99,1:9);
    j = 1;
    while j < 101
        if location(j,2) > 1.05
            max_PVkw(n,1) = location(j,1); %PV_KW
            max_PVkw(n,2) = str2double(cell2mat(legal_buses(n+1,1))); %BUS#
            %Store voltage of violation:
            max_PVkw(n,3) = location(j,2); %max3phV
            max_PVkw(n,4) = location(j,9); %km
            
            %Reset Variables;
            n = n + 1;
            j = 202;
        elseif location(j,4) > 100
            max_PVkw(n,1) = location(j,1); %PV_KW
            max_PVkw(n,2) = str2double(cell2mat(legal_buses(n+1,1))); %BUS#
            %max_PVkw(n,2) = legal_buses(n+1,1); %BUS#
            %Store voltage of violation:
            max_PVkw(n,3) = location(j,4); %max%THERM
            max_PVkw(n,4) = location(j,9); %km
            %Reset Variables;
            n = n + 1;
            j = 202;
        elseif j == 100
            max_PVkw(n,1) = location(j,1); %PV_KW
            max_PVkw(n,2) = str2double(cell2mat(legal_buses(n+1,1))); %BUS#
            %max_PVkw(n,2) = legal_buses(n+1,1); %BUS#
            max_PVkw(n,4) = location(j,9); %km
            n = n + 1;
        end
        j = j + 1;
    end
    i = i + 100;
end
fig = fig + 1;
figure(fig);
scatter(max_PVkw(:,4),max_PVkw(:,1)) %distance VS maxKW
axis([0 4 0 14000]);
    
    
    
    

