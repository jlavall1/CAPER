% SwitchingLines.m will find the 3phase bus located the farthest from the
% sub, then record the KW and KVAR leaving the sub when each line is
% switched off between this point and the sub

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

% Locate Longest Distance Bus
[longestDistance, toBus] = findLongestDistanceBus(DSSCircObj, '3phase');

% Find path to Source
upstreamBuses = findUpstreamBuses(DSSCircObj,toBus);
N = length(upstreamBuses);
Sub = regexprep(upstreamBuses(N),'(\_reg)','');

% Collect Initial KW info
DSSCircuit.SetActiveBus(Sub{1});
P_base = 

% Collect Sub Load Data with each line disabled along path
for i = 1:length(upstreamBuses)
    % Open Line
    DSSText.command = sprintf('open Line.%s',upstreamBuses(i));
    % Solve Power Flow
    DSSText.command = 'solve loadmult=1';
    % Get Sub KVA
    sim_Bus.S(i) = getBusInfo(DSSCircObj);
    sim_lines.S(i) = getLineInfo(DSSCircObj);
    %Need to pull 
    DSSText.command = sprintf('close Line.%s',Lines(i,1).name);
end
