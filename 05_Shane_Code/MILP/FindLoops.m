% Find all loops in NODES
clear

global NODE visited loop

[NODE,SECTION,~,~,~,~] = sxstRead;

[NODE.adj] = deal([]);
[NODE.close] = deal(0);
for i = 1:length(SECTION)
    index1 = find(ismember({NODE.ID},SECTION(i).FROM));
    index2 = find(ismember({NODE.ID},SECTION(i).TO));
    
    NODE(index1).adj = [NODE(index1).adj, index2];
    NODE(index2).adj = [NODE(index2).adj, index1];
end

%NODE = struct('ID',{'1' '2' '3' '4' '5' '6' '7' '8' '9'},...
%    'adj',{[2 6] [1 3 5] [2 4] [3 5 8] [2 4 9] [1 7 9] [6 8] [4 7 9] [5 6 8]});

visited = [];
loop = {};

dfs(1,0)

% Plot Loops
DSSInitialize
DSSText.Command = 'BatchEdit Line..* enable=yes';
DSSCircuit.Solution.Solve
figure; plotCircuitLines(DSSCircObj,'Coloring','numPhases')
hold on
cmp = colormap;
k = length(loop);
%for i = 1:k
i = 9;
    plot([NODE(loop{i}).XCoord],[NODE(loop{i}).YCoord],'o','Color',cmp(round(i*60/k),:))
%end