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

if feeder_NUM < 3
    Cap_info = getCapacitorInfo(DSSCircObj);
    Lines_info = getLineInfo(DSSCircObj);
    [~,index] = sortrows([Lines_info.bus1Distance].');
    Lines_info = Lines_info(index);
end
%Loads_info = getLoadInfo(DSSCircObj);
%%
% 4. Main Loop
%---------------------------------
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
% 5. User Select run length:
slt_DAY_RUN = 1;

if slt_DAY_RUN == 1
    %One day run on 2/13
    DAY = 13;
    MNTH = 2;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY;
elseif slt_DAY_RUN == 2
    %3 mnth run 2/1 - 5/1
    DAY = 1;
    MNTH = 2;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+MTH_LN(2)+MTH_LN(3)+MTH_LN(4)-1;
elseif slt_DAY_RUN == 3
    %Annual run
    DAY = 1;
    MNTH = 1;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F=364;
elseif slt_DAY_RUN == 4
    %One week run
    DAY = 1;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+6;
elseif slt_DAY_RUN == 5
    %Summer run:
    DAY = 1;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+MTH_LN(6)+MTH_LN(7)+MTH_LN(8)-1;
elseif slt_DAY_RUN == 6
    %DSDR to show cap movements:
    DAY = 13;
    MNTH = 6;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+6; %1 week run.
end

int_select=3;
if int_select == 1
    %5sec load sim step:
    int_1m=12;
    s_step=5; %sec
    ss=1;
    NUM_INC=60;
elseif int_select == 2
    %60sec load sim step:
    int_1m=1;
    s_step=60; %sec
    ss=1;
    NUM_INC=1;
elseif int_select == 3
    %5sec load sim step:
    int_1m=12;
    s_step=5; %sec
    ss=5;
    NUM_INC=60/5;
end

%%
cap_timer = 0;
tap_timer = 0;
v_sum = 0;
BUCK = 0;
BOOST = 0;

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
    PV_loadshape_daily = (PV_ON_OFF-1)*M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
    sim_num_PV=1440*12;
    sim_num=1440*int_1m;
    
    PV_loadshape_daily_1 = interp(PV_loadshape_daily,12);
    CAP_OPS_STEP2_1(DAY_I).kW(:,1) = interp(CAP_OPS_STEP2(DAY_I).kW(:,1),int_1m); %60s -> 5s
    CAP_OPS_STEP2_1(DAY_I).kW(:,2) = interp(CAP_OPS_STEP2(DAY_I).kW(:,2),int_1m); %60s -> 5s
    CAP_OPS_STEP2_1(DAY_I).kW(:,3) = interp(CAP_OPS_STEP2(DAY_I).kW(:,3),int_1m); %60s -> 5s
    CAP_OPS_1(DAY_I).DSS(:,1) = eff_KVAR(1,1)*interp(CAP_OPS(DAY_I).DSS(:,1),int_1m);
    CAP_OPS_1(DAY_I).DSS(:,2) = eff_KVAR(1,2)*interp(CAP_OPS(DAY_I).DSS(:,2),int_1m);
    CAP_OPS_1(DAY_I).DSS(:,3) = eff_KVAR(1,3)*interp(CAP_OPS(DAY_I).DSS(:,3),int_1m);
    
    if feeder_NUM < 4
        if DAY_I == DOY
            %--  Generate Solar Shapes:
            filelocation=strcat(s,'\');
            fileID = fopen([filelocation,'Loadshape_PV.dss'],'wt');
            fprintf(fileID,['New loadshape.LS_Solar npts=%s sinterval=%s mult=(',...
                sprintf('%f ',PV_loadshape_daily_1(:,1)),')\n'],num2str(sim_num_PV),num2str(s_step));
            %if PV_ON_OFF == 2
                fprintf(fileID,'new generator.PV bus1=%s phases=3 kv=%s kW=%s pf=1.00 Daily=LS_Solar enable=true\n',num2str(PV_bus),V_LL,num2str(PV_pmpp));
            %end
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
    else
        %Feeder 04
        if DAY_I == DOY
            %--  Generate Solar Shapes:
            filelocation=strcat(s,'\');
            fileID = fopen([filelocation,'Loadshape_PV.dss'],'wt');
            fprintf(fileID,['New loadshape.LS_Solar npts=%s sinterval=%s mult=(',...
                sprintf('%f ',PV_loadshape_daily_1(:,1)),')\n'],num2str(sim_num_PV),num2str(s_step));
            %if PV_ON_OFF == 2
                fprintf(fileID,'new generator.PV bus1=%s phases=3 kv=%s kW=%s pf=1.00 Daily=LS_Solar enable=true\n',num2str(PV_bus),V_LL,num2str(PV_pmpp));
            %end
            fclose(fileID);
            %--  Generate Load Shapes:
            filelocation=strcat(s,'\');
            fileID = fopen([filelocation,'Loadshape.dss'],'wt');
            fprintf(fileID,['New loadshape.LS_PhaseA npts=%s sinterval=%s pmult=(',...
                sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,1)/LoadTotals.kWA),') qmult=(',...
                sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,1)/LoadTotals.kVARA),')\n\n'],num2str(sim_num),num2str(s_step));
            fprintf(fileID,['New loadshape.LS_PhaseB npts=%s sinterval=%s pmult=(',...
                sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,2)/LoadTotals.kWB),') qmult=(',...
                sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,2)/LoadTotals.kVARB),')\n\n'],num2str(sim_num),num2str(s_step));
            fprintf(fileID,['New loadshape.LS_PhaseC npts=%s sinterval=%s pmult=(',...
                sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,3)/LoadTotals.kWC),') qmult=(',...
                sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,3)/LoadTotals.kVARC),')\n\n'],num2str(sim_num),num2str(s_step));
            fclose(fileID);

        else
            %-- Edit Loadshapes for next day:
            DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseA pmult=(',...
                sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,1)/LoadTotals.kWA),') qmult=(',...
                sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,1)/LoadTotals.kVARA),')']);
            DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseB pmult=(',...
                sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,2)/LoadTotals.kWB),') qmult=(',...
                sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,2)/LoadTotals.kVARB),')']);
            DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseC pmult=(',...
                sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,3)/LoadTotals.kWC),') qmult=(',...
                sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,3)/LoadTotals.kVARC),')']);
            DSSText.Command = sprintf(['Edit Loadshape.LS_Solar mult=(',...
                sprintf('%f ',PV_loadshape_daily_1(:,1)),')']);
        end
    end
    %{
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
    %}
    %%
    %--  Find {actual} reactive power:
    KVAR_ACTUAL.data=CAP_OPS_STEP1(DAY_I).data(:,1:6);
    %--  Find old Cap_Ops & initial status:
    sw_cap= CAP_OPS_STEP1(DAY_I).data(:,4);
    
    
    if DAY_I==DOY
        DSSText.command = ['Compile ',ckt_direct_prime];
        %Lines_info = getLineInfo(DSSCircObj);
        %[~,index] = sortrows([Lines_info.bus1Distance].');
        %Lines_info = Lines_info(index);
        if feeder_NUM < 3
            DSSText.command=sprintf('Edit Capacitor.%s states=0',swcap_name);
            cap_pos = 0;    %used to be 1
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,'1.00625');
            if VRR_Scheme == 1
                DSSText.command=sprintf('New RegControl.%s Transformer=%s Winding=2 R=0 X=0 Vreg=124 Band=1 PTratio=%s CTPrim=%s Delay=%s PTPhase=%s',trans_name,trans_name,PT_RATIO,CT_RATIO,'45',PT_PHASE);
            end
        elseif feeder_NUM == 3
            %Roxboro has alot of VRDs:
            DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{1},num2str(CAP_OPS(DAY_I).oper(1,1)));
            DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{2},num2str(CAP_OPS(DAY_I).oper(1,2)));
            DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{3},num2str(CAP_OPS(DAY_I).oper(1,3)));
        end
        
    else
        if feeder_NUM < 3
            DSSText.command=sprintf('Edit Capacitor.%s states=%s',swcap_name,num2str(CAP_DAY));
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,TAP_DAY);
        elseif feeder_NUM == 3
            %Roxboro has alot of VRDs:
            DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{1},num2str(CAP_OPS(DAY_I).oper(1,1)));
            DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{2},num2str(CAP_OPS(DAY_I).oper(1,2)));
            DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{3},num2str(CAP_OPS(DAY_I).oper(1,3)));
            DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,TAP_DAY);
        end
    end
    %--  Run QSTS 24hr sim:
    if timeseries_span == 2
        %(1) DAY, 24hr, 1 second timestep for MATLAB controls.
        %
        % Configure Simulation:
        DSSText.command=sprintf('set mode=daily stepsize=%s number=1 controlMode=TIME','0.083333'); %num2str(ss)
        DSSCircuit.Solution.dblHour = 0.0;
        i = 1; %counter for TVD sample & voltage violation check
        for t = 1:1:1440*NUM_INC
            
            % Solve at current time step
            if t == 3
                Buses_info = getBusInfo(DSSCircObj);
            end
            DSSCircuit.Solution.Solve
            DSSCircuit.SetActiveElement(sprintf('Line.%s',sub_line));
            Power   = DSSCircuit.ActiveCktElement.Powers;
            %Single Phase Real Power:
            MEAS(t).Sub_P_PhA = Power(1);
            MEAS(t).Sub_P_PhB = Power(3);
            MEAS(t).Sub_P_PhC = Power(5);
            %Single Phase Reactive Power:
            MEAS(t).Sub_Q_PhA = Power(2);
            MEAS(t).Sub_Q_PhB = Power(4);
            MEAS(t).Sub_Q_PhC = Power(6);
            
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
            % Switching Capacitor Control to verify accuracy.
            %{
            if mod(t,60) == 0
                Cap_Control_1
            end
            %}
            if feeder_NUM < 3
                Cap_Control_Active_Q
                BESS_Control_PeakShaving
                OLTC_Control_Active
            elseif feeder_NUM == 3
                %ROX
                if mod(t,900) == 0
                    %Every 15 mins..
                    Cap_Control_DSDR
                end
                SVR_Tap_Pos_DSDR
            end
            if mod(5*t,3600) == 0
                fprintf('Hour: %d\n',5*t/3600);
                if 5*t/3600 == 12
                    DSSText.command='Edit Storage.BESS1 State=IDLING';
                end
            end
            
        end
        
        %save tap pos to reset after next day load allocation:
        DSSText.command = sprintf('? Transformer.%s.Tap',trans_name);
        TAP_DAY = DSSText.Result;
        if feeder_NUM < 3
            CAP_DAY = YEAR_CAPSTATUS(DAY_I).CAP_POS(t,1);
        end
        
    end
    toc
    tic
    Export_Monitors_timeseries
    %Save Substation Info:
    %%
    YEAR_SUB(DAY_I).V=DATA_SAVE(1).phaseV;
    YEAR_LTC(DAY_I).OP=DATA_SAVE(1).LTC_Ops;
    YEAR_SIM_P(DAY_I).DSS_SUB=DATA_SAVE(1).phaseP;
    YEAR_SIM_Q(DAY_I).DSS_SUB=DATA_SAVE(1).phaseQ;
    if feeder_NUM == 3
        for LTC_n=1:1:5
            YEAR_LTCSTATUS(DAY_I).SVR(LTC_n).ph=SVR(LTC_n).ph;
            YEAR_LTCSTATUS(DAY_I).SVR(LTC_n).TAP=SVR(LTC_n).TAP;
        end
        
    end
    %Go onto next day...    
    DAY = DAY + 1;
    toc
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



%{
YEAR_CAPSTATUS(DOY).CAP_POS(t,1)=cap_pos;
YEAR_CAPSTATUS(DOY).Q_CAP(t,1)=MEAS(t).PF(1,7); %Reactive Power of cap_bank
YEAR_CAPCNTRL(DOY).CTL_PF(t,1)=MEAS(t).PF(1,4); %control PF
YEAR_CAPCNTRL(DOY).LD_LG(t,1)=MEAS(t).PF(1,6); %lead/lag
%}
%%
plot([BESS(1:17280).PCC])
hold on
plot([BESS(1:17280).kW])
    