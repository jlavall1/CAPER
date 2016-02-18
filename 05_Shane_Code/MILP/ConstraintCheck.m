
N = length(NODE);       % Number of Nodes
S = length(SECTION);    % Number of Sections
D = length(DER);        % Number of DER
L = length(LOAD);       % Number of Loads

% Let x = [a;alpha;b1;b2;bbar;c;gamma], then
% a     = x[           1           :           N           ]
% alpha = x[          N+1          :        (D+1)*N        ]
% b1    = x[       (D+1)*N+1       :       (D+1)*N+S       ]
% b2    = x[      (D+1)*N+S+1      :      (D+1)*N+2*S      ]
% bbar  = x[     (D+1)*N+2*S+1     :      (D+1)*N+3*S      ]
% beta  = x[     (D+1)*N+3*S+1     :    (D+1)*N+(3+D)*S    ]
% c     = x[   (D+1)*N+(3+D)*s+1   :   (D+1)*N+(3+D)*S+L   ]
% gamma = x[  (D+1)*N+(3+D)*S+L+1  :  (D+1)*N+(3+D)*S+L+D  ]

% Define starting indicies
a       = 0;
alpha   = a+N;
B1      = alpha+D*N;
B2      = B1+S;
bbar    = B2+S;
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
    x{B1+i} = sprintf('b1_%s_%s',SECTION(i).FROM,SECTION(i).TO);
    x{B2+i} = sprintf('b2_%s_%s',SECTION(i).FROM,SECTION(i).TO);
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