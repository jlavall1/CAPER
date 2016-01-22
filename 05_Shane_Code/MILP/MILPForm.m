function [f,intcon,Aineq,bineq,Aeq,beq,lb,ub] = MILPForm(NODE,SECTION,DER)
% N                 - NODE.ID
% S                 - (SECNTION.FROM,SECTION.TO)
% D                 - DER.ID
% w                 - NODE.w
% p                 - NODE.p
% q                 - NODE.q
% KVAmax_d          - DER.CAPACITY
% alpha             - 1
alpha = 1;
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

%%  Inequality Constraints
% -------------------------------------------------------------------------
% (6)  c_id - gamma_id <= 0         all i in N, d in D
% (7)  c_id - a_i <= 0              all i in N, d in D
% (8) -c_id + gamma_id + a_i <= 1   all i in N, d in D

b6 = zeros(d*n,1);
b7 = zeros(d*n,1);
b8 = ones (d*n,1);

A6 = zeros(d*n,xlen);
A6(:,n+s+1:(d+1)*n+s) = eye(d*n); % coeff for c_id (6)
A7 = A6; % coeff for c_id (7)
A7(:,1:n) = repmat(-eye(n),d,1); % coeff for a_i (7)
A6(:,(d+1)*n+s+1:(2*d+1)*n+s+1) = -eye(d*n); % coeff for gamma_id (6)
A8 = -A6; % coeff for c_id, gamma_id (8)
A8(:,1:n) = repmat(eye(n),d,1); % coeff for a_i (8)

% -------------------------------------------------------------------------
% (9) sum(alpha s_i c_id) <= KVAmax_d  all d in D
%     i<N

b9 = [DER.CAPACITY]'; % CHECK TO SEE IF ORIENTED CORRECTLY

A9 = zeros(d,xlen);
temp = alpha*sqrt([NODE.p].^2 + [NODE.q].^2);
for i = 1:d
    A9(i,i*n+s+1:(i+1)*n+s) = temp;
end
clear temp

% -------------------------------------------------------------------------
% (10) sum(gamma_id) <= 1  all i in N
%      d<D

b10 = ones(n,1);

A10 = zeros(n,xlen);
A10((d+1)*n+s+1:(2*d+1)*n+s) = repmat(eye(n),1,d);

% -------------------------------------------------------------------------
% (12) d_ij - b_ij <= 0                                                               all (i,j) in S
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

% (24) gamma_id - gamma_jd + b_ij <= 1    all (i,j) in S, d in D
%   -( gamma_id - gamma_jd ) + b_ij <= 1  all (i,j) in S, d in D

b12 = zeros(s,1);
b19 = M*ones(s,1);
b22 = M*ones(2*s,1);
b23 = [(M+1)*ones(s,1);zeros(s,1)];
b24 = ones(2*d*n,1);

A12 = zeros(s,xlen);
A12(:,(2*d+1)*n+s+1:(2*d+1)*n+2*s) = eye(s);
A12(:,n+1:n+s) = -eye(s);
for i = 1:s
    % Find Index of all adjacent sections
    index = {find(ismember({SECTION.FROM},SECTION(i).FROM)),...
    find(ismember({SECTION.FROM},SECTION(i).TO));...
    find(ismember({SECTION.TO},SECTION(i).FROM)),...
    find(ismember({SECTION.TO},SECTION(i).TO))};

    index{1}(index{1}==i) = [];
    index{4}(index{4}==i) = [];
    
end


Aineq = [A6;A7;A8;A9;A10;A12;A19;A22;A23;A24];
bineq = [b6;b7;b8;b9;b10;b12;b19;b22;b23;b24];

%%  Equality Constraints
% DSCC (1)-(4)
DSCC_len = length(PARAM.SC) + length(PARAM.SO) + length(PARAM.NC) + length(PARAM.NO);
Aeq_DSCC = zeros(DSCC_len,xlen);
beq_DSCC = zeros(DSCC_len,1);
% (1) Nodes constrained open      (a_i = 0 Vi<NO)       ---UNUSED---
% (2) Nodes constrained closed    (a_i = 1 Vi<NC)       ---UNUSED---
% (3) Sections constrained open   (b_ij = 0 V(i,j)<SO)  ---FAULTS---
% (4) Sections constrained closed (b_ij = 1 V(i,j)<SC)  ---NO SWI---
fields = {'NO','NC','SO','SC'};
i = 0;
for j = 1:4
    for k = 1:length(PARAM.(fields{j}))
        Aeq_DSCC(i + k, (j>2)*n + PARAM.(fields{j})(k)) = 1;
    end
    beq_DSCC(i+1:i+k) = ~mod(j,2);
    if ~isempty(k)
        i = i + k;
    end
end
    

% for j = 1:length(PARAM.NO)
%     Aeq_DSCC(i + j, PARAM.NO(j)) = 0;   % coeff for b (1)
% end
% for j = 1:length(PARAM.NC)
%     Aeq_DSCC(i + j, PARAM.NC(j)) = 1;    % coeff for b (2)
% end
% for j = 1:length(PARAM.SO)
%     Aeq_DSCC(i + j, n + PARAM.SO(j)) = 1;    % coeff for b_ij (4)
% end
% 
% for i = 1:length(PARAM.SC)
%     Aeq_DSCC(i    , n + PARAM.SC(i)) = 1;    % coeff for b_ij (3)
% end
% beq_DSCC(1:length(PARAM.SC)) = 1;    % b for (3)
    

% ZSC (9)&(11)
ZSC_len = m + n-1;
Aeq_ZSC = zeros(ZSC_len,xlen);
beq_ZSC = zeros(ZSC_len,1);
% (9) gamma_dd = 1
for k = 1:m
    der = find(ismember(NODE.ID,DER.ID(k)));
    Aeq_ZSC(k, (k+m+1)*n - 1 + der) = 1;  % coeff for gamma_kk (9)
end
beq_ZSC(1:m) = 1;   % b for (9)

% (11) sum(gamma_hd) - b_ij = 0, h = zeta_d(i,j) (child)
%      d<D
for i = 1:n-1
    for k = 1:m
        child = find(ismember(NODE.ID,SECTION.CHILD(i,k)));
        Aeq_ZSC(m + i, (k+m+1)*n - 1 + child) = 1;  % coeff for gamma_hk (11)
    end
    Aeq_ZSC(m + i, n + i) = -1;     % coeff for b_ij (11)
end

% PVCC (12)-(13)&(16)
PVCC_len = 3*m*n;
Aeq_PVCC = zeros(PVCC_len,xlen);
beq_PVCC = zeros(PVCC_len,1);
% (12) P_id - p_i * c_id - sum(P_jd) = 0, J = {j st j=zeta_d(i,j)}
%                          j<J
% (13) Q_id - q_i * c_id - sum(Q_jd) = 0, J = {j st j=zeta_d(i,j)}
%                          j<J
for i = 1:n
    for k = 1:m
        Aeq_PVCC(      m*(i-1)+k, (k+2*m+1)*n - 1 + i) = 1;     % coeff for P_ik (12)
        Aeq_PVCC(      m*(i-1)+k, (k    +1)*n - 1 + i) = -NODE.DEMAND(i,1); % coeff for c_ik (12)
        
        Aeq_PVCC(m*n + m*(i-1)+k, (k+3*m+1)*n - 1 + i) = 1;     % coeff for Q_ik (13)
        Aeq_PVCC(m*n + m*(i-1)+k, (k    +1)*n - 1 + i) = -NODE.DEMAND(i,2); % coeff for c_ik (13)
        
        children = find(~cellfun(@isempty,regexp(NODE.PARENT,NODE.ID(i))));
        for j = 1:length(children)
            Aeq_PVCC(      m*(i-1)+k, (k+2*m+1)*n - 1 + children(j)) = -1;     % coeff for P_jk (12)
            
            Aeq_PVCC(m*n + m*(i-1)+k, (k+3*m+1)*n - 1 + children(j)) = -1;     % coeff for Q_jk (13)
        end
    end
end

% (16.1) V_dd = V_R
for k = 1:m
    der = find(~cellfun(@isempty,regexp(NODE.ID,DER.ID(k))));
    Aeq_PVCC(2*m*n + k, (k+4*m+1)*n - 1 + der) = 1;  % coeff for V_kk (16.1)
end
beq_PVCC(2*m*n+1:(2*n+1)*m) = Vref;   % b for (16.1) 
% (16.2) V_id - V_jd + r_ij/V_R * P_id + x_ij/V_R * Q_id + delta_id = 0, j = theta_d(i) (parent)
for i = 1:n-1
    for k = 1:m
        child  = find(ismember(NODE.ID,SECTION.CHILD(i  ,k)));
        parent = find(ismember(NODE.ID,NODE.PARENT(child,k)));
        Aeq_PVCC((2*n+1)*m + m*(i-1)+k, (k+4*m+1)*n - 1 + child ) = 1;              % coeff for V_ik (child)
        Aeq_PVCC((2*n+1)*m + m*(i-1)+k, (k+4*m+1)*n - 1 + parent) = -1;             % coeff for V_jk (parent)
        Aeq_PVCC((2*n+1)*m + m*(i-1)+k, (k+2*m+1)*n - 1 + child ) = SECTION.IMPEDANCE(i,1)/(1000*Vref);% coeff for P_ik (child)
        Aeq_PVCC((2*n+1)*m + m*(i-1)+k, (k+3*m+1)*n - 1 + child ) = SECTION.IMPEDANCE(i,2)/(1000*Vref);% coeff for Q_ik (child)
        Aeq_PVCC((2*n+1)*m + m*(i-1)+k, (k+5*m+1)*n - 1 + child ) = 1;              % coeff for delta_ik (child)
    end
end

Aeq = [Aeq_DSCC; Aeq_ZSC; Aeq_PVCC];
beq = [beq_DSCC; beq_ZSC; beq_PVCC];