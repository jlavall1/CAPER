%Testing Cap_Ops Finder:
clear
clc
close all
base_path = 'C:\Users\jlavall\Documents\GitHub\CAPER';
path = strcat(base_path,'\04_DSCADA\Feeder_Data');
time_int = '1m';
cap_pos = 1; %used to be 1
addpath(path);
load FLAY.mat
FEEDER = FLAY;
clearvars FLAY
kW_peak = [1.424871573296857e+03,1.347528364235151e+03,1.716422704604557e+03];
Caps.Fixed(1)=600/3;
Caps.Swtch(1)=450/3;
%To be used for finding AllocationFactors for simulation:
eff_KW(1,1) = 0.9862;
eff_KW(1,2) = 0.993;
eff_KW(1,3) = 0.9894;
V_LTC = 1.03*((12.47e3)/sqrt(3));
% -- Flay 13.27km long --
root = 'Flay';
root1= 'Flay';
for DOY=1:1:364
    fprintf('\n%d DOY\n',DOY);
    
    %1] Declare duration & timestep:
    if strcmp(time_int,'1h') == 1
        t_int=0;
        s_step=3600;
        sim_num='24';
        fprintf('Sim. timestep=1hr\n');
    elseif strcmp(time_int,'1m') == 1
        t_int=1;
        s_step=60;
        sim_num='1440';
        %fprintf('Sim. timestep=60s\n');
    elseif strcmp(time_int,'30s') == 1
        t_int=2;
        s_step=30;
        sim_num='2880';
        fprintf('Sim. timestep=30s\n');
    elseif strcmp(time_int,'5s') == 1
        t_int=12;
        s_step=5;
        sim_num='17280';
        fprintf('Sim. timestep=5s\n');
    end
    [LOAD_ACTUAL,KVAR_ACTUAL]=Pull_DSCADA(DOY,FEEDER,t_int,sim_num);
    [LOAD_ACTUAL_1,KVAR_ACTUAL_1]=Pull_DSCADA(DOY+1,FEEDER,t_int,sim_num);
    %2]Find CAP ops:
    if Caps.Swtch(1) ~= 0
        [KVAR_ACTUAL,E,OPS]=Find_Cap_Ops_1(KVAR_ACTUAL,KVAR_ACTUAL_1,sim_num,s_step,Caps,LOAD_ACTUAL,LOAD_ACTUAL_1,cap_pos);
    end
    cap_pos = KVAR_ACTUAL.data(1440,4);
    CAP_OPS(DOY).data = KVAR_ACTUAL.data;
    %CAP_OPS(DOY).
    CAP_OPS(DOY).dP = KVAR_ACTUAL.dP;
    CAP_OPS(DOY).kW = LOAD_ACTUAL;
    CAP_OPS(DOY).error = E;
    CAP_OPS(DOY).oper = OPS;
end
%{
figure(1)
s = 1;
for i=1:1:364
    Y = CAP_OPS(i).data(1:1440,4);
    X = [s:1:1440+s-1]';
    %plot(s+j,CAP_OPS(i).data(j,4));
    plot(X,Y)
    hold on
    s = s + 1440;
end
axis([0 s -1 2])
figure(2)
s = 1;
for i=1:1:50
    Y = CAP_OPS(i).data(1:1440,7);
    X = [s:1:1440+s-1]';
    %plot(s+j,CAP_OPS(i).data(j,4));
    plot(X,Y)
    hold on
    s = s + 1440;
end
%%
figure(3)
%Test DOY=51:
T_DAY = 265;
plot(CAP_OPS(T_DAY).data(:,1),'r-')
hold on
plot(CAP_OPS(T_DAY).data(:,2),'g-')
hold on
plot(CAP_OPS(T_DAY).data(:,3),'b-')
hold on
plot(CAP_OPS(T_DAY).data(:,4)*-1*Caps.Swtch,'k-','LineWidth',3);
%%
figure(4)
s = 1;
for i=120:1:200
    Y = CAP_OPS(i).data(1:1440,10);
    X = [s:1:1440+s-1]';
    %plot(s+j,CAP_OPS(i).data(j,4));
    plot(X,Y)
    hold on
    s = s + 1440;
end
%%
%}
%%
fig = 0;
%close all
for i=150:1:365
    if CAP_OPS(i).oper == 0
        fig = fig + 1;
        figure(fig)
        T_DAY = i;
        plot(CAP_OPS(T_DAY).data(:,1),'r-')
        hold on
        plot(CAP_OPS(T_DAY).data(:,2),'g-')
        hold on
        plot(CAP_OPS(T_DAY).data(:,3),'b-')
        hold on
        plot(CAP_OPS(T_DAY).data(:,4)*-1*Caps.Swtch,'k-','LineWidth',3);
        hold off
        title(sprintf('DOY=%d',i));
    end
end
        
        
        

    
    