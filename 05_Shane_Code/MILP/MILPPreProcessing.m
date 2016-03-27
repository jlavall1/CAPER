function MILPPreProcessing
global NODE SECTION PARAM

% Find Adjacent Edge Representation of Graph
[NODE.adj] = deal([]);
[NODE.close] = deal(0);
for i = 1:length(SECTION)
    index1 = find(ismember({NODE.ID},SECTION(i).FROM));
    index2 = find(ismember({NODE.ID},SECTION(i).TO));
    
    NODE(index1).adj = [NODE(index1).adj, index2];
    NODE(index2).adj = [NODE(index2).adj, index1];
end

% Run Depth-first Search Algoritm to find Loops
global visited loop
visited = [];
loop = {};
dfs(1,0)

% Find Section IDs for each Loop
S = length(SECTION);
for i = 1:length(loop)
    n = length(loop{i}); % Number of nodes in loop (start & end on same node)
    
    [~,~,ic] = unique([{NODE(loop{i}).ID},{SECTION.FROM},{SECTION.TO}],'stable');
    PARAM.Loops{i} = {SECTION(ic(n+1:n+S)<=n & ic(n+S+1:n+2*S)<=n).ID};
end

disp('end')
