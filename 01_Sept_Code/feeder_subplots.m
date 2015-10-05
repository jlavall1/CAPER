% prompt = 'Enter file path: ';
% str = input(prompt,'s');
clear
clc

str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\run_master_allocate.DSS';
%str = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Run_Master_Allocate.DSS';
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
plotAmpProfile(DSSCircObj,'258904005');    %Commonwealth
%plotAmpProfile(DSSCircObj,'258126280');     %Flay


% Lines2=getLineInfo_DJM(DSSCircObj, DSSText);