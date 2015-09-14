%4.4] Plotting Tutorial:
clear
clc
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code')
load reference_CKT7_Vpu.mat
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
%
%Find directory of Circuit:
mainFile = GUI_openDSS_Locations();
DSSText.command = ['Compile "',mainFile];
% 3. Solve the circuit. Call anytime you want the circuit to resolve     
DSSText.command = 'solve'; 

%Declare name of basecase .dss file:
%master = 'Run_Master_Allocate.dss';
%basecaseFile = strcat(mainFile,master);
%DSSEnergyMeters = DSSCircuit.Meters;
%
%{
%Compile the circuit
%DSSText.command = 'Compile R:\00_CAPER_SYSTEM\05_OpenDSS_Circuits\Roxboro_Circuit_Opendss\Master.DSS'; 
%DSSText.command = ['Compile "', gridpvPath,'ExampleCircuit\master_Ckt24.dss"'];
%
%Solve basecase:

DSSText.command = 'Set mode=duty number=10  hour=1  h=1 sec=0';
DSSText.Command = 'Set Controlmode=Static'; %take control actions immediately without delays
DSSText.command = 'solve';
%}
%{  
DSSText.command = 'Set mode=snapshot';
DSSText.command = 'Set controlmode = static';
DSSText.command = 'solve';
%}
% Run load flow for base case with light load
DSSText.command ='solve loadmult=0.5';

Lines_Base = getLineInfo(DSSCircObj);
Buses_Base = getBusInfo(DSSCircObj);
%{
thermal = zeros(length(Lines_Base),3); %LINE_RATING | MAX sim PHASE CURRENT | %%THERMAL
ansi84 = zeros(length(Lines_Base),1);  %MAX sim PHASE VOLTAGE
%Obtain thermal rating:
jj = 1;
while jj<length(thermal)
    thermal(jj,1) = Lines_Base(jj,1).lineRating;
    jj = jj + 1;
end
%}
%
%3) Setup a pointer of the active circuit:
DSSCircuit = DSSCircObj.ActiveCircuit;
%5) Obtain Component Structs:
Buses = getBusInfo(DSSCircObj);
Loads = getLoadInfo(DSSCircObj);
%Trace the circuit all the way back to the substation
%UpstreamBuses = findUpstreamBuses(DSSCircObj, MYBUS);
%Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
%Voltages=Voltages'; %Transpose
%Buses_Names=DSSCircObj.ActiveCircuit.AllBusnames;

% Step through every load & scale it down:
%Get Capacitor Information
%Capacitors = getCapacitorInfo(DSSCircObj);
%Enable/Disable capacitor

%{
%Create a matrix with
ref_busVpu = cell(2452,2);
ii = 1; %Index for ref_busVpu
jj = 1;
while jj<length(Buses)+1
    %Buses.name
    %Buses.node
    if length(Buses(jj,1).nodes)==3 %3phase bus (easy)
        %Phase A:
        ref_busVpu{ii,1}=Buses(jj,1).name;
        ref_busVpu{ii,2}=num2str(1);
        ii = ii + 1;
        %Phase B;
        ref_busVpu{ii,1}=Buses(jj,1).name;
        ref_busVpu{ii,2}=num2str(2);
        ii = ii + 1;
        %Phase C;
        ref_busVpu{ii,1}=Buses(jj,1).name;
        ref_busVpu{ii,2}=num2str(3);
        ii = ii + 1;
        %fprintf('3ph Hit at %1.1f\n',jj);
    elseif length(Buses(jj,1).nodes)==1
        ref_busVpu{ii,1}=Buses(jj,1).name;
        ref_busVpu{ii,2}=num2str(Buses(jj,1).nodes);
        ii = ii + 1;
    elseif length(Buses(jj,1).nodes)==2
        %fprintf('This is 2ph @ %1.1f\n',jj);
        %Phase B;
        ref_busVpu{ii,1}=Buses(jj,1).name;
        ref_busVpu{ii,2}=num2str(Buses(jj,1).nodes(1,1));
        ii = ii + 1;
        %Phase C;
        ref_busVpu{ii,1}=Buses(jj,1).name;
        ref_busVpu{ii,2}=num2str(Buses(jj,1).nodes(1,2));
        ii = ii + 1;
    
    end
    jj = jj + 1;
end
%}
%
%{
% %Obtain V & I results from latest scenerio:        
% tic
% Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
% Voltages=Voltages';
% max_V = zeros(2,2); %[3ph_mx,index;1ph_mx,index]
% for i=1:1:length(Voltages)
%     if strcmp('1',ref_busVpu{i,2})==0 %This means that the voltage is on a 3ph bus:
%         if Voltages(i,1) > max_V(2,1);
%             max_V(2,1) = Voltages(i,1);
%             max_V(2,2) = i;
%         end
%     elseif strcmp('3',ref_busVpu{i,2})==0
%         if Voltages(i,1) > max_V(1,1);
%             max_V(1,1) = Voltages(i,1);
%             max_V(1,2) = i;
%         end
%     end   
% end       
% fDR_LD=DSSCircObj.ActiveCircuit.TotalPower;
% Lines = getLineInfo_Currents(DSSCircObj);
% toc
%}

%


% SOLVES THE HOSTING CAP!
% Initiate PV Central station:
%DSSText.command = 'new loadshape.PV_Loadshape npts=1 sinterval=60 csvfile="PVloadshape_Central.txt" Pbase=0.10 action=normalize';
%PV_in = getPVInfo(DSSCircObj);
%Gen_in = getGeneratorInfo(DSSCircObj);
DSSText.command = sprintf('new generator.PV bus1=%s phases=3 kv=12.47 kW=100 pf=1.00 enabled=false',Buses(3,1).name);
%DSSText.command = 'solve';
DSSText.command = 'solve loadmult=0.5';
%fprintf(fid,'new generator.PV%s bus1=%s phases=%1.0f kv=%2.2f kw=%2.2f pf=1 duty=PV_Loadshape\n',Transformers(ii).bus1,Transformers(ii).bus1,Transformers(ii).numPhases,Transformers(ii).bus1Voltage/1000,kva(ii)/totalSystemSize*totalPVSize);
% Set it as the active element and view its bus information

%DSSCircuit.SetActiveElement('generator.pv');
%{
%---------------------------------------------
%Iterate PV bus1 location throughout EPRI Circuit

%STEP 1] Find legal buses & save names:
legal_buses = cell(200,1);
ii = 5;
j = 1;
while ii<length(Buses)
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).voltage > 6000
        legal_buses{j,1} = Buses(ii,1).name;
        j = j + 1;
    end
    ii =ii + 1;
end
%{
ii = 5;
while ii<length(Loads)
    if strcmp(Loads(ii,1).busName,'s_1001577-da1') == 1
        fprintf('\nProblem Child.\n');
        Loads(ii,1).allocationFactor
        Loads(ii,1).Idx
    end
    ii = ii + 1;
end
%}

RESULTS = zeros(21000,13);%PV_size | Active PV bus | max P.U. | max %thermal | max %thermal 2

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Obtain V & I results from BASE CASE (0kW PVgen):        
%tic
Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
Voltages=Voltages';
max_V = zeros(2,2); %[3ph_mx,index;1ph_mx,index]
for i=1:1:length(Voltages)
    %Obtain peak 1-ph max Bus Voltage:
    if strcmp('1',ref_busVpu{i,2})==0 %This means that the voltage is on a 1ph bus:
        if Voltages(i,1) > max_V(2,1);
            max_V(2,1) = Voltages(i,1);
            max_V(2,2) = i;
        end
    elseif strcmp('3',ref_busVpu{i,2})==0
        if Voltages(i,1) > max_V(1,1);
            max_V(1,1) = Voltages(i,1);
            max_V(1,2) = i;
        end
    end   
end
Lines = getLineInfo_Currents(DSSCircObj);
Capacitors = getCapacitorInfo(DSSCircObj);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Calculate  %%ThermalRating  &  MAX(Phase Voltages in P.U.)
COUNT = 0;
if COUNT==0
    %Obtain thermal rating:
    thermal = zeros(length(Lines),3); %LINE_RATING | MAX sim PHASE CURRENT | %%THERMAL

    for i=1:1:length(thermal)
        if Lines(i,1).enabled == 0
            thermal(i,1) = 1;
        else
            thermal(i,1) = Lines(i,1).lineRating;
        end
    end
    COUNT=1; %to not grab linerating again
end

max_C = zeros(10,2); %reset max currents
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Calculate %THERMAL
kk = 4; %Starting at 4 to skip buses within substation.
while kk<length(thermal)
    %Find last Sim's phase vltgs:
    %ansi84(kk,1) = max(Lines(kk,1).bus1PhaseVoltagesPU);
    %Find last Sim's line currents:


    if Lines(kk,1).enabled == 1
        thermal(kk,2) = max(Lines(kk,1).bus1PhaseCurrent);
        thermal(kk,3) = (thermal(kk,2)/thermal(kk,1))*100;
    else
        thermal(kk,3) = 0;
    end
    %Filter out 120V/240/480 Lines:

    if Lines(kk,1).bus1Voltage < 6000
        %We are only concerned about the primary lines:
        thermal(kk,3) = 0;
    end
%{                
    %NOW lets check for Voltage Profile
%                 if ansi84(kk,1) > max_V(1,1)
%                     max_V(1,1) = ansi84(kk,1);
%                     max_V(1,2) = kk;
%                 end
    %Pull line power flows:
    %L_Currents(kk,n)=Lines(kk,1).bus1PowerReal;
%}
    kk = kk + 1;
end
%Pull top 10 thermal(:,3) & store in max_C:
M = thermal(:,3);
[Msorted,AbsoluteIndices] = sort(M(:));
Mbiggest = Msorted(end:-1:end-9);
Mindices = AbsoluteIndices(end:-1:end-9);
max_C(:,1) = Mbiggest;
max_C(:,2) = Mindices;
%Check feeder load:
power = DSSCircuit.ActiveCktElement.Powers;
power = reshape(power,2,[]); %two rows for real and reactive
fDR_LD = sum(power(1,1:3));         
RESULTS(1,1:8)=[0,max_V(1,1),max_V(2,1),max_C(1,1),max_C(2,1),0,Capacitors(1,1).powerReactive,Capacitors(2,1).powerReactive]; %|PV_KW|maxV_3ph|maxV_1ph|maxC1|maxC2|bus_name|kVAR_CAP1|kVAR_CAP2
%End of Search Function.
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%}
%%
m = 1;
n = 1;
DSSCircuit.Enable('generator.PV');
ii = 5;
PV_size = 100;
PV_LOC = 3;
%fDR_LD;
PV_VOLT= zeros(1,3); %Va Vb Vc
jj = 2; %skip jj=1 for basecase results:
COUNT = 0;
%Bus Loop.
while ii< length(Buses) %length(Buses)
    %Skip BUS if not 3-ph & connected to 12.47:
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).voltage > 6000
        % ~~~~~~~~~~~~~~~~~
        %Connect PV to Bus:
        DSSText.command = sprintf('edit generator.PV bus1=%s kW=%s',Buses(ii,1).name,num2str(PV_size));
        fprintf('%1.1f) SolarGEN located: %s\n',m,Buses(ii,1).name);
        % ~~~~~~~~~~~~~~~~~
        %
        %Search & obtain Line where PV is located on.
        s1 = Buses(ii,1).name;
        s2 = '.1.2.3';
        s = strcat(s1,'.1.2.3');
        for iii=1:1:length(Lines_Base)
            if strcmp(Lines_Base(iii,1).bus1,s) == 1 %Bus name matches:
                if Lines_Base(iii,1).numPhases == 3
                    PV_LOC = iii;
                end
            end
        end
        % ~~~~~~~~~~~~~~~~~
        %Iterate PV's kW:
        tic
        while PV_size < 10100
            
            %
            %Run powerflow at Bus location:
            %tic
            DSSText.command = sprintf('edit generator.PV kW=%s',num2str(PV_size));
            DSSText.command = 'solve loadmult=0.5';
            %{
            DSSText.command = 'Set mode=snapshot';
            DSSText.command = 'Set controlmode = static';
            DSSText.command = 'solve';
            %}
            %toc
            %fprintf('Power Flow complete\n');
            %{
            %Obtain Current & P.U. & select maximum of scenerio:
            Lines = getLineInfo_Currents(DSSCircObj);
            Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
            Voltages=Voltages'; %Transpose
            %Obtain Select Measurements:
            %	Feeder 3ph KW
            fDR_LD(1,1) = Lines(2,1).bus1PowerReal;
            %   Central-PV KW
            fDR_LD(1,2) = Lines(PV_LOC,1).bus1PowerReal;
            %}
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            %Obtain V & I results from latest scenerio:        
            %tic
            Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
            Voltages=Voltages';
            max_V = zeros(2,2); %[3ph_mx,index;1ph_mx,index]
            for i=1:1:length(Voltages)
                %Obtain peak 1-ph max Bus Voltage:
                if strcmp('1',ref_busVpu{i,2})==0 %This means that the voltage is on a 1ph bus:
                    if Voltages(i,1) > max_V(2,1);
                        max_V(2,1) = Voltages(i,1);
                        max_V(2,2) = i;
                    end
                elseif strcmp('3',ref_busVpu{i,2})==0
                    if Voltages(i,1) > max_V(1,1);
                        max_V(1,1) = Voltages(i,1);
                        max_V(1,2) = i;
                    end
                end   
            end
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            % Obtain PV-PCC VOLTAGE:
            for i=1:1:length(Voltages)
            %PV_VOLT(1:3)
                if strcmp(ref_busVpu{i,1},Buses(ii,1).name)==1 %a match!
                %if ref_busVpu{i,1}==str2double(Buses(ii,1).name)
                    %disp(i)
                    for ij=0:1:2
                        PV_VOLT(1,ij+1)=Voltages(i+ij,1); %obtain single phase voltages!
                    end
                    break
                end
            end
            %fDR_LD=DSSCircObj.ActiveCircuit.TotalPower;
            %This is to measure the feeder active load:
            DSSCircuit.SetActiveElement('Line.333');
            %power = DSSCircuit.ActiveDSSElement.Powers; %complex
            power = DSSCircuit.ActiveCktElement.Powers;
            power = reshape(power,2,[]); %two rows for real and reactive
            fDR_LD = sum(power(1,1:3));
            %fprintf('Feeder kW: %3.3f\n',fDR_LD);
            %toc
            
            %fDR_LD=0;
            %fDR_LD(2,1) = Lines(PV_LOC,1).bus1PowerReal;
            Lines = getLineInfo_Currents(DSSCircObj);
            Capacitors = getCapacitorInfo(DSSCircObj);
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            %Calculate  %%ThermalRating  &  MAX(Phase Voltages in P.U.)
            if COUNT==0
                %Obtain thermal rating:
                thermal = zeros(length(Lines),3); %LINE_RATING | MAX sim PHASE CURRENT | %%THERMAL
                
                for i=1:1:length(thermal)
                    if Lines(i,1).enabled == 0
                        thermal(i,1) = 1;
                    else
                        thermal(i,1) = Lines(i,1).lineRating;
                    end
                end
                COUNT=1; %to not grab linerating again
            end
            
            max_C = zeros(10,2); %reset max currents
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            %Calculate %THERMAL
            kk = 4; %Starting at 4 to skip buses within substation.
            while kk<length(thermal)
                %Find last Sim's phase vltgs:
                %ansi84(kk,1) = max(Lines(kk,1).bus1PhaseVoltagesPU);
                %Find last Sim's line currents:
                
                
                if Lines(kk,1).enabled == 1
                    thermal(kk,2) = max(Lines(kk,1).bus1PhaseCurrent);
                    thermal(kk,3) = (thermal(kk,2)/thermal(kk,1))*100;
                else
                    thermal(kk,3) = 0;
                end
                %Filter out 120V/240/480 Lines:
                
                if Lines(kk,1).bus1Voltage < 6000
                    %We are only concerned about the primary lines:
                    thermal(kk,3) = 0;
                end
%{                
                %NOW lets check for Voltage Profile
%                 if ansi84(kk,1) > max_V(1,1)
%                     max_V(1,1) = ansi84(kk,1);
%                     max_V(1,2) = kk;
%                 end
                %Pull line power flows:
                %L_Currents(kk,n)=Lines(kk,1).bus1PowerReal;
%}
                kk = kk + 1;
            end
            %Pull top 10 thermal(:,3) & store in max_C:
            M = thermal(:,3);
            [Msorted,AbsoluteIndices] = sort(M(:));
            Mbiggest = Msorted(end:-1:end-9);
            Mindices = AbsoluteIndices(end:-1:end-9);
            max_C(:,1) = Mbiggest;
            max_C(:,2) = Mindices;
            %End of Search Function.
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            
            %fprintf('Max %%thermalrating is %3.3f %%, located at:  %s\n',max_C(1,1),Lines(max_C(1,2),1).name);  
            %fprintf('\nMax P.U. voltage is %3.3f, located at:  %s\n',max_V(1,1),Lines(max_V(1,2),1).name);
            if mod(PV_size,2000) == 0
                fprintf('\tSIZE: %3.1f kW\n',PV_size);
            end
            %
            %Save results for this iteration:
            RESULTS(jj,1:8)=[PV_size,max_V(1,1),max_V(2,1),max_C(1,1),max_C(2,1),PV_LOC,Capacitors(1,1).powerReactive,Capacitors(2,1).powerReactive]; %|PV_KW|maxV_3ph|maxV_1ph|maxC1|maxC2|bus_name|kVAR_CAP1|kVAR_CAP2
            %*** leave Columns 9,10 blank for post_Process.m ***
            RESULTS(jj,11)=fDR_LD; %Feeder 3phase load in kW
            RESULTS(jj,12)=max(PV_VOLT(1,1:3)); %Maximum voltage voltage
            R_PV=(3*(RESULTS(jj,12)*((12.47e3)/sqrt(3)))^2)/(PV_size*1e3);
            RESULTS(jj,13)=R_PV; %Capture supposibly R_PV
            
            %Now increment the solar site:
            PV_size = PV_size + 100; %kW
            n = n + 1;
            jj = jj + 1;
            %toc
            %fprintf('Next Iteration\n');
        end
        toc
        m = m + 1;
    end
    %Reset size of PV system & move to next bus:
    PV_size = 100;
    %Increment Position:
    ii = ii + 1;
end
%%
%After Simulation, Lets show where all the locations were w/ distance from
%substation.
%{
%Add this part of script if you don't want to run sim"

%Setup the COM server:
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%Find directory of Circuit:
mainFile = GUI_openDSS_Locations();
%Declare name of basecase .dss file:
master = 'Master.dss';
basecaseFile = strcat(mainFile,master);
DSSText.command = ['Compile "',basecaseFile];
DSSText.command = 'Set mode=snapshot';
DSSText.command = 'Set controlmode = static';
DSSText.command = 'solve';
%Import desired Buses:
load config_LEGALBUSES.mat
%}

%{
%This is to print the feeder
figure(1);
%plotCircuitLines(DSSCircObj,'Coloring','lineLoading','PVMarker','on','MappingBackground','none');
Handles=plotCircuitLines(DSSCircObj,'Coloring','numPhases','MappingBackground','none');


%PV_PCC buses
addBuses = [legal_buses];
Bus2add =getBusInfo(DSSCircObj,addBuses,1);
BusesCoords = reshape([Bus2add.coordinates],2,[])';
%now lets add onto plot:
%   B = repmat(A,r1,r2): specs a list of scalars (rN) that describes how
%   copies of A are arranged in each dimension
busHandle = plot(repmat(BusesCoords(:,2)',2,1),repmat(BusesCoords(:,1)',2,1),'ko','MarkerSize',10,'MarkerFaceColor','c','LineStyle','none','DisplayName','Bottleneck');
legend([Handles.legendHandles,busHandle'],[Handles.legendText,'PV_{PCC} Locations'] )
%}
