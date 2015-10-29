clear
clc
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code')

%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;
%Find directory of Circuit:
% 1. Obtain user's choice of simulation:
DER_Planning_GUI_1
gui_response = STRING_0;
mainFile = gui_response{1,1};
feeder_NUM = gui_response{1,2};
scenerio_NUM = gui_response{1,3}; %1=VREG-top ; 2=VREG-bot ; 3=steadystate ; 4=RR_up ; 5=RR_down
base_path = gui_response{1,4};
cat_choice = gui_response{1,5};


% 1. Load background files:
filename = strcat(base_path,'\01_Sept_Code\Result_Analysis\RESULTS_FLAY_025.mat');
pu_load = 0.25;

path = strcat(base_path,'\01_Sept_Code');
addpath(path);
path = strcat(base_path,'\04_DSCADA');
addpath(path);

% 2. Compile the user selected circuit:
DSSText.command = ['Compile "',mainFile];
% 3. Solve the circuit. Call anytime you want the circuit to resolve     
DSSText.command = 'solve';
Lines_Base = getLineInfo(DSSCircObj);
Buses_Base = getBusInfo(DSSCircObj);
Loads_Base = getLoadInfo(DSSCircObj);
[~,index] = sortrows([Lines_Base.bus1Distance].'); 
Lines_Distance = Lines_Base(index); clear index
%
%%
% 1. Adjust initial simulation feeder load:
DSSText.command =sprintf('solve loadmult=%s',num2str(pu_load));
%{
figure(1);
plotCircuitLines(DSSCircObj,'Coloring','lineLoading','PVMarker','on','MappingBackground','none');
figure(2);
plotCircuitLines(DSSCircObj,'Coloring','voltage120','PVMarker','on','MappingBackground','none');
%}
%
% 5. Obtain all line & bus information used as reference:
Lines_Base = getLineInfo(DSSCircObj);
Buses_Base = getBusInfo(DSSCircObj);
Buses = getBusInfo(DSSCircObj);
Loads = getLoadInfo(DSSCircObj);
%%
%
%Function to generate node names from Buses_Base:
MAT_FILE_LOAD
%Extras:
xfmrNames = DSSCircuit.Transformers.AllNames;
lineNames = DSSCircuit.Lines.AllNames;
loadNames = DSSCircuit.Loads.AllNames;
%BusNames = DSSCircuit.Buses.AllNames;
%
%{
%Trace the circuit all the way back to the substation
%UpstreamBuses = findUpstreamBuses(DSSCircObj, MYBUS);
%Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
%Voltages=Voltages'; %Transpose
%Buses_Names=DSSCircObj.ActiveCircuit.AllBusnames;
%nXfmrs = DSSCircuit.Transformers.Count; %number of transformer present.
%}
% 6. Setup a pointer of the active circuit:
DSSCircuit = DSSCircObj.ActiveCircuit;

% 7. Setup Capacitors for control/switching:
Capacitors = getCapacitorInfo(DSSCircObj);
%Set Voltage Regulating Devices:
if scenerio_NUM == 1
    %UPPER VOLTAGE BAND
    cap_on = 0;
    %tap = 8;
    vreg = 125;
elseif scenerio_NUM == 2
    %LOWER VOLTAGE BAND
    cap_on = 1;
    %tap = -8;
    vreg = 118;
elseif scenerio_NUM == 3
    %SteadyState
    cap_on = 0;
    vreg = 124;
end

for jj=1:1:length(Capacitors)
    DSSText.command = sprintf('edit capacitor.%s state=%s',Capacitors(jj,1).name,num2str(cap_on));
end
DSSText.command =sprintf('solve loadmult=%s',num2str(pu_load));
Capacitors = getCapacitorInfo(DSSCircObj);
%DSSText.command = 'edit capacitor.cp-nr-613 state=0';

% 8. Setup Vreg control/tap:
%   Get Transformer Info
Transformers = getTransformerInfo(DSSCircObj);
XfmrTaps = struct();
xfmrName=DSSCircuit.Transformers.AllNames;

%{
% cycle through all the regulators using First .. Next
iReg = Regulators.First;
while iReg>0
   Regulators.MaxTapChange = 1;
   Regulators.Delay = 30;  % set all delays to 30s
   iReg = Regulators.Next; 
end
%}      
%   Change VREG taps:
%{
     -- Extra informtion about the voltage regulators  --
    PTratio= 110        CTPrim= 100 
    Vreg=125            Band=2.000000
    wdg2minTap=0.9      wdg2maxTap=1.1
    maxnumTaps=32
%} 
if feeder_NUM == 3 || feeder_NUM == 2       %Do only for feeders w/ line VREGs
    tic
    Regulators = DSSCircuit.RegControls;    % Assign a Variable to the RegControls interface
    for jj=4:1:length(xfmrName) %starts at 4 to skip the LTC
        %send:
        XfmrTaps(jj,1).names = xfmrName{jj,1};
        %DSSText.Command = sprintf('RegControl.%s.TapNum=5',char(xfmrName(jj)));
        DSSText.Command = sprintf('RegControl.%s.Vreg=%s',char(xfmrName(jj)),num2str(vreg));
        %Check:
        DSSText.command = sprintf('? RegControl.%s.TapNum',char(xfmrName(jj)));
        VREG_tap = DSSText.Result;
        DSSText.command = sprintf('? RegControl.%s.vreg',char(xfmrName(jj)));
        VREG_pt = DSSText.Result;
        %Save results:
        XfmrTaps(jj,1).Init_tap = str2double(VREG_tap);
        XfmrTaps(jj,1).vreg_setting = str2double(VREG_pt);

    end
    toc
end


% 9. Initiate PV Central station:
%{
%DSSText.command = 'new loadshape.PV_Loadshape npts=1 sinterval=60 csvfile="PVloadshape_Central.txt" Pbase=0.10 action=normalize';
%PV_in = getPVInfo(DSSCircObj);
%Gen_in = getGeneratorInfo(DSSCircObj);
%}
ii = 1;
while ii < length(Buses)
    if Buses(ii,1).distance > 1e-4
        bus_init = ii;
        ii = length(Buses);
    end
    ii = ii + 1;
end

DSSText.command = sprintf('new generator.PV bus1=%s phases=3 kv=12.47 kW=100 pf=1.00 enabled=false',Buses(bus_init,1).name);
%DSSText.command = 'solve';
DSSText.command =sprintf('solve loadmult=%s',num2str(pu_load));
Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
MAT_FILE_LOAD %generates 'ref_busVpu'
%---------------------------------------------
%Iterate PV bus1 location throughout EPRI Circuit

%STEP 1] Find legal buses & save names:
%legal_buses = cell(200,1);
ii = 5;
j = 1;
while ii<length(Buses)
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).voltage > 6000
        legal_buses{j,1} = Buses(ii,1).name;
        legal_distances{j,1} = Buses(ii,1).distance;
        j = j + 1;
    end
    ii =ii + 1;
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Save_BASECASE
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%%
% SOLVES THE HOSTING CAP!
m = 1;
n = 1;
DSSCircuit.Enable('generator.PV');
ii = bus_init;
PV_size = 100;
PV_LOC = 3;
P_loss = 0;
%fDR_LD;
PV_VOLT= zeros(1,3); %Va Vb Vc
%RESULTS = zeros(
jj = 2; %skip jj=1 for basecase results:
COUNT = 0;
%Bus Loop.
while ii< length(Buses) %length(Buses)
    %Skip BUS if not 3-ph & connected to 12.47:
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).voltage > 6000
        % ~~~~~~~~~~~~~~~~~
        %Connect PV to Bus:
        DSSText.command = sprintf('edit generator.PV bus1=%s kW=%s',Buses(ii,1).name,num2str(PV_size));
        fprintf('%1.1f/%1.1f SolarGEN located: %s\n',m,length(legal_buses),Buses(ii,1).name);
        %Reset Vreg to initial state:
        for ij=1:DSSCircuit.Transformers.Count;
            if isempty(XfmrTaps(ij,1).Init_tap) == 0
                DSSText.command= sprintf('edit RegControl.%s Tapnum=%s',char(xfmrName(ij)),num2str(XfmrTaps(ij,1).Init_tap));
            end
        end
        % ~~~~~~~~~~~~~~~~~
        %Search & obtain Line where PV is located on.
        s1 = Buses(ii,1).name;
        s2 = '.1.2.3';
        s = strcat(s1,'.1.2.3');
        for iii=1:1:length(Lines_Base)
            if strcmp(Lines_Base(iii,1).bus1,s) == 1 %Bus name matches:
                if Lines_Base(iii,1).numPhases == 3
                    B1 = Lines_Base(iii,1).bus1;
                    %take off node #'s (.1.2.3):
                    B2 = regexprep({B1},'(\.[0-9]+)','');
                    for jjj=1:1:length(Buses)
                        if strcmp(B2,Buses(jjj,1).name)==1 %match!
                            if Buses(jjj,1).distance > 1e-4
                                %Check to see if NOT in substation.
                                PV_LOC = iii;
                                
                            end
                        end
                    end
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
            DSSText.command =sprintf('solve loadmult=%s',num2str(pu_load));
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
            max_V = zeros(3,2); %[Aph_mx,index;Bph_mx,index;Cph_mx,index]
            for i=1:1:length(Voltages)
                %Obtain peak 1-ph max Bus Voltage:
                if strcmp('1',ref_busVpu{i,2})==0       %ph A
                    if Voltages(i,1) > max_V(2,1);
                        max_V(1,1) = Voltages(i,1);
                        max_V(1,2) = i;
                    end
                elseif strcmp('2',ref_busVpu{i,2})==0   %ph B
                     if Voltages(i,1) > max_V(1,1); 
                        max_V(2,1) = Voltages(i,1);
                        max_V(2,2) = i;
                     end
                elseif strcmp('3',ref_busVpu{i,2})==0   %ph C
                     if Voltages(i,1) > max_V(1,1);
                        max_V(3,1) = Voltages(i,1);
                        max_V(3,2) = i;
                     end
                end   
            end
            
            %fDR_LD=DSSCircObj.ActiveCircuit.TotalPower;
            %This is to measure the feeder active load:
            if  feeder_NUM == 0     %Bellhaven
                DSSCircuit.SetActiveElement('Line.259355408');
            elseif feeder_NUM == 1  %Commonwealth
                DSSCircuit.SetActiveElement('Line.259355408');%Still needs edit.
            elseif feeder_NUM == 2  %Flay
                DSSCircuit.SetActiveElement('Line.259363665');
            elseif feeder_NUM == 3  %Roxboro
                DSSCircuit.SetActiveElement('Line.333');
            end
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
            %if mod(PV_size,2000) == 0
                %fprintf('\tSIZE: %3.1f kW\n',PV_size);
            %end
            %
            %Save results for this iteration:
            RESULTS(jj,1:6)=[PV_size,max(max_V(:,1)),max_V(2,1),max_C(1,1),max_C(2,1),PV_LOC]; %|PV_KW|maxV_3ph|maxV_1ph|maxC1|maxC2|bus_name|kVAR_CAP1|kVAR_CAP2
            %{
            if length(Capacitors) == 2
                RESULTS(jj,7)=Capacitors(1,1).powerReactive;
                RESULTS(jj,8)=Capacitors(2,1).powerReactive;
            elseif length(Capacitors)== 3
                RESULTS(jj,7)=Capacitors(1,1).powerReactive;
                RESULTS(jj,8)=Capacitors(2,1).powerReactive;
                RESULTS(jj,10)=Capacitors(3,1).powerReactive;
            end
            %}
            RESULTS(jj,7)=0;
            RESULTS(jj,8)=0;
            %*** leave Columns 9,10 blank for post_Process_2.m ***
                  
            RESULTS(jj,11)=fDR_LD; %Feeder 3phase load in kW
            
            
            %Calculate R_PV now:
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
                    PV_VOLT(2,1)=Buses(ii,1).voltageAngle; %theta_V
                    %PV_VOLT(2,2)=Buses(ii,1).
                    break
                end
            end
            RESULTS(jj,12)=max(PV_VOLT(1,1:3)); %Maximum voltage voltage
            R_PV=(3*(RESULTS(jj,12)*((12.47e3)/sqrt(3)))^2)/(PV_size*1e3);
            RESULTS(jj,13)=R_PV; %Capture supposibly R_PV
            %
            %Calculate feeder power losses:
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            for i=1:1:length(Lines)
                P_loss = P_loss + Lines(i).losses;
            end
            RESULTS(jj,14)=P_loss;
            P_loss = 0;
            
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
save(filename,'RESULTS');
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
