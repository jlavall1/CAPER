function dfs(node1,parent)
    global NODE visited loop
    if sum(node1==visited)
        loop{end+1}=[visited(find(visited==node1,1,'last'):end),node1];
        index = true(size(loop{end}));
        for i = 2:length(loop{end})-1
            dup = find(ismember(loop{end}(i+1:end),loop{end}(i)),1,'last');
            index(i+1:i+dup) = false;
        end
        loop{end} = loop{end}(index);
        NODE(node1).close = parent;
        return
    end
    
    adj = NODE(node1).adj(NODE(node1).adj~=parent); % Exclude parent
    for i = 1:length(adj) % for all adjacent nodes to node 1
        if ~adj(i)==NODE(node1).close
            visited(end+1)=node1;
            dfs(adj(i),node1);
        end
    end
end