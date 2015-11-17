% prompt = 'Enter file path: ';
% str = input(prompt,'s');
clear
clc

%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\run_master_allocate.DSS';
%str = 'C:\Users\jlavall\Desktop\Commonwealth_Circuit_Opendss\run_master_allocate.DSS';
%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Roxboro_Circuit_Opendss\run_master_allocate.DSS';
%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Run_Master_Allocate.DSS';
str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Master_24hr_60sec.DSS';
%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Bellhaven_Circuit_Opendss\run_master_allocate.DSS';
% 1. Start the OpenDSS COM. Needs to be done each time MATLAB is opened     
[DSSCircObj, DSSText] = DSSStartup; 
    
% 2. Compiling the circuit     
DSSText.command = ['Compile ' str]; 

% 3. Solve the circuit. Call anytime you want the circuit to resolve     
%DSSText.command = 'solve loadmult=0.5'; 
DSSText.command = 'solve loadmult=1.0';
% 4. Run circuitCheck function to double-check for any errors in the circuit before using the toolbox     
%warnSt = circuitCheck(DSSCircObj);

DSSCircuit = DSSCircObj.ActiveCircuit;
Buses=getBusInfo(DSSCircObj);
Lines=getLineInfo(DSSCircObj);
Loads=getLoadInfo(DSSCircObj);
%%
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












