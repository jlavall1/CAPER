%function [NODE,SECTION,DER,DSCS] = DSSRead()
% Function to read Data from OpenDSS

%% Initialize
% Find the CAPER folder location (CAPER folder must be in MATLAB path)
fid = fopen('pathdef.m');
rootlocation = textscan(fid,'%c')';
rootlocation = regexp(rootlocation{1}','C:[^.]*?CAPER\\','match','once');

filename = 0;
load('COMMONWEALTH_Location.mat');
while ~filename
    [filename,filelocation] = uigetfile({'*.*','All Files'},'Select DSS Master File',...
        [rootlocation,'03_OpenDSS_Circuits\']);
end

% Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

% Compile and Solve the Circuit
DSSText.command = ['Compile ',[filelocation,filename]];
DSSText.command = 'solve';
DSSCircuit = DSSCircObj.ActiveCircuit;

%Lines_Base = getLineInfo(DSSCircObj);
%Buses_Base = getBusInfo(DSSCircObj);
%Loads_Base = getLoadInfo(DSSCircObj);

% Establish Headers for Return Variables
%HEADERS.NODE.DEMAND     = {'Phase A [kW]','Phase A [kVAR]'...
%    'Phase B [kW]','Phase B [kVAR]','Phase C [kW]','Phase C [kVAR]'};

%% Read in Element Names
% Get Node Names and Find Source Nodes
NODE.ID = DSSCircuit.AllBusNames;
DER.ID = NODE.ID(DSSCircuit.AllBusDistances == 0);
NODE.ID = NODE.ID(cellfun(@isempty,regexp(NODE.ID,'.*_reg'))); % Remove Regulator Nodes
DER.ID = DER.ID(cellfun(@isempty,regexp(DER.ID,'.*_reg'))); % Remove Regulator Nodes
N = length(NODE.ID); % Number of Nodes
D = length(DER.ID); % Number of DERs

% Get Section Names
Lines = DSSCircuit.Lines.AllNames;
S = length(Lines);

% Get Load Names
Loads = DSSCircuit.Loads.AllNames;
L = length(Loads); % Number of Loads

% Get Switch/Fuse Names
Fuses       = DSSCircuit.Fuses.AllNames;
Switches    = DSSCircuit.SwtControls.AllNames;

%% Read in Section DATA (SECTION.ID, SECTION.IMPEDANCE, SECTION.CAPACITY, DSCS.SC, DSCS.SO)
% Initialize Variables
SECTION.ID          = cell(S,2); % For Future: Have ID be section name and SECTION.NODE be node names
SECTION.IMPEDANCE   = zeros(S,6);
SECTION.CAPACITY    = zeros(S,3);
for i = 1:S
    % Set Active Element
    DSSCircuit.SetActiveElement(['Line.',Lines{i}]);
    DSSCircuit.Lines.Name = Lines{i};
    % to/from Node Names
    % Separate out Node IDs from Phase Indicators
    [Nodes,Phases] = regexp(DSSCircuit.ActiveElement.BusNames,'^.*?(?=[.])','match','split');
    SECTION.ID{i,1} = Nodes{1}{1}; SECTION.ID{i,2} = Nodes{2}{1};
    % Find phases
    Phases = regexp(Phases{1}{2},'\d','match');
    NumPhases = length(Phases);
    % Impedance Matricies
    Rmatrix = reshape(DSSCircuit.Lines.Rmatrix,NumPhases,[]);
    Xmatrix = reshape(DSSCircuit.Lines.Xmatrix,NumPhases,[]);
    Imax = DSSCircuit.Lines.NormAmps;
    for j = 1:NumPhases
        phase = str2num(Phases{j}); %#ok<ST2NM>
        % Line Impedance
        SECTION.IMPEDANCE(i,2*phase-1) = Rmatrix(j,j);
        SECTION.IMPEDANCE(i,2*phase)   = Xmatrix(j,j);
        % Line Capacity
        SECTION.CAPACITY(i,phase) = Imax;
    end
    
    
    % Switching Constraints
    
end

%% Read in Node DATA (NODE.WEIGHT)
NODE.WEIGHT = ones(N,1); % Currently weight is set to be equal for all nodes

%% Read in Load DATA (NODE.DEMAND,...)
NODE.DEMAND = zeros(N,6);
for i = 1:L
    phase = str2num(Loads{i}(end)); %#ok<ST2NM>   Determine Load Phase (1-A,2-B,3-C)
    % Locate Node in NODE.ID
    NodeIndex = find(~cellfun(@isempty,regexp(NODE.ID,Loads{i}(1:end-2))));
    % Check to see if Load Exists
    if isempty(NodeIndex)
        warning('Load.%s Not Found',Loads{i})
    else
        % Set Load Active and Read Real/Reactive Demand
        DSSCircuit.SetActiveElement(['Load.',Loads{i}]);
        % DEMAND: Nx6 Matrix
        % phase A | phase B | phase C
        %   p  q  |   p  q  |   p  q
        Powers = DSSCircuit.ActiveElement.Power;
        NODE.DEMAND(NodeIndex,2*phase-1) = Powers(1);
        NODE.DEMAND(NodeIndex,2*phase)   = Powers(2);
    end
    
    
end

%% Find Parent/Child Relationships for each node
% Make Copy of Section IDs
NODE.PARENT = cell(N,D);
for i = 1:D
    Sections = SECTION.ID;
    % Find Section Connected to DER
    SectionIndex = find(~cellfun(@isempty,regexp(Sections,DER.ID{i})));
    
    while ~isempty(Sections) % Loop until All sections have been assigned a Parent and Child
        for j = 1:length(SectionIndex) % For all sections attached to given node
            % Set Indexed Node as Parent of Paired Non-Indexed Node
            NODE.PARENT{find(~cellfun(@isempty,regexp(NODE.ID,...
                Sections{mod(SectionIndex,S),SectionIndex<S+1}))),i} = Sections{SectionIndex};
            % Set Non-Indexed Node as Child of Section
            
            % Delete Section
            Sections(mod(SectionIndex,S),:) = [];
        end
        
    end
end

[capacity_kva,DER.ID,~] = xlsread(filename,'Nodes',['P2:Q',num2str(n+1)]);
% Assuming a minimum power factor of 0.95
pf = 0.95;
DER.CAPACITY = [pf*capacity_kva,(1-pf^2)*capacity_kva];

[~,~,raw2] = xlsread(filename,'Sections',['B2:P',num2str(n)]);

SECTION.ID          = raw2(:,1:2);
SECTION.IMPEDANCE   = cell2mat(raw2(:,3:4));
SECTION.CAPACITY    = cell2mat(raw2(:,5));
SECTION.CHILD       = raw2(:,10:15);

% Generate DSCS
PARAM.SC = find(~cell2mat(raw2(:,6)));   % SECTION CONSTRAINED CLOSED (no switch)
PARAM.SO = [3;7;14];                     % SECTION CONSTRAINED OPEN (faulted sections)
PARAM.NC = [];                           % LOAD CONSTRAINED CLOSED
PARAM.NO = [];                           % LOAD CONSTRAINED OPEN

% Check intersection of SO & SC (remove duplicates from SC)
dup = intersect(PARAM.SC,PARAM.SO);
for i = 1:length(dup)
    PARAM.SC = PARAM.SC(PARAM.SC~=dup(i));
end

% Check intersection of SO & SC (remove duplicates from SC)
dup = intersect(PARAM.SC,PARAM.SO);
for i = 1:length(dup)
    PARAM.SC = PARAM.SC(PARAM.SC~=dup(i));
end

% Other Parameters
PARAM.VOLTAGE = [12.47,0.05];   % [Ref Voltage (kV), Tolerance]

