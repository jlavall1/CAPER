% 1. Generate Real Power & PV loadshape files:
%PV_Loadshape_generation
%cap_pos=1;
%feeder_Loadshape_generation_Dynamic %ckt_direct_prime (generated)
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%
% 2. Compile the user selected circuit:
ckt_direct_prime='C:\Users\jms6\Documents\GitHub\CAPER\CAPER\06_Joshua_Smith\DSS\Master_QSTS.dss';
DSSText.command = ['Compile ',ckt_direct_prime]; %Master_General.dss
% Get gridpv information
Cap_info = getCapacitorInfo(DSSCircObj);
Lines_info = getLineInfo(DSSCircObj);
% Sort lines by distance
[~,index] = sortrows([Lines_info.bus1Distance].');
Lines_info = Lines_info(index);

%Loads_info = getLoadInfo(DSSCircObj);


ReferenceData

MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31]; %number of days/month

slt_DAY_RUN = 1;
% Scenarios
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
end

int_select=2;
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
    ss=60;
    NUM_INC=1;
elseif int_select == 3
    %5sec load sim step:
    int_1m=12;
    s_step=5; %sec
    ss=5;
    NUM_INC=60/5;
end

%%
for DAY_I=DOY:1:DAY_F
    tic
    %-- Update Irradiance/PV_KW
    if DAY > MTH_LN(MNTH)
        MNTH = MNTH + 1;
        DAY = 1;
    end
    fprintf('\nQSTS Simulation: DOY= %d\n',DAY_I);
    
    eff_KVAR=ones(1,3);
    
    % interpolate seconds between minutes
    CAP_OPS_STEP2_1(DAY_I).kW(:,1) = interp(CAP_OPS_STEP2(DAY_I).kW(:,1),int_1m); %60s -> 5s
    CAP_OPS_STEP2_1(DAY_I).kW(:,2) = interp(CAP_OPS_STEP2(DAY_I).kW(:,2),int_1m); %60s -> 5s
    CAP_OPS_STEP2_1(DAY_I).kW(:,3) = interp(CAP_OPS_STEP2(DAY_I).kW(:,3),int_1m); %60s -> 5s
    CAP_OPS_1(DAY_I).DSS(:,1) = eff_KVAR(1,1)*interp(CAP_OPS(DAY_I).DSS(:,1),int_1m);
    CAP_OPS_1(DAY_I).DSS(:,2) = eff_KVAR(1,2)*interp(CAP_OPS(DAY_I).DSS(:,2),int_1m);
    CAP_OPS_1(DAY_I).DSS(:,3) = eff_KVAR(1,3)*interp(CAP_OPS(DAY_I).DSS(:,3),int_1m);
    
%Feeder 04
    if DAY_I == DOY
        %--  Generate Solar Shapes:
        %{
        filelocation=strcat(s,'\');
        fileID = fopen([filelocation,'Loadshape_PV.dss'],'wt');
        fprintf(fileID,['New loadshape.LS_Solar npts=%s sinterval=%s mult=(',...
            sprintf('%f ',PV_loadshape_daily_1(:,1)),')\n'],num2str(sim_num_PV),num2str(s_step));
        %if PV_ON_OFF == 2
            fprintf(fileID,'new generator.PV bus1=%s phases=3 kv=%s kW=%s pf=1.00 Daily=LS_Solar enable=true\n',num2str(PV_bus),V_LL,num2str(PV_pmpp));
        %end
        fclose(fileID);
        %}
        %--  Generate Load Shapes:
        s='C:\Users\jms6\Documents\GitHub\CAPER\CAPER\06_Joshua_Smith\DSS';
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
    
    if DAY_I==DOY
        DSSText.command = ['Compile ',ckt_direct_prime];
        %Lines_info = getLineInfo(DSSCircObj);
        %[~,index] = sortrows([Lines_info.bus1Distance].');
        %Lines_info = Lines_info(index);
        %Roxboro has alot of VRDs:
        DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{1},num2str(CAP_OPS(DAY_I).oper(1,1)));
        DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{2},num2str(CAP_OPS(DAY_I).oper(1,2)));
        DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{3},num2str(CAP_OPS(DAY_I).oper(1,3)));
    else
        %Roxboro has alot of VRDs:
        DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{1},num2str(CAP_OPS(DAY_I).oper(1,1)));
        DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{2},num2str(CAP_OPS(DAY_I).oper(1,2)));
        DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{3},num2str(CAP_OPS(DAY_I).oper(1,3)));
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
            if t == 1
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
            
            %{
            Calc TVD every 5sec & only during PV hours
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
            %}

            %ROX
            if mod(t,900) == 0
                %Every 15 mins..
                Cap_Control_DSDR
            end
            SVR_Tap_Pos_DSDR

            if mod(ss*t,3600) == 0
                fprintf('Hour: %d\n',ss*t/3600);
            end
            
        end
        i = 1;
        
        %save tap pos to reset after next day load allocation:
        DSSText.command = sprintf('? Transformer.%s.Tap',trans_name);
        TAP_DAY = DSSText.Result;
        if feeder_NUM < 3
            CAP_DAY = YEAR_CAPSTATUS(DAY_I).CAP_POS(t,1);
        end
        
    end
end