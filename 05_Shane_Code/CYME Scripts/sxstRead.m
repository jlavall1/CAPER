% Snap to grid function for CYME file
clc
%filename = 'Flay 12-01 - 2-3-15 loads (original).sxst';
filename = 'Commonwealth 12-05-  9-14 loads (original).sxst';

% Read File
FILE = fileread(filename);

% Find Nodes
n = length(strfind(FILE,'<Node>'));
s = length(strfind(FILE,'<Section>'));
l = length(strfind(FILE,'<SpotLoad>'));
fprintf('%d Nodes; %d Sections; %d Loads\n',n,s,l)

% Extract Node Information
nodeinfo = regexp(FILE,'<Node>(.*?)</Node>','match');
for i = 1:length(nodeinfo)
    NODE(i).ID = regexp(nodeinfo{i},'(?<=<NodeID>)(.*?)(?=</NodeID>)','match');
end
    
nodeinfo = nodeinfo{1,1};

NODE.ID = regexp(nodeinfo,'(?<=<NodeID>)(.*?)(?=</NodeID>)','match')';

nodex  = regexp(nodeinfo,'(?<=<X>)(.*?)(?=</X>)','match');
nodey  = regexp(nodeinfo,'(?<=<Y>)(.*?)(?=</Y>)','match');
NODE.COORD = zeros(n,2);
for i = 1:n
    NODE.COORD(i,1) = str2double(nodex{i});
    NODE.COORD(i,2) = str2double(nodey{i});
end

% Extract Section Information
sectinfo = regexp(FILE,'<Sections>(.*?)</Sections>','match');
sectinfo = sectinfo{1,1};

from = regexp(sectinfo,'(?<=<FromNodeID>)(.*?)(?=</FromNodeID>)','match')';
to   = regexp(sectinfo,'(?<=<ToNodeID>)(.*?)(?=</ToNodeID>)',    'match')';
SECTION.ID = [from,to];

%