%Plot Solar Coeff





%Plot 1) Monthly Averages of VI/DARR:
M_VI = zeros(12,1);
M_CI = zeros(12,1);
M_DARR = zeros(12,1);
hit = 0;
for n=1:1:12
    for d=1:1:365
        if M_PVSITE_SC(d,2) == n
            M_VI(n) = M_VI(n) + M_PVSITE_SC(d,4);
            M_CI(n) = M_CI(n) + M_PVSITE_SC(d,5);
            M_DARR(n) = M_DARR(n) + M_PVSITE_SC(d,6);
            hit = hit + 1;
        end
    end
    M_VI(n) = M_VI(n)/hit;
    M_CI(n) = M_CI(n)/hit;
    M_DARR(n) = M_DARR(n)/hit;
    hit = 0;
end
%%
%--------------------------------------------------------------------------
%Plot showing change in overall variability of Solar each month.
fig = 0;
fig = fig + 1;
figure(fig);
X=[1:1:12];
[AX,H1,H2]= plotyy(X,M_VI,X,M_DARR);
set(H1,'LineWidth',2);
set(H2,'LineWidth',2);
grid on
ylabel(AX(1),'Variability Index (VI)','FontSize',12,'FontWeight','bold');
ylabel(AX(2),'Daily Aggregate Ramp Rate (DARR)','FontSize',12,'FontWeight','bold');
xlabel('Month of Year','FontSize',12,'FontWeight','bold');
legend('Monthly Average VI','Monthly Average DARR','Location','SouthWest');
set(gca,'FontWeight','bold');
set(AX,'xtick',[1:1:12])
%axis([1 12 0 20]);
%
%--------------------------------------------------------------------------
%Plot to justify why 3 month run was conducted.
fig = fig + 1;
figure(fig);
h1=plot(X,M_CI,'r-','LineWidth',2);
hold on
h2=plot(X,LOAD(2).KW_avg/LOAD(2).MAX,'b-','LineWidth',1.5);
hold on
h3=plot(X,LOAD(3).KW_avg/LOAD(3).MAX,'b--','LineWidth',1.5);
hold on
h4=plot(X,M_CI-LOAD(2).KW_avg/LOAD(2).MAX,'k-','LineWidth',2);
hold on
h5=plot(X,M_CI-LOAD(3).KW_avg/LOAD(3).MAX,'k--','LineWidth',2);
hold on
X=ones(7,1);
Y=[0;0.2;0.4;0.6;0.8;1.0;1.2];
plot(X*2,Y,'m--','LineWidth',2.5);
hold on
plot(X*5,Y,'m--','LineWidth',2.5);

legend([h1 h2 h3 h4 h5],'Solar CI Avg.','Feeder 02 Daytime Load Avg.','Feeder 03 Daytime Load Avg.','Feeder 02 Difference: CI & Pavg','Feeder 03 Difference: CI & Pavg');
axis([1 12 -0.1 1.2]);
grid on
xlabel('Month of Year','FontSize',12,'FontWeight','bold');
ylabel('Per Unit (PU)','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
