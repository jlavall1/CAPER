function SimplifyGraph(node,section)
% SimplifyGraph.m takes a graph defined by NODE and SECTION and returns a
%  graph containing only the elements contained in node and section. The
%  reduced graph will maintain the electrical characteristics of the
%  origional graph to the highest degree possible

global NODE SECTION oNODE oSECTION
% Save Original graph for mapping
oNODE = NODE;
oSECTION = SECTION;

N = length(oNODE); % Number of Buses
S = length(oSECTION); % Number of Lines


% Verify that all elements in section are in SECTION
[~,~,ic] = unique([{oSECTION.ID},section],'stable');
SKEEP = ic(S+1:end);
[check,index] = max(ic);
if check>S
    error('section{%d} not recognized',index-S)
end

% Verify that all elements in node are in NODE
[~,~,ic] = unique([{oNODE.ID},node,{oSECTION(SKEEP).FROM},{oSECTION(SKEEP).TO}],'stable');
NKEEP = unique(ic(N+1:end));
[check,index] = max(ic);
if check>N
    error('node{%d} not recognized',index-N)
end

%% Build Adjacency List

% Break graph at nodes in node


[NODE.adj] = deal([]);
[NODE.close] = deal(0);
for i = 1:S
    if ~ismember(SECTION(i).ID,section) % Remove sections in section
        index1 = find(ismember({NODE.ID},SECTION(i).FROM));
        index2 = find(ismember({NODE.ID},SECTION(i).TO));
    
        NODE(index1).adj = [NODE(index1).adj, index2];
        NODE(index2).adj = [NODE(index2).adj, index1];
    end
end


%% Find Connected Components and Loops
global loop visited
i=1; j=1; k=1;
visited = [];
loop = {};
while i<=N
    if ~sum(i==visited)
        % Call DFS for unvisited nodes
        dfs(i,0);
        visited(end+1) = i;

        % Place all nodes visited in DFS into a connected group and count
        connected{j} = unique(visited(k:end),'stable');
        k = length(visited)+1;
        j = j+1;
    end
    i = i+1; % Move to next node
end


%% Create Reduced Graph
SECTION = oSECTION(SKEEP);
NODE = oNODE(NKEEP);
nkeep = length(NKEEP);

[NODE.kW] = deal(0);
[NODE.kVAR] = deal(0);

k = 1;
c = length(connected);

for i = 1:c
    % Find nodes to keep in connected component
    [~,~,ic] = unique([{NODE.ID},{oNODE(connected{i}).ID}],'stable');
    cindex = find(ic(nkeep+1:end)<=nkeep); % index of keep nodes in connected
    index = ic(nkeep+cindex); % index of keep nodes in NODE
    oindex = connected{i}(cindex); % index of keep nodes in oNODE
    n = length(index);
    
%     if sum(index==240)
%         i
%     end
    
    switch n
        case 1 % Only one node in cluster is to be kept
            % Method: Add all load to keep node (cluster+existing-old)
            NODE(index).kW   = sum([oNODE(connected{i}).kW])  +NODE(index).kW;
            NODE(index).kVAR = sum([oNODE(connected{i}).kVAR])+NODE(index).kVAR;
            NODE(index).kVA  = sqrt(NODE(index).kW^2+NODE(index).kVAR^2);
            NODE(index).pf   = NODE(index).kW/(NODE(index).kVA+eps);
            
            % Create Map between NODE and oNODE
            NODE(index).Map = connected{i};
            NODE(index).MapID = {oNODE(connected{i}).ID};
            
            [oNODE(connected{i}).Map] = deal(index);
            [oNODE(connected{i}).MapID] = deal(NODE(index).ID);
            
            
        case 2 % Two nodes in cluster are to be kept
            % Method: Add a single section between two nodes and divide
            % load between them
            SECTION(end+1).ID = sprintf('%09d',k);
            SECTION(end).FROM = NODE(index(1)).ID;
            SECTION(end).TO   = NODE(index(2)).ID;
            
            % Device, LineCode, Wires, Spacing...
            
            % Find new length of section
            %[SECTION(end).Length,~] = findpath(SECTION(end).FROM,SECTION(end).TO,Buses,Lines)
            
            for j = 1:length(connected{i})
                % Assign load to end points based on location formula
                %  d1/d2 - distance to node1/node2
                %  len   - length of path from node1 to node2
                %  com   - distance of path common between d1 and d2
                %           = (d1+d2-len)/2
                %  %L1   - percentance of load atributed to node1
                %           = (d2-com)/len
                %  %L2   - percentance of load atributed to node1
                %           = (d1-com)/len
                
            end
            
        otherwise
            disp('whoops')
            i
            
            
    end

    
    
    
end

