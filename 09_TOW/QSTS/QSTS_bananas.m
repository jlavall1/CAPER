clear;
clc;
close all
% 1. Generate Real Power & PV loadshape files:
%PV_Loadshape_generation
%cap_pos=1;
%feeder_Loadshape_generation_Dynamic %ckt_direct_prime (generated)
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%
addpath('C:\Users\ATOW\Documents\GitHub\CAPER\09_TOW\QSTS\DSS');
% 2. Compile the user selected circuit:
ckt_direct_prime='C:\Users\ATOW\Documents\GitHub\CAPER\09_TOW\QSTS\DSS\Master.dss';
%DSSText.command = ['Compile ',ckt_direct_prime]; %Master_General.dss


%Loads_info = getLoadInfo(DSSCircObj);
%%
load MOCKS01.mat
load LoadTotals.mat
load PV_Shape.mat
Caps.Name{1}='CAP1';
Caps.Name{2}='CAP2';
Caps.Name{3}='CAP3';
Caps.Swtch(1)=1200/3; 
Caps.Swtch(2)=1200/3; 
Caps.Swtch(3)=1200/3;
trans_name='T5240B12';
sub_line='254399393';
%%
%for DAY_I=DOY:1:DAY_F
    tic
    %%
    %-- Update Irradiance/PV_KW
%     if DAY > MTH_LN(MNTH)
%         MNTH = MNTH + 1;
%         DAY = 1;
%     end
    %fprintf('\nQSTS Simulation: DOY= %d\n',DAY_I);
    
    %eff_KVAR=ones(1,3);
    
    % interpolate seconds between minutes
%     CAP_OPS_STEP2_1(DAY_I).kW(:,1) = interp(CAP_OPS_STEP2(DAY_I).kW(:,1),int_1m); %60s -> 5s
%     CAP_OPS_STEP2_1(DAY_I).kW(:,2) = interp(CAP_OPS_STEP2(DAY_I).kW(:,2),int_1m); %60s -> 5s
%     CAP_OPS_STEP2_1(DAY_I).kW(:,3) = interp(CAP_OPS_STEP2(DAY_I).kW(:,3),int_1m); %60s -> 5s
%     CAP_OPS_1(DAY_I).DSS(:,1) = eff_KVAR(1,1)*interp(CAP_OPS(DAY_I).DSS(:,1),int_1m);
%     CAP_OPS_1(DAY_I).DSS(:,2) = eff_KVAR(1,2)*interp(CAP_OPS(DAY_I).DSS(:,2),int_1m);
%     CAP_OPS_1(DAY_I).DSS(:,3) = eff_KVAR(1,3)*interp(CAP_OPS(DAY_I).DSS(:,3),int_1m);
    
%Feeder 04
        
    %if DAY_I == DOY
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
        %%
        
        s_step = 60;
        sim_num = 1440;
        
        s='C:\Users\ATOW\Documents\GitHub\CAPER\09_TOW\QSTS\DSS';
        filelocation=strcat(s,'\');
        fileID = fopen([filelocation,'Loadshape.dss'],'wt');
        fprintf(fileID,['New loadshape.LS_PhaseA npts=%d sinterval=%d pmult=(',...
            sprintf('%f ',MOCKS01.kW(:,1)/LoadTotals.kWA),') qmult=(',...
            sprintf('%f ',MOCKS01.kVAR(:,1)/LoadTotals.kVARA),')\n\n'],sim_num,s_step);
        fprintf(fileID,['New loadshape.LS_PhaseB npts=%d sinterval=%d pmult=(',...
            sprintf('%f ',MOCKS01.kW(:,2)/LoadTotals.kWB),') qmult=(',...
            sprintf('%f ',MOCKS01.kVAR(:,2)/LoadTotals.kVARB),')\n\n'],sim_num,s_step);
        fprintf(fileID,['New loadshape.LS_PhaseC npts=%d sinterval=%d pmult=(',...
            sprintf('%f ',MOCKS01.kW(:,3)/LoadTotals.kWC),') qmult=(',...
            sprintf('%f ',MOCKS01.kVAR(:,3)/LoadTotals.kVARC),')\n\n'],sim_num,s_step);
        
        fprintf(fileID,['New loadshape.LS_Solar npts=%d sinterval=%d mult=(',...
            sprintf('%f ',PV_Shape),')\n\n'],sim_num,s_step);
        fclose(fileID);

%     else
%         %-- Edit Loadshapes for next day:
%         DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseA pmult=(',...
%             sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,1)/LoadTotals.kWA),') qmult=(',...
%             sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,1)/LoadTotals.kVARA),')']);
%         DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseB pmult=(',...
%             sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,2)/LoadTotals.kWB),') qmult=(',...
%             sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,2)/LoadTotals.kVARB),')']);
%         DSSText.Command = sprintf(['Edit Loadshape.LS_PhaseC pmult=(',...
%             sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,3)/LoadTotals.kWC),') qmult=(',...
%             sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,3)/LoadTotals.kVARC),')']);
%         %DSSText.Command = sprintf(['Edit Loadshape.LS_Solar mult=(',...
%             %sprintf('%f ',PV_loadshape_daily_1(:,1)),')']);
%     end
    
    %if DAY_I==DOY
        DSSText.command = ['Compile ',ckt_direct_prime];
        %Lines_info = getLineInfo(DSSCircObj);
        %[~,index] = sortrows([Lines_info.bus1Distance].');
        %Lines_info = Lines_info(index);
        %Roxboro has alot of VRDs:
%         DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{1},num2str(CAP_OPS(DAY_I).oper(1,1)));
%         DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{2},num2str(CAP_OPS(DAY_I).oper(1,2)));
%         DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{3},num2str(CAP_OPS(DAY_I).oper(1,3)));
%     else
%         %Roxboro has alot of VRDs:
%         DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{1},num2str(CAP_OPS(DAY_I).oper(1,1)));
%         DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{2},num2str(CAP_OPS(DAY_I).oper(1,2)));
%         DSSText.command=sprintf('Edit Capacitor.%s states=%s',Caps.Name{3},num2str(CAP_OPS(DAY_I).oper(1,3)));
%         DSSText.command=sprintf('Transformer.%s.Taps=[1.0, %s]',trans_name,TAP_DAY);
%     end
    
    %--  Run QSTS 24hr sim:
    %if timeseries_span == 2
        %(1) DAY, 24hr, 1 second timestep for MATLAB controls.
        %
        % Configure Simulation:
        DSSText.command=sprintf('set mode=daily stepsize=%d number=1 controlMode=TIME',60);  %num2str(ss/60)
        DSSCircuit.Solution.dblHour = 0.0;
        %i = 1; %counter for TVD sample & voltage violation check
        BatteryPCT = zeros(1441,1);
        for t = 1:1:1440
            
            % Solve at current time step
            
            DSSCircuit.Solution.Solve
%             if t == 1
%                 Buses_info = getBusInfo(DSSCircObj);
%                 % Get gridpv information
%                 Cap_info = getCapacitorInfo(DSSCircObj);
%                 Lines_info = getLineInfo(DSSCircObj);
%                 % Sort lines by distance
%                 [~,index] = sortrows([Lines_info.bus1Distance].');
%                 Lines_info = Lines_info(index);
%             end
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
            
            % Get State of Charge
            BESS.Prated=1000; %kW
            DSSCircuit.SetActiveElement('Storage.BESS');
            DSSText.command='? Storage.BESS.%stored';
            MEAS(t).SOC=str2double(DSSText.Result);           %<---------------------
            DSSText.command='? Storage.BESS.%Discharge';
            MEAS(t).DR=BESS.Prated*(str2double(DSSText.Result))/100;%<---------------
            DSSText.command='? Storage.BESS.%Charge';
            MEAS(t).CR=BESS.Prated*(str2double(DSSText.Result))/100;%<---------------
            
            set_point = 5800; %kW
            band = 1000; %kW
            nptsavg = 3;
            SubkW = [MEAS(t).Sub_P_PhA]+[MEAS(t).Sub_P_PhB]+[MEAS(t).Sub_P_PhC];
            BatteryPCT(t+1) = ((band)/10)*round((set_point-SubkW+(1000/100)*BatteryPCT(t))/(band));
            BatteryPCT(t+1) = mean(BatteryPCT((t-nptsavg+2)+(t<nptsavg-1)*(-t+nptsavg-1):t+1));
            State = sign(BatteryPCT(t+1));
            BatteryPCT(t+1) = State*min(100,State*BatteryPCT(t+1));
            if State <= 0
                DSSText.Command = sprintf('Edit Storage.BESS State=DISCHARGE %%Discharge=%d %%Charge=0',abs(BatteryPCT(t+1)));
            else 
                DSSText.Command = sprintf('Edit Storage.BESS State=CHARGE %%Charge=%d %%Discharge=0',abs(BatteryPCT(t+1)));
            end
            %Potential Transformer Equivalent:
            %DSSCircuit.SetActiveElement(sprintf('Transformer.%s',trans_name)); % trans_name - OLTC name
            %Phs_V=DSSCircuit.ActiveElement.Voltages; % pulls all the fricking voltages
            %V_phC_s=Phs_V(13)+1i*Phs_V(14); %Phase C on secondary side
            %MEAS(t).V_OLTC_PT =abs(V_phC_s)/110; % develop logic to check turns ratio
            %------------------------------------
            %Voltage Regulation Relay Equiv:
            %DSSText.command = sprintf('? Transformer.%s.Tap',trans_name);
            %MEAS(t).OLTC_tap = str2double(DSSText.Result);
            
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
            %{ 
            ***Update tap position and cap control
            if mod(t,900) == 0
                %Every 15 mins..
                Cap_Control_DSDR
            end
            SVR_Tap_Pos_DSDR

            if mod(ss*t,3600) == 0
                fprintf('Hour: %d\n',ss*t/3600);
            end
            %}
            
        end
        %i = 1;
        
        %save tap pos to reset after next day load allocation:
        %DSSText.command = sprintf('? Transformer.%s.Tap',trans_name);
        %TAP_DAY = DSSText.Result;
        %if feeder_NUM < 3
            %CAP_DAY = YEAR_CAPSTATUS(DAY_I).CAP_POS(t,1);
        %end

%% Plot Results
close all;
current_time = datenum('6/2/2014')+(0:1440-1)'/1440;
figure;
plot(current_time,[MEAS.Sub_P_PhA],'-k','LineWidth',2)
hold on
plot(current_time,[MEAS.Sub_P_PhB],'-r','LineWidth',2)
plot(current_time,[MEAS.Sub_P_PhC],'-b','LineWidth',2)

plot(current_time,MOCKS01.kW(:,1),'--k','LineWidth',1)
plot(current_time,MOCKS01.kW(:,2),'--r','LineWidth',1)
plot(current_time,MOCKS01.kW(:,3),'--b','LineWidth',1)
hold off
grid on;
set(gca,'FontSize',10,'FontWeight','bold')
datetick(gca)
xlabel(gca,sprintf('%s [hours]',datestr(current_time(1))),'FontSize',12,'FontWeight','bold')
ylabel(gca,'Three Phase Real Power (P_{3{\phi}}) [kW]','FontSize',12,'FontWeight','bold')
title('Peak Shave QSTS','FontWeight','bold','FontSize',12);
legend('Phase A','Phase B','Phase C','Location','SouthEast')

figure;
h(1) = plot(current_time,[MEAS.Sub_P_PhA]+[MEAS.Sub_P_PhB]+[MEAS.Sub_P_PhC],'-k','LineWidth',2);
hold on
h(2) = plot(current_time,MOCKS01.kW(:,1)+MOCKS01.kW(:,2)+MOCKS01.kW(:,3),'--r','LineWidth',2);
h(3) = plot([current_time(1),current_time(end)],[set_point set_point]+band/2,':k','LineWidth',2);
plot([current_time(1),current_time(end)],[set_point set_point]-band/2,':k','LineWidth',2);
hold on
%find transitions:
j=1;
jj=1;
for i=3:1:1440
    if abs(MEAS(i).DR-MEAS(i-1).DR) > 300
        if j == 1
            save_t(j)=i;
            j = 2;
        end
    end
    if MEAS(i).CR-MEAS(i-1).CR > -300
        if jj == 1
            save_t1(jj)=i;
            jj = 2;
        end
    elseif MEAS(i).CR-MEAS(i-1).CR < 300
        if jj == 2
            save_t1(jj)=i;
            jj = 3;
        end
    end
end
txt1= sprintf('SOC=%s',num2str(MEAS(save_t(1)).SOC));
text(current_time(save_t(1)),5000,txt1,'Color','b','HorizontalAlignment','Right');


%Settings
grid on;
set(gca,'FontSize',10,'FontWeight','bold');
datetick(gca)
xlabel(gca,sprintf('%s [hours]',datestr(current_time(1))),'FontSize',12,'FontWeight','bold');
ylabel(gca,'kW [pu]','FontSize',12,'FontWeight','bold');
title('Peak Shave QSTS','FontWeight','bold','FontSize',12);
legend([h(1) h(2) h(3)],'With Battery','Without Battery','Bandwidth','Location','SouthEast');

        
    %end
%end