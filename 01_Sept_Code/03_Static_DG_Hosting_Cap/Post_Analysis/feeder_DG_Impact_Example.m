% prompt = 'Enter file path: ';
% str = input(prompt,'s');
clear
clc
close all
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\Result_Analysis');
load config_LEGALBUSES_FLAY.mat
load config_LEGALDISTANCE_FLAY.mat

fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss';
peak_current = [196.597331353572,186.718068471483,238.090235458346];
peak_kW = 1343.768+1276.852+1653.2766;
min_kW = 1200;

energy_line = '259363665';
fprintf('Characteristics for:\t1 - FLAY\n\n');
vbase = 7;

str = strcat(fileloc,'\Master.DSS'); 
[DSSCircObj, DSSText] = DSSStartup; 
DSSText.command = ['Compile ' str]; 
DSSText.command = sprintf('New EnergyMeter.CircuitMeter LINE.%s terminal=1 option=R PhaseVoltageReport=yes',energy_line);
DSSText.command = sprintf('EnergyMeter.CircuitMeter.peakcurrent=[  %s   %s   %s  ]',num2str(peak_current(1,1)),num2str(peak_current(1,2)),num2str(peak_current(1,3)));
DSSText.command = 'Disable Capacitor.*';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'Enable Capacitor.*';

%Run at desired Load Level:
DSSText.command = 'solve loadmult=0.50';

DSSCircuit = DSSCircObj.ActiveCircuit;
Buses=getBusInfo(DSSCircObj);
Lines=getLineInfo(DSSCircObj);
Loads=getLoadInfo(DSSCircObj);
[~,index] = sortrows([Lines.bus1Distance].'); 
Lines_Distance = Lines(index); 
%For Post_Process & Post_Process_2
xfmrNames = DSSCircuit.Transformers.AllNames;
lineNames = DSSCircuit.Lines.AllNames;
loadNames = DSSCircuit.Loads.AllNames;
Lines_Base = getLineInfo(DSSCircObj);
Buses_Base = getBusInfo(DSSCircObj);
%Find downstream buses:
Section.B=findDownstreamBuses(DSSCircObj,'258425578');
Section.C=findDownstreamBuses(DSSCircObj,'258425583');
Section.D=findDownstreamBuses(DSSCircObj,'258405796');



%%
ii = 1;
j = 1;
while ii<length(Buses)
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).kVBase > vbase && Buses(ii,1).distance ~= 0
        legal_buses{j,1} = Buses(ii,1).name;
        legal_distances{j,1} = Buses(ii,1).distance;
        for jj=1:1:length(Section.B)
            if strcmp(Section.B{jj,1},legal_buses{j,1}) == 1
                legal_buses{j,2} = 1;
            end
        end
        for jj=1:1:length(Section.C)
            if strcmp(Section.C{jj,1},legal_buses{j,1}) == 1
                legal_buses{j,2} = 2;
            end
        end
        for jj=1:1:length(Section.D)
            if strcmp(Section.D{jj,1},legal_buses{j,1}) == 1
                legal_buses{j,2} = 3;
            end
        end
        if isempty(legal_buses{j,2}) == 1 
            legal_buses{j,2}=0; 
        end
        legal_buses{j,3}=Buses(ii,1).voltagePU;
        
        for ln=1:1:length(Lines_Base)
            if strcmp(strcat(legal_buses{j,1},'.1.2.3'),Lines_Base(ln,1).bus1)
                legal_buses{j,4}=Lines_Base(ii,1).bus1PowerReal;
            end
        end
        legal_buses{j,5}=legal_distances{j,1};
        
        
        %}
        j = j + 1;
    end
    ii =ii + 1;
end
%%
C = sortrows(legal_buses,5); 
D = sortrows(legal_buses,2);
%base_profile = legal_buses{index,1:5}; 
plot(cell2mat(C(:,5)),cell2mat(C(:,3)),'b-')
hold on
plot(cell2mat(D(:,5)),cell2mat(C(:,3)),'r-')
%%
%{'258406388',3,1.02546698285314,109.269301188467,6.38698000000000}
%{'258406238',3,1.02643470082650,2100.85868286123,5.67706000000000}
%{'263395399',2,1.02685896756743,1.72214829937927,5.70324000000000}
figure(1)
plotVoltageProfile(DSSCircObj,'SecondarySystem','off');

DSSText.command = sprintf('new generator.PV bus1=%s phases=3 kv=12.47 kW=5000 pf=1.00 enabled=true','263395399');
DSSText.command = 'solve loadmult=0.50';
Buses=getBusInfo(DSSCircObj);
Lines=getLineInfo(DSSCircObj);

figure(2)
plotVoltageProfile(DSSCircObj,'SecondarySystem','off');
%%
jj=1;
legal_buses{:,3}=zeros(length(legal_buses),1);
for ii=1:1:length(Buses)
    if strcmp(Buses(ii,1).name,legal_buses{jj,1}) == 1
        legal_buses{jj,3}=Buses(ii,1).voltagePU;
    end
end
%%
E = sortrows(legal_buses,2);
%%
[~,~,BASE_CASE] = xlsread('EXAMPLE_PV.xlsx','BASE_CASE');
[~,~,PV_CASE] = xlsread('EXAMPLE_PV.xlsx','PV_CASE');
figure(2);
plot(cell2mat(BASE_CASE(2:36,5)),cell2mat(BASE_CASE(2:36,3)),'b-','LineWidth',3);
hold on
plot(cell2mat(BASE_CASE(2:34,10)),cell2mat(BASE_CASE(2:34,8)),'r-','LineWidth',3);
hold on
plot(cell2mat(BASE_CASE(2:135,15)),cell2mat(BASE_CASE(2:135,13)),'Color',[0 0.6 0.0],'LineWidth',3);
hold on
plot(cell2mat(BASE_CASE(2:135,20)),cell2mat(BASE_CASE(2:135,18)),'Color',[0.6 0.0 0.8],'LineWidth',3);
%Settings:
xlabel('Bus Distance from Substation (km)','FontWeight','bold','FontSize',12);
ylabel('Bus Voltage (V) [pu]','FontWeight','bold','FontSize',12);   
legend('Zone 1','Zone 2','Zone 3','Zone 4');
grid on
set(gca,'FontWeight','bold');  
%----------------------
figure(3);
plot(cell2mat(BASE_CASE(2:36,5)),cell2mat(BASE_CASE(2:36,3)),'k-','LineWidth',1);
hold on
plot(cell2mat(BASE_CASE(2:34,10)),cell2mat(BASE_CASE(2:34,8)),'k-','LineWidth',1);
hold on
plot(cell2mat(BASE_CASE(2:135,15)),cell2mat(BASE_CASE(2:135,13)),'k-','LineWidth',1);
hold on
plot(cell2mat(BASE_CASE(2:135,20)),cell2mat(BASE_CASE(2:135,18)),'k-','LineWidth',1);
hold on
h(1)=plot(cell2mat(PV_CASE(2:36,5)),cell2mat(PV_CASE(2:36,3)),'b-','LineWidth',3);
hold on
h(2)=plot(cell2mat(PV_CASE(2:34,10)),cell2mat(PV_CASE(2:34,8)),'r-','LineWidth',3);
hold on
h(3)=plot(cell2mat(PV_CASE(2:135,15)),cell2mat(PV_CASE(2:135,13)),'Color',[0 0.6 0.0],'LineWidth',3);
hold on
h(4)=plot(cell2mat(PV_CASE(2:135,20)),cell2mat(PV_CASE(2:135,18)),'Color',[0.6 0.0 0.8],'LineWidth',3);

















