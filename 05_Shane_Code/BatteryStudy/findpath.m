function [param,BusNames] = findpath(bus1,bus2,Buses,Lines,Weight)
% findpath.m finds the shortest path between two nodes given by bus1 and
%  bus2. The Set of nodes and sections are stored in Buses.ID and
%  Lines.Bus1/Lines.Bus2. by default, the lengths of each edge saved in
%  Lines.Length will be used to find the path. Optionally, findpath.m can
%  use another edge weight defined by Weight.

v = length(Buses); % Number of Buses
e = length(Lines); % Number of Lines

% Verify that bus1 and bus2 exist
[~,~,ic] = unique([{Buses.ID},bus1,bus2],'stable');
[check,index] = max(ic);
if check>v
    error('bus%d not recognized',index-v)
end

% Create Graph Matrix

FROM = regexp([Lines.Bus1],'(?<ID>\w+)([.][123]{1})+','names');
TO   = regexp([Lines.Bus2],'(?<ID>\w+)([.][123]{1})+','names');
[~,~,index1] = unique([{Buses.ID},{FROM.ID}],'stable');
[~,~,index2] = unique([{Buses.ID},{TO.ID}],'stable');
[check,index] = max([index1;index2]);
if check>v
    linERR = mod(index-1,e+v)+1-v;
    busERR = floor((index-1)/(e+v))+1;
    error('Line %d bus%d not recognized',linERR,busERR)
end

i = [index1(v+1:end);index2(v+1:end)];
j = [index2(v+1:end);index1(v+1:end)];
v = [[Lines.Length]';[Lines.Length]'];
G = sparse(i,j,v);

[dist,path,~] = graphshortestpath(G,ic(end-1),ic(end));

BusNames = {Buses(path).ID};

if nargin<=4
    param = dist;
else
    H = sparse(i,j,[Weight;Weight]);
    param = 0;
    for i = 1:length(path)-1
        param = param+H(path(i),path(i+1));
    end
end
