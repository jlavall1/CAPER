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
LD = length(LOAD);       % Number of Loads
LP = length(PARAM.Loop);

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
% c     = x[    D*LP   ]
% d     = x[     D     ]


% Define starting indicies
a       = 0;
alpha   = a+D*N;
b       = alpha+D*(LD+D);
bbar    = b+D*S;
beta1   = bbar+S;
beta2   = beta1+D*S;
c       = beta2+D*S;
d       = c+D*LP;

f_a     = zeros(D*N,1);
f_alpha = -repmat([[LOAD.w]'.*[LOAD.p]';zeros(D,1)],D,1);
f_b     = zeros(D*S,1);
f_bbar  = 10*ones(S,1);
f_beta1 = zeros(D*S,1);
f_beta2 = zeros(D*S,1);
f_c     = zeros(D*LP,1);
f_d     = zeros(D,1);

f = [f_a;f_alpha;f_b;f_bbar;f_beta1;f_beta2;f_c;f_d];

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
PARAM.NC(:,index(index<NC)) = [];
NC = length(PARAM.NC);


% r1 = zeros(NO,1);
% [~,~,ic] = unique([{LOAD.ID},PARAM.NO],'stable');
% i1 = reshape(repmat(1:NO,D,1),[],1);
% j1 = alpha+reshape(repmat(ic(LD+1:end)',D,1)+(LD+D)*repmat((0:D-1)',1,NO),[],1);
% v1 = ones(NO*D,1);
% A1 = sparse(i1,j1,v1,NO,xlen);
% 
% r2 = ones(NC,1);
% [~,~,ic] = unique([{LOAD.ID},PARAM.NC],'stable');
% i2 = reshape(repmat(1:NC,D,1),[],1);
% j2 = alpha+reshape(repmat(ic(LD+1:end)',D,1)+(LD+D)*repmat((0:D-1)',1,NC),[],1);
% v2 = ones(NC*D,1);
% A2 = sparse(i2,j2,v2,NC,xlen);

r3 = zeros(SO,1);
[~,~,ic] = unique([{SECTION.ID},PARAM.SO],'stable');
i3 = reshape(repmat(1:SO,D,1),[],1);
j3 = b+reshape(repmat(ic(end-SO+1:end)',D,1)+S*repmat((0:D-1)',1,SO),[],1);
v3 = ones(SO*D,1);
A3 = sparse(i3,j3,v3,SO,xlen);

r4 = ones(SC,1);
[~,~,ic] = unique([{SECTION.ID},PARAM.SC],'stable');
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
j6 = reshape([bbar+(1:S);b+repmat(1:S,D,1)+S*repmat((0:D-1)',1,S)],[],1);
v6 = repmat([1;-ones(D,1)],S,1);
A6 = sparse(i6,j6,v6,S,xlen);

rl8 = [SECTION.NormalStatus]';
ru8 = 2*ones(S,1)-[SECTION.NormalStatus]';
i8 = reshape(repmat(1:S,D+1,1),[],1);
j8 = reshape([bbar+(1:S);b+repmat(1:S,D,1)+S*repmat((0:D-1)',1,S)],[],1);
v8 = repmat([1;ones(D,1)],S,1);
A8 = sparse(i8,j8,v8,S,xlen);

% -OC-(10)-&-(11)----------------------------------------------------------
% (10) d_g - sum( alpha_dg ) <= 0  all g in G
%            d<D
% (11) alpha_dg - d_g        <= 0  all g in G, d in D

rl10 = -Inf(D,1);
ru10 = zeros(D,1);
i10 = reshape(repmat(1:D,D+1,1),[],1);
j10 = reshape([d+(1:D);alpha+LD+repmat((1:D)',1,D)+(LD+D)*repmat(0:D-1,D,1)],[],1);
v10 = repmat([1;-ones(D,1)],D,1);
A10 = sparse(i10,j10,v10,D,xlen);

rl11 = -Inf(D*D,1);
ru11 = zeros(D*D,1);
i11 = reshape(repmat(1:D*D,2,1),[],1);
j11 = reshape([reshape(alpha+LD+repmat((1:D)',1,D)+(LD+D)*repmat(0:D-1,D,1),[],1),...
    reshape(repmat(d+(1:D),D,1),[],1)]',[],1);
v11 = repmat([1;-1],D*D,1);
A11 = sparse(i11,j11,v11,D*D,xlen);

% -OC-(12)----------------------------------------------------------------
% (12) (eta/pf) * sum( alpha_ig * p_i) - sum( alpha_dg KVAmax_d ) <= 0    all g in G
%                 i<L                  d<D

rl12 = -Inf(D,1);
ru12 = zeros(D,1);
i12 = reshape(repmat(1:D,LD+D,1),[],1);
j12 = alpha+reshape(repmat((1:LD+D)',1,D)+(LD+D)*repmat(0:D-1,LD+D,1),[],1);
v12 = repmat([eta*[LOAD.p]'/pf;-1000*[DER.MVACapacity]'],D,1);
A12 = sparse(i12,j12,v12,D,xlen);


% -MCC-(13)-&-(14)---------------------------------------------------------
% (13) alpha_ig - a_ig <= 0  all i in {D,L}, g in G
% (14) sum( a_ig ) = 1   all i in N
%      g<G

rl13 = -Inf(D*(LD+D),1);
ru13 = zeros(D*(LD+D),1);
[~,~,ic] = unique([{NODE.ID},{LOAD.ID},{DER.ID}],'stable');
i13 = reshape(repmat(1:D*(LD+D),2,1),[],1);
j13 = reshape([alpha+(1:D*(D+LD));a+reshape(repmat(ic(N+1:end),1,D)+N*repmat(0:D-1,D+LD,1),1,[])],[],1);
v13 = repmat([1;-1],D*(LD+D),1);
A13 = sparse(i13,j13,v13,D*(LD+D),xlen);

rl14 = ones(N,1); %-Inf(N,1);
ru14 = ones(N,1);
i14 = reshape(repmat(1:N,D,1),[],1);
j14 = reshape(a+repmat(1:N,D,1)+N*repmat((0:D-1)',1,N),[],1);
v14 = ones(D*N,1);
A14 = sparse(i14,j14,v14,N,xlen);

% -MCC-(15)----------------------------------------------------------------
% (15) a_ig + a_jg - 2*( b_ijg + beta2_ijg ) - beta1_ijg = 0  all (i,j) in S, g in G

r15 = zeros(D*S,1);
[~,~,ic] = unique([{NODE.ID},{SECTION.FROM},{SECTION.TO}],'stable');
i15 = reshape(repmat(1:D*S,5,1),[],1);
j15 = reshape([a+reshape(repmat(reshape([ic(N+1:N+S)';ic(N+S+1:end)'],...
    [],1),1,D)+N*repmat(0:D-1,2*S,1),2,[]);b+(1:D*S);beta2+(1:D*S);beta1+(1:D*S)],[],1);
v15 = repmat([1;1;-2;-2;-1],D*S,1);
A15 = sparse(i15,j15,v15,D*S,xlen);

% -MCC-(16)----------------------------------------------------------------
% (16) sum( b_ijg ) + (1/2)*sum( beta1_ijg ) + sum( beta2_ijg ) = 1  all (i,j) in S
%      g<G                  g<G                g<G

r16 = ones(S,1);
i16 = reshape(repmat(1:S,3*D,1),[],1);
j16 = reshape([b+repmat(1:S,D,1)+S*repmat((0:D-1)',1,S);...
    beta1+repmat(1:S,D,1)+S*repmat((0:D-1)',1,S);...
    beta2+repmat(1:S,D,1)+S*repmat((0:D-1)',1,S)],[],1);
v16 = repmat([ones(D,1);(1/2)*ones(D,1);ones(D,1)],S,1);
A16 = sparse(i16,j16,v16,S,xlen);

% -RSC-(17)----------------------------------------------------------------
% (17) c_cg - sum( a_ig ) <= 0  all c in C, g in G
%             i<c
% (17) a_ig - c_cg        <= 0  all i in c, g in G, c in C


j=0;
i17 = [];
j17 = [];
v17 = [];
for i = 1:LP
    lps = length(PARAM.Loop(i).NODE);
    [~,~,ic] = unique([{NODE.ID},PARAM.Loop(i).NODE],'stable');
    i17 = [i17;reshape(repmat(j+1:j+D*lps,2,1),[],1)];
    j17 = [j17;reshape([a+reshape(repmat(ic(N+1:end),1,D)+N*repmat(0:D-1,lps,1),1,[]);...
               c+i+reshape(LP*repmat(0:D-1,lps,1),1,[])],[],1)];
    v17 = [v17;repmat([1;-1],D*lps,1)];
    
    j = j+D*lps;
    
    i17 = [i17;reshape(repmat(j+1:j+D,lps+1,1),[],1)];
    j17 = [j17;reshape([c+i+LP*(0:D-1);repmat(ic(N+1:end),1,D)+N*repmat(0:D-1,lps,1)],[],1)];
    v17 = [v17;repmat([1;-ones(lps,1)],D,1)];
    
    j = j+D;
end
A17 = sparse(i17,j17,v17,j,xlen);
rl17 = -Inf(j,1);
ru17 = zeros(j,1);


% -RSC-(18)----------------------------------------------------------------
% (18) (1/2)*sum(  sum( beta1_ijg ) ) + sum(  sum( beta2_ijg ) ) - sum( c_cg ) = N_c - 1  all c in C
%          (i,j)<c g<G                (i,j)<c g<G                  g<G

% r18 = [PARAM.Loop.Num]'-ones(LP,1);
% i18 = [];
% j18 = [];
% v18 = [];
% for i = 1:LP
%     lp = length(PARAM.Loop(i).SECTION);
%     [~,~,ic] = unique([{SECTION.ID},PARAM.Loop(i).SECTION],'stable');
%     i18 = [i18;i*ones(2*D*lp+D,1)];
%     j18 = [j18;beta1+reshape(repmat(ic(S+1:end),1,D)+S*repmat(0:D-1,lp,1),[],1);...
%                beta2+reshape(repmat(ic(S+1:end),1,D)+S*repmat(0:D-1,lp,1),[],1);...
%                c+i+LP*(0:D-1)'];
%     v18 = [v18;(1/2)*ones(D*lp,1);ones(D*lp,1);-ones(D,1)];
% end
% A18 = sparse(i18,j18,v18,LP,xlen);

% -RSC-(18)----------------------------------------------------------------
% (18) sum( sum( a_ig ) ) - sum(  sum( b_ijg ) ) - sum( c_cg ) = 0  all c in C
%      i<c  g<G           (i,j)<c g<G              g<G

% r18 = zeros(LP,1);
% i18 = [];
% j18 = [];
% v18 = [];
% for i = 1:LP
%     lpn = length(PARAM.Loop(i).NODE);
%     lps = length(PARAM.Loop(i).SECTION);
%     [~,~,icn] = unique([{NODE.ID},PARAM.Loop(i).NODE],'stable');
%     [~,~,ics] = unique([{SECTION.ID},PARAM.Loop(i).SECTION],'stable');
%     i18 = [i18;i*ones(D*(lpn+lps+1),1)];
%     j18 = [j18;a+reshape(repmat(icn(N+1:end),1,D)+N*repmat(0:D-1,lpn,1),[],1);...
%                b+reshape(repmat(ics(S+1:end),1,D)+S*repmat(0:D-1,lps,1),[],1);...
%                c+i+LP*(0:D-1)'];
%     v18 = [v18;ones(D*lpn,1);-ones(D*lps,1);-ones(D,1)];
% end
% A18 = sparse(i18,j18,v18,LP,xlen);

% -RSC-(18)----------------------------------------------------------------
% (18)   sum(  sum( b_ijg ) ) <= |C|-1  all c in C
%      (i,j)<c g<G

rl18 = zeros(LP,1);
ru18 = [PARAM.Loop.Num]'-1;
i18 = [];
j18 = [];
v18 = [];
for i = 1:LP
    [~,~,ic] = unique([{SECTION.ID},PARAM.Loop(i).SECTION],'stable');
    i18 = [i18;i*ones(D*PARAM.Loop(i).Num,1)];
    j18 = [j18;b+reshape(repmat(ic(S+1:end),1,D)+S*repmat(0:D-1,PARAM.Loop(i).Num,1),[],1)];
    v18 = [v18;ones(D*PARAM.Loop(i).Num,1)];
end
A18 = sparse(i18,j18,v18,LP,xlen);

% -RSC-(19)----------------------------------------------------------------
% (19) sum( sum( a_ig ) ) - sum(  sum( b_ijg ) ) - sum( d_g ) = 0
%      g<G  i<N             g<G (i,j)<S            g<G

r19 = 0;
i19 = ones(D*(N+S+1),1);
j19 = [a+(1:D*N)';b+(1:D*S)';d+(1:D)'];
v19 = [ones(D*N,1);-ones(D*(S+1),1)];
A19 = sparse(i19,j19,v19,1,xlen);

% Join all constraint matricies
% Constraints to Exclude (for debug)
A1 = []; r1 = [];
A2 = []; r2 = [];
%A3 = []; r3 = [];
%A4 = []; r4 = [];
%A6 = []; rl6 = []; ru6 = [];
%A8 = []; rl8 = []; ru8 = [];
%A10 = []; rl10 = []; ru10 = [];
%A11 = []; rl11 = []; ru11 = [];
%A12 = []; rl12 = []; ru12 = [];
%A13 = []; rl13 = []; ru13 = [];
%A14 = []; r14 = [];
%A15 = []; r15 = [];
%A16 = []; r16 = [];
A17 = []; rl17 = []; ru17 = [];
%A18 = []; r18 = [];
%A19 = []; r19 = [];

A  = [A1; A2; A3; A4; A6; A8; A10; A11; A12; A13; A14; A15; A16; A17; A18; A19];
rl = [r1; r2; r3; r4;rl6;rl8;rl10;rl11;rl12;rl13;rl14; r15; r16;rl17;rl18; r19];
ru = [r1; r2; r3; r4;ru6;ru8;ru10;ru11;ru12;ru13;ru14; r15; r16;ru17;ru18; r19];