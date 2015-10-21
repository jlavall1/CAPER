function [N,S,w,p,q,r,x,D,Pmax_d,Qmax_d,theta_d,zeta_d,...
    c_const,Imax] = ExcelRead(filename,n)
% ExcelRead.m reads in circuit data from an the spredsheet named 'filename'
%  The spreadsheet should have two sheets named 'Nodes' and 'Sections'
%  n is the number of nodes

[~,~,DATA1] = xlsread(filename,'Nodes',['B2:M',num2str(n+1)]);

N = DATA1(:,1);
p = cell2mat(DATA1(:,2));
q = cell2mat(DATA1(:,3));
priority = cell2mat(DATA1(:,4));
w = 10.^(2*priority);
theta_d = DATA1(:,7:12);

[Smax_d,D,~] = xlsread(filename,'Nodes',['P2:Q',num2str(n+1)]);

% Assuming a minimum power factor of 0.95
Pmax_d = 0.9*Smax_d;
Qmax_d = 0.19*Smax_d;

[~,~,DATA3] = xlsread(filename,'Sections',['B2:P',num2str(n)]);

S = DATA3(:,1:2);
r = cell2mat(DATA3(:,3));
x = cell2mat(DATA3(:,4));
zeta_d = DATA3(:,10:15);
c_const = ~cell2mat(DATA3(:,6));
Imax = cell2mat(DATA3(:,5));

