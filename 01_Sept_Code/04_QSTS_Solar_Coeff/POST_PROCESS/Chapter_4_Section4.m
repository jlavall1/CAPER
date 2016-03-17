%3 month runs showing impact of PV on (2) Test Feeders.
clear
clc
close all
%================
%Select Choice--
Feeder = 3;
Plot_NUM = 4;
%1=Solar Coeff VS load  
%2=Show POIs         
%3=Sum. OLTC TapCngs(
%4=TVD Impact       (4plots)  [Show_TVD_Impact]         
%5=Peak Dev. TVD    (1plot )  [Show_SUBV_peak]
%6=Peak Dev. in Tap Changes   [Show_Worst_Tap_inv]
%7=(1) Week Plot    (2plots)           
%8=Concept of TVD 	(Voltage Deviation & TVD)   
%9=


%===============
%%
basepath = 'C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff';
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\Feeder_Data');
load M_MOCKS
M_PVSITE = M_MOCKS;
load M_MOCKS_INFO
M_PVSITE_INFO = M_MOCKS_INFO;
load M_MOCKS_SC
M_PVSITE_SC = M_MOCKS_SC;
clear M_MOCKS M_MOCKS_INFO M_MOCKS_SC
%Load to historical Loadsets:
load Annual_daytime_load_FLAY.mat
load Annual_ls_FLAY.mat         %MAX.MONTH.KW.A
load FLAY.mat
LOAD(3).MAX = max(MAX.MONTH.KW.A(1:12,1)+MAX.MONTH.KW.B(1:12,1)+MAX.MONTH.KW.C(1:12,1));
LOAD(3).KW = WINDOW.KW.A(:,1)+WINDOW.KW.B(:,1)+WINDOW.KW.C(:,1);
%Find monthly averages:
months = [31,28,31,30,31,30,31,31,30,31,30,31];
mn_max = 0;
t_w=0;  
tt =0;
sum = 0;
day_t=1;
%Increment through the months & find averages
for i=1:12
    x_w=60*6*months(i);
    for ii=tt+1:x_w+tt
        if isnan(LOAD(3).KW(ii,1))
            %fprintf('fuck you\n');
        else
            sum = abs(LOAD(3).KW(ii,1)) + sum;
        end
        day_t = day_t + 1;
    end
    tt = tt+x_w;
    LOAD(3).KW_avg(i,1) = sum/x_w;
    sum = 0;
end
clear MAX WINDOW FLAY

%   -FEEDER 02-
load Annual_daytime_load_CMNWLTH.mat
load Annual_ls_CMNWLTH.mat
LOAD(2).MAX = max(MAX.MONTH.KW.A(1:12,1)+MAX.MONTH.KW.B(1:12,1)+MAX.MONTH.KW.C(1:12,1));
LOAD(2).KW = WINDOW.KW.A(:,1)+WINDOW.KW.B(:,1)+WINDOW.KW.C(:,1);
mn_max = 0;
t_w=0;  
tt =0;
sum = 0;
day_t=1;
%Increment through the months & find averages
for i=1:12
    x_w=60*6*months(i);
    for ii=tt+1:x_w+tt
        if isnan(LOAD(2).KW(ii,1))
            %fprintf('fuck you\n');
        else
            sum = abs(LOAD(2).KW(ii,1)) + sum;
        end
        day_t = day_t + 1;
    end
    tt = tt+x_w;
    LOAD(2).KW_avg(i,1) = sum/x_w;
    sum = 0;
end
%%
%make directories for each sim type:
if Feeder == 2
    path1=strcat(basepath,'\02_CMNW\Three_Month_Run\Base_Sequential');
    path2=strcat(basepath,'\02_CMNW\Three_Month_Run\POI_1_Sequential');
    path3=strcat(basepath,'\02_CMNW\Three_Month_Run\POI_2_Sequential');
elseif Feeder == 3
    path1=strcat(basepath,'\03_FLAY\Three_Month_Runs\Base_Sequential');
    path2=strcat(basepath,'\03_FLAY\Three_Month_Runs\POI_1_Sequential');
    path3=strcat(basepath,'\03_FLAY\Three_Month_Runs\POI_2_Sequential');
end

if Plot_NUM == 1
    %Solar Coeff:
    fig = 0;
    Plot_SOLAR_COEFF
elseif Plot_NUM == 2
    %POI Locations
    fig = 1;
    Show_DER_PV_PCC
elseif Plot_NUM == 3
    fig = 0;
    Show_LTC_OPs
elseif Plot_NUM == 4
    fig = 0;
    %TVD impact on daytime hours:
    Show_TVD_Impact
elseif Plot_NUM == 5
    %Select maximum Delta(TVD) Day on Feeder 02 ONLY
    fig = 0;
    if Feeder == 2
        PEAK_DOY=110;
    elseif Feeder == 3
        %PEAK_DOY=75;
        PEAK_DOY=45;
    end
    Show_SUBV_peak
elseif Plot_NUM == 6
    %Select maximum increase # of Tap changes on Feeder 02 ONLY
    fig = 0;
    Show_Worst_Tap_inv
elseif Plot_NUM == 7
    %Select (1) Week span with highest observed voltage on feeder during
    %3mnth run. Show P & Vmin/max vs. Time
    fig = 0;
    Show_Severe_V_Rise
elseif Plot_NUM == 8
    %Show TVD/distance
    fig = 0;
    path1=strcat(basepath,'\02_CMNW\TVD_max_Run\Base');
    path2=strcat(basepath,'\02_CMNW\TVD_max_Run\POI_1');
    path3=strcat(basepath,'\02_CMNW\TVD_max_Run\POI_2');
    
    Show_Concept_TVD
end
    








%{        
if Feeder == 3
        addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\Feeder_Data');
        
        
        
        %LOAD(3).AVG = 
        addpath(strcat(basepath,'\03_FLAY\Three_Month_Runs\Base_Sequential'));
    %Base Case Load:
        load YR_SIM_CAP1_FLAY_00.mat    %YEAR_CAPSTATUS
        RUN(1).YEAR_CAPSTATUS = YEAR_CAPSTATUS;
        clear YEAR_CAPSTATUS
        load YR_SIM_CAP2_FLAY_00.mat    %YEAR_CAPCNTRL
        RUN(1).YEAR_CAPCNTRL = YEAR_CAPCNTRL;
        clear YEAR_CAPCNTRL
        load YR_SIM_MEAS_FLAY_00.mat    %DATA_SAVE
        RUN(1).DATA_SAVE = DATA_SAVE;
        clear DATA_SAVE
        load YR_SIM_OLTC_FLAY_00.mat    %YEAR_LTC
        RUN(1).YEAR_LTC = YEAR_LTC;
        clear YEAR_LTC
        load YR_SIM_P_FLAY_00.mat       %YEAR_SIM_P
        RUN(1).YEAR_SIM_P = YEAR_SIM_P;
        clear YEAR_SIM_P
        load YR_SIM_Q_FLAY_00.mat       %YEAR_SIM_Q
        RUN(1).YEAR_SIM_Q = YEAR_SIM_Q;
        clear YEAR_SIM_Q
        load YR_SIM_SUBV_FLAY_00.mat    %YEAR_SUB
        RUN(1).YEAR_SUB = YEAR_SUB;
        clear YEAR_SUB
        load YR_SIM_TVD_FLAY_00.mat     %Settings
        RUN(1).Settings = Settings;
        clear Settings
    %POI_1 Case Load:
        n = 2;
        addpath(strcat(basepath,'\03_FLAY\Three_Month_Runs\POI_1_Sequential'));
        load YR_SIM_CAP1_FLAY_010.mat    %YEAR_CAPSTATUS
        RUN(n).YEAR_CAPSTATUS = YEAR_CAPSTATUS;
        clear YEAR_CAPSTATUS
        load YR_SIM_CAP2_FLAY_010.mat    %YEAR_CAPCNTRL
        RUN(n).YEAR_CAPCNTRL = YEAR_CAPCNTRL;
        clear YEAR_CAPCNTRL
        load YR_SIM_MEAS_FLAY_010.mat    %DATA_SAVE
        RUN(n).DATA_SAVE = DATA_SAVE;
        clear DATA_SAVE
        load YR_SIM_OLTC_FLAY_010.mat    %YEAR_LTC
        RUN(n).YEAR_LTC = YEAR_LTC;
        clear YEAR_LTC
        load YR_SIM_P_FLAY_010.mat       %YEAR_SIM_P
        RUN(n).YEAR_SIM_P = YEAR_SIM_P;
        clear YEAR_SIM_P
        load YR_SIM_Q_1_FLAY_010.mat       %YEAR_SIM_Q_1
        load YR_SIM_Q_2_FLAY_010.mat       %YEAR_SIM_Q_2
        RUN(n).YEAR_SIM_Q(32:60) = YEAR_SIM_Q_1(32:60);
        RUN(n).YEAR_SIM_Q(61:120) = YEAR_SIM_Q_2(61:120);
        clear YEAR_SIM_Q_1 YEAR_SIM_Q_2
        load YR_SIM_SUBV_FLAY_010.mat    %YEAR_SUB
        RUN(n).YEAR_SUB = YEAR_SUB;
        clear YEAR_SUB
        load YR_SIM_TVD_FLAY_010.mat     %Settings
        RUN(n).Settings = Settings;
        clear Settings
        load YR_SIM_FDR_V_FLAY_010.mat   %?
        RUN(n).YEAR_FDR = YEAR_FDR;
        clear YEAR_FDR
        
elseif Feeder == 2
        addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\02_CMNW\Three_Month_Run\Base_Sequential');
    %Base Case Load:
        n = 1;
        load YR_SIM_CAP1_CMNW_00.mat    %YEAR_CAPSTATUS
        RUN(n).YEAR_CAPSTATUS = YEAR_CAPSTATUS;
        clear YEAR_CAPSTATUS
        load YR_SIM_CAP2_CMNW_00.mat    %YEAR_CAPCNTRL
        RUN(n).YEAR_CAPCNTRL = YEAR_CAPCNTRL;
        clear YEAR_CAPCNTRL
        load YR_SIM_MEAS_CMNW_00.mat    %DATA_SAVE
        RUN(n).DATA_SAVE = DATA_SAVE;
        clear DATA_SAVE
        
        load YR_SIM_P_CMNW_00.mat       %YEAR_SIM_P
        RUN(n).YEAR_SIM_P = YEAR_SIM_P;
        clear YEAR_SIM_P
        load YR_SIM_Q_1_CMNW_00.mat       %YEAR_SIM_Q_1
        load YR_SIM_Q_2_CMNW_00.mat       %YEAR_SIM_Q_2
        RUN(n).YEAR_SIM_Q(32:60) = YEAR_SIM_Q_1(32:60);
        RUN(n).YEAR_SIM_Q(61:120) = YEAR_SIM_Q_2(61:120);
        load YR_SIM_SUBV_CMNW_00.mat    %YEAR_SUB
        RUN(n).YEAR_SUB = YEAR_SUB;
        clear YEAR_SUB
        load YR_SIM_TVD_CMNW_00.mat     %Settings
        RUN(n).Settings = Settings;
        clear Settings
    %POI Case 1 Load:
        n = 2;
        addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\02_CMNW\Three_Month_Run\POI_1_Sequential');
        load YR_SIM_CAP1_CMNW_025.mat    %YEAR_CAPSTATUS
        RUN(n).YEAR_CAPSTATUS = YEAR_CAPSTATUS;
        clear YEAR_CAPSTATUS
        load YR_SIM_CAP2_CMNW_025.mat    %YEAR_CAPCNTRL
        RUN(n).YEAR_CAPCNTRL = YEAR_CAPCNTRL;
        clear YEAR_CAPCNTRL
        load YR_SIM_MEAS_CMNW_025.mat    %DATA_SAVE
        RUN(n).DATA_SAVE = DATA_SAVE;
        clear DATA_SAVE
        
        load YR_SIM_P_CMNW_025.mat       %YEAR_SIM_P
        RUN(n).YEAR_SIM_P = YEAR_SIM_P;
        clear YEAR_SIM_P
        load YR_SIM_Q_1_CMNW_025.mat       %YEAR_SIM_Q_1
        load YR_SIM_Q_2_CMNW_025.mat       %YEAR_SIM_Q_2
        RUN(n).YEAR_SIM_Q(32:60) = YEAR_SIM_Q_1(32:60);
        RUN(n).YEAR_SIM_Q(61:120) = YEAR_SIM_Q_2(61:120);
        clear YEAR_SIM_Q_1 YEAR_SIM_Q_2
        load YR_SIM_SUBV_CMNW_025.mat    %YEAR_SUB
        RUN(n).YEAR_SUB = YEAR_SUB;
        clear YEAR_SUB
        load YR_SIM_TVD_CMNW_025.mat     %Settings
        RUN(n).Settings = Settings;
        clear Settings
        load YR_SIM_FDR_V_CMNW_025.mat   %?
        RUN(n).YEAR_FDR = YEAR_FDR;
        clear YEAR_FDR
    %POI Case 2 Load:
        n = 3;
        addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\02_CMNW\Three_Month_Run\POI_2_Sequential');
        load YR_SIM_CAP1_CMNW_050.mat    %YEAR_CAPSTATUS
        RUN(n).YEAR_CAPSTATUS = YEAR_CAPSTATUS;
        clear YEAR_CAPSTATUS
        load YR_SIM_CAP2_CMNW_050.mat    %YEAR_CAPCNTRL
        RUN(n).YEAR_CAPCNTRL = YEAR_CAPCNTRL;
        clear YEAR_CAPCNTRL
        load YR_SIM_MEAS_CMNW_050.mat    %DATA_SAVE
        RUN(n).DATA_SAVE = DATA_SAVE;
        clear DATA_SAVE
        
        load YR_SIM_P_CMNW_050.mat       %YEAR_SIM_P
        RUN(n).YEAR_SIM_P = YEAR_SIM_P;
        clear YEAR_SIM_P
        load YR_SIM_Q_1_CMNW_050.mat       %YEAR_SIM_Q_1
        load YR_SIM_Q_2_CMNW_050.mat       %YEAR_SIM_Q_2
        RUN(n).YEAR_SIM_Q(32:60) = YEAR_SIM_Q_1(32:60);
        RUN(n).YEAR_SIM_Q(61:120) = YEAR_SIM_Q_2(61:120);
        clear YEAR_SIM_Q_1 YEAR_SIM_Q_2
        load YR_SIM_SUBV_CMNW_050.mat    %YEAR_SUB
        RUN(n).YEAR_SUB = YEAR_SUB;
        clear YEAR_SUB
        load YR_SIM_TVD_CMNW_050.mat     %Settings
        RUN(n).Settings = Settings;
        clear Settings
        load YR_SIM_FDR_V_CMNW_050.mat   %?
        RUN(n).YEAR_FDR = YEAR_FDR;
        clear YEAR_FDR
end
        
        
    
    
%%

%%
%--------------------------------------------------------------------------
%plot POI Test Locations of selected feeder.
%fig = fig + 1;
%Show_DER_PV_PCC
%%
%--------------------------------------------------------------------------



fig = fig + 1;
Show_LTC_OPs

%{
X = X + 1;
X = [1/86400:1/86400:1]';
if n == 1
    plot(X,RUN(n).YEAR_LTC(DOY).OP(86400,3),'b-');
elseif n == 2
    plot(X,RUN(n).YEAR_LTC(DOY).OP(86400,3),'r-');
end
    hold on
%}
%}





        
        
