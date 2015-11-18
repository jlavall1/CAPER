% prompt = 'Enter file path: ';
% str = input(prompt,'s');
clear
clc

%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\run_master_allocate.DSS';
%str = 'C:\Users\jlavall\Desktop\Commonwealth_Circuit_Opendss\run_master_allocate.DSS';
%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Roxboro_Circuit_Opendss\run_master_allocate.DSS';
%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Run_Master_Allocate.DSS';
fileloc ='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss';
str = strcat(fileloc,'\Master.DSS');
%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Bellhaven_Circuit_Opendss\run_master_allocate.DSS';
% 1. Start the OpenDSS COM. Needs to be done each time MATLAB is opened     
[DSSCircObj, DSSText] = DSSStartup; 
    
% 2. Compiling the circuit & Allocate Load according to peak current in
% desired loadshape. This will work w/ nominal values.
peak_current = [196.597331353572,186.718068471483,238.090235458346];
%peak_current = [100,100,100];
DSSText.command = ['Compile ' str]; 
DSSText.command = 'New EnergyMeter.CircuitMeter LINE.259363665 terminal=1 option=R PhaseVoltageReport=yes';
%DSSText.command = 'EnergyMeter.CircuitMeter.peakcurrent=[  196.597331353572   186.718068471483   238.090235458346  ]';
DSSText.command = sprintf('EnergyMeter.CircuitMeter.peakcurrent=[  %s   %s   %s  ]',num2str(peak_current(1,1)),num2str(peak_current(1,2)),num2str(peak_current(1,3)));
DSSText.command = 'Disable Capacitor.*';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'AllocateLoad';
DSSText.command = 'Dump AllocationFactors';
DSSText.command = 'Enable Capacitor.*';

% 3. 
DSSText.command = 'solve loadmult=1.0';
% 4. Run circuitCheck function to double-check for any errors in the circuit before using the toolbox     
%warnSt = circuitCheck(DSSCircObj);

DSSCircuit = DSSCircObj.ActiveCircuit;
Buses=getBusInfo(DSSCircObj);
Lines=getLineInfo(DSSCircObj);
Loads=getLoadInfo(DSSCircObj);
[~,index] = sortrows([Lines.bus1Distance].'); 
Lines_Distance = Lines(index); 
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












