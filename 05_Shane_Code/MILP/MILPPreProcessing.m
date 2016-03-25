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

PARAM.Loops = loop;
