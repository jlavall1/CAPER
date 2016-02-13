function [f,intcon,Aineq,bineq,Aeq,beq,lb,ub] = ResiliencyMILPForm(NODE,SECTION,LOAD,DER,PARAM)
% N                 - NODE.ID
% S                 - (SECNTION.FROM,SECTION.TO)
% D                 - DER.ID
% w                 - NODE.w
% p                 - NODE.p
% q                 - NODE.q
% KVAmax_d          - DER.CAPACITY
% alpha             - 1
eta = 1;
pf = 0.85;
M = 5;

N = length(NODE);       % Number of Nodes
S = length(SECTION);    % Number of Sections
D = length(DER);        % Number of DER
L = length(LOAD);      % Number of Loads

%%
%            max                    sum(w_i * sum(c_id*p_i))
% a,alpha,b,bbar,beta,c,gamma       i<N       d<D

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

f_a     = zeros(N,1);
f_alpha = zeros(D*N,1);
f_b     = zeros(S,1);
f_bbar  = ones(S,1);
f_beta  = zeros(D*S,1);
f_c     = repmat([LOAD.w]'.*[LOAD.p]',D,1);
f_gamma = zeros(D,1);

f = [f_a;f_alpha;f_b;f_bbar;f_beta;f_c;f_gamma];

xlen = length(f);

%% Set variable bounds/binary constraints
% All Variables are binary
lb = zeros(xlen,1);
ub = ones (xlen,1);
intcon = 1:xlen;

%%  Constraints
% -DSCC-(1)-to-(4)---------------------------------------------------------
% (1) Nodes constrained open      (a_i = 0 Vi<NO)       ---UNUSED---
% (2) Nodes constrained closed    (a_i = 1 Vi<NC)       ---FIX CP---
% (3) Sections constrained open   (b_ij = 0 V(i,j)<SO)  ---FAULTS---
% (4) Sections constrained closed (b_ij = 1 V(i,j)<SC)  ---NO SWI---

NO = length(PARAM.NO);
NC = length(PARAM.NC);
SO = length(PARAM.SO);
SC = length(PARAM.SC);

% Remove Duplicates
[~,~,ic] = unique([PARAM.SC,PARAM.SO],'stable');
index = ic(end-SO+1:end);
PARAM.SC(:,index(index<SC)) = [];
SC = length(PARAM.SC);

[~,~,ic] = unique([PARAM.NC,PARAM.NO],'stable');
index = ic(end-NO+1:end);
PARAM.SC(:,index(index<NC)) = [];
NC = length(PARAM.NC);

b1 = zeros(NO,1);
b2 = ones (NC,1);
b3 = zeros(SO,1);
b4 = ones (SC,1);

A1 = zeros(NO,xlen);
A2 = zeros(NC,xlen);
A3 = zeros(SO,xlen);
A4 = zeros(SC,xlen);

for i = 1:NO
    % Find index of constrained node
    index = find(ismember({NODE.ID},PARAM.NO{i}));
    
    A1(i,a+index) = 1; % coeff for a_i (1)
end

for i = 1:NC
    % Find index of constrained node
    index = find(ismember({NODE.ID},PARAM.NC{i}));
    
    A2(i,a+index) = 1; % coeff for a_i (2)
end

for i = 1:SO
    % Find index of constrained section
    index = find(ismember({SECTION.ID},PARAM.SO{i}));
    
    A3(i,b+index) = 1; % coeff for b_ij (3)
end

for i = 1:SC
    % Find index of constrained section
    index = find(ismember({SECTION.ID},PARAM.SC{i}));
    
    A4(i,b+index) = 1; % coeff for b_ij (4)
end

% -DSCS-(6)-to-(9)----------------------------------------------------------
% (6)    bbar_ij - b_ij <= n_ij       all (i,j) in S
% (7) -( bbar_ij - b_ij ) <= n_ij     all (i,j) in S
% (8) -( bbar_ij + b_ij ) <= - n_ij   all (i,j) in S
% (9)    bbar_ij + b_ij <= 2 - n_ij   all (i,j) in S

b6 = [SECTION.NormalStatus]';
b7 = [SECTION.NormalStatus]';
b8 = -[SECTION.NormalStatus]';
b9 = 2*ones(S,1)-[SECTION.NormalStatus]';

A6 = zeros(S,xlen);
A6(:,bbar+1:bbar+S) = eye(S); % coeff for beta_ij (6)
A9 = A6; % coeff for beta_ij (9)
A6(:,b+1:b+S) = -eye(S); % coeff for b_ij (6)
A7 = sparse(-A6); % coeff for beta_ij, b_ij (7)
A9(:,b+1:b+S) = eye(S); % coeff for b_ij (9)
A8 = sparse(-A9); % coeff for beta_ij, b_ij (8)

A6 = sparse(A6);
A9 = sparse(A9);

% -MCC-(13)-to-(15)----------------------------------------------------------
% (13)  c_id - gamma_id <= 0         all i in L, d in D
% (14)  c_id - a_i <= 0              all i in L, d in D
% (15) -c_id + gamma_id + a_i <= 1   all i in L, d in D

b11 = zeros(D*N,1); 
b12 = zeros(D*N,1);
b13 = ones (D*N,1);

A11 = zeros(D*N,xlen);
A11(:,c+1:c+D*N) = eye(D*N); % coeff for c_id (13)
A12 = A11; % coeff for c_id (14)
A12(:,a+1:a+N) = repmat(-eye(N),D,1); % coeff for a_i (12)
A11(:,gamma+1:gamma+D*N) = -eye(D*N); % coeff for gamma_id (11)
A13 = -A11; % coeff for c_id, gamma_id (13)
A13(:,a+1:a+N) = repmat(eye(N),D,1); % coeff for a_i (13)

% -MCC-(16)--VDC-(20)-&-(21)---------------------------------------
% (16) eta * sum( c_ig p_i) - sum( alpha_dg KVAmax_d ) <= 0    all g in G
%      i<L                     d<D

b16 = sparse([],[],[],D,1);

[~,~,ic] = unique([{NODE.ID},{DER.ID}],'stable');
index = ic(end-D+1:end);

i16 = [reshape(repmat(1:D,L,1),[],1);reshape(repmat(1:D,D,1),[],1)];
j16 = [c+(1:D*L)';alpha+reshape(repmat(N*(0:D-1),D,1)+repmat(index,1,D),[],1)];
v16 = [repmat(eta*[LOAD.p]'/pf,D,1);repmat(-[DER.CAPACITY]',D,1)];
A16 = sparse(i16,j16,v16,D,xlen);

%{
A16 = zeros(D,xlen);

temp = eta*[LOAD.p]/pf;
for i = 1:D
    A16(i,c+(i-1)*L+1:c+i*L) = temp;  % coeff for c_ig,  g constant (16)
    A16(i,alpha+(i-1)*N+index) = -[DER.CAPACITY]; % coeff for alpha_dg,  g constant (16)
end
clear temp
%}






Aineq = [A6;A7;A8;A9;A11;A12;A13;A16;A15;A17;A19;A20;A26;A29;A30];
bineq = [b6;b7;b8;b9;b11;b12;b13;b16;b15;b17;b19;b20;b26;b29;b30];

Aeq = [A1;A2;A3;A4;A16;A21];
beq = [b1;b2;b3;b4;b16;b21];