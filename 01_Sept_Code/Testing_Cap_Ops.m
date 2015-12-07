%Testing Cap_Ops Finder:
clear
clc
base_path = 'C:\Users\jlavall\Documents\GitHub\CAPER';
path = strcat(base_path,'\04_DSCADA\Feeder_Data');
time_int = '1m';
cap_pos = 1;
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
for DOY=1:1:365
    fprintf('\n%d DOY\n',DOY);
    %1] Select data for 24hour period --
    LOAD_ACTUAL_1(:,1) = FEEDER.kW.A(time2int(DOY,0,0):time2int(DOY,23,59),1);
    LOAD_ACTUAL_1(:,2) = FEEDER.kW.B(time2int(DOY,0,0):time2int(DOY,23,59),1);
    LOAD_ACTUAL_1(:,3) = FEEDER.kW.C(time2int(DOY,0,0):time2int(DOY,23,59),1);
    KVAR_ACTUAL_1(:,1) = FEEDER.kVAR.A(time2int(DOY,0,0):time2int(DOY,23,59),1);
    KVAR_ACTUAL_1(:,2) = FEEDER.kVAR.B(time2int(DOY,0,0):time2int(DOY,23,59),1);
    KVAR_ACTUAL_1(:,3) = FEEDER.kVAR.C(time2int(DOY,0,0):time2int(DOY,23,59),1);
    %2] Declare duration & timestep:
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
    %3]Re-size original 1min data accordingly:
    if t_int ~= 0
        LOAD_ACTUAL(:,1) = interp(LOAD_ACTUAL_1(:,1),t_int);
        LOAD_ACTUAL(:,2) = interp(LOAD_ACTUAL_1(:,2),t_int);
        LOAD_ACTUAL(:,3) = interp(LOAD_ACTUAL_1(:,3),t_int);
        KVAR_ACTUAL.data(:,1) = interp(KVAR_ACTUAL_1(:,1),t_int);
        KVAR_ACTUAL.data(:,2) = interp(KVAR_ACTUAL_1(:,2),t_int);
        KVAR_ACTUAL.data(:,3) = interp(KVAR_ACTUAL_1(:,3),t_int);
    else
        jj=1;
        for ii=1:60:length(LOAD_ACTUAL_1)
            LOAD_ACTUAL(jj,1) = LOAD_ACTUAL_1(ii,1);
            LOAD_ACTUAL(jj,2) = LOAD_ACTUAL_1(ii,2);
            LOAD_ACTUAL(jj,3) = LOAD_ACTUAL_1(ii,3);
            KVAR_ACTUAL.data(jj,1) = KVAR_ACTUAL_1(ii,1);
            KVAR_ACTUAL.data(jj,2) = KVAR_ACTUAL_1(ii,2);
            KVAR_ACTUAL.data(jj,3) = KVAR_ACTUAL_1(ii,3);
            jj = jj + 1;
        end
    end
    %4]Check to see if there are any NaN:
    j = 1;
    error_len= zeros(1,3);
    error_srt = 0;
    for ph=1:1:3
        for i=1:1:str2num(sim_num)
            if isnan(KVAR_ACTUAL.data(i,ph)) == 1
                save(j,ph) = i;
                if j ~= 1
                    if save(j-1,ph) == i-1
                        error_len(1,ph) = error_len(1,ph) + 1;
                        if error_srt == 0
                            error_srt = i-1;
                        end
                    end
                end
                j = j + 1;
            end
        end
        j = 1;
    end
    disp(error_len)
    fprintf('Error started: %d\n',error_srt);
    %   Linearize data gaps:
    if error_srt ~= 0
        for ph=1:1:3
            y1 = KVAR_ACTUAL.data(error_srt-1,ph);
            y2 = KVAR_ACTUAL.data(error_srt+error_len(1,ph)+1,ph);
            m = (y2-y1)/(error_len(1,ph)+1);
            for i=0:1:error_len(1,ph)
                KVAR_ACTUAL.data(error_srt+i,ph) = KVAR_ACTUAL.data(error_srt+i-1,ph)+m;
            end
        end
    end
            
    
    %5]Find CAP ops:
    if Caps.Swtch(1) ~= 0
        [KVAR_ACTUAL,cap_pos]=Find_Cap_Ops(KVAR_ACTUAL,sim_num,s_step,Caps,LOAD_ACTUAL,cap_pos);
    end
    CAP_OPS(DOY).data = KVAR_ACTUAL.data;
end
%%
figure(1)
s = 1;
for i=1:1:50
    Y = CAP_OPS(i).data(1:1440,4);
    X = [s:1:1440+s-1]';
    %plot(s+j,CAP_OPS(i).data(j,4));
    plot(X,Y)
    hold on
    s = s + 1440;
end
    
    