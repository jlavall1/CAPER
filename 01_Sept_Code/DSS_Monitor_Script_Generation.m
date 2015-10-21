%monitors.txt script generation:
%%
clear
clc
close all
%Lets create the needed monitors:
feeder_NUM = 1;

if feeder_NUM == 1
    %Commonwealth --
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss';
    addpath(temp_dir)
    load Lines_Monitor.mat %Lines_Distance
    %For export .txt file --
    filename = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\Monitors_GEN.txt';
    
elseif feeder_NUM == 2
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss';
    addpath(temp_dir)
    load Lines_Monitor.mat %Lines_Distance
    %For export .txt file --
    filename = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Monitors_GEN.txt';
    
end

%%
%I want pos Seq (=64) of Mode=1 (Power of each phase)
%       [ Set ppolar=no to get kw, kvar ]
%   Initialize variables:
base1 = 'New Monitor.';
n = length(Lines_Distance(:,1));
j = 1;
k = 2;

while k <= n
    line = Lines_Distance(k,1).name;
    numPh = Lines_Distance(k,1).numPhases;   
    if numPh == 3
        for i=1:1:2
            Monitor{j,2}=Lines_Distance(k,1).bus1Distance;
            B1 = Lines_Distance(k,1).bus1;
            %take off node #'s (.1.2.3):
            Monitor{j,3}=regexprep({B1},'(\.[0-9]+)','');
            
            Monitor{j,1}=strcat(base1,line);
            if i==1
                Monitor{j,1}=strcat(Monitor{j,1},'_Mon_VI');
            elseif i==2
                Monitor{j,1}=strcat(Monitor{j,1},'_Mon_PQ');
            end
            Monitor{j,1}=strcat(Monitor{j,1},sprintf('  element=line.%s',line));
            if i==1
                Monitor{j,1}=strcat(Monitor{j,1},' term=1  mode=0 Residual=Yes');
            elseif i==2
                Monitor{j,1}=strcat(Monitor{j,1},' term=1  mode=1 PPolar=No');
            end
            %Split out PV bus:
            %{
            if strcmp(Monitor{j,3},'258405587')==1
                disp(j)
            end
            %}
            %increment to next string --
            j = j + 1
            
        end
    end
    k = k + 1;
end
%%
%Export strings to .txt file:
fileID=fopen(filename,'w');
for j=1:1:length(Monitor)
    fprintf(fileID,'%s\r\n',Monitor{j,1});
end
fclose(fileID);

fprintf('The VI & PQ monitors at all nodes w/ 3 phase\n');
fprintf('have been created in a .txt file. Move to .dss\n');
