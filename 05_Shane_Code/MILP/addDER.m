function [NODE,SECTION,DER] = addDER(NODE,SECTION,DER,der)
% addDER.m adds DER to the nodes in the cell array der

D = length(DER);

% Remove Duplicates
der = unique([{DER.ID},der],'stable');
der = der(D+1:end);
d = length(der);

% Find new der nodes in NODE
[~,~,ic] = unique([{NODE.ID},der],'stable');
ic = ic(end-d+1:end);
if max(ic)>length(NODE)
    error('DER connection node not recognized')
end

for i = D+1:D+d
    % Name DER Node
    ID = sprintf('CKT_TIE%d',i-D);
    
    % Add Node
    NODE(end+1).ID = ID;
    NODE(end).w = 1;
    NODE(end).p = 0;
    NODE(end).q = 0;
    NODE(end).XCoord = NODE(ic(i-D)).XCoord;
    NODE(end).YCoord = NODE(ic(i-D)).YCoord + 20;
    
    % Add Section
    SECTION(end+1).ID = [ID,'_SW'];
    SECTION(end).Phase = 'ABC';
    SECTION(end).FROM = ID;
    SECTION(end).TO = der{i-D};
    SECTION(end).Device = 1;
    SECTION(end).NormalStatus = 0;
    
    % Add DER
    DER(i).ID = ID;
    DER(i).CAPACITY = 10000;
    
end