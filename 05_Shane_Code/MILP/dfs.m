function dfs(node1,parent)
    global NODE visited loop
    if sum(node1==visited)
        loop{end+1}=[visited(find(visited==node1,1,'last'):end),node1];
        return
    end
    visited(end+1)=node1;
    adj = NODE(node1).adj(NODE(node1).adj~=parent); % Exclude parent
    for i = 1:length(adj) % for all adjacent nodes to node 1
        dfs(adj(i),node1);
    end
end