close all
figure(1)
plot([dist.LONG],[dist.LAT],'xw','MarkerSize',5);
plotGoogleMap
%axis([X_min X_Max Y_min Y_max])
%%
figure(2)
h(1:length(res_conn)) = plot([res_conn.LONG]',[res_conn.LAT]','.c','MarkerSize',10);
hold on
g(1:length(comm_conn)) = plot([comm_conn.LONG]',[comm_conn.LAT]','.g','MarkerSize',10);
hold on
hh(1:length(utility_conn)) = plot([utility_conn.LONG]',[utility_conn.LAT]','.r','MarkerSize',10);
hold on
gg(1:length(res_pend)) = plot([res_pend.LONG]',[res_pend.LAT]','.y','MarkerSize',10);
hold on
jj(1:length(comm_pend)) = plot([comm_pend.LONG]',[comm_pend.LAT]','.b','MarkerSize',10);
hold on
kk(1:length(utility_pend)) = plot([utility_pend.LONG]',[utility_pend.LAT]','.m','MarkerSize',10);
plotGoogleMap
axis([-84 -78 34 37])
legend([h(1) g(1) hh(1) gg(1) jj(1) kk(1)],'Residential (CONN)','Commerical (CONN)','Utility Scale (CONN)','Residential (PEND)','Commerical (PEND)','Utility Scale (PEND)','Location','SouthEast');
%legend([h(1)],'CSKLJ','Location','SouthEast');