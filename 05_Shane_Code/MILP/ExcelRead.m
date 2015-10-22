function [NODE,SECTION,DER,PARAM] = ExcelRead(filename,n)
% ExcelRead.m reads in circuit data from an the spredsheet named 'filename'
%  The spreadsheet should have two sheets named 'Nodes' and 'Sections'

[~,~,raw1] = xlsread(filename,'Nodes',['B2:M',num2str(n+1)]);

NODE.ID     = raw1(:,1);
NODE.DEMAND = cell2mat(raw1(:,2:3));
priority    = cell2mat(raw1(:,4));
NODE.WEIGHT = 10.^priority;
NODE.PARENT = raw1(:,7:12);

[capacity_kva,DER.ID,~] = xlsread(filename,'Nodes',['P2:Q',num2str(n+1)]);
% Assuming a minimum power factor of 0.95
pf = 0.95;
DER.CAPACITY = [pf*capacity_kva,(1-pf^2)*capacity_kva];

[~,~,raw2] = xlsread(filename,'Sections',['B2:P',num2str(n)]);

SECTION.ID          = raw2(:,1:2);
SECTION.IMPEDANCE   = cell2mat(raw2(:,3:4));
SECTION.CAPACITY    = cell2mat(raw2(:,5));
SECTION.CHILD       = raw2(:,10:15);

% Generate DSCS
PARAM.SC = find(~cell2mat(raw2(:,6)));   % SECTION CONSTRAINED CLOSED (no switch)
PARAM.SO = [3;7;14];                     % SECTION CONSTRAINED OPEN (faulted sections)
PARAM.NC = [];                           % LOAD CONSTRAINED CLOSED
PARAM.NO = [];                           % LOAD CONSTRAINED OPEN

% Check intersection of SO & SC (remove duplicates from SC)
dup = intersect(PARAM.SC,PARAM.SO);
for i = 1:length(dup)
    PARAM.SC = PARAM.SC(PARAM.SC~=dup(i));
end

% Check intersection of SO & SC (remove duplicates from SC)
dup = intersect(PARAM.SC,PARAM.SO);
for i = 1:length(dup)
    PARAM.SC = PARAM.SC(PARAM.SC~=dup(i));
end

% Other Parameters
PARAM.VOLTAGE = [12.47,0.05];   % [Ref Voltage (kV), Tolerance]

