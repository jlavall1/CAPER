% prompt = 'Enter file path: ';
% str = input(prompt,'s');
clear
clc
close all
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);

feeder_NUM=menu('Which Feeder?','1) Bell','2) Common','3) Flay','4) Rox','5) Holly','6) ERaleigh');
while feeder_NUM<1
    feeder_NUM=menu('Which Feeder?','1) Bell','2) Common','3) Flay','4) Rox','5) Holly','6) ERaleigh');
end
load_LVL=menu('What kind of simulation?','100%','Min. Load Level','Fault Study');
while load_LVL<1
    load_LVL=menu('What kind of simulation?','100%','Min. Load Level','Fault Study');
end


%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\run_master_allocate.DSS';
%str = 'C:\Users\jlavall\Desktop\Commonwealth_Circuit_Opendss\run_master_allocate.DSS';
%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Roxboro_Circuit_Opendss\run_master_allocate.DSS';
%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Run_Master_Allocate.DSS';
%---------------------------
%fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss';
if feeder_NUM == 1
    fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Bellhaven_Circuit_Opendss';
    peak_current = [424.489787369243,385.714277946091,446.938766508963];
    peak_kW = 2940.857+2699.883+3092.130;
    min_kW = 1937.500;
    if load_LVL == 1
        ratio = 1.0;
    elseif load_LVL == 2
        ratio = min_kW/peak_kW;
    end
    energy_line = '258839833';
    fprintf('Characteristics for:\t1 - BELLHAVEN\n\n');
    vbase = 7;
elseif feeder_NUM == 2
    fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss';
    peak_current = [345.492818586166,362.418979727275,291.727365549702];
    peak_kW = 2473.691+2609.370+2099.989;
    min_kW = 2445.941;
    if load_LVL == 1
        ratio = 1.0;
    elseif load_LVL == 2
        ratio=min_kW/peak_kW;
    end
    
    energy_line = '259355408';
    fprintf('Characteristics for:\t1 - COMMONWEALTH\n\n');
    vbase = 7;
elseif feeder_NUM == 3
    fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss';
    peak_current = [196.597331353572,186.718068471483,238.090235458346];
    peak_kW = 1343.768+1276.852+1653.2766;
    min_kW = 1200;
    if load_LVL == 1
        ratio = 1.0;
    elseif load_LVL == 2
        ratio= min_kW/peak_kW;
    end
    
    energy_line = '259363665';
    fprintf('Characteristics for:\t1 - FLAY\n\n');
    vbase = 7;
elseif feeder_NUM == 4
    fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Roxboro_Circuit_Opendss';
    peak_current = [232.766663065503,242.994085721044,238.029663479192];
    peak_kW = 3189.476+3319.354+3254.487;
    min_kW = 3157.978;
    if load_LVL == 1
        ratio = 1.0;
    elseif load_LVL == 2
        ratio = min_kW/peak_kW;
    end
    
    energy_line = 'PH997__2571841';
    fprintf('Characteristics for:\t1 - ROXBORO\n\n');
    vbase = 13;
elseif feeder_NUM == 5
    fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\HollySprings_Circuit_Opendss';
    peak_current = [263.73641240095,296.245661392728,201.389207853812];
    peak_kW=3585.700+4021.705+2741.913;
    min_kW = 2022.5799;
    if load_LVL == 1
        ratio = 1.0;
    elseif load_LVL == 2
        ratio = min_kW/peak_kW;
    end
    
    energy_line = '10EF34__2663676';
    fprintf('Characteristics for:\t1 - HOLLY SPRINGS\n\n');
    vbase = 13;
elseif feeder_NUM == 6
    %fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\ERaleigh_Circuit_Opendss';
    fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\ERaleigh_Circuit_1';
    peak_current = [214.80136594272,223.211693408696,217.825750072964];
    peak_kW=(1545.687+1606.278+1569.691);
    min_kW = 1351.478;
    if load_LVL == 1
        ratio = 1.0;
    elseif load_LVL == 2
        ratio = min_kW/peak_kW;
    end
    
    energy_line = 'PDP28__2843462';
    fprintf('Characteristics for:\t1 - E.RALEIGH\n\n');
    vbase = 7;
end

str = strcat(fileloc,'\Master.DSS');
% 1. Start the OpenDSS COM. Needs to be done each time MATLAB is opened     
[DSSCircObj, DSSText] = DSSStartup; 
%DSSText.command = ['Compile ' str];     
% 2. Compiling the circuit & Allocate Load according to peak current in
% desired loadshape. This will work w/ nominal values.

%peak_current = [196.597331353572,186.718068471483,238.090235458346];
%peak_current = [100,100,100];
DSSText.command = ['Compile ' str]; 
DSSText.command = sprintf('New EnergyMeter.CircuitMeter LINE.%s terminal=1 option=R PhaseVoltageReport=yes',energy_line);
%DSSText.command = 'EnergyMeter.CircuitMeter.peakcurrent=[  196.597331353572   186.718068471483   238.090235458346  ]';
DSSText.command = sprintf('EnergyMeter.CircuitMeter.peakcurrent=[  %s   %s   %s  ]',num2str(peak_current(1,1)),num2str(peak_current(1,2)),num2str(peak_current(1,3)));
DSSText.command = 'Disable Capacitor.*';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
%DSSText.command = 'Dump AllocationFactors';
DSSText.command = 'Enable Capacitor.*';
 
if load_LVL < 3
    DSSText.command = sprintf('solve loadmult=%s',num2str(ratio));
elseif load_LVL == 3
    DSSText.command = 'Solve mode=faultstudy';
end
% 4. Run circuitCheck function to double-check for any errors in the circuit before using the toolbox
warnSt = circuitCheck(DSSCircObj);

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
ii = 1;
j = 1;
while ii<length(Buses)
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).kVBase > vbase && Buses(ii,1).distance ~= 0
        legal_buses{j,1} = Buses(ii,1).name;
        legal_distances{j,1} = Buses(ii,1).distance;
        j = j + 1;
    end
    ii =ii + 1;
end

%-------------------------------------------------------------------------
%Find Conductor total distance:
total_length=0;
min_voltage=1.1;
max_3ph_distance=0;
max_distance=-1;
n=length(Lines_Distance);
feeder_LD = Lines_Distance(1,1).bus1PowerReal;
load_center=0;
P_diff_min=100e6;

for i=1:1:n
    total_length=total_length + Lines_Distance(i,1).length;
    if Lines_Distance(i,1).numPhases == 3
        VOLT=max(Lines_Distance(i,1).bus1PhaseVoltagesPU(1,:));
        if min_voltage > VOLT
            min_voltage=VOLT;
            if min_voltage < .8
                min_voltage=1.1;
            end
        end

        if Lines_Distance(i,1).bus1Distance > max_3ph_distance
            max_3ph_distance = Lines_Distance(i,1).bus1Distance;
        end
    end
    if Lines_Distance(i,1).bus1Distance > max_distance
        max_distance=Lines_Distance(i,1).bus1Distance;
        max_dist_bus=i;
    end
    P_diff = abs(feeder_LD*0.5-abs(Lines_Distance(i,1).bus1PowerReal));
    if P_diff < P_diff_min && i ~= 1
        load_center=i;
        P_diff_min=P_diff;
    end
end
%Find load center from distance:
distance_diff(1,1) = 1000;
distance_diff(1,2) = 0;
for i=1:1:n
    diff_km = abs((max_distance/2)-Lines_Distance(i,1).bus1Distance);
    if diff_km < distance_diff(1,1)
        distance_diff(1,1) = diff_km;
        distance_diff(1,2) = i;
    end
end

if load_LVL < 3
    fprintf('(Solved at %s%%)\n\n',num2str(ratio*100));
    fprintf('Peak Load (MW): %3.3f\n',Lines_Distance(1,1).bus1PowerReal/1000);
    fprintf('Total Length: %3.3f mi\n',(total_length*0.621371)/1000);
    fprintf('Peak Load Headroom: %3.3f P.U.\n',(1.05-min_voltage));
    fprintf('Overall End Distance: %3.3f km\n',max_distance);
    fprintf('3-ph End Distance: %3.3f km\n\n',max_3ph_distance);
elseif load_LVL == 3
    fprintf('End Feeder  Located @ Bus: %s\n',Lines_Distance(max_dist_bus,1).name);
    fprintf('Load Center Located @ Bus: %s\n',Lines_Distance(load_center,1).name);
    fprintf('Overall End Resistance: %3.3f ohms\n',Lines_Distance(max_dist_bus,1).bus1Zsc1(1,1));
    fprintf('KW Load Center Resistance: %3.3f ohms\n',Lines_Distance(load_center,1).bus1Zsc1(1,1));
    fprintf('Distance Load Center Resistance: %3.3f ohms\n',Lines_Distance(distance_diff(1,2),1).bus1Zsc1(1,1));
    SC_Imped=struct('Zsc1', {Buses(1:end).Zsc1}, 'Zsc0', {Buses(1:end).Zsc0});
    %Plot Rsc1 vs km from sub:
%%
    figure(1);
    count = 0;
    sum = 0;
    for j=1:1:n
        sum = sum + Lines_Distance(j,1).bus1Zsc1(1,1);
        if Lines_Distance(j,1).bus1Zsc1(1,1) > 100 || Lines_Distance(j,1).bus1Zsc1(1,1) < -100
            count = count + 1;
            fprintf('Error Located %d\n',j);
        end
        plot(Lines_Distance(j,1).bus1Distance,Lines_Distance(j,1).bus1Zsc1(1,1),'bo');
        hold on
    end
    %fprintf('Load Center Resistance: %3.3f ohm\n',Lines_Distance(load_center,1).bus1Zsc1(1,1));
    fprintf('Number of Violations: %d\t SUM: %d\n',count,sum);
end
%%
%Now lets find kVA/phase & proportion of 100kVA:
KVA_ph = zeros(1,3); 
count = zeros(1,2); %Residential & Commercial
for j=1:1:length(Loads)
    if Loads(j,1).nodes == 1
        KVA_ph(1,1) = KVA_ph(1,1) + Loads(j,1).xfkVA;
    elseif Loads(j,1).nodes == 2
        KVA_ph(1,2) = KVA_ph(1,2) + Loads(j,1).xfkVA;
    elseif Loads(j,1).nodes == 3
        KVA_ph(1,3) = KVA_ph(1,3) + Loads(j,1).xfkVA;
    else
        fprintf('missing here: %d\n',j);
    end
    %Customer Count:
    if Loads(j,1).xfkVA > 100
        count(1,2) = count(1,2) + 1;
    else
        count(1,1) = count(1,1) + 1;
    end
end

total_KVA = KVA_ph(1,1)+KVA_ph(1,2)+KVA_ph(1,3);
fprintf('Connected kVA:\n A:%3.3f\n B:%3.3f\n C:%3.3f\n',KVA_ph(1,1),KVA_ph(1,2),KVA_ph(1,3));
fprintf('Connected kVA(PU):\n A:%3.3f\n B:%3.3f\n C:%3.3f\n',(KVA_ph(1,1)/total_KVA)*100,(KVA_ph(1,2)/total_KVA)*100,(KVA_ph(1,3)/total_KVA)*100);
total_LD = count(1,1) + count(1,2);
fprintf('R=%3.3f %% and C=%3.3f %%\n',(count(1,1)/total_LD)*100,(count(1,2)/total_LD)*100);
%%
for i=1:1:length(Lines_Distance)
    phase_check(i,1).name = Lines_Distance(i,1).name;
    phase_check(i,1).bus1 = Lines_Distance(i,1).bus1;
    phase_check(i,1).bus2 = Lines_Distance(i,1).bus2;
    phase_check(i,1).bus1phC=Lines_Distance(i,1).bus1PhaseCurrent;
    phase_check(i,1).bus1Voltage=Lines_Distance(i,1).bus1Voltage;
end
plot([phase_check.bus1Voltage])
%%

%-------------------------------------------------------------------------
%Find Voltage headroom:


%%
%   This section was made to give an initial assessment of what feeder
%   looks like V,I, P,Q vs. distance
%{
figure(1);
subplot(2,2,1);
plotKWProfile(DSSCircObj);
%title('kw Profile');
subplot(2,2,2);
plotKVARProfile(DSSCircObj,'Only3Phase','on');
%title('
subplot(2,2,3);
plotVoltageProfile(DSSCircObj,'SecondarySystem','off');
subplot(2,2,4);
%plotAmpProfile(DSSCircObj,'258904005');    %Commonwealth
%plotAmpProfile(DSSCircObj,'258126280');     %Flay
%plotAmpProfile(DSSCircObj,'1713339'); %Roxboro
% Lines2=getLineInfo_DJM(DSSCircObj, DSSText);
%%
gcf=plotCircuitLines(DSSCircObj,'Coloring','numPhases','MappingBackground','none');
%}
%%
%{
%Search function to see what buses have loads on them, 3ph,2ph,1ph.
Buses_tilda = zeros(length(Buses),4);

for i=1:1:length(Loads)
    busNUM=Loads(i,1).busName(1:end-2);
    
    %Search for it in Buses & save:
    for j=1:1:length(Buses_tilda)
        if strcmp(busNUM,Buses(j,1).name) == 1
            Buses_tilda(j,1) = Buses_tilda(j,1) + 1;
            Buses_tilda(j,2) = str2num(Buses(j,1).name);
            %Line 1
            for k=1:1:length(Lines)
                lineBUS1=Lines(k,1).bus1(1:end-2);
                if strcmp(lineBUS1,Buses(j,1).name) == 1
                    Buses_tilda(j,3) = str2num(Lines(k,1).name);
                elseif strcmp(Lines(k,1).bus2(1:end-2),Buses(j,1).name)
                    Buses_tilda(j,4) = str2num(Lines(k,1).name);
                end
            end
            
        end
    end
    
end
%}












