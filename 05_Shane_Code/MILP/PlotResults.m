% Plot LP Results
figure; cmap = colormap(hsv);
% DER Locations
[~,~,ic] = unique([{NODE.ID},{DER.ID}],'stable');
plot([NODE(ic(end-D:end)).XCoord],[NODE(ic(end-D:end)).YCoord],'sb','MarkerSize',20)
hold on

% Nodes and Loads
for i = 1:D
    index = find(logical([NODE.(['alpha_MG',int2str(i)])]));
    plot([NODE(index).XCoord],[NODE(index).YCoord],'.',...
        'Color',cmap(floor(64/D)*(i-1)+1,:),'MarkerSize',20) %hsv2rgb([(i-1)/D .5 .5])
    
    load = [];
    for j = 1:length(index)
        load = [load,find(ismember({LOAD.ID},NODE(j).ID))];
    end
    
    plot([LOAD(load).XCoord],...
         [LOAD(load).YCoord],'^',...
        'Color',cmap(floor(64/D)*(i-1)+1,:),'MarkerSize',20)
%     plot([LOAD(logical([LOAD.MGNumber]==i)).XCoord],...
%          [LOAD(logical([LOAD.MGNumber]==i)).YCoord],'^',...
%         'Color',cmap(floor(64/D)*(i-1)+1,:),'MarkerSize',20)
end

% Sections
Closed = SECTION( logical([SECTION.b]));
Open   = SECTION(~logical([SECTION.b]));

for i = 1:length(Closed)
    index = [find(ismember({NODE.ID},Closed(i).FROM)),find(ismember({NODE.ID},Closed(i).TO))];
    plot([NODE(index).XCoord],[NODE(index).YCoord],'-k')
end

for i = 1:length(Open)
    index = [find(ismember({NODE.ID},Open(i).FROM)),find(ismember({NODE.ID},Open(i).TO))];
    plot([NODE(index).XCoord],[NODE(index).YCoord],'-r')
end
