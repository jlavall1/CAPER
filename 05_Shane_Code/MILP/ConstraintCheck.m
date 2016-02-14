
N = length(NODE);       % Number of Nodes
S = length(SECTION);    % Number of Sections
D = length(DER);        % Number of DER
L = length(LOAD);       % Number of Loads

% Let x = [a;alpha;b;bbar;c;gamma], then
% a     = x[       1      :       n      ]
% alpha = x[      n+1     :    (d+1)*n   ]
% b     = x[   (d+1)*n+1  :   (d+1)*n+s  ]
% bbar  = x[    (d+1)*n+s+1 :   (d+1)*n+2s ]
% beta  = x[   (d+1)*n+2s+1 : (d+1)*n+(2+d)s  ]
% c     = x[ (d+1)*n+(2+d)s+1  :  (d+1)n+2s ]
% gamma = x[  (d+1)n+2s+1 : (2d+1)n+2s ]

% Define starting indicies
a       = 0;
alpha   = a+N;
b       = alpha+D*N;
bbar    = b+S;
beta    = bbar+S;
c       = beta+D*S;
gamma   = c+L*D;


for i = 1:N
    x{a+i} = sprintf('a_%s',NODE(i).ID);
    
    for j = 1:D
        x{alpha+(j-1)*N+i} = sprintf('alpha_%s_MG%d',NODE(i).ID,j);
    end
end

for i = 1:S
    x{b+i} = sprintf('b_%s_%s',SECTION(i).FROM,SECTION(i).TO);
    x{bbar+i} = sprintf('bbar_%s_%s',SECTION(i).FROM,SECTION(i).TO);
    for j = 1:D
        x{beta+i+(j-1)*S} = sprintf('beta_%s_%s_MG%d',SECTION(i).FROM,SECTION(i).TO,j);
    end
end

for i = 1:L
    for j = 1:D
        x{c+i+(j-1)*L} = sprintf('c_%s_MG%d',LOAD(i).ID,j);
    end
end

for i = 1:D
    x{gamma+i} = sprintf('gamma_MG%d',i);
end

save('xvars.mat','x')
%{
load('xvars.mat');
clear var
[n,~] = size(A);
for i = 1:n
    var(i) = {x(logical(A(i,:)))};
end
%}