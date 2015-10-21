%code to load in selected PV site for simulation.
%{
clear
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);
sim_type=menu('Import data from which source?','PV_kw with VI/CI','DEC NUG Solar Farms');
while sim_type<1
    sim_type=menu('Import data from which source?','PV_kw with VI/CI','DEC NUG Solar Farms');
end

if sim_type == 1
    PV_Site=menu('Choose Site:','Shelby,NC (King''s Mtn','Murphy,NC (western tip)','Taylorsville,NC (middle of DEC)');
    while sim_type<1
        PV_Site=menu('Choose Site:','Shelby,NC (King''s Mtn','Murphy,NC (western tip)','Taylorsville,NC (middle of DEC)');
    end
elseif sim_type == 2
    PV_Site=menu('Choose Site:','5.0MW - Mocksville Farm','3.5MW - Ararat Rock 3.5MW','1.5MW - Old Dominion','1.0MW - Mayberry Farm');
    while sim_type<1
        PV_Site=menu('Choose Site:','5.0MW - Mocksville Farm','3.5MW - Ararat Rock 3.5MW','1.5MW - Old Dominion','1.0MW - Mayberry Farm');
    end
end
%}
%Load Results from individual analysis:
addpath(PV_Site_path);

if PV_Site == 1
    load M_SHELBY_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_SHELBY_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_SHELBY_INFO.kW;
    M_PVSITE_INFO.name = M_SHELBY_INFO.name;
    M_PVSITE_INFO.VI = M_SHELBY_INFO.VI;
    M_PVSITE_INFO.CI = M_SHELBY_INFO.CI;
    load M_SHELBY.mat
    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_SHELBY(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_SHELBY(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_SHELBY(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    load M_SHELBY_SC.mat
    M_PVSITE_SC = M_SHELBY_SC;
    clearvars M_SHELBY_INFO M_SHELBY M_SHELBY_SC
elseif PV_Site == 2
    %MURPHY
    load M_MURPHY_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_MURPHY_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_MURPHY_INFO.kW;
    M_PVSITE_INFO.name = M_MURPHY_INFO.name;
    load M_MURPHY.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_MURPHY(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_MURPHY(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_MURPHY(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_MURPHY_INFO M_MURPHY
elseif PV_Site == 3
    %TAYLOR
    load M_TAYLOR_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_TAYLOR_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_TAYLOR_INFO.kW;
    M_PVSITE_INFO.name = M_TAYLOR_INFO.name;
    load M_TAYLOR.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_TAYLOR(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_TAYLOR(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_TAYLOR(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_TAYLOR_INFO M_TAYLOR
elseif PV_Site == 4
    load M_MOCKS_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_MOCKS_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_MOCKS_INFO.kW;
    M_PVSITE_INFO.name = M_MOCKS_INFO.name;
    load M_MOCKS.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_MOCKS(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_MOCKS(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_MOCKS(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_MOCKS_INFO M_MOCKS
elseif PV_Site == 5
    load M_AROCK_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_AROCK_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_AROCK_INFO.kW;
    M_PVSITE_INFO.name = M_AROCK_INFO.name;
    load M_AROCK.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_AROCK(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_AROCK(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_AROCK(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_AROCK_INFO M_AROCK

elseif PV_Site == 6
    load M_ODOM_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_ODOM_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_ODOM_INFO.kW;
    M_PVSITE_INFO.name = M_ODOM_INFO.name;
    load M_ODOM.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_ODOM(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_ODOM(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_ODOM(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_ODOM_INFO M_ODOM
elseif PV_Site == 7
    load M_MAYB_INFO.mat
    M_PVSITE_INFO.RR_distrib = M_MAYB_INFO.RR_distrib;
    M_PVSITE_INFO.kW = M_MAYB_INFO.kW;
    M_PVSITE_INFO.name = M_MAYB_INFO.name;
    load M_MAYB.mat

    for i=1:1:12
        M_PVSITE(i).DAY(:,:) = M_MAYB(i).DAY(1:end-1,1:6);    
        M_PVSITE(i).RR_1MIN(:,:) = M_MAYB(i).RR_1MIN(:,1:3);
        M_PVSITE(i).PU(:,:) = M_MAYB(i).kW(1:end-1,1)./M_PVSITE_INFO.kW;
    end
    clearvars M_MAYB_INFO M_MAYB
end
%%
%For (1) Day simulation with spec. DARR category:
%DOY = 50;
if timeseries_span < 4
    DOY = 0;
    %User wants:
    CAT = 4;
    VI_min = 10.5;
    VI_max = 10.8;
    
    if CAT == 1
        RR_distrib = M_PVSITE_INFO.RR_distrib.Cat1(:,1:4);
    elseif CAT == 2
        RR_distrib = M_PVSITE_INFO.RR_distrib.Cat2(:,1:4);
    elseif CAT == 3
        RR_distrib = M_PVSITE_INFO.RR_distrib.Cat3(:,1:4);
    elseif CAT == 4
        RR_distrib = M_PVSITE_INFO.RR_distrib.Cat4(:,1:4);
        %DOY = M_PVSITE_INFO.RR_distrib.Cat4(1,1);
    elseif CAT == 5
        RR_distrib = M_PVSITE_INFO.RR_distrib.Cat5(:,1:7);
        %DOY = M_PVSITE_INFO.RR_distrib.Cat5(1,1);
    end
    %RR_distrib contains all DOYs within Specifc DARR Cat.
    %   Now lets select a day within VI limits:
    DOY_potent = zeros(length(RR_distrib(:,1)),3); %SAVE: DOY|VI|CI
    ii = 1;
    for j=1:1:length(RR_distrib(:,1))
        VI = M_PVSITE_INFO.VI(RR_distrib(j,1),1);
        if VI >= VI_min && VI <= VI_max
            DOY_potent(ii,1)=RR_distrib(j,1); %DOY
            DOY_potent(ii,2)=VI;
            DOY_potent(ii,3)=M_PVSITE_INFO.CI(RR_distrib(j,1)); %CI
            ii = ii + 1;
        end
    end
    if ii == 1
        fprintf('Did not find specificied Day\n');
        DOY=RR_distrib(1,1);
    end
    %Find day with maximum CI:
    max_CI=max(DOY_potent(1:ii-1,3));
    for j=1:1:ii-1
        if DOY_potent(j,3)==max_CI
            DOY=DOY_potent(j,1);
            fprintf('DOY to start sim will be %0.0f\n',DOY);
        end
    end
    %
    %Day selection search function:
    for i=1:1:length(RR_distrib(:,1))
        if RR_distrib(i,1) == DOY
            %Day match!
            MNTH = RR_distrib(i,2);
            DAY = RR_distrib(i,3);
        end
    end
end
%%
%Now lets pull the kW in P.U. matrix for that specified day:
%PV1_loadshape_daily = M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
%PV_loadshape_daily = interp(PV1_loadshape_daily(:,1),60); %go down to 1 second dataset --
%Export to .csv & clear variables that are not needed:
%clearvars M_PVSITE RR_distrib
%s = strtok(ckt_direct,'\Run_Master_Allocate.dss');
s = ckt_direct(1:end-23); %<--------------------- THIS MIGHT CHANGE TOOO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
str = ckt_direct;
idx = strfind(str,'\');
str = str(1:idx(8)-1);
if timeseries_span == 1
    %6hr:
    PV1_loadshape_daily = M_PVSITE(MNTH).PU(time2int(DAY,10,0):time2int(DAY,15,59),1);%1minute interval --
    PV_loadshape_daily = interp(PV1_loadshape_daily(:,1),60); %go down to 1 second dataset --
    s_pv_txt = '\LS_PVpeakhours.txt';
elseif timeseries_span == 2
    %24hr:
    PV1_loadshape_daily = M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
    PV_loadshape_daily = interp(PV1_loadshape_daily(:,1),60); %go down to 1 second dataset --
    s_pv_txt = '\LS_PVdaily.txt';
elseif timeseries_span == 3
    %168hr(1week):
    PV1_loadshape_daily = M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY+6,23,59),1);%1minute interval --
    PV_loadshape_daily = interp(PV1_loadshape_daily(:,1),30); %60sec. to 2sec dataset --
    s_pv_txt = '\LS_PVweekly.txt';
elseif timeseries_span == 4
    %29-31day sim (1mnth):
    MNTH = monthly_span;    %DOY & shift come from feeder_Loadshape_generation.m
    MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
    MTH_DY(2,1:12) = [1,32,60,91,121,152,182,213,244,274,305,335];
    DOY = MTH_DY(2,monthly_span);   %From top--> monthly_span:
    shift = MTH_LN(1,monthly_span)-1;
    
    PV1_loadshape_daily = M_PVSITE(MNTH).PU(time2int(1,0,0):time2int(shift+1,23,59),1);%1minute interval --
    PV_loadshape_daily = interp(PV1_loadshape_daily(:,1),6); %60sec. to 10sec dataset --
    if shift+1 == 28
        s_pv_txt = '\LS_PVmonthly28.txt';   %241920 datapoints (28*24*60*60/10)
    elseif shift+1 == 30
        s_pv_txt = '\LS_PVmonthly30.txt';   %259200 datapoints (30*24*60*60/10)
    elseif shift+1 == 31
        s_pv_txt = '\LS_PVmonthly31.txt';   %267840 datapoints (31*24*60*60/10)
    end
elseif timeseries_span == 5
    %365 (1year):
    DAY = 1;
    PV1_loadshape_daily = M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY+364,23,59),1);%1minute interval --
    PV_loadshape_daily = interp(PV1_loadshape_daily(:,1),6); %60sec. to 10sec dataset --   
    s_pv_txt = '\LS_PVannual.txt';
end
clearvars M_PVSITE %RR_distrib
%Write .csv file for simulation --
s_pv = strcat(s,s_pv_txt);
csvwrite(s_pv,PV_loadshape_daily)
%%
%see if we can export .dss file --
%type PV_loadshape.dat
%{
if timeseries_span == 1
    PV_opendss_file=cellstr('new loadshape.PV_Loadshape npts=21600 sinterval=1 csvfile="LS_PVpeakhours.txt" Pbase=1.00 action=normalizenew pvsystem.PV bus1=258405587 irradiance=1 phases=3 kv=12.47 kVA=1100.00 pf=1.00 pmpp=1000.00 duty=PV_Loadshape');
    filename=strcat(s,'\Flay_CentralPV_6hr.dss');
elseif timeseries_span == 2
    PV_opendss_file=cellstr('new loadshape.PV_Loadshape npts=86400 sinterval=1 csvfile="LS_PVdaily.txt" Pbase=1.00 action=normalizenew pvsystem.PV bus1=258405587 irradiance=1 phases=3 kv=12.47 kVA=1100.00 pf=1.00 pmpp=1000.00 duty=PV_Loadshape');
    filename=strcat(s,'\Flay_CentralPV_24hr.dss');
end

fid=fopen(filename,'w');
for i=1:length(PV_opendss_file)
    cell=cell2mat(PV_opendss_file(1,i));
    fprintf(fid,[cell ' ']);
end
fclose(fid);

%csvwrite(filename,PV_opendss_file);
%}


