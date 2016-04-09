function BatteryPreProcessing()
% Reduce Graph to only include the sections between the Sub and each PV.
%  These will be the only PCC's considers for the BESS

global NODE SECTION visited loop

% Save Current graph for mapping
global oNODE oSECTION
oNODE = NODE;
oSECTION = SECTION;

% Find all PCC Buses
toc
disp('Finding BESS Locations...')

SubBus = 'FLAY_RET_16271201';
PVBus = {'260007367' '258406388'};
NPCC = {};
for i = 1:length(PVBus)
    [~,Path] = findpath(SubBus,PVBus{i},NODE,SECTION);
    NPCC = unique([NPCC,Path]);
end
clear Path

% Find all Sections in PCC path
S = length(SECTION);
npcc = length(NPCC);
[~,~,ic] = unique([NPCC,{SECTION.FROM},{SECTION.TO}],'stable');
SPCC = ic(npcc+1:npcc+S)<=npcc & ic(npcc+S+1:npcc+2*S)<=npcc;

[NODE.adj] = deal([]);
[NODE.close] = deal(0);
for i = 1:length(SECTION)
    % Remove Sectins in the PCC path
    %if SECTION(i).numPhase~=3 && SECTION(i).NormalStatus
    if ~SPCC(i)
        index1 = find(ismember({NODE.ID},SECTION(i).FROM));
        index2 = find(ismember({NODE.ID},SECTION(i).TO));
    
        NODE(index1).adj = [NODE(index1).adj, index2];
        NODE(index2).adj = [NODE(index2).adj, index1];
    end
end

% Find all Connected components
i=1; j=1; k=1;
visited = [];
loop = {};
while i<length(NODE)
    if ~sum(i==visited)
        % Call DFS for unvisited nodes
        dfs(i,0);
        visited(end+1) = i;

        % Place all nodes visited in DFS into a connected group
        connected{j} = unique(visited(k:end),'stable');
        
        % Remove Sections contained within Connected component
        n = length(connected{j});
        [~,~,ic] = unique([{NODE(connected{j}).ID},{SECTION.FROM},{SECTION.TO}],'stable');
        SECTION = SECTION(ic(n+1:n+S)>n | ic(n+S+1:n+2*S)>n);
        S = length(SECTION); % Update section length
        
        k = length(visited)+1;
        j = j+1;
    end
    i = i+1; % Move to next node
end

% Create New Nodes and Sections
N = length(connected);

NODE = struct('Map',connected);
for i = 1:N
    % Find PCC Node
    [~,~,ic] = unique([NPCC,{oNODE(connected{i}).ID}],'stable');
    index = ic(npcc+1:end)<=npcc;
    if sum(index)~=1
        error('Must have exactly 1 PCC Nodes')
    end
    
    %NODE(i).ID = sprintf('%04d',i);
    NODE(i).ID = oNODE(connected{i}(index)).ID;
    NODE(i).MapID = {oNODE(connected{i}).ID};
    NODE(i).XCoord = oNODE(connected{i}(index)).XCoord;
    NODE(i).YCoord = oNODE(connected{i}(index)).YCoord;
    NODE(i).kW   = sum([oNODE(connected{i}).kW]);
    NODE(i).kVAR = sum([oNODE(connected{i}).kVAR]);
    NODE(i).kVA  = sqrt(NODE(i).kW^2+NODE(i).kVAR^2);
    NODE(i).pf   = NODE(i).kW/(NODE(i).kVA+eps);
    
    [oNODE(connected{i}).Map] = deal(i);
    [oNODE(connected{i}).MapID] = deal(NODE(i).ID);
end

for i = 1:S
    index = {find(ismember({oNODE.ID},SECTION(i).FROM),1,'first'),...
        find(ismember({oNODE.ID},SECTION(i).TO),1,'first')};
    
    SECTION(i).MapFROM = SECTION(i).FROM;
    SECTION(i).MapTO = SECTION(i).TO;
    
    SECTION(i).FROM = oNODE(index{1}).MapID;
    SECTION(i).TO   = oNODE(index{2}).MapID;
    SECTION(i).Bus1 = [SECTION(i).FROM,'.1.2.3'];
    SECTION(i).Bus2 = [SECTION(i).TO,'.1.2.3'];
end

%disp('end')
    

