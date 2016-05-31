close all

figure(1)
plot([dist.LONG],[dist.LAT],'.w','MarkerSize',15);
plotGoogleMap
axis([-83.35 -78.55 33.8 36.8 ])

%%
figure(2)
h(1:length(res_conn)) = plot([res_conn.LONG]',[res_conn.LAT]','.c','MarkerSize',15);
hold on
g(1:length(comm_conn)) = plot([comm_conn.LONG]',[comm_conn.LAT]','.g','MarkerSize',15);
hold on
hh(1:length(utility_conn)) = plot([utility_conn.LONG]',[utility_conn.LAT]','.r','MarkerSize',20);
hold on
gg(1:length(res_pend)) = plot([res_pend.LONG]',[res_pend.LAT]','.y','MarkerSize',15);
hold on
jj(1:length(comm_pend)) = plot([comm_pend.LONG]',[comm_pend.LAT]','.b','MarkerSize',15);
hold on
kk(1:length(utility_pend)) = plot([utility_pend.LONG]',[utility_pend.LAT]','.m','MarkerSize',20);
plotGoogleMap
axis([-84 -78 34 37])
legend([h(1) g(1) hh(1) gg(1) jj(1) kk(1)],'Residential (CONN)','Commerical (CONN)','Utility Scale (CONN)','Residential (PEND)','Commerical (PEND)','Utility Scale (PEND)','Location','SouthEast');
%legend([h(1)],'CSKLJ','Location','SouthEast');
%%
figure(3)

qq(1:length(substation_matches)) = plot([substation_matches.LONG]',[substation_matches.LAT]','-kh','MarkerSize',13,'MarkerFaceColor',[0,0.5,1],'LineStyle','none');
hold on
pp(1) = plot(bell_long,bell_lat,'xr','MarkerSize',20,'LineWidth',4);
plotGoogleMap
axis([-81.69 -80.93 34.94 35.52])
legend([pp(1) qq(1)],'Substation 1','Vicinity','Location','SouthEast');