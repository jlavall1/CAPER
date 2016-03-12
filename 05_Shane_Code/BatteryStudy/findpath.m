function BusNames = findpath(bus1,bus2,Buses,Lines)

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
    linERR = mod(index-1,e+v)+1;
    busERR = floor((index-1)/(e+v))+1;
    error('Line %d bus%d not recognized',linERR,busERR)
end

i = [index1(v+1:end)';index2(v+1:end)'];
j = [index2(v+1:end)';index1(v+1:end)'];
v = [Lines.Length,Lines.Length]';
G = sparse(i,j,v);

[~,path,~] = graphshortestpath(G,ic(end-1),ic(end));

BusNames = {Buses(path).ID};

