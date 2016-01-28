function [f,intcon,Aineq,bineq,Aeq,beq,lb,ub] = ResiliencyMILPForm(NODE,SECTION,DER,PARAM)
% N                 - NODE.ID
% S                 - (SECNTION.FROM,SECTION.TO)
% D                 - DER.ID
% w                 - NODE.w
% p                 - NODE.p
% q                 - NODE.q
% KVAmax_d          - DER.CAPACITY
% alpha             - 1
alpha = 1;
pf = 0.85;
M = 5;

N = length({NODE.ID});    % Number of Nodes
S = length({SECTION.ID}); % Number of Sections
D = length({DER.ID});     % Number of DER

%%
%     max             sum(w_i * sum(c_id*p_i))
% a,b,c,gamma,d       i<N       d<D

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

f_a     = zeros(N,1);
f_b     = zeros(S,1);
f_beta  = ones(S,1);
f_c     = -ones(N*D,1) - repmat([NODE.w]'.*[NODE.p]',D,1);
f_gamma = zeros(D*N,1);
f_d     = zeros(S,1);

f = [f_a;f_b;f_beta;f_c;f_gamma;f_d];

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
    
    A2(i,a+index) = 1; % coeff for a_i (1)
end

for i = 1:NC
    % Find index of constrained node
    index = find(ismember({NODE.ID},PARAM.NC{i}));
    
    A2(i,a+index) = 1; % coeff for a_i (2)
end

for i = 1:SO
    % Find index of constrained section
    index = find(ismember({SECTION.ID},PARAM.SO{i}));
    
    A4(i,b+index) = 1; % coeff for b_ij (3)
end

for i = 1:SC
    % Find index of constrained section
    index = find(ismember({SECTION.ID},PARAM.SC{i}));
    
    A4(i,b+index) = 1; % coeff for b_ij (4)
end

% -DSCS-(6)-to-(9)----------------------------------------------------------
% (6)    beta_ij - b_ij <= n_ij       all (i,j) in S
% (7) -( beta_ij - b_ij ) <= n_ij     all (i,j) in S
% (8) -( beta_ij + b_ij ) <= - n_ij   all (i,j) in S
% (9)    beta_ij + b_ij <= 2 - n_ij   all (i,j) in S

b6 = [SECTION.NormalStatus]';
b7 = [SECTION.NormalStatus]';
b8 = -[SECTION.NormalStatus]';
b9 = 2*ones(S,1)-[SECTION.NormalStatus]';

A6 = zeros(S,xlen);
A6(:,beta+1:beta+S) = eye(S); % coeff for beta_ij (6)
A9 = A6; % coeff for beta_ij (9)
A6(:,b+1:b+S) = -eye(S); % coeff for b_ij (6)
A7 = -A6; % coeff for beta_ij, b_ij (7)
A9(:,b+1:b+S) = eye(S); % coeff for b_ij (9)
A8 = -A9; % coeff for beta_ij, b_ij (8)

% -MCC-(11)-to-(13)----------------------------------------------------------
% (11)  c_id - gamma_id <= 0         all i in N, d in D
% (12)  c_id - a_i <= 0              all i in N, d in D
% (13) -c_id + gamma_id + a_i <= 1   all i in N, d in D

b11 = zeros(D*N,1); 
b12 = zeros(D*N,1);
b13 = ones (D*N,1);

A11 = zeros(D*N,xlen);
A11(:,c+1:c+D*N) = eye(D*N); % coeff for c_id (11)
A12 = A11; % coeff for c_id (12)
A12(:,a+1:a+N) = repmat(-eye(N),D,1); % coeff for a_i (12)
A11(:,gamma+1:gamma+D*N) = -eye(D*N); % coeff for gamma_id (11)
A13 = -A11; % coeff for c_id, gamma_id (13)
A13(:,a+1:a+N) = repmat(eye(N),D,1); % coeff for a_i (13)

% -MCC-(14)-to-(16)--VDC-(20)-&-(21)---------------------------------------
% (14) sum(alpha s_i c_id) <= KVAmax_d  all d in D
%      i<N
% (15) sum(gamma_id) <= 1               all i in N
%      d<D
% (16) gamma_dd = 1                     all d in D
% (20) d_ij - b_ij <= 0                 all (i,j) in S
% (21) d_dj - b_dj = 0                  all (d,j) in S, d in D
%      d_id = 0                         all (i,d) in S, d in D

% index = { id  dj }

b14 = [DER.CAPACITY]'; % CHECK TO SEE IF ORIENTED CORRECTLY
b15 = ones(N,1);
b16 = ones(D,1);
b20 = zeros(S,1);

A14 = zeros(D,xlen);

A15 = zeros(N,xlen);
A15(:,gamma+1:gamma+D*N) = repmat(eye(N),1,D); % coeff for gamma_id (15)

A16 = zeros(D,xlen);

A20 = zeros(S,xlen);
A20(:,d+1:d+S) = eye(S); % coeff for d_ij (20)
A20(:,b+1:b+S) = -eye(S); % coeff for b_ij (20)

A21 = zeros(1,xlen);

temp = alpha*[NODE.p]/pf;
j = 1;
for i = 1:D
    A14(i,c+(i-1)*N+1:c+i*N) = temp;  % coeff for c_id  all i in N, d constant (14)
    
    % Find node index of DER
    index = find(ismember({NODE.ID},DER(i).ID));
    
    A16(i,gamma+(i-1)*d+index) = 1;  % coeff for gamma_dd (16)
    
    % Find section index of all sections adjacent to DER
    index = {find(ismember({SECTION.FROM},DER(i).ID)),...
        find(ismember({SECTION.TO},DER(i).ID))};
    
    while ~isempty(index{1})
        A21(j,d+index{1}(1)) = 1; % coeff for d_dj (21.1)
        A21(j,b+index{1}(1)) = -1; % coeff for b_dj (21.1)
        index{1}(1) = [];
        
        j = j+1;
    end
    
    while ~isempty(index{2})
        A21(j,d+index{2}(1)) = 1; % coeff for d_id (21.2)
        index{2}(1) = [];
        
        j = j+1;
    end
end
clear temp

b21 = zeros(j-1,1);

% -MCC-(19)----------------------------------------------------------------
% (19)

b19 = zeros(D*(N-D),1);

A19 = zeros(D*N,xlen);
A19(:,gamma+1:gamma+D*N) = eye(D*N);

for i = 1:N
    index = {find(ismember({SECTION.FROM},NODE(i).ID)),...
        find(ismember({SECTION.TO},NODE(i).ID))};
    
    A19(i+0:N:D*N,d+index{1}) = 1;
    A19(i+0:N:D*N,[b+index{1},d+index{2}]) = -1;
end

for i = 1:D
    index = find(ismember({NODE.ID},DER(i).ID));
    A19(index+0:N:D*N,:) = [];
end


% -MCC-(17)--VDC-(26)-&-(29)-to-(30)---------------------------------------
% (17) gamma_id - gamma_jd + b_ij <= 1    all (i,j) in S, d in D
%   -( gamma_id - gamma_jd ) + b_ij <= 1  all (i,j) in S, d in D

% index = [ FROM  ,  TO ]

% (26) sum(d_ki) +   sum(b_ik-d_ik) + sum(b_jk-d_jk) +   sum(d_kj) + M*b_ij <= M + 1  all (i,j) in S
%     (k,i)<S     (i,k)<S,k\=j       (j,k)<S          (k,j)<S,k\=i
% (29) sum(d_ki) +   sum(b_ik-d_ik) - d_ij + M*b_ij <= M                              all (i,j) in S
%     (k,i)<S     (i,k)<S,k\=j  
%   -( sum(d_ki) +   sum(b_ik-d_ik) - d_ij ) + M*b_ij <= M                            all (i,j) in S
%     (k,i)<S     (i,k)<S,k\=j  
% (30) sum(b_jk-d_jk) +   sum(d_kj) + d_ij + M*b_ij <= M + 1                          all (i,j) in S
%     (j,k)<S          (i,k)<S,k\=i
%   -( sum(b_jk-d_jk) +   sum(d_kj) + d_ij ) + b_ij <= 0                              all (i,j) in S
%     (j,k)<S          (i,k)<S,k\=i

% index = { ik  ki  jk  kj }

b17 = ones(2*D*S,1);
b26 = (M+1)*ones(S,1);
b29 = M*ones(2*S,1);
b30 = [(M+1)*ones(S,1);zeros(S,1)];

A17 = zeros(2*D*S,xlen);
A26 = zeros(S,xlen);
A29 = zeros(2*S,xlen);
A30 = zeros(2*S,xlen);

for k = 1:S % for each section (i,j)
    % Find index of FROM and TO nodes of section
    index = [find(ismember({NODE.ID},SECTION(k).FROM)),...
    find(ismember({NODE.ID},SECTION(k).TO))];
    
    A17(k+0:S:D*S,gamma+index(1)) = 1; % coeff for gamma_id (17.1)
    A17(k+0:S:D*S,gamma+index(2)) = -1; % coeff for gamma_jd (17.1)
    A17(k+D*S:S:2*D*S,:) = -A17(k+0:S:D*S,:); % coeff for gamma_id, gamma_jd (17.2)
    A17(k+0:S:2*D*S,b+k) = 1; % coeff for b_ij (17.1) (17.2)
    
    % Find Index of all adjacent sections
    index = {find(ismember({SECTION.FROM},SECTION(k).FROM)),...
    find(ismember({SECTION.TO},SECTION(k).FROM)),...
    find(ismember({SECTION.FROM},SECTION(k).TO)),...
    find(ismember({SECTION.TO},SECTION(k).TO))};
    % Remove section k from list of adjacent sections
    index{1}(index{1}==k) = [];
    index{4}(index{4}==k) = [];
    
    A26(k,d+[index{1},index{3}]) = -1; % coeff for d_ik, d_jk (26)
    A26(k,[b+[index{1},index{3}],d+[index{2},index{4}]]) = 1; % coeff for b_ik, d_ik, d_ki, d_kj (26)
    A26(k,b+k) = M; % coeff for b_ij (26)
    
    A29(k,[d+index{1},d+k]) = -1; % coeff for d_ik, d_ij (29.1)
    A29(k,[b+index{1},d+index{2}]) = 1; % coeff for b_ik, d_ki (29.1)
    A29(k+S,:) = -A29(k,:); % coeff for d_ik, d_ij, b_ik, d_ki (29.2)
    A29([k,k+S],b+k) = M; % coeff for b_ij (29.1) (29.2)
    
    A30(k,d+index{3}) = -1; % coeff for d_jk (30.1)
    A30(k,[b+index{3},d+index{4},d+k]) = 1; % coeff for b_jk, d_kj, d_ij (30.1)
    A30(k+S,:) = -A30(k,:); % coeff for d_jk, b_jk, d_kj, d_ij (30.2)
    A30([k,k+S],b+k) = 1; % coeff for b_ij (30.1) (30.2)
end

% Remove Constraints (29) and (30) from Sections with DER Attached
for i = 1:D
    index = [find(ismember({SECTION.FROM},DER(i).ID)),...
    find(ismember({SECTION.TO},DER(i).ID))];
    
    b29([index,index+S],:) = [];
    b30([index,index+S],:) = [];
    
    A29([index,index+S],:) = [];
    A30([index,index+S],:) = [];
end

Aineq = [A6;A7;A8;A9;A11;A12;A13;A14;A15;A17;A19;A20;A26;A29;A30];
bineq = [b6;b7;b8;b9;b11;b12;b13;b14;b15;b17;b19;b20;b26;b29;b30];

Aeq = [A1;A2;A3;A4;A16;A21];
beq = [b1;b2;b3;b4;b16;b21];