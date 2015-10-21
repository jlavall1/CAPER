% Setup the COM server
[DSSCircObj, DSSText, ~] = DSSStartup;

% Find the DSS Master File
filename = 0;
while ~filename
    [filename,filelocation] = uigetfile({'*.*','All Files'},'Select DSS Master File',...
        'C:\Users\SJKIMBL\Documents\MATLAB\GitHub\CAPER\03_OpenDSS_Circuits\');
end
%
% Compile the Circuit
DSSText.command = ['Compile ',[filelocation,filename]];

% 3. Solve the circuit. Call anytime you want the circuit to resolve     
DSSText.command = 'solve'; 

% 4. Run circuitCheck function to double-check for any errors in the
% circuit before using the toolbox warnSt = circuitCheck(DSSCircObj);
DSSCircuit = DSSCircObj.ActiveCircuit;
Buses = getBusInfo(DSSCircObj);
Lines = getLineInfo(DSSCircObj);

% Plot Circuit Profiles
figure(1);
subplot(2,2,1);
plotKWProfile(DSSCircObj);
subplot(2,2,2);
plotKVARProfile(DSSCircObj,'Only3Phase','on');
subplot(2,2,3);
plotVoltageProfile(DSSCircObj,'SecondarySystem','off');
subplot(2,2,4);
plotAmpProfile(DSSCircObj,'258904005');

for i = 1:1:length(Lines)
    
    DSSText.command = sprintf('open Line.%s',Lines(i,1).name);
    DSSText.command = 'solve loadmult=1';
    sim_Bus.S(i) = getBusInfo(DSSCircObj);
    sim_lines.S(i) = getLineInfo(DSSCircObj);
    %Need to pull 
    DSSText.command = sprintf('close Line.%s',Lines(i,1).name);
end
    
    
    
