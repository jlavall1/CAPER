clc
for i = 1:m
    ZONE.(strcat('DER',D{i})) = N(gamma(:,i)>.5);
    fprintf('Connected Nodes in Zone %d\n',i)
    disp(ZONE.(strcat('DER',D{i})))
    
    LOAD.(strcat('DER',D{i})) = N(c(:,i)>.5);
    fprintf('Loads Supplied in Zone %d\n',i)
    disp(LOAD.(strcat('DER',D{i})))
    fprintf('Loads NOT Supplied in Zone %d\n',i)
    disp(N(logical(p.*(gamma(:,i)>.5).*(c(:,i)<.5))))
    
    POWER.(strcat('DER',D{i}))(1,1) = sum(p(logical(    c(:,i))));
    POWER.(strcat('DER',D{i}))(1,2) = sum(q(logical(    c(:,i))));
end
disp(POWER)