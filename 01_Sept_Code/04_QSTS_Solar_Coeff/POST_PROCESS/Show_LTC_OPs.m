%Shows LTC OPS
%plot showing # LTC tap changes per day:
n = 1;
addpath(path1);
if Feeder == 2
    load YR_SIM_OLTC_CMNW_00.mat    %YEAR_LTC
elseif Feeder == 3
    load YR_SIM_OLTC_FLAY_00.mat    %YEAR_LTC
end
RUN(n).YEAR_LTC = YEAR_LTC;
clear YEAR_LTC

n = 2;
addpath(path2);
if Feeder == 2
    load YR_SIM_OLTC_CMNW_025.mat    %YEAR_LTC
elseif Feeder == 3
    load YR_SIM_OLTC_FLAY_010.mat    %YEAR_LTC
end
RUN(n).YEAR_LTC = YEAR_LTC;
clear YEAR_LTC

n = 3;
addpath(path3);
if Feeder == 2
    load YR_SIM_OLTC_CMNW_050.mat    %YEAR_LTC
elseif Feeder == 3
    load YR_SIM_OLTC_FLAY_025.mat    %YEAR_LTC
end
RUN(n).YEAR_LTC = YEAR_LTC;
clear YEAR_LTC
%%

m = 1;
count = zeros(120,3);
n = 1;
RUN_1(1).OLTC = zeros(256320,2);
for DOY=32:1:120
    %Count TAP Changes:
    for t=30:30:86400
        if RUN(n).YEAR_LTC(DOY).OP(t,3) ~= RUN(n).YEAR_LTC(DOY).OP(t-30+1,3)
            count(DOY,n)=count(DOY,n)+1;
        end
        %Sample every 60 seconds
        RUN_1(1).OLTC(m,1) = RUN(n).YEAR_LTC(DOY).OP(t,3);
        RUN_1(1).TIME(m,2) = m/2880;
        m = m + 1;
    end
    disp(DOY)
end
n = 2;
m = 1;
RUN_1(2).OLTC = zeros(256320,2);
for DOY=32:1:120
    %Count TAP Changes:
    for t=30:30:86400
       
        if RUN(n).YEAR_LTC(DOY).OP(t,3) ~= RUN(n).YEAR_LTC(DOY).OP(t-30+1,3)
            count(DOY,n)=count(DOY,n)+1;
        end
        %Sample every 60 seconds
        RUN_1(2).OLTC(m,1) = RUN(n).YEAR_LTC(DOY).OP(t,3);
        RUN_1(2).TIME(m,2) = m/2880;
        m = m + 1;
    end
    disp(DOY)
end
n = 3;
m = 1;
RUN_1(3).OLTC = zeros(256320,2);
for DOY=32:1:120
    %Count TAP Changes:
    for t=30:30:86400
       
        if RUN(n).YEAR_LTC(DOY).OP(t,3) ~= RUN(n).YEAR_LTC(DOY).OP(t-30+1,3)
            count(DOY,n)=count(DOY,n)+1;
        end
        %Sample every 60 seconds
        RUN_1(3).OLTC(m,1) = RUN(n).YEAR_LTC(DOY).OP(t,3);
        RUN_1(3).TIME(m,2) = m/2880;
        m = m + 1;
    end
    disp(DOY)
end
%%
if Feeder == 2
    fn1='\YR_SIM_CMNW_SUMTAP';
    fn2='\YR_SIM_CMNW_TAPPOS';
elseif Feeder == 3
    fn1='\YR_SIM_FLAY_SUMTAP';
    fn2='\YR_SIM_FLAY_TAPPOS';
end
fn=strcat('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\POST_PROCESS',fn1);
save(fn,'count');
fn=strcat('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\POST_PROCESS',fn2);
save(fn,'RUN_1');

%%
%Plot Results:
fig = fig + 1;
figure(fig)

plot(count(:,1),'b-','LineWidth',2);
hold on
plot(count(:,2),'r-','LineWidth',2.5);
hold on
plot(count(:,3),'g-','LineWidth',2);
legend('Base','POI1','POI2','Location','NorthWest');
axis([30 120 -5 25])
xlabel('Day of Year','FontSize',12,'FontWeight','bold');
ylabel('Number of Tap Changes per Day','FontSize',12,'FontWeight','bold');
set(gca,'FontWeight','bold');
grid on

%{
X=[1:1:120]';
X=[X,X,X];
hb = bar(X,count);
set(hb(1), 'FaceColor','b');
set(hb(2), 'FaceColor','r');
set(hb(3), 'FaceColor','g');
%}