function [f,intcon,Aineq,bineq,Aeq,beq,lb,ub] = MILPFormulation(NODE,SECTION,DER,PARAM)
% N                 - NODE.ID
% S                 - SECNTION.ID
% w                 - NODE.WEIGHT
% [p,q]             - NODE.DEMAND
% [x,r]             - SECTION.IMPEDANCE
% D                 - DER.ID
% [Pmax_d,Qmax_d]   - DER.CAPACITY
% theta_d           - NODE.PARENT
% zeta_d            - SECTION.CHILD
% Imax              - SECTION.CAPACITY

n = length(NODE.ID);
m = length(DER.ID);
Vref = PARAM.VOLTAGE(1);
tol  = PARAM.VOLTAGE(2);

%%
%           max              sum(w_i * sum(c_id*p_i))
% a,b,c,gamma,P,Q,V,delta    i<N       d<D

% Let x = [a;b;c;gamma;P;Q;V;delta], then
% a     = x[        1:      n  ]
% b     = x[      n+1:     2n-1]
% c     = x[     2n  :(2+ m)n-1]
% gamma = x[(2+ m)n  :(2+2m)n-1]
% P     = x[(2+2m)n  :(2+3m)n-1]
% Q     = x[(2+3m)n  :(2+4m)n-1]
% V     = x[(2+4m)n  :(2+5m)n-1]
% delta = x[(2+5m)n  :(2+6m)n-1]

f_a     = zeros(n,1);
f_b     = zeros(n-1,1);
f_c     = repmat(-NODE.WEIGHT.*NODE.DEMAND(:,1),m,1);
f_gamma = zeros(m*n,1);
f_P     = zeros(m*n,1);
f_Q     = zeros(m*n,1);
f_V     = zeros(m*n,1);
f_delta = zeros(m*n,1);

f = [f_a;f_b;f_c;f_gamma;f_P;f_Q;f_V;f_delta];

xlen = length(f);

%% Set variable bounds/binary constraints
% Lower Bound 0 for all variables
lb = zeros((2+6*m)*n - 1,1);

% Binary Variables: a,b,c,gamma
intcon = 1:(2+2*m)*n - 1;
ub = ones ((2+6*m)*n - 1,1);
% Un-constrained Variables: P,Q,V,delta
ub((2+2*m)*n:end) = Inf;

%%  Inequality Constraints
% LPC (5)-(7)--------------------------------------------------------------
LPC_len = 3*m*n;
Aineq_LPC = zeros(LPC_len,xlen);
bineq_LPC = zeros(LPC_len,1);
% (5) c_id - gamma_id <= 0
Aineq_LPC(1:m*n,   2 *n:(  m+2)*n-1) =  eye(m*n);   % coeff for c_id
Aineq_LPC(1:m*n,(m+2)*n:(2*m+2)*n-1) = -eye(m*n);   % coeff for gamma_id

% (6) c_id - a_i <= 0
% (7) gamma_id - c_id + a_i <= 1
for i = 1:n
    for k = 1:m
        Aineq_LPC(  m*n + m*(i-1)+k, (k  +1)*n - 1 + i) =  1;   % coeff for c_ik (6)
        
        Aineq_LPC(2*m*n + m*(i-1)+k, (k+m+1)*n - 1 + i) =  1;   % coeff for gamma_ik (7)
        Aineq_LPC(2*m*n + m*(i-1)+k, (k  +1)*n - 1 + i) = -1;   % coeff for c_ik (7)
    end
    Aineq_LPC(  m*n + m*(i-1)+1:  m*n + m*i, i) = -1;   % coeff for a_i (6)
    
    Aineq_LPC(2*m*n + m*(i-1)+1:2*m*n + m*i, i) =  1;   % coeff for a_i (7)
end
bineq_LPC(2*m*n+1:3*m*n) = 1;   % b for (7)

% ZSC (8)&(10)-------------------------------------------------------------
ZSC_len = n + m*(n-1);
Aineq_ZSC = zeros(ZSC_len,xlen);
bineq_ZSC = zeros(ZSC_len,1);
% (8) sum(gamma_id) <= 1
%     d<D
% (10) gamma_id - gamma_jd <= 0, j = theta_d(i) (parent)
j = 1; % (10)
for i = 1:n
    for k = 1:m
        Aineq_ZSC(i, (k+m+1)*n - 1 + i) = 1;    % coeff for gamma_ik (8)
        
        if ~strcmp(DER.ID(k),NODE.ID(i)) % Exclude nodes with no parents (10)
            % Find parent node for node i (10)
            parent = find(ismember(NODE.ID,NODE.PARENT(i,k)));
            Aineq_ZSC(n + j, (k+m+1)*n - 1 + i     ) = 1;   % coeff for gamma_ik (10)
            Aineq_ZSC(n + j, (k+m+1)*n - 1 + parent) = -1;  % coeff for gamma_jk (10)
            j = j+1;
        end
    end
end
bineq_ZSC(1:n) = 1; % b for (8)

% PVCC (14)-(15)&(17)-(20)-------------------------------------------------
PVCC_len = (4*m+2)*n; %+ m*(n-1);
Aineq_PVCC = zeros(PVCC_len,xlen);
bineq_PVCC = zeros(PVCC_len,1);
% (14) P_id - Pmax_d * gamma_id <= 0
% (15) Q_id - Qmax_d * gamma_id <= 0
% (17) delta_id + V_R * gamma_id <= V_R
% (18) V_id - V_R * gamma_id <= 0
% (19.1) sum(V_id)  <=  V_R * (1+tol)
%        d<D
% (19.2) sum(-V_id) <= -V_R * (1-tol)
%        d<D
for i = 1:n
    for k = 1:m
        Aineq_PVCC(        m*(i-1)+k, (k+2*m+1)*n - 1 + i) = 1;                 % coeff for P_ik (14)
        Aineq_PVCC(        m*(i-1)+k, (k+  m+1)*n - 1 + i) = -DER.CAPACITY(k,1);% coeff for gamma_ik (14)
        
        Aineq_PVCC(  m*n + m*(i-1)+k, (k+3*m+1)*n - 1 + i) = 1;                 % coeff for Q_ik (15)
        Aineq_PVCC(  m*n + m*(i-1)+k, (k+  m+1)*n - 1 + i) = -DER.CAPACITY(k,2);% coeff for gamma_ik (15)
        
        Aineq_PVCC(2*m*n + m*(i-1)+k, (k+5*m+1)*n - 1 + i) = 1;                 % coeff for delta_ik (17)
        Aineq_PVCC(2*m*n + m*(i-1)+k, (k+  m+1)*n - 1 + i) = Vref;              % coeff for gamma_ik (17)
        
        Aineq_PVCC(3*m*n + m*(i-1)+k, (k+4*m+1)*n - 1 + i) = 1;                 % coeff for V_ik (18)
        Aineq_PVCC(3*m*n + m*(i-1)+k, (k+  m+1)*n - 1 + i) = -Vref;             % coeff for gamma_ik (18)
        
        Aineq_PVCC(      4*m*n + i  , (k+4*m+1)*n - 1 + i) = 1;                 % coeff for V_ik (19.1)
        Aineq_PVCC(  (4*m+1)*n + i  , (k+4*m+1)*n - 1 + i) = -1;                % coeff for V_ik (19.2)
    end
end
bineq_PVCC(    2*m*n + 1 :     3*m*n) =  Vref;           % b for (17)
bineq_PVCC(    4*m*n + 1 : (4*m+1)*n) =  Vref*(1+tol);   % b for (19.1)
bineq_PVCC((4*m+1)*n + 1 : (4*m+2)*n) = -Vref*(1-tol);   % b for (19.2)

% (20) P_jd - Imax_ij * Vref * (1- tol) * gamma_id <= 0, j = zeta_d(i,j) (child)
%for i = 1:n-1
%    for k = 1:m
%         child = find(ismember(N,zeta_d(i,k)));
%         Aineq_PVCC((4*m+2)*n + m*(i-1)+k, (k+2*m+1)*n - 1 + child) = 1;                         % coeff for P_ik (14)
%         Aineq_PVCC((4*m+2)*n + m*(i-1)+k, (k+  m+1)*n - 1 + i    ) = -Imax(i)*Vref*(1-tol);      % coeff for gamma_ik (14)
%     end
% end

Aineq = [Aineq_LPC; Aineq_ZSC; Aineq_PVCC];
bineq = [bineq_LPC; bineq_ZSC; bineq_PVCC];

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