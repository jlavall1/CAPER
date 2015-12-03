% ECE 6180      Project         Shane Kimble
load('COMMONWEALTH_Location.mat');
filename = 'Master_Fault.dss';

% Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
DSSCircuit = DSSCircObj.ActiveCircuit;

% Compile Circuit
DSSText.Command = ['Compile ',[filelocation,filename]];
%Lines_sc=getLineInfo(DSSCircObj);
%
% Initialize Fault Study Mode
DSSText.Command = 'Solve Mode=FaultStudy';

LineNames = DSSCircuit.Lines.AllNames;
for i = 1:length(LineNames)
    Lines(i).ID = LineNames{i};
    DSSCircuit.SetActiveElement(['Line.',LineNames{i}]);
    Lines(i).Bus1 = regexp(DSSCircuit.ActiveCktElement.BusNames{1},'^.*?(?=[.])','match');
    Lines(i).Bus2 = regexp(DSSCircuit.ActiveCktElement.BusNames{2},'^.*?(?=[.])','match');
    Lines(i).Phase = DSSCircuit.ActiveCktElement.NumPhases;
    Lines(i).Amps = DSSCircuit.ActiveCktElement.NormalAmps;
    
    DSSCircuit.SetActiveBus(Lines(i).Bus1{1});
    Lines(i).Distance = DSSCircuit.ActiveBus.Distance;
    Zsc = DSSCircuit.ActiveBus.Zsc1;
    Lines(i).Rsc = Zsc(1);
    Lines(i).Xsc = Zsc(2);
end
Lines = Lines([Lines.Phase] == 3); % Only 3 phase
Lines = Lines([Lines.Amps] > 480); % Only >480A Current Rating
[~,index] = sortrows([Lines.Distance].');
Lines = Lines(index);

% Commense Fault Study
DSSText.Command = 'New Fault.F1 enabled=no';

% Record Short Circuit Impedance and organize by Rsc
%Phase = {'A' 'B' 'C'};
%for p = 1:3
    for i = 1:length(Lines)
        % Fault Phase p on Bus1 of Line i
        DSSText.Command = 'Solve Mode=Snapshot';
        DSSText.Command = sprintf('Edit Fault.F1 Bus1=%s.%d enabled=yes',Lines(i).Bus1{1},2); %p);
        DSSText.Command = 'Solve Mode=dynamic number=1';
    
        DSSCircuit.SetActiveElement('Fault.F1');
        %Lines(i).(sprintf('Isc%c',Phase{p})) = DSSCircuit.ActiveCktElement.CurrentsMagAng(1);
        Lines(i).IscB = DSSCircuit.ActiveCktElement.CurrentsMagAng(1);
        DSSText.Command = 'Edit Fault.F1 enabled=no';
    end
%end

% 3 Phase Fault at Substaion
DSSText.Command = 'Solve Mode=Snapshot';
DSSText.Command = 'Edit Fault.F1 Bus1=commonwealth_ret_01311205.1.2.3 Phase=3';
DSSText.Command = 'Solve Mode=dynamic number=1';
DSSCircuit.SetActiveElement('Fault.F1');


% Problem 3 Plots
figure;
%plot([Lines.Rsc],[Lines.IscA],'-k',[Lines.Rsc],[Lines.IscB],'-r',[Lines.Rsc],[Lines.IscC],'-b')
plot([Lines.Rsc],[Lines.IscB],'-k')
grid on;
set(gca,'FontSize',10,'FontWeight','bold')
xlabel(gca,'Short Circuit Resistance [\Omega]','FontSize',12,'FontWeight','bold')
ylabel(gca,'Short Circuit Current [A]','FontSize',12,'FontWeight','bold')
title('Problem 3: SLG Fault Study on Phase B','FontWeight','bold','FontSize',12);
%legend('Phase A','Phase B','Phase C')