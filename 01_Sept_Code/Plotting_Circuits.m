%4.4] Plotting Tutorial:
clear
clc
%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
%%
%Find directory of Circuit:
mainFile = GUI_openDSS_Locations();
%Declare name of basecase .dss file:
master = 'Master_ckt7.dss';
basecaseFile = strcat(mainFile,master);
DSSText.command = ['Compile "',basecaseFile];
%%
%}
%Compile the circuit
%DSSText.command = 'Compile R:\00_CAPER_SYSTEM\05_OpenDSS_Circuits\Roxboro_Circuit_Opendss\Master.DSS'; 
%DSSText.command = ['Compile "', gridpvPath,'ExampleCircuit\master_Ckt24.dss"'];
%%
%Solve basecase:
%{
DSSText.command = 'Set mode=duty number=10  hour=1  h=1 sec=0';
DSSText.Command = 'Set Controlmode=Static'; %take control actions immediately without delays
DSSText.command = 'solve';
%}
  
DSSText.command = 'Set mode=snapshot';
DSSText.command = 'Set controlmode = static';
DSSText.command = 'solve';


Lines_Base = getLineInfo(DSSCircObj);
thermal = zeros(length(Lines_Base),3); %LINE_RATING | MAX sim PHASE CURRENT | %%THERMAL
ansi84 = zeros(length(Lines_Base),1);  %MAX sim PHASE VOLTAGE
jj = 1;
while jj<length(thermal)
    thermal(jj,1) = Lines_Base(jj,1).lineRating;
    jj = jj + 1;
end


%3) Setup a pointer of the active circuit:
DSSCircuit = DSSCircObj.ActiveCircuit;
%5) Obtain Component Structs:
Buses = getBusInfo(DSSCircObj);
Loads = getLoadInfo(DSSCircObj);
% Step through every load & scale it down:

%%

% Initiate PV Central station:
%DSSText.command = 'new loadshape.PV_Loadshape npts=1 sinterval=60 csvfile="PVloadshape_Central.txt" Pbase=0.10 action=normalize';

DSSText.command = sprintf('new generator.PV bus1=%s phases=3 kv=12.47 kW=100 pf=1.00 enabled=false',Buses(3,1).name);
DSSText.command = 'solve';
%fprintf(fid,'new generator.PV%s bus1=%s phases=%1.0f kv=%2.2f kw=%2.2f pf=1 duty=PV_Loadshape\n',Transformers(ii).bus1,Transformers(ii).bus1,Transformers(ii).numPhases,Transformers(ii).bus1Voltage/1000,kva(ii)/totalSystemSize*totalPVSize);
% Set it as the active element and view its bus information

%DSSCircuit.SetActiveElement('generator.pv');

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
ii = 5;
while ii<length(Loads)
    if strcmp(Loads(ii,1).busName,'s_1001577-da1') == 1
        fprintf('\nProblem Child.\n');
        Loads(ii,1).allocationFactor
        Loads(ii,1).Idx
    end
    ii = ii + 1;
end

m = 1;
n = 1;
DSSCircuit.Enable('generator.PV');
ii = 5;
PV_size = 100;
PV_LOC = 3;
fDR_LD = zeros(1,3);
jj = 1;
RESULTS = zeros(11000,10);%PV_size | Active PV bus | max P.U. | max %thermal | max %thermal 2
L_Currents = zeros(length(Lines_Base(:,1)),100);
%Bus Loop.
while ii< 6%length(Buses)
    %Skip BUS if not 3-ph & connected to 12.47:
    if Buses(ii,1).numPhases == 3 && Buses(ii,1).voltage > 6000
        %Connect PV to Bus:
        DSSText.command = sprintf('edit generator.PV bus1=%s kW=%s',Buses(ii,1).name,num2str(PV_size));
        fprintf('%1.1f) SolarGEN located: %s\n',m,Buses(ii,1).name);
        %PV_in = getPVInfo(DSSCircObj);
        %Gen_in = getGeneratorInfo(DSSCircObj);
        %Search & obtain Line where PV is located on.
        s1 = Buses(ii,1).name;
        s2 = '.1.2.3';
        s = strcat(s1,s2);
        for iii=1:1:length(Lines_Base)
            if strcmp(Lines_Base(iii,1).bus1,s) == 1 %Bus name matches:
                if Lines_Base(iii,1).numPhases == 3
                    PV_LOC = iii;
                end
            end
        end
        
        %Iterate PV's kW:
        while PV_size < 5100
            %
            %Run powerflow at Bus location:
            DSSText.command = sprintf('edit generator.PV kW=%s',num2str(PV_size));
            DSSText.command = 'Set mode=snapshot';
            DSSText.command = 'Set controlmode = static';
            DSSText.command = 'solve';
            
            %{
            DSSText.command = 'Set mode=duty number=10  hour=1  h=1 sec=0';
            DSSText.Command = 'Set Controlmode=Static'; %take control actions immediately without delays
            DSSText.command = 'solve';
            %}
            %{
            %Run simulations every 1-minute and find max/min voltages
            simulationResolution = 60; %in seconds
            simulationSteps = 24*60*7;
            DSSText.Command = sprintf('Set mode=duty number=1  hour=0  h=%i sec=0',simulationResolution);
            DSSText.Command = 'Set Controlmode=TIME';
            %}
            %
            %Obtain Current & P.U. & select maximum of scenerio:
            %   Use this if you want to speed the process up:
            Lines = getLineInfo_Currents(DSSCircObj);
            %   OR THIS if you want to see what is available:
            %Lines = getLineInfo(DSSCircObj);

            %Feeder kW MEAS:
                fDR_LD(1,1) = Lines(2,1).bus1PowerReal;
            %PV kW MEAS:
                fDR_LD(1,2) = Lines(PV_LOC,1).bus1PowerReal;
            
            max_C = zeros(10,2);
            max_V = [0,0];
            %
            %Calculate %ThermalRating  &  MAX(Phase Voltages in P.U.)
            kk = 4;
            while kk<length(thermal)
                %Find last Sim's phase vltgs:
                ansi84(kk,1) = max(Lines(kk,1).bus1PhaseVoltagesPU);
                %Find last Sim's line currents:
                thermal(kk,2) = max(Lines(kk,1).bus1PhaseCurrent);
                thermal(kk,3) = (thermal(kk,2)/thermal(kk,1))*100;
                
                if Lines(kk,1).bus1Voltage < 6000
                    %We are only concerned about the primary lines:
                    thermal(kk,3) = 0;
                end
                
                %NOW lets check for Voltage Profile
                if ansi84(kk,1) > max_V(1,1)
                    max_V(1,1) = ansi84(kk,1);
                    max_V(1,2) = kk;
                end
                %Pull line power flows:
                L_Currents(kk,n)=Lines(kk,1).bus1PowerReal;

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
        
            %fprintf('Max %%thermalrating is %3.3f %%, located at:  %s\n',max_C(1,1),Lines(max_C(1,2),1).name);  
            %fprintf('\nMax P.U. voltage is %3.3f, located at:  %s\n',max_V(1,1),Lines(max_V(1,2),1).name);
            if mod(PV_size,1000) == 0
                fprintf('\tSIZE: %3.1f kW\n',PV_size);
            end
            %fprintf('\t\tMEAS: %3.3f kW\n',fDR_LD(1,2));
            %fprintf('\nFeeder Real Power = %3.4f kW\n',fDR_LD(1,1));
            %fprintf('---------------\n\n');
            %Save results for this iteration:
            %RESULTS = zeros(200,4);%PV_size | Active PV bus | max P.U. | max %thermal Bus Loop.
            RESULTS(jj,1:6)=[PV_size,fDR_LD(1,2),max_V(1,1),max_C(1,1),max_C(2,1),max_C(3,1)];
            %Now increment the solar site:
            PV_size = PV_size + 100; %kW
            n = n + 1;
            jj = jj + 1;    
        end
        m = m + 1;
    end
    %Reset size of PV system & move to next bus:
    PV_size = 100;
    %Increment Position:
    ii = ii + 1;
end
    










%This is to print the feeder
figure(1);
plotCircuitLines(DSSCircObj,'Coloring','lineLoading','PVMarker','on','MappingBackground','none');
%%
load DISTANCE.mat
figure(2);
colors = {'r-','b-','k-','r--','b--'};
n = 1;

plot(DISTANCE(1:1157,1),L_Currents(1:1157,n),'r--');
hold on
n = n + 1;
plot(DISTANCE(1:1157,1),L_Currents(1:1157,n),'b-');
hold on
n = n + 1;
plot(DISTANCE(1:1157,1),L_Currents(1:1157,n),'k-*');
hold on


      

