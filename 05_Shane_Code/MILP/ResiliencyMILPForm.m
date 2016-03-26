function [f,A,rl,ru,lb,ub,xint] = ResiliencyMILPForm

global NODE SECTION LOAD DER PARAM
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
L = length(LOAD);       % Number of Loads

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

% Let x = [a;alpha;b;bbar;beta1;beta2;c], then
% a     = x[    D*N    ]
% alpha = x[  D*(L+D)  ]
% b     = x[    D*S    ]
% bbar  = x[     S     ]
% beta1 = x[    D*S    ]
% beta2 = x[    D*S    ]
% c     = x[     D     ]


% Define starting indicies
a       = 0;
alpha   = a+D*N;
b       = alpha+D*(L+D);
bbar    = b+D*S;
beta1   = bbar+S;
beta2   = beta1+D*S;
c       = beta2+D*S;

f_a     = zeros(D*N,1);
f_alpha = -repmat([[LOAD.w]'.*[LOAD.p]';zeros(D,1)],D,1);
f_b     = zeros(D*S,1);
f_bbar  = ones(S,1);
f_beta1 = zeros(D*S,1);
f_beta2 = zeros(D*S,1);
f_c     = zeros(D*S,1);

f = [f_a;f_alpha;f_b;f_bbar;f_beta1;f_beta2;f_c];

xlen = length(f);

%% Set variable bounds/binary constraints
% All Variables are binary
lb = zeros(xlen,1);
ub = ones (xlen,1);
xint = repmat('B',1,length(f));

%%  Constraints
% -OC-(1)-to-(4)-----------------------------------------------------------
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


r1 = zeros(NO,1);
[~,~,ic] = unique([{NODE.ID},PARAM.NO],'stable');
i1 = reshape(repmat(1:NO,D,1),[],1);
j1 = alpha+reshape(repmat(ic(end-NO+1:end)',D,1)+N*repmat((0:D-1)',1,NO),[],1);
v1 = ones(NO*D,1);
A1 = sparse(i1,j1,v1,NO,xlen);

r2 = ones (NC,1);
[~,~,ic] = unique([{NODE.ID},PARAM.NC],'stable');
i2 = reshape(repmat(1:NC,D,1),[],1);
j2 = alpha+reshape(repmat(ic(end-NC+1:end)',D,1)+N*repmat((0:D-1)',1,NC),[],1);
v2 = ones(NC*D,1);
A2 = sparse(i2,j2,v2,NC,xlen);

r3 = zeros(SO,1);
[~,~,ic] = unique([{SECTION.ID},PARAM.SO],'stable');
i3 = reshape(repmat(1:SO,D,1),[],1);
j3 = b+reshape(repmat(ic(end-SO+1:end)',D,1)+S*repmat((0:D-1)',1,SO),[],1);
v3 = ones(SO*D,1);
A3 = sparse(i3,j3,v3,SO,xlen);

r4 = ones (SC,1);
[~,~,ic] = unique([{NODE.ID},PARAM.NO],'stable');
i4 = reshape(repmat(1:SC,D,1),[],1);
j4 = b+reshape(repmat(ic(end-SC+1:end)',D,1)+S*repmat((0:D-1)',1,SC),[],1);
v4 = ones(SC*D,1);
A4 = sparse(i4,j4,v4,SC,xlen);


% -OC-(6)-to-(9)-----------------------------------------------------------
% (6/7)   -n_ij <= bbar_ij - sum( b_ijg ) <= n_ij       all (i,j) in S
%                            g<G
% (8/9)    n_ij <= bbar_ij + sum( b_ijg ) <= 2 - n_ij   all (i,j) in S
%                            g<G

rl6 = -[SECTION.NormalStatus]';
ru6 = [SECTION.NormalStatus]';
i6 = reshape(repmat(1:S,D+1,1),[],1);
j6 = reshape([bbar+1:S;b+repmat(1:S,D,1)],[],1);
v6 = repmat([1;-ones(D,1)],S,1);
A6 = sparse(i6,j6,v6,S,xlen);

rl8 = [SECTION.NormalStatus]';
ru8 = 2*ones(S,1)-[SECTION.NormalStatus]';
i8 = reshape(repmat(1:S,D+1,1),[],1);
j8 = reshape([bbar+1:S;b+repmat(1:S,D,1)],[],1);
v8 = repmat([1;ones(D,1)],S,1);
A8 = sparse(i8,j8,v8,S,xlen);

% -OC-(10)-&-(11)----------------------------------------------------------
% (10) c_g - sum( alpha_dg ) <= 0  all g in G
%            d<D
% (11) alpha_dg - c_g        <= 0  all g in G, d in D

rl10 = -Inf(D,1);
ru10 = zeros(D,1);
i10 = reshape(repmat(1:D,D+1,1),[],1);
j10 = reshape([c+(1:D);alpha+L+repmat((1:D)',1,D)+(L+D)*repmat(0:D-1,D,1)],[],1);
v10 = repmat([1;-ones(D,1)],D,1);
A10 = sparse(i10,j10,v10,D,xlen);

rl11 = -Inf(D*D,1);
ru11 = zeros(D*D,1);
i11 = reshape(repmat(1:D*D,2,1),[],1);
j11 = reshape([reshape(alpha+L+repmat((1:D)',1,D)+(L+D)*repmat(0:D-1,D,1),[],1),...
    reshape(repmat(c+(1:D),D,1),[],1)]',[],1);
v11 = repmat([1;-1],D*D,1);
A11 = sparse(i11,j11,v11,D*D,xlen);

%% THIS IS WHERE I STOPPED
% -OC-(12)----------------------------------------------------------------
% (12) (eta/pf) * sum( alpha_ig p_i) - sum( alpha_dg KVAmax_d ) <= 0    all g in G
%                 i<L                  d<D

rl12 = -Inf(D,1);
ru12 = zeros(D,1);
[~,~,ic] = unique([{NODE.ID},{DER.ID}],'stable');
index = ic(end-D+1:end);
i12 = [reshape(repmat(1:D,L,1),[],1);reshape(repmat(1:D,D,1),[],1)];
j12 = [alpha+(1:D*L)';alpha+reshape(repmat(N*(0:D-1),D,1)+repmat(index,1,D),[],1)];
v12 = [repmat(eta*[LOAD.p]'/pf,D,1);repmat(-[DER.MVACapacity]',D,1)];
A12 = sparse(i12,j12,v12,D,xlen);


% -MCC-(13)-&-(14)---------------------------------------------------------
% (13) alpha_ig - a_ig <= 0  all i in {D,L}, g in G
% (14) sum( a_ig ) = 1   all i in N
%      g<G


% -MCC-(15)----------------------------------------------------------------
% (15) a_ig + a_jg - 2*( b_ijg + beta2_ijg ) - beta1_ijg = 0  all (i,j) in S, g in G

% -MCC-(16)----------------------------------------------------------------
% (16) sum( b_ijg ) + (1/2)*sum( beta1_ijg ) + sum( beta2_ijg ) = 1  all (i,j) in S
%      g<G                  g<G                g<G

% -RSC-(17)----------------------------------------------------------------
% (17) (1/4)*sum(  sum( beta1_ijg ) ) + sum(  sum( beta2_ijg ) ) >= 1  all c in C
%          (i,j)<c g<G                (i,j)<c g<G

% -RSC-(18)----------------------------------------------------------------
% (18) sum( sum( a_ig ) ) - sum(  sum( b_ijg ) ) - sum( c_g ) = 0
%      g<G  i<N             g<G (i,j)<S            g<G








% -RSC-(26)-&-(27)---------------------------------------------------------

% (27) sum( sum( alpha_ig ) ) - sum( sum( beta_ijg ) ) - sum( gamma_g ) = 0
%      i<N  i<N                 g<G (i,j)<S              g<G


b27 = sparse([],[],[],1,1);



i27 = ones((N+S+1)*D,1);
j27 = j26;
v27 = v26;
A27 = sparse(i27,j27,v27,1,xlen);


A  = [A1; A2; A3; A4; A6; A8; A10; A11; A12; A13; A14; A15; A16; A17; A18];
rl = [r1; r2; r3; r4;rl6;rl8;rl10;rl11;rl12;rl13; r14; r15; r16;rl17; r18];
ru = [r1; r2; r3; r4;ru6;ru8;ru10;ru11;ru12;ru13; r14; r15; r16;rl17; r18];