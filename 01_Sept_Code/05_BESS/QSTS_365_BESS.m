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

%   This will not be available without solving circuit first.
Cap_info = getCapacitorInfo(DSSCircObj);
Lines_info = getLineInfo(DSSCircObj);
[~,index] = sortrows([Lines_info.bus1Distance].');
Lines_info = Lines_info(index);
%Loads_info = getLoadInfo(DSSCircObj);

%%
% 1. Initialize Flags:
%cap_timer = 0;
%tap_timer = 0;
v_sum = 0;
%BUCK = 0;
%BOOST = 0;
%vio_LTC_time=0;



for DAY_I=DOY:1:DAY_F
    tic
    %-- Update Irradiance/PV_KW
    if DAY > MTH_LN(MNTH)
        MNTH = MNTH + 1;
        DAY = 1;
    end
    fprintf('\nQSTS Simulation: DOY= %d\n',DAY_I);
    %%
    %Obtain Historical Datasets:
    if PV_SCEN ~= 4
        PV_loadshape_daily = (PV_ON_OFF-1)*M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
        PV_loadshape_daily_1 = interp(PV_loadshape_daily,12);
    elseif PV_SCEN == 4
        %TWO PVs connected:
        %   (1)
        PV_loadshape_daily = (PV_ON_OFF-1)*M_PVSITE_1(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
        PV_loadshape_daily_1 = interp(PV_loadshape_daily,12);
        %   (2)
        PV_loadshape_daily = (PV_ON_OFF-1)*M_PVSITE_2(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
        PV_loadshape_daily_2 = interp(PV_loadshape_daily,12);
    end
        
        
    sim_num_PV=1440*12;
    sim_num=1440*int_1m;
    
    
    CAP_OPS_STEP2_1(DAY_I).kW(:,1) = interp(CAP_OPS_STEP2(DAY_I).kW(:,1),int_1m); %60s -> 5s
    CAP_OPS_STEP2_1(DAY_I).kW(:,2) = interp(CAP_OPS_STEP2(DAY_I).kW(:,2),int_1m); %60s -> 5s
    CAP_OPS_STEP2_1(DAY_I).kW(:,3) = interp(CAP_OPS_STEP2(DAY_I).kW(:,3),int_1m); %60s -> 5s
    CAP_OPS_1(DAY_I).DSS(:,1) = eff_KVAR(1,1)*interp(CAP_OPS(DAY_I).DSS(:,1),int_1m);
    CAP_OPS_1(DAY_I).DSS(:,2) = eff_KVAR(1,2)*interp(CAP_OPS(DAY_I).DSS(:,2),int_1m);
    CAP_OPS_1(DAY_I).DSS(:,3) = eff_KVAR(1,3)*interp(CAP_OPS(DAY_I).DSS(:,3),int_1m);
    

    if DAY_I == DOY
        %--  Generate Solar Shapes:
        filelocation=strcat(s,'\');
        fileID = fopen([filelocation,'Loadshape_PV.dss'],'wt');
        fprintf(fileID,['New loadshape.LS_Solar npts=%s sinterval=%s mult=(',...
            sprintf('%f ',PV_loadshape_daily_1(:,1)),')\n'],num2str(sim_num_PV),num2str(s_step));
        fprintf(fileID,'new generator.PV bus1=%s phases=3 kv=%s kW=%s pf=1.00 Daily=LS_Solar enable=true\n',num2str(PV_bus),V_LL,num2str(PV_pmpp));
        fclose(fileID);
        
        %--  Generate Load Shapes:
        filelocation=strcat(s,'\');
        fileID = fopen([filelocation,'Loadshape.dss'],'wt');
        fprintf(fileID,['New loadshape.LS_PhaseA npts=%s sinterval=%s pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,1)),') qmult=(',...
            sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,1)),')\n\n'],num2str(sim_num),num2str(s_step));
        fprintf(fileID,['New loadshape.LS_PhaseB npts=%s sinterval=%s pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,2)),') qmult=(',...
            sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,2)),')\n\n'],num2str(sim_num),num2str(s_step));
        fprintf(fileID,['New loadshape.LS_PhaseC npts=%s sinterval=%s pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,3)),') qmult=(',...
            sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,3)),')\n\n'],num2str(sim_num),num2str(s_step));
        fclose(fileID);

    else
        %-- Edit Loadshapes for next day:
        DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseA pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,1)),') qmult=(',...
            sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,1)),')']);
        DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseB pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,2)),') qmult=(',...
            sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,2)),')']);
        DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseC pmult=(',...
            sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,3)),') qmult=(',...
            sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,3)),')']);
        DSSText.Command = sprintf(['Edit Loadshape.LS_Solar mult=(',...
            sprintf('%f ',PV_loadshape_daily_1(:,1)),')']);
    end
    

    
    %%
    %--  Find {actual} reactive power:
    KVAR_ACTUAL.data=CAP_OPS_STEP1(DAY_I).data(:,1:6);
    %--  Find old Cap_Ops & initial status:
    sw_cap= CAP_OPS_STEP1(DAY_I).data(:,4);
    
    if DAY_I==DOY
        %Starting DAY --> Compile Circuit & set intial states of SVRs & SC
        DSSText.command = ['Compile ',ckt_direct_prime];
        %--  Switched CAP. State of operation:
        DSSText.command=sprintf('Edit Capacitor.%s states=%s',swcap_name,num2str(sw_cap(1)));
        cap_pos = sw_cap(1);    %(might not be needed...)
        %--  OLTC State of operation:
        DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,'1.00625');
        
        %--  Connect BESS if Requested:
        if BESS_ON == 1
            DECLARE_BESS
        end
        %-- Initialize State variables:
        LTC_STATE(1).VIO_TIME=0;
        LTC_STATE(1).SVR_TMR=0;
        LTC_STATE(1).HV = 0;
        LTC_STATE(1).LV = 0;
        
        SWC_STATE(1).VIO_TIME=0;
        SWC_STATE(1).SC_TMR = 0;
        SWC_STATE(1).SC_OP = 0;
        SWC_STATE(1).SC_CL = 0;
        
        MSTR_STATE(1).F_CAP_CL=0;
        MSTR_STATE(1).F_CAP_OP=0;
        MSTR_STATE(1).SC_CL_EN=0;
        MSTR_STATE(1).SC_OP_EN=0;
        
    else
        %Save VRD states for next DAY run.
        DSSText.command=sprintf('Edit Capacitor.%s states=%s',swcap_name,num2str(CAP_DAY));
        DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,TAP_DAY);
    end
    %--  Run QSTS 24hr sim:
    if timeseries_span == 2
        %(1) DAY, 24hr, 1 second timestep for MATLAB controls.
        %
        % Configure Simulation:
        DSSText.command=sprintf('set mode=daily stepsize=%s number=1 controlMode=TIME',num2str(ss));  %num2str(ss/60)
        DSSCircuit.Solution.dblHour = 0.0;
        i = 1; %counter for TVD sample & voltage violation check
        for t = 1:1:1440*NUM_INC
            
            % Solve at current time step
            if t == 3
                Buses_info = getBusInfo(DSSCircObj);
            end
            DSSCircuit.Solution.Solve
            %--------------------------------------------------------------
            %   Pull only available field datapoints:
            SCADA_PULL
            %^Outputs: SCADA(t) & BESS_M(t)
            %{
            DSSCircuit.SetActiveElement(sprintf('Line.%s',sub_line));
            Power   = DSSCircuit.ActiveCktElement.Powers;
            %   Single Phase Real Power:
            MEAS(t).Sub_P_PhA = Power(1);
            MEAS(t).Sub_P_PhB = Power(3);
            MEAS(t).Sub_P_PhC = Power(5);
            %   Single Phase Reactive Power:
            MEAS(t).Sub_Q_PhA = Power(2);
            MEAS(t).Sub_Q_PhB = Power(4);
            MEAS(t).Sub_Q_PhC = Power(6);
            %}
            %--------------------------------------------------------------
            % Calc TVD every 5sec & only during PV hours (10AM-4PM)
            if t>=10*3600/ss && t<16*3600/ss
                if mod(t,5) == 0
                    Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
                    YEAR_FDR(i).V=[Voltages'];
                    phaseVoltagesPU = {Buses_info.phaseVoltagesPU}.';
                    phaseVoltagesPH = {Buses_info.numPhases}.';
                    phasesVoltageNODE = {Buses_info.nodes}.';
                    TVD_SAVE(i,1)=TVD_Calc_5sec(Voltages',phaseVoltagesPH,phasesVoltageNODE,feeder_NUM);
                    i = i + 1;
                end
            end  
            %--------------------------------------------------------------
            % Voltage Reg. Equip. Controls:
            Master_Control
            if BESS_ON == 1
                %BESS Controller updating CR/DR every 5 seconds.
                BESS_PV_Control
            end
            [SWC_STATE(t),LTC_STATE(t),MSTR_STATE(t)]=OLTC_Control(DSSCircObj,SCADA(t),SWC_STATE(t),LTC_STATE(t),MSTR_STATE(t),t);
            [SWC_STATE(t+1),LTC_STATE(t+1)]=SWC_Control(DSSCircObj,SCADA(t),SWC_STATE(t),LTC_STATE(t),MSTR_STATE(t),t);

            %OLTC_Control_Active
            
            %--------------------------------------------------------------
            % Print out HoD:
            if mod(ss*t,3600) == 0
                fprintf('Hour: %d\n',ss*t/3600);
                
                if PV_ON_OFF == 3
                    if ss*t/3600 == 12
                        %At noon, move state to idle
                        DSSText.command='Edit Storage.BESS1 State=IDLING';
                    end
                end
            end
            
        end
        i = 1; %(index for TVD & FDR_Voltage vectors)
        %------------------------------------------------------------------
        %Save Status of Equipement for Next Day Run:
        TAP_DAY = SCADA(t).OLTC_TAP;
        CAP_DAY = SCADA(t).SC_S; 
    end
    %%
    toc
    tic
    Export_Monitors_timeseries
    %Save Results:
    DAY_Struct_SAVE
    toc

    %Go onto next day...    
    DAY = DAY + 1;
end
%%
%Save necessary datasets:
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
if slt_DAY_RUN == 2
    for DOY=1:1:120
        if DOY <= 60
            YEAR_SIM_Q_1(DOY).DSS_SUB=YEAR_SIM_Q(DOY).DSS_SUB;
        else
            YEAR_SIM_Q_2(DOY).DSS_SUB=YEAR_SIM_Q(DOY).DSS_SUB;
        end
    end
    fn4='\YR_SIM_Q_1_';
    fn4=strcat(filedir,fn4);
    fn4=strcat(fn4,scen_nm);
    save(fn4,'YEAR_SIM_Q_1');
    fn44='\YR_SIM_Q_2_';
    fn44=strcat(filedir,fn44);
    fn44=strcat(fn44,scen_nm);
    save(fn44,'YEAR_SIM_Q_2');
else
    fn4='\YR_SIM_Q_';
    fn4=strcat(filedir,fn4);
    fn4=strcat(fn4,scen_nm);
    save(fn4,'YEAR_SIM_Q');
end

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
%9]
if feeder_NUM ~= 3 
    fn9='\YR_SIM_FDR_V_';
    fn9=strcat(filedir,fn9);
    fn9=strcat(fn9,scen_nm);
    save(fn9,'YEAR_FDR');
end
%10]
fn10='\YR_SIM_LTC_CTL';
fn10=strcat(filedir,fn10);
fn10=strcat(fn10,scen_nm);
save(fn10,'YEAR_LTCSTATUS');
if BESS_ON == 1
    fn11='\YR_SIM_BESS_STATE';
    fn11=strcat(filedir,fn11);
    fn11=strcat(fn11,scen_nm);
    save(fn11,'YEAR_BESS');
end


%{
YEAR_CAPSTATUS(DOY).CAP_POS(t,1)=cap_pos;
YEAR_CAPSTATUS(DOY).Q_CAP(t,1)=MEAS(t).PF(1,7); %Reactive Power of cap_bank
YEAR_CAPCNTRL(DOY).CTL_PF(t,1)=MEAS(t).PF(1,4); %control PF
YEAR_CAPCNTRL(DOY).LD_LG(t,1)=MEAS(t).PF(1,6); %lead/lag
%}
%%
if BESS_ON == 1
    figure(1)
    plot([BESS_M.SOC],'b-','LineWidth',2);
    hold on
    plot(SOC_ref*100,'b--','LineWidth',1);
    figure(2)
    plot([BESS_M.CR],'b-','LineWidth',3);
    hold on
    plot(CR_ref,'r--','LineWidth',2);
    figure(3)
    plot([BESS_M.PCC],'b-','LineWidth',2);
    
end
%{
plot([BESS(1:17280).PCC])
hold on
plot([BESS(1:17280).kW])
%}
    