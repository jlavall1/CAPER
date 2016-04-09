function BatteryPreProcessing()

global NODE SECTION visited loop

% Save Current graph for mapping
global oNODE oSECTION
oNODE = NODE;
oSECTION = SECTION;

[NODE.adj] = deal([]);
[NODE.close] = deal(0);
for i = 1:length(SECTION)
    % Remove 3 phase lines and Open Points
    if SECTION(i).numPhase~=3 && SECTION(i).NormalStatus
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
        S = length(SECTION);
        n = length(connected{j});
        [~,~,ic] = unique([{NODE(connected{j}).ID},{SECTION.FROM},{SECTION.TO}],'stable');
        SECTION = SECTION(ic(n+1:n+S)>n | ic(n+S+1:n+2*S)>n);
        
        k = length(visited)+1;
        j = j+1;
    end
    i = i+1; % Move to next node
end

% Create New Nodes and Sections
N = length(connected);
S = length(SECTION);

NODE = struct('Map',connected);
for i = 1:N
    [oNODE(connected{i}).Map] = deal(i);
    [oNODE(connected{i}).MapID] = deal(sprintf('%04d',i));
    
    NODE(i).ID = sprintf('%04d',i);
    NODE(i).MapID = {oNODE(connected{i}).ID};
    NODE(i).XCoord = mean([oNODE(connected{i}).XCoord]);
    NODE(i).YCoord = mean([oNODE(connected{i}).YCoord]);
    NODE(i).kW   = sum([oNODE(connected{i}).kW]);
    NODE(i).kVAR = sum([oNODE(connected{i}).kVAR]);
    NODE(i).kVA  = sqrt(NODE(i).kW^2+NODE(i).kVAR^2);
    NODE(i).pf   = NODE(i).kW/(NODE(i).kVA+eps);
end

for i = 1:S
    index = {find(ismember({oNODE.ID},SECTION(i).FROM),1,'first'),...
        find(ismember({oNODE.ID},SECTION(i).TO),1,'first')};
    
    SECTION(i).FROM = oNODE(index{1}).MapID;
    SECTION(i).TO   = oNODE(index{2}).MapID;
end

%disp('end')
    

