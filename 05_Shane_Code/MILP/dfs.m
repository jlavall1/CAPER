function dfs(node,parent)
    global NODE visited loop

    if sum(node==visited) % Node has already been visited
        % Any node that has dfs called on it twice closes a loop
        % Find the previous visit
        loop{end+1} = visited(find(visited==node,1,'last'):end);
        
        % Removed repeated nodes in path
        index = true(size(loop{end})); % true-node is in loop/false-o.w.
        for i = 2:length(loop{end})-1
            % Find index of duplicate node if it exists
            dup = find(ismember(loop{end}(i+1:end),loop{end}(i)),1,'last');
            index(i+1:i+dup) = false;
        end
        loop{end} = loop{end}(index);
        
        % Designate a close edge to prevent loop from being tagged again
        NODE(node).close = parent;
    else

        visited(end+1) = node;
        
        % Visit All Adjacent Nodes
        adj = NODE(node).adj(NODE(node).adj~=parent); % Exclude parent
        for i = 1:length(adj) % for all nodes adjacent node
            if ~(adj(i)==NODE(node).close) % Do not revist close edges
                dfs(adj(i),node);
                visited(end+1)=node;
            end
        end
    end
end