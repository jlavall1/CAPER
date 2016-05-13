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
    n = length(loop{i}); % Number of nodes in loop
    
    PARAM.Loop(i).NODE = {NODE(loop{i}).ID};
    [~,~,ic] = unique([{NODE(loop{i}).ID},{SECTION.FROM},{SECTION.TO}],'stable');
    PARAM.Loop(i).SECTION = {SECTION(ic(n+1:n+S)<=n & ic(n+S+1:n+2*S)<=n).ID};
end

% Combine cycles with shared edges
[PARAM.Loop.Num] = deal(1);
i = 1;
while i <= length(PARAM.Loop)
    j = i+1;
    while j <= length(PARAM.Loop)
        A = [PARAM.Loop(i).SECTION,PARAM.Loop(j).SECTION];
        C = unique(A);
        if length(C)<length(A)
            PARAM.Loop(i).SECTION = C;
            PARAM.Loop(i).NODE = unique([PARAM.Loop(i).NODE,PARAM.Loop(j).NODE]);
            PARAM.Loop(i).Num = PARAM.Loop(i).Num + 1;
            PARAM.Loop(j) = [];
        else
            j = j+1;
        end
    end
    i = i+1;
end


% Add origional Loops back in
% S = length(SECTION);
% for i = 1:length(loop)
%     n = length(loop{i}); % Number of nodes in loop
%     
%     PARAM.Loop(end+1).NODE = {NODE(loop{i}).ID};
%     [~,~,ic] = unique([{NODE(loop{i}).ID},{SECTION.FROM},{SECTION.TO}],'stable');
%     PARAM.Loop(end).SECTION = {SECTION(ic(n+1:n+S)<=n & ic(n+S+1:n+2*S)<=n).ID};
%     PARAM.Loop(end).Num = 1;
% end
