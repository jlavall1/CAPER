% Solves the MILP for the 124 node reduced version of Commonwealth 01311205
%  with 6 DERs and 3 main line Faults
clear
clc

% Define System Parameters
filename = 'Commonwealth_reduced.xlsx';
n = 124;        % number of nodes
m = 6;          % number of DERs

% Read Excel Data
[NODE,SECTION,DER,DSCS] = ExcelRead(filename,n);

% Formulate Problem
[f,intcon,Aineq,bineq,Aeq,beq,lb,ub] = MILPFormulation(NODE,SECTION,DER,DSCS);

% Solve Problem
[X,fval,exitflag,output] = intlinprog(f,intcon,Aineq,bineq,Aeq,beq,lb,ub);

% Seperate out Variables
a = X(  1:  n  );
b = X(n+1:2*n-1);
c = []; gamma=[]; P = []; Q = []; V = []; delta = [];
for k = 1:m
    c     = [c    ,X((k+1    )*n:(k+2    )*n-1)];
    gamma = [gamma,X((k+1+  m)*n:(k+2+  m)*n-1)];
    P     = [P    ,X((k+1+2*m)*n:(k+2+2*m)*n-1)];
    Q     = [Q    ,X((k+1+3*m)*n:(k+2+3*m)*n-1)];
    V     = [V    ,X((k+1+4*m)*n:(k+2+4*m)*n-1)];
    delta = [delta,X((k+1+5*m)*n:(k+2+5*m)*n-1)];
end

