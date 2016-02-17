% Snap to grid function for CYME file
clc
filename = 'Flay_ret_16271201_Simplified_.sxst';

% Read File
FILE = fileread(filename);

% Find Nodes
node_start  = strfind(FILE,'<Node>');
node_finish = strfind(FILE,'</Node>');

% Find Sections
sec_start  = strfind(FILE,'<Section>');
sec_finish = strfind(FILE,'</Section>');

% Display what was found
n = length(node_start);
s = length(sec_start);
fprintf('%d Nodes and %d Sections found\n',n,s)

% Initialize Variables
NODE.ID     = cell(n,1);
NODE.COORD  = zeros(n,2);
SECTION.ID  = cell(s,2);

% Node Information
for i = 1:n
    % Separate out Node Information
    INFO = FILE(node_start(i):node_finish(i));
    
    remain = INFO;
    while true
        [str, remain] = strtok(remain, '<>');
        if isempty(str),  break;  end
        disp(sprintf('%s', str))
    end
    
    % Capture Node ID (assumed to be an integer)
    NODE.ID{i} = int2str(sscanf(INFO,'<Node>\n<NodeID>%d'));
    
    % Capture x and y Coordinates
    x_start  = strfind(INFO,'<X>');
    NODE.COORD(i,1) = sscanf(INFO(x_start:end),'<X>%f');
    y_start  = strfind(INFO,'<Y>');
    NODE.COORD(i,2) = sscanf(INFO(y_start:end),'<Y>%f');
   
    % Display what happened
    fprintf('\nNode ID: %s\nX: %12.6f\tY: %12.6f\n',NODE.ID{i},NODE.COORD(i,1),NODE.COORD(i,2))
end

% Section Information
for i = 1:s
    % Separate out Node Information
    INFO = FILE(sec_start(i):sec_finish(i));
    
    % Capture Node ID (assumed to be an integer)
    SECTION.ID{i,1} = int2str(sscanf(INFO,'<Node>\n<NodeID>%d'));
    
    % Capture x and y Coordinates
    x_start  = strfind(INFO,'<X>');
    NODE.COORD(i,1) = sscanf(INFO(x_start:end),'<X>%f');
    y_start  = strfind(INFO,'<Y>');
    NODE.COORD(i,2) = sscanf(INFO(y_start:end),'<Y>%f');
   
    % Display what happened
    fprintf('\nNode ID: %s\nX: %12.6f\tY: %12.6f\n',NODE.ID{i},NODE.COORD(i,1),NODE.COORD(i,2))
end