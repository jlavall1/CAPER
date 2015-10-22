% Snap to grid function for CYME file
clc
filename = 'Bellhaven_ret_01291204_Simplified.sxst';
savename = 'Bellhaven_ret_01291204_Simplified_.sxst';

% Read File
FILE = fileread(filename);

% Find Nodes
start  = strfind(FILE,'<Node>');
finish = strfind(FILE,'</Node>');
% Display information
fprintf('%d Nodes found\n',length(start))

for i = length(start):-1:1
    % Separate out Node Information
    OLDNODE = FILE(start(i):finish(i));
    
    % Round X position to nearest 25
    x_start  = strfind(OLDNODE,'<X>');
    oldx = sscanf(OLDNODE(x_start:end),'<X>%f');
    newx = round(oldx/25)*25;
    % Round Y position to nearest 25
    y_start  = strfind(OLDNODE,'<Y>');
    oldy = sscanf(OLDNODE(y_start:end),'<Y>%f');
    newy = round(oldy/25)*25;
    
    % Replace in Node Information
    NEWNODE = strrep(OLDNODE,['<X>',num2str(oldx,'%.6f'),'</X>'],['<X>',num2str(newx,'%.6f'),'</X>']);
    NEWNODE = strrep(NEWNODE,['<Y>',num2str(oldy,'%.6f'),'</Y>'],['<Y>',num2str(newy,'%.6f'),'</Y>']);
    % Replace in file
    FILE = strrep(FILE,OLDNODE,NEWNODE);
    
    % Display what happened
    fprintf('\n%s\nOld: %12.6f\tNew: %12.6f\nOld: %12.6f\tNew: %12.6f\n',OLDNODE(8:19),oldx,newx,oldy,newy)
end

% Save file
fileID = fopen(savename,'w');
fprintf(fileID,'%s',FILE);
fclose(fileID);

