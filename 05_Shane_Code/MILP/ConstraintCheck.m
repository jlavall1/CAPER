N = length({NODE.ID});    % Number of Nodes
S = length({SECTION.ID}); % Number of Sections
D = length({DER.ID});     % Number of DER

% Let x = [a;b;c;gamma;d], then
% a     = x[       1      :     n      ]
% b     = x[      n+1     :    n+s     ]
% beta  = x[     n+s+1    :    n+2s    ]
% c     = x[    n+2s+1    :  (d+1)n+2s ]
% gamma = x[  (d+1)n+2s+1 : (2d+1)n+2s ]
% d     = x[ (2d+1)n+2s+1 : (2d+1)n+3s ]

% Define starting indicies
a       = 0;
b       = N;
beta    = N+S;
c       = N+2*S;
gamma   = (D+1)*N+2*S;
d       = (2*D+1)*N+2*S;

xlen = length(f);

for i = 1:N
    x{a+i} = sprintf('a_%s',NODE(i).ID);
    
    for j = 1:D
        x{c+(j-1)*N+i} = sprintf('c_%s_%s',NODE(i).ID,DER(j).ID);
        x{gamma+(j-1)*N+i} = sprintf('gamma_%s_%s',NODE(i).ID,DER(j).ID);
    end
end

for i = 1:S
    x{b+i} = sprintf('b_%s_%s',SECTION(i).FROM,SECTION(i).TO);
    x{beta+i} = sprintf('beta_%s_%s',SECTION(i).FROM,SECTION(i).TO);
    x{d+i} = sprintf('d_%s_%s',SECTION(i).FROM,SECTION(i).TO);
end

clear var
[n,~] = size(A);
for i = 1:n
    var(i) = {x(logical(A(i,:)))};
end