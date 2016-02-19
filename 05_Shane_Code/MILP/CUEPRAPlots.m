DSSInitialize;

DSSText.command = 'Edit Line.264495349 enabled=no';
DSSCircuit.Solution.Solve

figure;
subplot(2,1,1)
plotKWProfile(DSSCircObj);
xlabel('Distance from Source (km)','FontWeight','bold','FontSize',12)
subplot(2,1,2)
plotVoltageProfile(DSSCircObj);
xlabel('Distance from Source (km)','FontWeight','bold','FontSize',12)
figure; plotCircuitLines(DSSCircObj,'SubstationMarker','off','CapacitorMarker','off','Coloring','distance');
set(gca,'xTickLabel',[])
set(gca,'yTickLabel',[])
title('Distance from Source (km)','FontWeight','bold','FontSize',12);






% DSSText.command = 'Edit Line.264495349 enabled=no';
% DSSText.command = 'Edit Line.CKT_TIE4_SW enabled=yes';
% DSSCircuit.Solution.Solve
% 
% [NODE,SECTION,LOAD,DER,PARAM,DSS] = sxstRead;
% 
% DSSText.command = 'BatchEdit Line..* enabled=yes';
% DSSCircuit.Solution.Solve
% plotCircuitLines(DSSCircObj,'SubstationMarker','off','CapacitorMarker','off');
% hold on
% [~,index] = sortrows({NODE.ID}.'); NODE = NODE(index(end:-1:1)); clear index
% h(1) = plot([NODE(1).XCoord],[NODE(1).YCoord],'sb','MarkerSize',20);
% plot([NODE([2 3 4 5]).XCoord],[NODE([2 3 4 5]).YCoord],'sb','MarkerSize',20)
% h(2) = plot(mean([NODE([97 605]).XCoord]),mean([NODE([97 605]).YCoord]),'xr','MarkerSize',20);
% legend(h,'Source','Fault')