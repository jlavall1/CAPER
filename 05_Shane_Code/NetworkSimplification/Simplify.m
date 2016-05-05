% Simplify.m is a driver for testing the function SimplifyGraph.m

global NODE SECTION

% Read in Graph
[NODE,SECTION,~,~,~,~] = sxstRead;
% Remove Open points
SECTION = SECTION([SECTION.NormalStatus]);
% Remove End of feeder Nodes
[~,~,ic] = unique([{'264487210','264487418'},{NODE.ID}],'stable');
NODE(ic(3:end)<=2) = [];

% Keep only 3ph
node = {};
section = {SECTION([SECTION.numPhase]==3).ID};

% combine first 8 spans after the regulator
[~,~,ic] = unique([{'290683555','290683439','290683436','290683469',...
    '290683470','258405603','258405610','258405615'},section],'stable');
section(ic(9:end)<=8) = [];


% Call Simplification function
SimplifyGraph(node,section)


%% Plot Reduced Graph
N = length(NODE);
S = length(SECTION);
MaxLoad = max([NODE.kW]);

fig = figure;
hold on

for i = 1:S
    index = [find(ismember({NODE.ID},SECTION(i).FROM)),find(ismember({NODE.ID},SECTION(i).TO))];
    plot([NODE(index).XCoord],[NODE(index).YCoord],'-k','LineWidth',2.5)
    hold on
end

for i = 1:N
    if NODE(i).kW>0
        h(3) = plot(NODE(i).XCoord,NODE(i).YCoord,'ko','MarkerSize',4*10^(NODE(i).kW/MaxLoad),...
            'MarkerFaceColor','w','LineStyle','none');
    end
end