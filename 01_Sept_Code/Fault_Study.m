%1) To find highest Short Circuit Fault Current in the system.
%2) Interate through all PV sizes at each legal location to check the 10%
%Rule
tic
addpath(strcat(base_path,'\01_Sept_Code'));

% 1. Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
filename = strcat(base_path,'\01_Sept_Code\Result_Analysis\RESULTS');
SHC_Feeder_Settings %load selection & energy meter info.
if feeder_NUM == 0
    load config_LEGALBUSES_BELL.mat
elseif feeder_NUM == 1
    load config_LEGALBUSES_CMNWLTH.mat
elseif feeder_NUM == 2
    load config_LEGALBUSES_FLAY.mat
elseif feeder_NUM == 3
    load config_LEGALBUSES_ROX.mat
elseif feeder_NUM == 5
    load config_LEGALBUSES_HLLY.mat
elseif feeder_NUM == 6
    load config_LEGALBUSES_ERAL.mat
end
filename = strcat(filename,cir_name);
path = strcat(base_path,'\04_DSCADA');
addpath(path);

% 3. Compile & solve circuit:
DSSText.command = ['Compile ',ckt_direct];  
DSSText.command = sprintf('New EnergyMeter.CircuitMeter LINE.%s terminal=1 option=R PhaseVoltageReport=yes',energy_line);
DSSText.command = sprintf('EnergyMeter.CircuitMeter.peakcurrent=[  %s   %s   %s  ]',num2str(peak_current(1,1)),num2str(peak_current(1,2)),num2str(peak_current(1,3)));
DSSText.command = 'Disable Capacitor.*';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'Enable Capacitor.*';
DSSText.command = 'solve';
Lines_Base = getLineInfo(DSSCircObj);
Buses_Base = getBusInfo(DSSCircObj);
Loads_Base = getLoadInfo(DSSCircObj);
[~,index] = sortrows([Lines_Base.bus1Distance].'); 
Lines_Distance = Lines_Base(index); clear index
%%
DSSText.Command = 'Solve Mode=FaultStudy';
LineNames = DSSCircuit.Lines.AllNames;
% Read in Line Data from DSS
for i = 1:length(LineNames)-1
    Lines(i).ID = LineNames{i};
    DSSCircuit.SetActiveElement(['Line.',LineNames{i}]);
    Lines(i).Bus1 = regexp(DSSCircuit.ActiveCktElement.BusNames{1},'^.*?(?=[.])','match');
    Lines(i).Bus2 = regexp(DSSCircuit.ActiveCktElement.BusNames{2},'^.*?(?=[.])','match');
    Lines(i).Phase = DSSCircuit.ActiveCktElement.NumPhases;
    Lines(i).Amps = DSSCircuit.ActiveCktElement.NormalAmps;
    
    % Find Upstream Bus
    DSSCircuit.SetActiveBus(Lines(i).Bus1{1});
    Lines(i).Distance = DSSCircuit.ActiveBus.Distance;
    DSSCircuit.SetActiveBus(Lines(i).Bus2{1});
    [Lines(i).Distance,index] = min([DSSCircuit.ActiveBus.Distance,Lines(i).Distance]);
    if index == 2
        DSSCircuit.SetActiveBus(Lines(i).Bus1{1}); % Go back to origional Bus
    end
    
    % Record Zsc
    Zsc = DSSCircuit.ActiveBus.Zsc1;
    Lines(i).Rsc = Zsc(1);
    Lines(i).Xsc = Zsc(2);
end
% Remove Unwanted lines and sort
Lines = Lines([Lines.Phase] == 3); % Only 3 phase
Lines = Lines([Lines.Amps] > 180); % Only >480A Current Rating
[~,index] = sortrows([Lines.Distance].');
Lines = Lines(index);
%%
%Begin fault study to find highest fault current in circuit:
% Begin Fault Study
DSSText.Command = 'New Fault.F1 Phase=3 enabled=no';
%DSSText.Command = 'Edit Fault.F1 Bus1=commonwealth_ret_01311205.1.2.3 Phase=3 enabled=yes';
% Record Short Circuit Impedance and organize by Rsc
%Phase = {'A' 'B' 'C'}; % 
%for p = 1:3 %
for i = 1:length(Lines)
    % Fault Phase p on Bus1 of Line i
    DSSText.Command = 'Solve Mode=Snapshot';
    DSSText.Command = sprintf('Edit Fault.F1 Bus1=%s.%s enabled=yes',Lines(i).Bus1{1},'1.2.3'); %p);
    DSSText.Command = 'Solve Mode=dynamic number=1';

    DSSCircuit.SetActiveElement('Fault.F1');
    %Lines(i).(sprintf('Isc%c',Phase{p})) = DSSCircuit.ActiveCktElement.CurrentsMagAng(1); %
    Lines(i).IscBASE = DSSCircuit.ActiveCktElement.CurrentsMagAng(1);
    DSSText.Command = 'Edit Fault.F1 enabled=no';
end
%{
DSSText.command = 'Solve Mode=Snapshot';
% Now lets test legal bus locations:
i = 1;
while i < length(Buses_Base)
    if Buses_Base(i,1).distance > 1e-4
        bus_init = i;
        i = length(Buses_Base);
    end
    i = i + 1;
end

if feeder_NUM ~= 3 && feeder_NUM ~= 4
    DSSText.command = sprintf('new generator.PV bus1=%s phases=3 kv=12.47 kW=100 pf=1.00 enabled=false',Buses_Base(bus_init,1).name);
else
    DSSText.command = sprintf('new generator.PV bus1=%s phases=3 kv=22.87 kW=100 pf=1.00 enabled=false',Buses_Base(bus_init,1).name);
end
DSSText.command = sprintf('solve loadmult=1.0');
DSSCircuit.Enable('generator.PV');
PCC=1;
PV_size=100;
j=1;
while PCC < length(legal_buses)
    for i=1:1:length(Buses_Base)
        if strcmp(Buses_Base(i,1).name,legal_buses{PCC,1})== 1
            %Match!
            DSSText.command = sprintf('edit generator.PV bus1=%s kW=%s',Buses_Base(i,1).name,num2str(PV_size));
            while PV_size < 10100
                DSSText.command = sprintf('edit generator.PV kW=%s',num2str(PV_size));
                DSSText.command = sprintf('solve loadmult=1.0');
                %Solve fault:
                DSSText.Command = 'Solve Mode=Snapshot';
                DSSText.Command = sprintf('Edit Fault.F1 Bus1=%s.%s enabled=yes',Buses_Base(i,1).name,'1.2.3');
                DSSText.Command = 'Solve Mode=dynamic number=1';
                DSSCircuit.SetActiveElement('Fault.F1');
                SC_RESULTS(j).Isc = DSSCircuit.ActiveCktElement.CurrentsMagAng(1);
                SC_RESULTS(j).PCC = PCC;
                SC_RESULTS(j).BUS1 = Buses_Base(i,1).name;
                %Increment:
                j = j + 1;
                PV_size = PV_size + 100;
            end
            fprintf('%d/%d PCC Locations Complete.\n',PCC,length(legal_buses));
            PCC = PCC + 1;
            PV_size = 100;
        end
    end
end
%%
%Process DATA:
PCC = 1;
while PCC < length(legal_buses)
    for i=1:1:length(Lines)
        if strcmp(Lines(i).Bus1,legal_buses{PCC,1})== 1
            for j=1:1:99
                SC_RESULTS(PCC+j).BASE = Lines(i).IscBASE;
            end
            PCC = PCC + 1;
            i = length(Lines);
        end
    end
end
%}

        



