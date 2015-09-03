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
%Plotting Circuits:
DSSText.command = 'Set mode=duty number=10 hour=13 h=1 sec=1800';
DSSText.command = 'Set controlmode = static';
DSSText.command = 'solve';
Lines = getLineInfo_Currents(DSSCircObj);
thermal = zeros(length(Lines),3); %LINE_RATING | MAX sim PHASE CURRENT | %%THERMAL
jj = 1;
while jj<length(thermal)
    thermal(jj,1) = Lines(jj,1).lineRating;
    jj = jj + 1;
end

ansi84 = zeros(length(Lines),1); %MAX sim PHASE VOLTAGE
%Base Case: (a test)

jj = 1;
max_C = [0,0];
max_V = [0,0];
while jj<length(thermal)
    %Find last Sim's phase vltgs:
    ansi84(jj,1) = max(Lines(jj,1).bus1PhaseVoltagesPU);
    %Find last Sim's line currnts:
    thermal(jj,2) = max(Lines(jj,1).bus1PhaseCurrent);

    thermal(jj,3) = (thermal(jj,2)/thermal(jj,1))*100;
    %Hold if the maximum;
    if thermal(jj,3) > max_C(1,1)
        max_C(1,1) = thermal(jj,3);
        max_C(1,2) = jj;
    end
    if ansi84(jj,1) > max_V(1,1)
        max_V(1,1) = ansi84(jj,1);
        max_V(1,2) = jj;
    end

    jj = jj + 1;
end
fprintf('Max %%thermalrating is %3.3f %%, located at:  %s\n',max_C(1,1),Lines(max_C(1,2),1).name);  
fprintf('\nMax P.U. voltage is %3.3f, located at:  %s\n',max_V(1,1),Lines(max_V(1,2),1).name);


%3) Setup a pointer of the active circuit:
DSSCircuit = DSSCircObj.ActiveCircuit;
%5) Obtain Component Structs:
Buses = getBusInfo(DSSCircObj);
Loads = getLoadInfo(DSSCircObj);
%%

% Connect PV at first bus after substation:
DSSText.command = sprintf('new generator.PV bus1=%s phases=3 kv=12.47 kw=100 pf=1 enabled=true',Buses(3,1).name);
% Set it as the active element and view its bus information
DSSCircuit.SetActiveElement('generator.pv');

%---------------------------------------------
%Iterate PV bus1 location throughout Circuit 24.
i = 3;
PV_size = 100;
%Bus Loop.
while i<length(Buses)
    %Only connect a Central PV station to a 3-phase bus.
    if Buses(i,1).numPhases == 3
        %Connect PV to Bus:
        DSSText.command = sprintf('edit generator.PV bus1=%s kw=%s',Buses(i,1).name,num2str(PV_size));
        
    end
    i = i + 1;
end








%This is to print the feeder
%figure(1);
%plotCircuitLines(DSSCircObj,'Coloring','numPhases','MappingBackground','none');
 
        
