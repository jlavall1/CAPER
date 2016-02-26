% 1. Generate Real Power & PV loadshape files:
%PV_Loadshape_generation
%cap_pos=1;
%feeder_Loadshape_generation_Dynamic %ckt_direct_prime (generated)
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%
% 2. Compile the user selected circuit:
DSSText.command = ['Compile ',ckt_direct_prime]; %Master_General.dss
%location = cd;
%cd(location);

%Cap_info = getCapacitorInfo(DSSCircObj);
%Lines_info = getLineInfo(DSSCircObj);
%[~,index] = sortrows([Lines_info.bus1Distance].');
%Lines_info = Lines_info(index);
Buses_info = getBusInfo(DSSCircObj);
%Loads_info = getLoadInfo(DSSCircObj);
%%
% 4. Main Loop
%---------------------------------
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
DAY = 1;
DAY_F = MTH_LN(2)+MTH_LN(3)+MTH_LN(4)-1;
%DAY_F =0;
MNTH = 2;
DOY=calc_DOY(MNTH,DAY);
cap_timer = 0;
tap_timer = 0;
BUCK = 0;
BOOST = 0;
%DOY=64;DOY+1
for DAY_I=DOY:1:DOY+DAY_F %365
    tic
    %-- Update Irradiance/PV_KW
    if DAY > MTH_LN(MNTH)
        MNTH = MNTH + 1;
        DAY = 1;
    end
    fprintf('\nQSTS Simulation: DOY= %d\n',DAY_I);
    %%
    PV_loadshape_daily = (PV_ON_OFF-1)*M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
    
    if DAY_I == DOY
        %--  Generate Solar Shapes:
        filelocation=strcat(s,'\');
        fileID = fopen([filelocation,'Loadshape_PV.dss'],'wt');
        fprintf(fileID,['New loadshape.LS_Solar npts=%s sinterval=%s mult=(',...
            sprintf('%f ',PV_loadshape_daily(:,1)),')\n'],num2str(sim_num),num2str(s_step));
        %if PV_ON_OFF == 2
            fprintf(fileID,'new generator.PV bus1=%s phases=3 kv=12.47 kW=%s pf=1.00 Daily=LS_Solar enable=true\n',num2str(PV_bus),num2str(PV_pmpp));
        %end
        fclose(fileID);
        %--  Generate Load Shapes:
        filelocation=strcat(s,'\');
        fileID = fopen([filelocation,'Loadshape.dss'],'wt');
        fprintf(fileID,['New loadshape.LS_PhaseA npts=%s sinterval=%s pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2(DAY_I).kW(:,1)),') qmult=(',...
            sprintf('%f ',CAP_OPS(DAY_I).DSS(:,1)),')\n\n'],num2str(sim_num),num2str(s_step));
        fprintf(fileID,['New loadshape.LS_PhaseB npts=%s sinterval=%s pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2(DAY_I).kW(:,2)),') qmult=(',...
            sprintf('%f ',CAP_OPS(DAY_I).DSS(:,2)),')\n\n'],num2str(sim_num),num2str(s_step));
        fprintf(fileID,['New loadshape.LS_PhaseC npts=%s sinterval=%s pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2(DAY_I).kW(:,3)),') qmult=(',...
            sprintf('%f ',CAP_OPS(DAY_I).DSS(:,3)),')\n\n'],num2str(sim_num),num2str(s_step));
        fclose(fileID);
        
    else
        %-- Edit Loadshapes for next day:
        DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseA pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2(DAY_I).kW(:,1)),') qmult=(',...
            sprintf('%f ',CAP_OPS(DAY_I).DSS(:,1)),')']);
        DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseB pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2(DAY_I).kW(:,2)),') qmult=(',...
            sprintf('%f ',CAP_OPS(DAY_I).DSS(:,2)),')']);
        DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseC pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2(DAY_I).kW(:,3)),') qmult=(',...
            sprintf('%f ',CAP_OPS(DAY_I).DSS(:,3)),')']);
        DSSText.Command = sprintf(['Edit Loadshape.LS_Solar mult=(',...
            sprintf('%f ',PV_loadshape_daily(:,1)),')']);
    end
    %%
    %--  Find {actual} reactive power:
    KVAR_ACTUAL.data=CAP_OPS_STEP1(DAY_I).data(:,1:6);
    %--  Find old Cap_Ops & initial status:
    sw_cap= CAP_OPS_STEP1(DAY_I).data(:,4);
    
    
    if DAY_I==DOY
        DSSText.command = ['Compile ',ckt_direct_prime];
        Lines_info = getLineInfo(DSSCircObj);
        [~,index] = sortrows([Lines_info.bus1Distance].');
        Lines_info = Lines_info(index);
        DSSText.command='Edit Capacitor.38391707_sw states=0';
        cap_pos = 0; %used to be 1
        DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,'1.00625');
    else
        DSSText.command=sprintf('Edit Capacitor.38391707_sw states=%s',num2str(CAP_DAY));
        DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,TAP_DAY);
    end
    %--  Run QSTS 24hr sim:
    if timeseries_span == 2
        %(1) DAY, 24hr, 1 second timestep for MATLAB controls.
        %
        % Configure Simulation:
        DSSText.command='set mode=daily stepsize=1 number=1';
        DSSCircuit.Solution.dblHour = 0.0;
        i = 1; %counter for TVD sample & voltage violation check
        for t = 1:1:1440*60
            % Solve at current time step
            DSSCircuit.Solution.Solve
            % Calc TVD every 5sec & only during PV hours
            if t>=10*3600 && t<16*3600
                if mod(t,5) == 0
                    Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
                    YEAR_FDR(i).V=[Voltages'];
                    phaseVoltagesPU = {Buses_info.phaseVoltagesPU}.';
                    TVD_SAVE(i,1:4)=TVD_Calc_5sec(Voltages',phaseVoltagesPU);
                    i = i + 1;
                end
            end  
            % Switching Capacitor Control
            %{
            if mod(t,60) == 0
                Cap_Control_1
            end
            %}
            Cap_Control_Active_Q
            OLTC_Control_Active
            if mod(t,3600) == 0
                fprintf('Hour: %d\n',t/3600);
            end
            
        end
        
        %save tap pos to reset after next day load allocation:
        DSSText.command = sprintf('? Transformer.%s.Tap',trans_name);
        TAP_DAY = DSSText.Result;
        CAP_DAY = YEAR_CAPSTATUS(DAY_I).CAP_POS(t,1);
        
    end
    toc
    tic
    Export_Monitors_timeseries
    %Find P,Q residuals=DSCADA-DSS
    
    YEAR_SUB(DAY_I).V=DATA_SAVE(1).phaseV;
    YEAR_LTC(DAY_I).OP=DATA_SAVE(1).LTC_Ops;
    YEAR_SIM_P(DAY_I).DSS_SUB=DATA_SAVE(1).phaseP;
    YEAR_SIM_Q(DAY_I).DSS_SUB=DATA_SAVE(1).phaseQ;
    
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
fn1='\YR_SIM_SUBV_';
fn1=strcat(filedir,fn1);
fn1=strcat(fn1,scen_nm);
save(fn1,'YEAR_SUB');
%2]
fn2='\YR_SIM_OLTC_';
fn2=strcat(filedir,fn2);
fn2=strcat(fn2,scen_nm);
save(fn2,'YEAR_LTC');
%3]
fn3='\YR_SIM_P_';
fn3=strcat(filedir,fn3);
fn3=strcat(fn3,scen_nm);
save(fn3,'YEAR_SIM_P');
%4]
fn4='\YR_SIM_Q_';
fn4=strcat(filedir,fn4);
fn4=strcat(fn4,scen_nm);
save(fn4,'YEAR_SIM_Q');
%5]
fn5='\YR_SIM_TVD_';
fn5=strcat(filedir,fn5);
fn5=strcat(fn5,scen_nm);
save(fn5,'Settings');
%6]
fn6='\YR_SIM_MEAS_'; %more can be added to this
fn6=strcat(filedir,fn6);
fn6=strcat(fn6,scen_nm);
save(fn6,'DATA_SAVE');
%7]
fn7='\YR_SIM_CAP1_';
fn7=strcat(filedir,fn7);
fn7=strcat(fn7,scen_nm);
save(fn7,'YEAR_CAPSTATUS');
%8]
fn8='\YR_SIM_CAP2_';
fn8=strcat(filedir,fn8);
fn8=strcat(fn8,scen_nm);
save(fn8,'YEAR_CAPCNTRL');
%%
%9]
fn9='\YR_SIM_FDR_V_';
fn9=strcat(filedir,fn9);
fn9=strcat(fn9,scen_nm);
save(fn9,'YEAR_FDR');



%{
YEAR_CAPSTATUS(DOY).CAP_POS(t,1)=cap_pos;
YEAR_CAPSTATUS(DOY).Q_CAP(t,1)=MEAS(t).PF(1,7); %Reactive Power of cap_bank
YEAR_CAPCNTRL(DOY).CTL_PF(t,1)=MEAS(t).PF(1,4); %control PF
YEAR_CAPCNTRL(DOY).LD_LG(t,1)=MEAS(t).PF(1,6); %lead/lag
%}
    