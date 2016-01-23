function [f,intcon,Aineq,bineq,Aeq,beq,lb,ub] = MILPForm(NODE,SECTION,DER,PARAM)
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

n = length(NODE.ID);    % Number of Nodes
s = length(SECTION.ID); % Number of Sections
d = length(DER.ID);     % Number of DER

%%
%     max             sum(w_i * sum(c_id*p_i))
% a,b,c,gamma,d       i<N       d<D

% Let x = [a;b;c;gamma;d], then
% a     = x[      1      :      n     ]
% b     = x[     n+1     :     n+s    ]
% c     = x[    n+s+1    :  (d+1)n+s  ]
% gamma = x[  (d+1)n+s+1 : (2d+1)n+s  ]
% d     = x[ (2d+1)n+s+1 : (2d+1)n+2s ]

% define starting indicies
a = 0;
b = n;
c = n+s;
gamma = (d+1)*n+s;
d = (2*d+1)*n+s;

f_a     = zeros(n,1);
f_b     = zeros(s,1);
f_c     = repmat(-[NODE.w].*[NODE.p],d,1);
f_gamma = zeros(d*n,1);
f_d     = zeros(s,1);

f = [f_a;f_b;f_c;f_gamma;f_d];

xlen = length(f);

%% Set variable bounds/binary constraints
% All Variables are binary
lb = zeros(xlen,1);
ub = ones (xlen,1);
intcon = 1:xlen;

%%  Constraints
% -------------------------------------------------------------------------
% (1) Nodes constrained open      (a_i = 0 Vi<NO)       ---UNUSED---
% (2) Nodes constrained closed    (a_i = 1 Vi<NC)       ---FIX CP---
% (3) Sections constrained open   (b_ij = 0 V(i,j)<SO)  ---FAULTS---
% (4) Sections constrained closed (b_ij = 1 V(i,j)<SC)  ---NO SWI---

b1 = [];
b2 = ones(length(PARAM.NC),1);
b3 = zeros(length(PARAM.SO),1);
b4 = ones(length(PARAM.SC),1);

A1 = [];
A2 = zeros(length(PARAM.NC),xlen);
A3 = zeros(length(PARAM.SO),xlen);
A3 = zeros(length(PARAM.SC),xlen);

while 
    
% -------------------------------------------------------------------------
% (6)  c_id - gamma_id <= 0         all i in N, d in D
% (7)  c_id - a_i <= 0              all i in N, d in D
% (8) -c_id + gamma_id + a_i <= 1   all i in N, d in D

b6 = zeros(d*n,1);
b7 = zeros(d*n,1);
b8 = ones (d*n,1);

A6 = zeros(d*n,xlen);
A6(:,c+1:c+d*n) = eye(d*n); % coeff for c_id (6)
A7 = A6; % coeff for c_id (7)
A7(:,a+1:a+n) = repmat(-eye(n),d,1); % coeff for a_i (7)
A6(:,gamma+1:gamma+d*n) = -eye(d*n); % coeff for gamma_id (6)
A8 = -A6; % coeff for c_id, gamma_id (8)
A8(:,a+1:a+n) = repmat(eye(n),d,1); % coeff for a_i (8)

% -------------------------------------------------------------------------
% (9) sum(alpha s_i c_id) <= KVAmax_d  all d in D
%     i<N
% (11) gamma_dd = 1                    all d in D

% (13) d_dj - b_dj = 0                 all (d,j) in S, d in D
% (14) d_id = 0                        all (i,d) in S, d in D

% index = { id  dj }

b9 = [DER.CAPACITY]'; % CHECK TO SEE IF ORIENTED CORRECTLY
b11 = ones(d,1);

A9 = zeros(d,xlen);
A11 = zeros(d,xlen);
A1314 = zeros(1,xlen);

temp = alpha*[NODE.p]/pf;
j = 1;
for i = 1:d
    A9(i,c+(i-1)*n+1:c+i*n) = temp;  % coeff for c_id  all i in N, d constant (9)
    
    % Find node index of DER
    index = find(ismember({NODE.ID},DER(i).ID));
    
    A11(i,gamma+(i-1)*d+index) = 1;  % coeff for gamma_dd (11)
    
    % Find section index of all sections adjacent to DER
    index = {find(ismember({SECTION.FROM},DER(i).ID)),...
        find(ismember({SECTION.TO},DER(i).ID))};
    
    while ~isempty(index{2})
        A1314(j,d+index{2}(1)) = 1; % coeff for d_dj (13)
        A1314(j,b+index{2}(1)) = -1; % coeff for b_dj (13)
        index{2}(1) = [];
        
        j = j+1;
    end
    
    while ~isempty(index{1})
        A1314(j,d+index{1}(1)) = 1; % coeff for d_id (14)
        index{1}(1) = [];
        
        j = j+1;
    end
end
clear temp

b1314 = zeros(j-1,1);

% -------------------------------------------------------------------------
% (10) sum(gamma_id) <= 1  all i in N
%      d<D
% (12) d_ij - b_ij <= 0  all (i,j) in S

b10 = ones(n,1);
b12 = zeros(s,1);

A10 = zeros(n,xlen);
A10(gamma+1:gamma+d*n) = repmat(eye(n),1,d);

A12 = zeros(s,xlen);
A12(:,d+1:d+s) = eye(s);
A12(:,b+1:b+s) = -eye(s);

% -------------------------------------------------------------------------
% (19) sum(d_ki) +   sum(b_ik-d_ik) + sum(b_jk-d_jk) +   sum(d_kj) + M*b_ij <= M + 1  all (i,j) in S
%     (k,i)<S     (i,k)<S,k\=j       (j,k)<S          (k,j)<S,k\=i
% (22) sum(d_ki) +   sum(b_ik-d_ik) - d_ij + M*b_ij <= M                              all (i,j) in S
%     (k,i)<S     (i,k)<S,k\=j  
%   -( sum(d_ki) +   sum(b_ik-d_ik) - d_ij ) + M*b_ij <= M                            all (i,j) in S
%     (k,i)<S     (i,k)<S,k\=j  
% (23) sum(b_jk-d_jk) +   sum(d_kj) + d_ij + M*b_ij <= M + 1                          all (i,j) in S
%     (j,k)<S          (i,k)<S,k\=i
%   -( sum(b_jk-d_jk) +   sum(d_kj) + d_ij ) + M*b_ij <= 0                            all (i,j) in S
%     (j,k)<S          (i,k)<S,k\=i

% index = { ik  ki  ;  jk  kj }

% (24) gamma_id - gamma_jd + b_ij <= 1    all (i,j) in S, d in D
%   -( gamma_id - gamma_jd ) + b_ij <= 1  all (i,j) in S, d in D

b19 = M*ones(s,1);
b22 = M*ones(2*s,1);
b23 = [(M+1)*ones(s,1);zeros(s,1)];
b24 = ones(2*d*n,1);

A19 = zeros(s,xlen);
A22 = zeros(2*s,xlen);
A23 = zeros(2*s,xlen);
A24 = zeros(2*d*s,xlen);

for k = 1:s % for each section (i,j)
    % Find Index of all adjacent sections
    index = {find(ismember({SECTION.FROM},SECTION(k).FROM)),...
    find(ismember({SECTION.FROM},SECTION(k).TO));...
    find(ismember({SECTION.TO},SECTION(k).FROM)),...
    find(ismember({SECTION.TO},SECTION(k).TO))};
    % Remove section k from list of adjacent sections
    index{1}(index{1}==k) = [];
    index{4}(index{4}==k) = [];
    
    A19(k,d+[index{1},index{3}]) = -1; % coeff for d_ik, d_jk (19)
    A19(k,[b+[index{1},index{3}],d+[index{2},index{4}]]) = 1; % coeff for b_ik, d_ik, d_ki, d_kj (19)
    A19(k,b+k) = M; % coeff for b_ij (19)
    
    A22(k,[d+index{1},d+k]) = -1; % coeff for d_ik, d_ij (22.1)
    A22(k,[b+index{1},d+index{2}]) = 1; % coeff for b_ik, d_ki (22.1)
    A22(k+s,:) = -A22(k,:); % coeff for d_ik, d_ij, b_ik, d_ki (22.2)
    A22([k,k+s],b+k) = M; % coeff for b_ij (22.1) (22.2)
    
    A23(k,d+index{3}) = -1; % coeff for d_jk (23.1)
    A23(k,[b+index{3},d+index{4},d+k]) = 1; % coeff for b_jk, d_kj, d_ij (23.1)
    A23(k+s,:) = -A23(k,:); % coeff for d_jk, b_jk, d_kj, d_ij (23.2)
    A23([k,k+s],b+k) = M; % coeff for b_ij (23.1) (23.2)
    
    % Find index of FROM and TO nodes
    index = [find(ismember({NODE.ID},SECTION(k).FROM)),...
    find(ismember({NODE.ID},SECTION(k).TO))];
    
    A24(k+0:s:(d-1)*s,gamma+index(1)) = 1; % coeff for gamma_id (24.1)
    A24(k+0:s:(d-1)*s,gamma+index(2)) = -1; % coeff for gamma_jd (24.1)
    A24(k+d*s:s:(2*d-1)*s) = -A24(k+0:s:(d-1)*s,:); % coeff for gamma_id, gamma_jd (24.2)
    A24(k+0:s:(2*d-1)*s,b+k) = 1; % coeff for b_ij (24.1) (24.2)
end


Aineq = [A6;A7;A8;A9;A10;A12;A19;A22;A23;A24];
bineq = [b6;b7;b8;b9;b10;b12;b19;b22;b23;b24];

Aeq = [A1;A2;A3;A4;A11;A1314];
beq = [b1;b2;b3;b4;b11;b1314];