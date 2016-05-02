function [H,f,A,rl,ru,lb,ub,xint] = BatteryMILPForm()

global NODE SECTION PV BESS PARAM

%%
%   min 0.5*x'*H*x + f'*x      subject to:     rl <= A*x <= ru
%    x                                         qrl <= x'Q'x + l'x <= qru
%                                              lb <= x <= ub
%                                              for i = 1..n: xi in Z
%                                              for j = 1..m: xj in {0,1} 
%
%   x = opti_cplex([],f,A,rl,ru,lb,ub,xint) solves a LP/MILP where f is the 
%   objective vector, A,rl,ru are the linear constraints, lb,ub are the
%   bounds and xint is a string of integer variables ('C', 'I', 'B').

% Let x = [a;c;d;E;P;Pbar;r]

n = length(NODE);
s = length(SECTION);
pv = length(PV);
t = length(PARAM.beta);

% Define starting indicies
a       = 0;
b       = a+n;
c       = b+n*t;
d       = c+n*t;
E       = d+n*t;
P       = E+n*(t+2);
Pbar    = P+(s+1)*t;
r       = Pbar+s*t;

% Objective Function
f_a     = zeros(n,1);
f_b     = zeros(n*t,1);
f_c     = (1-BESS.etac)*ones(n*t,1);
f_d     = (1-BESS.etad)*ones(n*t,1);
f_E     = zeros(n*(t+2),1);
f_P     = zeros((s+1)*t,1);
%f_Pbar  = repmat(abs([SECTION.Z1])',t,1);
%f_Pbar  = repmat(abs([SECTION.Length])',t,1);
f_Pbar  = zeros(s*t,1);
f_r     = zeros(s*t,1);

f = [f_a;f_b;f_c;f_d;f_E;f_P;f_Pbar;f_r];

xlen = length(f);

% min( (dt*Zij1/Vb^2)P_ij^2 )
iH = Pbar+(1:s*t);
jH = Pbar+(1:s*t);
vH = 2*PARAM.dt*repmat(real([SECTION.Z1])',t,1)/PARAM.kV^2;
H = sparse(iH,jH,vH,xlen,xlen);

%H = [];


%% Constraints
% Variable Bounds
lb = [zeros(size(f_a));
    zeros(size(f_b));
    zeros(size(f_c));
    zeros(size(f_d));
    BESS.Er*ones(size(f_E));
    -Inf(size(f_P));
    zeros(size(f_Pbar));
    zeros(size(f_r))];

ub = [ones(size(f_a));
    ones(size(f_b));
    Inf(size(f_c));
    Inf(size(f_d));
    BESS.ER*ones(size(f_E));
    Inf(size(f_P));
    Inf(size(f_Pbar));
    ones(size(f_r))];

xint = [repmat('B',size(f_a')),...
    repmat('B',size(f_b')),...
    repmat('C',size(f_c')),...
    repmat('C',size(f_d')),...
    repmat('C',size(f_E')),...
    repmat('C',size(f_P')),...
    repmat('C',size(f_Pbar')),...
    repmat('B',size(f_r'))];

% -Battery Constraints-----------------------------------------------------
% (2) sum( a_i ) = 1
%     i<N

r2 = 1;
i2 = ones(n,1);
j2 = a+(1:n)';
v2 = ones(n,1);
A2 = sparse(i2,j2,v2,1,xlen);

% (3)  c_i(t) - a_i*PR <= 0,  all i in N, t in T
% (3a) c_i(t) - b_i(t)*PR <= 0,  all i in N, t in T

rl3 = -Inf(n*t,1);
ru3 = zeros(n*t,1);
i3 = reshape(repmat(1:n*t,2,1),[],1);
j3 = reshape([c+(1:n*t);a+reshape(repmat(1:n,t,1),[],1)'],[],1);
v3 = repmat([1;-BESS.PR],n*t,1);
A3 = sparse(i3,j3,v3,n*t,xlen);

rl3a = -Inf(n*t,1);
ru3a = zeros(n*t,1);
i3a = reshape(repmat(1:n*t,2,1),[],1);
j3a = reshape([c+(1:n*t);b+(1:n*t)],[],1);
v3a = repmat([1;-BESS.PR],n*t,1);
A3a = sparse(i3a,j3a,v3a,n*t,xlen);

% (4)  d_i(t) - a_i*PR <= 0,  all i in N, t in T
% (4a) d_i(t) + b_i*PR <= PR,  all i in N, t in T

rl4 = -Inf(n*t,1);
ru4 = zeros(n*t,1);
i4 = reshape(repmat(1:n*t,2,1),[],1);
j4 = reshape([d+(1:n*t);a+reshape(repmat(1:n,t,1),[],1)'],[],1);
v4 = repmat([1;-BESS.PR],n*t,1);
A4 = sparse(i4,j4,v4,n*t,xlen);

rl4a = -Inf(n*t,1);
ru4a = BESS.PR*ones(n*t,1);
i4a = reshape(repmat(1:n*t,2,1),[],1);
j4a = reshape([d+(1:n*t);b+(1:n*t)],[],1);
v4a = repmat([1;BESS.PR],n*t,1);
A4a = sparse(i4a,j4a,v4a,n*t,xlen);

% (6) E_i(t+1) - E_i(t) - dt*eta_c*c_i(t) + dt*d_i(t)/eta_d = 0,  all i in N, t in T

r6 = zeros(n*t,1);
i6 = reshape(repmat(1:n*t,4,1),[],1);
j6 = reshape([E+reshape(repmat((2:(t/2)+1)',1,2*n)+((t/2)+1)*repmat(0:2*n-1,t/2,1),[],1)';...
              E+reshape(repmat((1:(t/2))'  ,1,2*n)+((t/2)+1)*repmat(0:2*n-1,t/2,1),[],1)';...
              c+reshape(repmat((1:(t/2))'  ,1,2*n)+ (t/2)   *repmat(0:2*n-1,t/2,1),[],1)';...
              d+reshape(repmat((1:(t/2))'  ,1,2*n)+ (t/2)   *repmat(0:2*n-1,t/2,1),[],1)'],[],1);
v6 = repmat([1;-1;-PARAM.dt*BESS.etac;PARAM.dt/BESS.etad],n*t,1);
A6 = sparse(i6,j6,v6,n*t,xlen);

% (7) P_ij(t) - sum( P_jk(t) ) - c_j(t) + d_j(t) =  beta(t)*p_j - sum( gamma(t)*PV_j ),  for all (i,j) in S, t in T
%             (j,k)<S                                             j<PV

r7 = [];
i7 = [];
j7 = [];
v7 = [];
for i = 1:s
    % index = { [node index] [section indicies] [PV index] }
    index = {find(ismember({NODE.ID},SECTION(i).TO)),...
        find(ismember({SECTION.FROM},SECTION(i).TO)),...
        find(ismember({PV.Bus1},SECTION(i).TO))};
    adj = length(index{2}); % number of adjacent sections
    pv  = length(index{3}); % number of adjacent pv
    if pv>0
        r7 = [r7;NODE(index{1}).kW*PARAM.beta - PV(index{3}).kW*repmat(PARAM.gamma,2,pv)];
    else
        r7 = [r7;NODE(index{1}).kW*PARAM.beta];
    end
    i7 = [i7;reshape(repmat((i-1)*t+1:i*t,adj+3,1),[],1)];
    j7 = [j7;reshape([P+t*(i-1)+(1:t);P+t*repmat(index{2}'-1,1,t)+repmat(1:t,adj,1);...
        c+t*(index{1}-1)+(1:t);d+t*(index{1}-1)+(1:t)],[],1)];
    v7 = [v7;repmat([1;-ones(adj,1);-1;1],t,1)];
end
A7 = sparse(i7,j7,v7,s*t,xlen);

% (8) P_g(t) - sum( P_sk(t) ) - c_s(t) + d_s(t) =  beta(t)*p_s - sum( gamma(t)*PV_s ),  all t in T
%             (s,k)<S                                            s<PV
% NOTE: no PV or load at sub bus
index = {find(ismember({NODE.ID},PARAM.SubBus)),...
    find(ismember({SECTION.FROM},PARAM.SubBus))};

r8 = zeros(t,1);
i8 = reshape(repmat(1:t,4,1),[],1);
j8 = reshape([P+s*t+(1:t);P+t*(index{2}-1)+(1:t);...
    c+t*(index{1}-1)+(1:t);d+t*(index{1}-1)+(1:t)],[],1);
v8 = repmat([1;-1;-1;1],t,1);
A8 = sparse(i8,j8,v8,t,xlen);

% (10) Pbar_ij(t) - P_ij(t) >= 0                all (i,j) in S, t in T
%      Pbar_ij(t) - P_ij(t) - M*r_ij(t) <= 0
% (11) Pbar_ij(t) + P_ij(t) >= 0                all (i,j) in S, t in T
%      Pbar_ij(t) + P_ij(t) + M*r_ij(t) <= M
M = 2*PARAM.LoadTotal;

rl10 = [zeros(s*t,1);-Inf(s*t,1)];
ru10 = [Inf(s*t,1);zeros(s*t,1)];
i10 = reshape([repmat(1:s*t,2,1);repmat(s*t+(1:s*t),3,1)],[],1);
j10 = reshape([Pbar+(1:s*t);P+(1:s*t);Pbar+(1:s*t);P+(1:s*t);r+(1:s*t)],[],1);
v10 = repmat([1;-1;1;-1;-M],s*t,1);
A10 = sparse(i10,j10,v10,2*s*t,xlen);

rl11 = [zeros(s*t,1);-Inf(s*t,1)];
ru11 = [Inf(s*t,1);M*ones(s*t,1)];
i11 = reshape([repmat(1:s*t,2,1);repmat(s*t+(1:s*t),3,1)],[],1);
j11 = reshape([P+(1:s*t);Pbar+(1:s*t);P+(1:s*t);Pbar+(1:s*t);r+(1:s*t)],[],1);
v11 = repmat([1;1;1;1;M],s*t,1);
A11 = sparse(i11,j11,v11,2*s*t,xlen);

% (12) E_i(0) - E_i(end) = 0, all i in N
% (13) E_i(8am) = Er,  all i in N

r12 = zeros(n,1);
i12 = reshape(repmat(1:n,2,1),[],1);
j12 = reshape([E+1+((t/2)+1)*(0:n-1);E+((t/2)+1)*(1:n)],[],1);
v12 = repmat([1;-1],n,1);
A12 = sparse(i12,j12,v12,n,xlen);

r13 = BESS.Er*ones(n,1);
i13 = (1:n)';
j13 = E+(8/PARAM.dt)+1+((t/2)+1)*(0:n-1)';
v13 = ones(n,1);
A13 = sparse(i13,j13,v13,n,xlen);


% Combine Constraint Matricies
%A10 = []; rl10 = []; ru10 = [];
%A7 = []; r7 = [];
%A8 = []; r8 = [];
%A11 = []; rl11 = []; ru11 = [];


A  = [A2; A3; A3a; A4; A4a;A6;A7;A8; A10; A11;A12;A13];
rl = [r2;rl3;rl3a;rl4;rl4a;r6;r7;r8;rl10;rl11;r12;r13];
ru = [r2;ru3;ru3a;ru4;ru4a;r6;r7;r8;ru10;ru11;r12;r13];









