%function [Buses,Lines] = findpath_LP(bus1,bus2,Buses,Lines)
%{
findpath.m will find the shortest distance path between Bus1 and Bus2 in the graph
    defined by Buses (verticies) and Lines (edges)

Required Fields:
Buses
    .ID     - BusID

Lines
    .ID     - LineID
    .Length - Length of Line

--BIP-FORMULATION--
Parameters
Length  - length of edge; defined for all l in Lines

Decision Variables
a(i)    - 1 := node i belongs to path, 0 := else
b(ij)   - 1 := section ij belongs to path, 0 := else
c(ij)   - 1 := section ij is a cut edge, 0 := else

Objective Function
    min ( Lines.Length .* b )
    a,b

Constraints
(1) a(k) = 1, all k in {Bus1,Bus2}

(2) 2*b(ij) - a(i) - a(j) + c(ij) = 0, all ij in Lines

(3) |V| - |E| + |C| = |K|
    sum(a) -  sum(b) + 0 = 1
   i<Buses   ij<Lines

%}

v = length(Buses); % Number of Buses
e = length(Lines); % Number of Lines

% Let x = [a;b]
xint = repmat('B',1,v+2*e); % Constraint to be Binary
% Starting indicies
a = 0;
b = v;
c = v+e;

f = [zeros(v,1);[Lines.Length]';zeros(e,1)];
xlen = length(f);

% Formulate Constraints
% (1)
[~,~,ic] = unique([{Buses.ID},bus1,bus2],'stable');
[check,index] = max(ic);
if check>v % Check to see if bus1 & bus2 exist
    error('bus%d not recognized',index-v)
end

i1 = [1;2];
j1 = a+ic(end-1:end);
v1 = [1;1];
r1 = [1;1];
A1 = sparse(i1,j1,v1,2,xlen);

% (2)
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

i2 = reshape(repmat(1:e,4,1),[],1);
j2 = reshape([b+(1:e);a+index1(v+1:end)';a+index2(v+1:end)';c+(1:e)],[],1);
v2 = repmat([2;-1;-1;1],e,1);
r2 = zeros(e,1);
A2 = sparse(i2,j2,v2,e,xlen);

% (3)
i3 = ones(v+e,1);
j3 = (1:v+e)';
v3 = [ones(v,1);-ones(e,1)];
r3 = 1;
A3 = sparse(i3,j3,v3,1,xlen);
% Constraint (1)

% Solve BIP
[X,fval,exitflag,info] = opti_cplex([],f,[A1;A2;A3],[r1;r2;r3],[r1;r2;r3],zeros(xlen,1),ones(xlen,1),xint);

% Parse out solution
a = logical(X(a+1:a+v));
b = logical(X(b+1:b+e));
c = logical(X(c+1:c+e));

bus = Buses(logical(a));
lin = Lines(logical(b));