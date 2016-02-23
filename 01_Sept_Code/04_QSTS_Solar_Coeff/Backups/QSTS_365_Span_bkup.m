% 1. Generate Real Power & PV loadshape files:
%PV_Loadshape_generation
%cap_pos=1;
%feeder_Loadshape_generation_Dynamic %ckt_direct_prime (generated)

%
% 2. Compile the user selected circuit:
location = cd;
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;



%%   
%cd(location);
%
% 3. Compile PV system to a location:

%Force the following:
%}
%-------------------------------------
%Add PV Plant:
%%
str = ckt_direct;
idx = strfind(str,'\');
str = str(1:idx(8)-1);
%  ***root & root1 gen. in feeder_Loadshape_generation***
if timeseries_span == 1
    s_pv_txt = sprintf('%s_CentralPV_6hr.dss',dss_rt);
elseif timeseries_span == 2
    s_pv_txt = sprintf('%s_CentralPV_24hr.dss',dss_rt); %just added the 2
elseif timeseries_span == 3
    s_pv_txt = sprintf('%s_CentralPV_168hr.dss',dss_rt);
elseif timeseries_span == 4
    if shift+1 == 28
        s_pv_txt = sprintf('%s_CentralPV_1mnth28.dss',dss_rt);
    elseif shift+1 == 30
        s_pv_txt = sprintf('%s_CentralPV_1mnth30.dss',dss_rt);
    elseif shift+1 == 31
        s_pv_txt = sprintf('%s_CentralPV_1mnth31.dss',dss_rt);
    end
elseif timeseries_span == 5
    s_pv_txt = sprintf('%s_CentralPV_365dy.dss',dss_rt);
end
s='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\';
solarfilename = strcat(s,s_pv_txt);
%%
%solarfilename = 'C:\Users\jlavall\Documents\OpenDSS\GridPV\ExampleCircuit\Ckt24_PV_Central_7_5.dss';
%if PV_ON_OFF == 2
%    DSSText.command = sprintf('Compile (%s)',solarfilename); %add solar scenario
%end
DSSText.command = ['Compile ',ckt_direct_prime]; %Master_General.dss
location = cd;
cd(location);
Cap_info = getCapacitorInfo(DSSCircObj);
Lines_info = getLineInfo(DSSCircObj);
[~,index] = sortrows([Lines_info.bus1Distance].');
Lines_info = Lines_info(index);
Buses_info = getBusInfo(DSSCircObj);
Loads_info = getLoadInfo(DSSCircObj);

%DSSText.command = sprintf('edit pvsystem.PV bus1=%s pmpp=%s kVA=%s',PV_bus,num2str(PV_pmpp),num2str(PV_pmpp*1.1));
%------------------------------------------
%{
if PV_ON_OFF == 2
    DSSText.command=sprintf('new pvsystem.PV bus1=%s irradiance=1 phases=3 kv=12.47 pf=1.00 daily=LS_PVshape pmpp=%s kVA=%s',PV_bus,num2str(PV_pmpp),num2str(PV_pmpp*1.1));
    DSSText.command='edit pvsystem.PV enabled=true';
else
    DSSText.command='edit pvsystem.PV enabled=false';
end
%}
%%
% 4. Main Loop
%---------------------------------
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
DAY = 1;
MNTH = 1;
cap_pos = 0; %used to be 1
DSSText.command='Edit Capacitor.38391707_sw enabled=false';
for DOY=1:1:364 %365
    tic
    %-- Update Irradiance/PV_KW
    if DAY > MTH_LN(MNTH)
        MNTH = MNTH + 1;
        DAY = 1;
    end
    fprintf('\nQSTS Simulation: DOY= %d\n',DOY);
    PV1_loadshape_daily = M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
    PV_loadshape_daily = (PV_ON_OFF-1)*interp(PV1_loadshape_daily(:,1),60); %go down to 1 second dataset --
    s_pv_txt = 'LS_PVdaily.csv';
    s_pv = strcat(s,s_pv_txt);
    %csvwrite(s_pv,PV_loadshape_daily)
    
%
    %-- Generate PV Shape:

    filelocation=strcat(s,'');
    %fileID = fopen([filelocation,'Loadshape_PV.csv'],'wt');
    %{
    fileID = fopen([filelocation,'Loadshape_PV.dss'],'wt');
    fprintf(fileID,['New loadshape.LS_PVshape Pbase=1.00 npts=%s sinterval=%s action=normalize mult=(',...
       sprintf('%0.4f ',PV_loadshape_daily),')\n\n'],num2str(86400),num2str(1));
    %{
    %fprintf(fileID,['New loadshape.LS_PVshape Pbase=1.00 action=normalize npts=%s sinterval=%s mult=(',...
        %sprintf('%f ',PV_loadshape_daily(:,1)),')'],'86400','1');
    %fprintf(fileID,'New loadshape.LS_PVshape Pbase=1.00 npts=86400 sinterval=1 mult=(file=LS_PVdaily.csv) action=normalize');
    %fprintf(fileID,['New loadshape.LS_PVshape Pbase=1.00 npts=86400 sinterval=1',sprintf('%f ',PV_loadshape_daily),'action=normalize');
    %fprintf(fileID,['New loadshape.LS_PVshape Pbase=1.00 npts=%s sinterval=%s action=normalize mult=(',...
    %    sprintf('%0.2f ',PV_loadshape_daily),')\n\n'],num2str(86400),num2str(1));
    %fprintf(fileID,'New loadshape.LS_PVshape Pbase=1.00 npts=86400 sinterval=1 csvfile="LS_PVdaily.txt" action=normalize');
    %New loadshape.LS_PVshape Pbase=1.00 npts=86400 interval=(1.0 3600 /) mult=(File=LS_PVdaily.csv)
    %}
    %fprintf(fileID,sprintf('%f,\n ',PV_loadshape_daily));
    fclose(fileID);
    %}
     %
    %--  Generate Load Shapes:
    
    filelocation=strcat(s,'\');
    
    fileID = fopen([filelocation,'Loadshape_SOLAR.dss'],'wt');
    fprintf(fileID,['New loadshape.LS_PVshape Pbase=1.00 npts=%s sinterval=%s action=normalize mult=(',...
       sprintf('%0.4f ',PV_loadshape_daily),')\n\n'],num2str(86400),num2str(1));
    fclose(fileID);
    
    fileID = fopen([filelocation,'Loadshape.dss'],'wt');
    fprintf(fileID,['New loadshape.LS_PhaseA npts=%s sinterval=%s pmult=(',...
        sprintf('%4.3f ',CAP_OPS_STEP2(DOY).kW(:,1)),') qmult=(',...
        sprintf('%4.3f ',CAP_OPS(DOY).DSS(:,1)),')\n\n'],num2str(sim_num),num2str(s_step));
    fprintf(fileID,['New loadshape.LS_PhaseB npts=%s sinterval=%s pmult=(',...
        sprintf('%4.3f ',CAP_OPS_STEP2(DOY).kW(:,2)),') qmult=(',...
        sprintf('%4.3f ',CAP_OPS(DOY).DSS(:,2)),')\n\n'],num2str(sim_num),num2str(s_step));
    fprintf(fileID,['New loadshape.LS_PhaseC npts=%s sinterval=%s pmult=(',...
        sprintf('%4.3f ',CAP_OPS_STEP2(DOY).kW(:,3)),') qmult=(',...
        sprintf('%4.3f ',CAP_OPS(DOY).DSS(:,3)),')\n\n'],num2str(sim_num),num2str(s_step));
    %{
    fprintf(fileID,['New loadshape.LS_PVshape Pbase=1.00 npts=%s sinterval=%s action=normalize mult=(',...
       sprintf('%0.3f ',PV_loadshape_daily),')\n\n'],num2str(86400),num2str(1));
        %}
    fclose(fileID); 
        %%
    KVAR_ACTUAL.data=CAP_OPS_STEP1(DOY).data(:,1:6);
    
    %-- Find Cap Ops & Pmult/Qmult from CAP_OPS {struct}
    sw_cap= CAP_OPS_STEP1(DOY).data(:,4);
    
    %--  Tell program where DSS Files are:
    if feeder_NUM == 2
        CUTOFF=10;
    else
        CUTOFF=23;
    end

    %--  Re-Compile .DSS files:
    DSSText.command = ['Compile ',ckt_direct_prime];
    location = cd;
    cd(location);
    %fprintf('hi\n');
    if PV_ON_OFF == 2
        %DSSText.command = 'New loadshape.LS_PVshape Pbase=1.00 npts=86400 sinterval=1 mult=(file=LS_PVdaily.csv) action=normalize';
        DSSText.command = sprintf('new pvsystem.PV bus1=%s irradiance=1 phases=3 kv=12.47 pf=1.00 daily=LS_PVshape pmpp=%s kVA=%s',PV_bus,num2str(PV_pmpp),num2str(PV_pmpp*1.1));
    end
    DSSText.command='Edit Capacitor.38391707_sw enabled=false';
    
    %--  Run QSTS 24hr sim:
    if timeseries_span == 2
        %(1) DAY, 24hr
        % Solve QSTS Solution:
        DSSText.command=sprintf('set mode=daily stepsize=%s number=%s',time_int,'1');
        DSSCircuit.Solution.dblHour = 0.0;
        for t = 1:1:str2num(sim_num)
            % Solve at current time step
            DSSCircuit.Solution.Solve
            % Switching Capacitor Control
            Cap_Control_1
        end
    end
    Export_Monitors_timeseries
    %Find P,Q residuals=DSCADA-DSS
    YEAR_SIM_LTC(DOY).DSS_LTC_V=DATA_SAVE(1).phaseV;
    YEAR_SIM_LTC(DOY).DSS_LTC_OP=DATA_SAVE(1).LTC_Ops;
    YEAR_SIM_PQ(DOY).DSS_SUB_P=DATA_SAVE(1).phaseP;
    YEAR_SIM_PQ(DOY).DSS_SUB_Q=DATA_SAVE(1).phaseQ;
    %Find Base Case LTC & Cap ops/day
    %Pre_Summary
    
    DAY = DAY + 1;
    toc
end
%%
%Save necessary datasets:
%root = 'FLAY_0';
%root1='03_FLAY';
%Zsc_loc=[00,10,25,50];
filedir = strcat(base_path,'\01_Sept_Code\04_QSTS_Solar_Coeff\');
filedir = strcat(filedir,root1);
scen_nm = strcat(root,num2str(Zsc_loc(LC)));
%1]
fn1='\YR_SIM_LTC_';
fn1=strcat(filedir,fn1);
fn1=strcat(fn1,scen_nm);
save(fn1,'YEAR_SIM_LTC');
%2]
fn2='\YR_SIM_PQ_';
fn2=strcat(filedir,fn2);
fn2=strcat(fn2,scen_nm);
save(fn2,'YEAR_SIM_PQ');
%3]
fn3='\YR_SIM_TVD_';
fn3=strcat(filedir,fn3);
fn3=strcat(fn3,scen_nm);
save(fn3,'Settings');
%4]
fn4='\YR_SIM_MEAS_';
fn4=strcat(filedir,fn4);
fn4=strcat(fn4,scen_nm);
save(fn4,'DATA_SAVE');




    