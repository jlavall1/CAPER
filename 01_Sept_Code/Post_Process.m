%Post function results to replicate paper:
%Use of ERPI CKT7
clear
clc
%Load results and information about the circuit-
load RESULTS_9_3_2015.mat
load DISTANCE.mat
%
%1) Setup the COM server
%[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%2) Compile the Circuit:
%DSSText.command = 'compile C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\EPRI_ckt7\Master_ckt7.dss';
%DSSText.command = 'solve';

%3) Setup a pointer(handle) of the active circuit:
%DSSCircuit = DSSCircObj.ActiveCircuit;

%4) Obtain Component Names:
%xfmrNames = DSSCircuit.Transformers.AllNames;
%lineNames = DSSCircuit.Lines.AllNames;
load config_LOADNAMES.mat
load config_LINENAMES.mat
load config_XFMRNAMES.mat
%loadNames = DSSCircuit.Loads.AllNames;
%busNames = DSSCircuit.Buses.AllNames;
%5) Obtain Component Structs:
%Capacitors = getCapacitorInfo(DSSCircObj);
%Loads = getLoadInfo(DSSCircObj);
%Buses = getBusInfo(DSSCircObj);
%Transformers = getTransformerInfo(DSSCircObj);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%PV_size | Active PV bus | max P.U. | max %thermal | max %thermal 

%sort_Results = sortrows(RESULTS(1:10000,1:6),1);
sort_Results = xlsread('RESULTS_SORTED.xlsx');

%%
n = 0;
DONE = 0;
jj = 1;
ii=1;
while ii<length(sort_Results)-200
    while n < 5100
        if RESULTS(ii,1) == n && DONE == 0
            %Obtain group of 201simresults:
            SM.(['PU_',num2str(n)]) = sort_Results(ii:ii+200,3);
            SM.(['THRM_',num2str(n)]) = sort_Results(ii:ii+200,4);
            %Now lets sort by desired field.
            SM.(['PU_',num2str(n)]) = sort(SM.(['PU_',num2str(n)])(:,1));
            SM.(['THRM_',num2str(n)]) = sort(SM.(['THRM_',num2str(n)])(:,1));
            
            %Force kick out of while loop:
            n = 5100; 
            DONE = 1;
            %SM.(pv_size{n+1,1}).A(m,1) = sort_RESULTS(ii,4);
        end
        
        %Make new struct at different installed capacity 
        n = n + 100;
    end
    ii = ii + 1;
    n = 0;
    DONE = 0;
end
%%
%The object of this while loop is to calculate the interquat
%
%Worker variables:
n = 100;
i = 1;
m = 1;
ii = 1;
%Stat variables:
agg = 0;
agg1 = 0;
index = 0;
Q_V = zeros(51,10);
Q_I = zeros(51,10);
Q_Vv = zeros(51,10);
Q_Ii = zeros(51,10);
nn = 200; %samples
PERC = [0,0.05,0.10,0.25,0.5,0.75,0.9,0.95,1];

while n < 5100
    %{
    %aggregate each set of ALL locations under same PV_kw:
    while m < 201
        
        agg = agg + SM.(['PU_',num2str(n)])(m,1);
        agg1 = agg1 + SM.(['THRM_',num2str(n)])(m,1);

        m = m + 1;
    end
    %}
    %Voltage Profiles:
    for j=1:1:9
        index = nn*PERC(1,j);
        if index == 0
            index = 1;
        end
        Q_V(i,j) = sort(SM.(['PU_',num2str(n)])(index,1));
        Q_I(i,j) = sort(SM.(['THRM_',num2str(n)])(index,1));
    end
    Q_V(i,10) = mean(SM.(['PU_',num2str(n)])(:,1));
    Q_I(i,10) = mean(SM.(['THRM_',num2str(n)])(:,1));
    
    %{
    %Changes in values for Area Chart:
    Q_Vv(i,1) = Q_V(i,1);
    Q_Ii(i,1) = Q_I(i,1);
    for j=2:1:9
        Q_Vv(i,j) = Q_V(i,j) - Q_V(i,j-1);
        Q_Ii(i,j) = Q_I(i,j) - Q_I(i,j-1);
    end
    %}
    %refresh variables:
    %agg = 0;
    %agg1 = 0;
    m = 1;
    n = n + 100;
    i = i + 1;
end



%%
%Visualize the results:
% PLOT!!!
pv_size = zeros(51,9);
n = 0;
m = 1;
sort_Results = sort(RESULTS);
while n<5100
    for k=1:1:9
        pv_size(m,k) = n;
    end
    n = n + 100;
    m = m + 1;
end
%
%Declare color RGB:
COLOR= zeros(6,3);
COLOR(1,:) = [0.0 1.0 1.0];
COLOR(2,:) = [0.0 0.8 1.0];
COLOR(3,:) = [0.0 0.6 1.0];
COLOR(4,:) = [0.0 0.0 0.4]; %inner quartile
COLOR(4,:) = [0.0 0.0 0.4];
COLOR(3,:) = [0.0 0.6 1.0];

%%
% "Effect of PV Size on max BUS VOLTAGE under 50% Load"
fig = 1;
figure(fig);

C = zeros(3,1);
for j=1:1:9
    %C = COLOR(j,:);
    %y = Q_V(2:51,j);
    scatter(pv_size(1:51,j),Q_V(1:51,j))
    %plot(pv_size(2:51,1),y,'Color',C);
    hold on
end


axis([0 5000 1.01 1.05]);

%% 
% "Effect of PV size on max LINE loading under 50% load"
% 
fig = fig + 1;
figure(fig);
x = pv_size(2:51,1);
% 5th & below percentile:

% 
% 95th percentile:

%First
y1 = Q_I(2:51,1);
%5th & below
y2 = Q_I(2:51,2);
%5th to 10th
y3 = Q_I(2:51,3);
%10th to 25th
y4 = Q_I(2:51,4);
%25th to 50th (Median)
y5 = Q_I(2:51,5);
%50th to 75th
y6 = Q_I(2:51,6);
%75th to 90th
y7 = Q_I(2:51,7);
%90th to 95th
y8 = Q_I(2:51,8);


baseLine = 100;        %# Baseline value for filling under the curves
index = 2:50;         %# Indices of points to fill under


plot(x,y7,'Color',[0.0 1.0 1.0]);
hold on;
plot(x,y8,'Color',[0.0 0.8 1.0]);
hold on
fill(x,y2,[0.0 1.0 1.0],'EdgeColor','none');   
% fill(x,y1,[0.0 1.0 1.0],'EdgeColor','none');   
% hold on;
X=[x,fliplr(x)];                %#create continuous x value array for plotting
Y=[y1,fliplr(y2)];              %#create y values for out and then back
fill(X,Y,'b');                  %#plot filled area
axis([0 5000 0 200]);

%{
hold on;
plot(x,y3,'Color',[0.0 0.6 1.0]);
hold on;
fill(x,y3,[0.0 1.0 1.0],'EdgeColor','none');   

hold on;
plot(x,y4,'Color',[0.0 0.0 0.4]);
hold on;
fill(x,y4,[0.0 1.0 1.0],'EdgeColor','none');   
hold on;
plot(x,y5,'r','LineWidth',3);
hold on;
plot(x,y6,'Color',[0.0 0.6 1.0]);
hold on;
plot(x,y7,'Color',[0.0 0.8 1.0]);
hold on;
plot(x,y8,'Color',[0.0 1.0 1.0]);                            
hold on;    
%}                                 
%{

h1 = fill(x,y7,'b','EdgeColor','none');        

hold on;
plot(x,y1,'g');                             
h2 = fill(x,y1,'g','EdgeColor','none');
%}

%h2 = fill(x(index([1 1:end end])),y2(index([1 1:end end])),'g','EdgeColor','none');
%{
%plot(x(index),baseLine.*ones(size(index)),'r');  %# Plot the red line
x=0:0.01:2*pi;                  %#initialize x array
y1=sin(x);                      %#create first curve
y2=sin(x)+.5;                   %#create second curve
X=[x,fliplr(x)];                %#create continuous x value array for plotting
Y=[y1,fliplr(y2)];              %#create y values for out and then back
fill(X,Y,'b');                  %#plot filled area
%}

%%
%testing: %Thermal Rating --
fig = fig + 1;
figure(fig);
for j=1:1:9
    scatter(pv_size(1:51,j),Q_I(1:51,j))
    hold on
end

