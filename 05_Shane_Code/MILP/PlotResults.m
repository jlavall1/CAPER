% Plot LP Results
figure; cmap = colormap(hsv);
% DER Locations
[~,~,ic] = unique([{NODE.ID},{DER.ID}],'stable');
h(1) = plot([NODE(ic(end-D+1:end)).XCoord],[NODE(ic(end-D+1:end)).YCoord],'kh','MarkerSize',15,'MarkerFaceColor',[0,0.5,1],'LineStyle','none');
set(gca,'YTick',[])
set(gca,'XTick',[])
hold on

Open = true(1,S);
for i = 1:D
    if round(sum([DER.(['alpha_MG',int2str(i)])]))
    % Nodes
    index = logical(round([NODE.(['a_MG',int2str(i)])]));
    h(end+1) = plot([NODE(index).XCoord],[NODE(index).YCoord],'.',...
        'Color',cmap(floor(64/D)*(i-1)+round(64/(2*D)),:),'MarkerSize',20); %hsv2rgb([(i-1)/D .5 .5])
    
    % Sections
    sec = logical(round([SECTION.(['b_MG',int2str(i)])]));
    Open = Open.*~sec;
    Closed = SECTION(sec);
    for j = 1:length(Closed)
        index = [find(ismember({NODE.ID},Closed(j).FROM)),find(ismember({NODE.ID},Closed(j).TO))];
        plot([NODE(index).XCoord],[NODE(index).YCoord],'-','Color',cmap(floor(64/D)*(i-1)+round(64/(2*D)),:),'LineWidth',2.5)
    end
    
    % Loads
    index = logical(round([LOAD.(['alpha_MG',int2str(i)])]));
    plot([LOAD(index).XCoord],[LOAD(index).YCoord],'ko','MarkerSize',4,'MarkerFaceColor','w','LineStyle','none');
    end
end

% Open Sections
Open = SECTION(logical(Open));

for i = 1:length(Open)
    index = [find(ismember({NODE.ID},Open(i).FROM)),find(ismember({NODE.ID},Open(i).TO))];
    ho = plot([NODE(index).XCoord],[NODE(index).YCoord],'-r','LineWidth',2);
end

% Faulted Sections
[~,~,ic] = unique([{SECTION.ID},PARAM.SO],'stable');

for i = S+1:length(ic)
    index = [find(ismember({NODE.ID},SECTION(ic(i)).FROM)),find(ismember({NODE.ID},SECTION(ic(i)).TO))];
    hf = plot(mean([NODE(index).XCoord]),mean([NODE(index).YCoord]),'xr','MarkerSize',20);
end

%legend([hs,hl,ho],'Source','Load','Normally Open Section')
legend(h(2:end),MG)
%legend([hs,hl,ho,h],'Source','Load','Normally Open Section',MG)
