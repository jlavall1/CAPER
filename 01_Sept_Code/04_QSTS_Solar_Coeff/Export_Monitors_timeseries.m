%%
%clear
%clc
%close all
%Lets create the needed monitors:
%feeder_NUM = 1;
if feeder_NUM == 0
    %Bellhaven --
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Bellhaven_Circuit_Opendss';
    addpath(temp_dir)
elseif feeder_NUM == 1
    %Commonwealth --
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss';
    addpath(temp_dir)
    addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis');
    %load config_LOAD
    load Lines_Monitor_CMNW.mat %Lines_Distance
    %For export .txt file --
    filename = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\TIME_RESULTS';
    
elseif feeder_NUM == 2
    %Flay --
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss';
    addpath(temp_dir)
    addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis');
    load config_LOADSBASE_FLAY.mat %Loads_Base
    
    load Lines_Monitor_FLAY.mat %Lines_Distance
    %For export .txt file --
    filename = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\TIME_RESULTS';
    monitorfile_base= 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Results';
    root1 = 'Flay';
elseif feeder_NUM == 8
    %EPRI CKT7 --
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\EPRI_ckt24';
    addpath(temp_dir)
    addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis');
    %load config_LOADSBASE_FLAY.mat %Loads_Base
    
    load Lines_Monitor.mat %Lines_Distance
    %For export to .txt file --
    filename = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\EPRI_ckt24\Monitors_GEN.txt';
    root1 = '05410';
end
%%
n = length(Lines_Distance(:,1));
k = 2;
j = 1;
COUNT_ST = 1;
COUNT = 1;
%Pull PCC monitors:

    DSSText.Command = sprintf('export mon fdr_%s_Mon_PQ',root1);
    monitorFile = DSSText.Result;
    MyCSV = importdata(monitorFile);
    delete(monitorFile);
    subPowers = MyCSV.data(:,3:2:7);
    subReact = MyCSV.data(:,4:2:8);
    %
    DATA_SAVE(j,1).phaseP = subPowers;
    DATA_SAVE(j,1).phaseQ = subReact;
    DATA_SAVE(j,1).Name = sprintf('%s',root1);
    j = j + 1;
    
%Now do general pull:
n=length(Lines_Distance);
while k <= n
    numPh = Lines_Distance(k,1).numPhases; 
    if numPh == 3
        for i=1:1:2
            %line = Lines_Distance(k,1).name;
            %Save info in the following fashion:
            %[bus1]  [numPhases] [monitor name] [phaseCurrents] [
            %[2]
            if COUNT == 1
                Monitor{j,1} = Lines_Distance(k,1).numPhases;   
                Monitor{j,2}= Lines_Distance(k,1).bus1Distance;
                B1 = Lines_Distance(k,1).bus1;
                %take off node #'s (.1.2.3):
                bus1=regexprep({B1},'(\.[0-9]+)','');
                Monitor{j,3} = Lines_Distance(k,1).name;
                DATA_SAVE(j,1).Name = Monitor{j,3};
                DATA_SAVE(j,1).Bus1 = B1;
                %Find V,I,P,Q ----
                if i==1
                    Monitor{j,3}=strcat(Monitor{j,3},'_Mon_VI');
                    DSSText.Command = sprintf('export mon %s',char(Monitor{j,3}));
                    monitorFile = DSSText.Result;
                    MyCSV = importdata(monitorFile);
                    %Find static  ----
                    if COUNT_ST == 1
                        Hour = MyCSV.data(:,1); Second = MyCSV.data(:,2);
                        COUNT_ST = COUNT_ST + 1;
                        DATA_SAVE(j,1).Hour = Hour;
                        DATA_SAVE(j,1).Sec = Second;
                    end
                    delete(monitorFile);
                    %subVoltages = MyCSV.data(:,3:2:7);
                    subVoltages = MyCSV.data(:,3:1:5);
                    if subVoltages(1,1)> 18900 || subVoltages(1,2) > 18900 || subVoltages(1,3) > 18900
                        DATA_SAVE(j,1).Vbase = (34.5e3)/sqrt(3);
                    elseif subVoltages(1,1)> 6480 || subVoltages(1,2) > 6480 || subVoltages(1,3) > 6480
                        DATA_SAVE(j,1).Vbase = (12.47e3)/sqrt(3);
                    elseif subVoltages(1,1)> 250 || subVoltages(1,2) > 250 || subVoltages(1,3) > 250
                        DATA_SAVE(j,1).Vbase = (480)/sqrt(3);
                    else
                        DATA_SAVE(j,1).Vbase = 0;
                    end
                    DATA_SAVE(j,1).Vstatic = Lines_Distance(k,1).bus1Voltage;

                    %subCurrents = MyCSV.data(:,11:2:15);
                    subCurrents = MyCSV.data(:,6:1:8);
                    %
                    DATA_SAVE(j,1).phaseV = subVoltages;
                    %DATA_SAVE(j,1).TVD = TVD_Calc(DATA_SAVE(j,1).phaseV,DATA_SAVE(j,1).Vbase,V_LTC_PU);
                    
                    %DATA_SAVE(j,1).phaseI = subCurrents;
                elseif i==2
                    Monitor{j,3}=strcat(Monitor{j,3},'_Mon_PQ');
                    DSSText.Command = sprintf('export mon %s',char(Monitor{j,3}));
                    monitorFile = DSSText.Result;
                    MyCSV = importdata(monitorFile);
                    delete(monitorFile);
                    subPowers = MyCSV.data(:,3:2:7);
                    subReact = MyCSV.data(:,4:2:8);
                    %
                    %DATA_SAVE(j,1).phaseP = subPowers;
                    %DATA_SAVE(j,1).phaseQ = subReact;
                end
                DATA_SAVE(j,1).distance = Monitor{j,2};
            end
        end
        %Add other info:
        %12.47 0.480, 0.208, 0.24, 0.12
        
        
        if feeder_NUM == 8
            COUNT = COUNT + 1;
            if COUNT == 4
                COUNT = 1;
                j = j + 1;
            end
        else
            j = j + 1;
        end
    end
    k = k + 1;
end
%%
%-----------------------------------------------------------
%Now lets calculate some things:
%DATA_SAVE(j,1).phaseV = subVoltages;



%{
%-----------------------------------------------------------
%when the monitors are at the nodes where loads are located:
%   Used when Load voltage is wanted.
c_j = j;
k=1;
while k<=100%length(Loads_Base)
    %Assign new monitor name:
    Monitor{j,1}=strcat(num2str(k),'_Mon_VI');
    %Export monitor:
    DSSText.Command = sprintf('export mon %s',char(Monitor{j,1}));
    monitorFile = DSSText.Result;
    MyCSV = importdata(monitorFile);
    delete(monitorFile);
    %subVoltages = MyCSV.data(:,3:2:7);
    m = size(MyCSV.data);
    if m(1,2)==8 %3ph
        subVoltages = MyCSV.data(:,3:1:5);
        subCurrents = MyCSV.data(:,6:1:8);
    elseif m(1,2)==6 %2ph
        subVoltages = MyCSV.data(:,3:1:4);
        subCurrents = MyCSV.data(:,5:1:6);
    elseif m(1,2)==4 %1ph
        subVoltages = MyCSV.data(:,3);
        subCurrents = MyCSV.data(:,4);
    end
    %
    DATA_SAVE(j,1).phaseV = subVoltages;
    DATA_SAVE(j,1).phaseI = subCurrents;
    DATA_SAVE(j,1).title = MyCSV.textdata(1,:);
    DATA_SAVE(j,1).loadnum = k;
    
    k = k + 1;
    j = j + 1;
end
%}
%%
if feeder_NUM ~= 8
    %Now lets export LTC tap changes:
    DSSText.Command = 'export mon LTC';
    monitorFile = DSSText.Result;
    MyLTC = importdata(monitorFile);
    delete(monitorFile);
    DATA_SAVE(1).LTC_Ops = MyLTC.data;
    
    %Now lets export LTC XFMR winding voltages:
    DSSText.Command = 'export mon subVI';
    monitorFile = DSSText.Result;
    MySUBV = importdata(monitorFile);
    delete(monitorFile);
    DATA_SAVE(1).phaseV = MySUBV.data(:,3:2:7);
    DATA_SAVE(1).phaseI = MySUBV.data(:,11:2:15);
    DATA_SAVE(1).distance = 0;
    DATA_SAVE(1).DOY = DOY;
    
    %Now lets save all simulation settings:
    Settings(1).pmpp = PV_pmpp;
    Settings(1).pv_bus = PV_bus;
    Settings(DOY).DOY = DOY;
    Settings(DOY).WoY = (DOY - mod(DOY,7))/8+1;
    %TVD=TVD_Calc(DATA_SAVE);
    %%
    Settings(DOY).TVD_t = TVD_Calc(DATA_SAVE,V_LTC_PU);
    SUM_TVD=zeros(1,3);
    for tt=1:1:length(Settings(DOY).TVD_t)
        for ph=1:1:3
            SUM_TVD(1,ph)=SUM_TVD(1,ph)+Settings(DOY).TVD_t(tt,ph);
        end
    end
    Settings(DOY).TVD_avg=SUM_TVD/1440;
            
    OPS=CUM_TapCount(DATA_SAVE);
    Settings(DOY).LTCops = OPS;
    Settings(DOY).VI = M_PVSITE_INFO.VI(DOY,1);
    Settings(DOY).CI = M_PVSITE_INFO.CI(DOY,1);
    Settings(DOY).DARR = M_PVSITE_SC(DOY,6);
    
    
    
    
    
    
    
    
    
    
    
    %DATA_SAVE(1).settings = Settings;
    %{
    %Save struct of post sim. results.
    if QSTS_select ~= 4
        if PV_ON_OFF == 1
            save(filename,'DATA_SAVE');  
        elseif PV_ON_OFF == 2
            filename2=strcat(monitorfile_base,sprintf('/%s_Imped.mat',num2str(perc_Imp*100)));
            DATA_PV = DATA_SAVE;
            save(filename2,'DATA_PV');
        end
    elseif QSTS_select == 4
        %Save any additional information for that day:
        %DATA_SAVE(1).KVAR_ACTUAL = KVAR_ACTUAL;
        %DATA_SAVE(1).KW_ACTUAL = LOAD_ACTUAL;
        
        %Save the .mat file:
        if PV_ON_OFF == 2  
            filename2=strcat(monitorfile_base,sprintf('/DOY_%s_PV_%s_Imped.mat',num2str(DOY),num2str(perc_Imp*100)));
            DATA_PV = DATA_SAVE;
            save(filename2,'DATA_PV');
        else
            filename2=strcat(monitorfile_base,sprintf('/DOY_%s_BASE.mat',num2str(DOY)));
            DATA_BASE = DATA_SAVE;
            save(filename2,'DATA_BASE');
        end
    end
    %}
end