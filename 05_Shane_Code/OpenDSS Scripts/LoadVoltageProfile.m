%{
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

%}

%% Plot Circuit Profiles
% USING GRIDPV TOOLBOX
figure(1);
%subplot(2,2,1);
subplot(1,3,1);
plotKWProfile(DSSCircObj,'AveragePhase','on');
%subplot(2,2,2);
subplot(1,3,2);
plotKVARProfile(DSSCircObj,'Only3Phase','on','AveragePhase','on');
axis([0 6 -50 300])
%subplot(2,2,3);
subplot(1,3,3);
plotVoltageProfile(DSSCircObj,'Only3Phase','on','AveragePhase','on','VoltScale','pu');
axis([0 6 .99 1.04])
%subplot(2,2,4);
%plotAmpProfile(DSSCircObj,'258904005','AveragePhase','on');




% OUTPUT FROM MILP (Variables must be defined in workspace)
figure(2);
subplot(1,3,1);
plot(NODE.DISTANCE,P/3,'.')
axis([0 6 -500 2500])
grid on;
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Substation (km)','FontSize',12,'FontWeight','bold')
ylabel(gca,'kW','FontSize',12,'FontWeight','bold')
title('Feeder kW Profile (MILP)','FontWeight','bold','FontSize',12);
legend('Average')

subplot(1,3,2);
plot(NODE.DISTANCE,Q/3,'.')
axis([0 6 -50 300])
grid on;
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Substation (km)','FontSize',12,'FontWeight','bold')
ylabel(gca,'kVAR','FontSize',12,'FontWeight','bold')
title('Feeder kVAR Profile (MILP)','FontWeight','bold','FontSize',12);
legend('Average')

subplot(1,3,3);
plot(NODE.DISTANCE,V/12.47,'.')
axis([0 6 .98 1.04])
grid on;
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Substation (km)','FontSize',12,'FontWeight','bold')
ylabel(gca,'Bus Voltage (pu)','FontSize',12,'FontWeight','bold')
title('Feeder Voltage Profile (MILP)','FontWeight','bold','FontSize',12);
legend('Average')




% OUTPUT FROM MILP compared to OpenDSS(Variables must be defined in workspace)
Lines_Base = getLineInfo(DSSCircObj);
Lines_Base = Lines_Base([Lines_Base.numPhases]==3); % Only 3 Phase

figure(3);
subplot(1,3,1);
plot([Lines_Base.bus1Distance],[Lines_Base.bus1PowerReal]/3,'.k','MarkerSize',8)
hold on
plot(NODE.DISTANCE,P/3,'.r')
axis([0 6 -500 2500])
grid on;
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Substation (km)','FontSize',12,'FontWeight','bold')
ylabel(gca,'kW','FontSize',12,'FontWeight','bold')
title('Feeder kW Profile','FontWeight','bold','FontSize',12);
legend('OpenDSS','MILP')

subplot(1,3,2);
plot([Lines_Base.bus1Distance],[Lines_Base.bus1PowerReactive]/3,'.k','MarkerSize',8)
hold on
plot(NODE.DISTANCE,Q/3,'.r')
axis([0 6 -50 300])
grid on;
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Substation (km)','FontSize',12,'FontWeight','bold')
ylabel(gca,'kVAR','FontSize',12,'FontWeight','bold')
title('Feeder kVAR Profile','FontWeight','bold','FontSize',12);
legend('OpenDSS','MILP')

subplot(1,3,3);
plot([Lines_Base.bus1Distance],[Lines_Base.bus1VoltagePU],'.k','MarkerSize',8)
hold on
plot(NODE.DISTANCE,V/12.47,'.r')
axis([0 6 .99 1.04])
grid on;
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Substation (km)','FontSize',12,'FontWeight','bold')
ylabel(gca,'Bus Voltage (pu)','FontSize',12,'FontWeight','bold')
title('Feeder Voltage Profile','FontWeight','bold','FontSize',12);
legend('OpenDSS','MILP')




%% Calculate Error
Len = length(Lines_Base);
errPowerReal = zeros(Len,1);
errPowerReactive = zeros(Len,1);
errVoltage = zeros(Len,1);
for i = 1:length(Lines_Base)
    NodeIndex = find(~cellfun(@isempty,regexp(NODE.ID,regexp(Lines_Base(i).bus1,'^.*?(?=[.])','match'))));
    if (~isempty(NodeIndex))
        errPowerReal(i)     = (Lines_Base(i).bus1PowerReal     - P(NodeIndex)      );%/Lines_Base(i).bus1PowerReal;
        errPowerReactive(i) = (Lines_Base(i).bus1PowerReactive - Q(NodeIndex)      );%/Lines_Base(i).bus1PowerReactive;
        errVoltage(i)       = (Lines_Base(i).bus1VoltagePU     - V(NodeIndex)/12.47);%/Lines_Base(i).bus1VoltagePU;
    end
end



% Plot Errors
figure(4);
subplot(1,3,1);
plot([Lines_Base.bus1Distance],errPowerReal,'.k')
grid on;
%axis([0 6 -1 1])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Substation (km)','FontSize',12,'FontWeight','bold')
ylabel(gca,'Percent Error','FontSize',12,'FontWeight','bold')
title('Feeder kW Profile','FontWeight','bold','FontSize',12);
legend('Percent Error')

subplot(1,3,2);
plot([Lines_Base.bus1Distance],errPowerReactive,'.k','MarkerSize',8)
grid on;
%axis([0 6 -1 1])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Substation (km)','FontSize',12,'FontWeight','bold')
ylabel(gca,'Percent Error','FontSize',12,'FontWeight','bold')
title('Feeder kVAR Profile','FontWeight','bold','FontSize',12);
legend('Percent Error')

subplot(1,3,3);
plot([Lines_Base.bus1Distance],errVoltage,'.k','MarkerSize',8)
grid on;
%axis([0 6 -.01 .1])
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Distance from Substation (km)','FontSize',12,'FontWeight','bold')
ylabel(gca,'Percent Error','FontSize',12,'FontWeight','bold')
title('Feeder Voltage Profile','FontWeight','bold','FontSize',12);
legend('Percent Error')




%{
for i = 1:1:length(Lines)
    
    DSSText.command = sprintf('open Line.%s',Lines(i,1).name);
    DSSText.command = 'solve loadmult=1';
    sim_Bus.S(i) = getBusInfo(DSSCircObj);
    sim_lines.S(i) = getLineInfo(DSSCircObj);
    %Need to pull 
    DSSText.command = sprintf('close Line.%s',Lines(i,1).name);
end
    
    
    
%}