clc

for i = 1:m
    ZONE.(strcat('DER',DER.ID{i})) = NODE.ID(gamma(:,i)>.5);
    fprintf('Connected Nodes in Zone %d\n',i)
    disp(ZONE.(strcat('DER',DER.ID{i})))
    
    LOAD.(strcat('DER',DER.ID{i})) = NODE.ID(c(:,i)>.5);
    fprintf('Loads Supplied in Zone %d\n',i)
    disp(LOAD.(strcat('DER',DER.ID{i})))
    fprintf('Loads NOT Supplied in Zone %d\n',i)
    disp(NODE.ID(logical(NODE.DEMAND(:,1).*(gamma(:,i)>.5).*(c(:,i)<.5))))
    
    POWER.(strcat('DER',DER.ID{i}))(1,1) = sum(NODE.DEMAND(logical(c(:,i)),1));
    POWER.(strcat('DER',DER.ID{i}))(1,2) = sum(NODE.DEMAND(logical(c(:,i)),2));
end
disp(POWER)