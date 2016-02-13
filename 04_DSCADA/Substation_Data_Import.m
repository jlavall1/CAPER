%Import Substation Data, re-structure, check for NaN:
clear
clc
close all
fig = 0;
maindir = 'C:\Users\jlavall\Documents\GitHub\CAPER';
maindir = strcat(maindir,'\04_DSCADA\MOCKS');
addpath(maindir);
%{
n=1;
[MSVL.MN(n).YR(1).d, MSVL.MN(1).YR(1).TIME, ~] = xlsread('MocksvilleMn_2401.xlsx','2007');
[MSVL.MN(n).YR(2).d, MSVL.MN(1).YR(2).TIME, ~] = xlsread('MocksvilleMn_2401.xlsx','2008');
[MSVL.MN(n).YR(3).d, MSVL.MN(1).YR(3).TIME, ~] = xlsread('MocksvilleMn_2401.xlsx','2009');
[MSVL.MN(n).YR(4).d, MSVL.MN(1).YR(4).TIME, ~] = xlsread('MocksvilleMn_2401.xlsx','2010');
[MSVL.MN(n).YR(5).d, MSVL.MN(1).YR(5).TIME, ~] = xlsread('MocksvilleMn_2401.xlsx','2011');
[MSVL.MN(n).YR(6).d, MSVL.MN(1).YR(6).TIME, ~] = xlsread('MocksvilleMn_2401.xlsx','2012');
[MSVL.MN(n).YR(7).d, MSVL.MN(1).YR(7).TIME, ~] = xlsread('MocksvilleMn_2401.xlsx','2013');
[MSVL.MN(n).YR(8).d, MSVL.MN(1).YR(8).TIME, ~] = xlsread('MocksvilleMn_2401.xlsx','2014');
n=n+1;
[MSVL.MN(n).YR(1).d, MSVL.MN(n).YR(1).TIME, ~] = xlsread('MocksvilleMn_2402.xlsx','2007');
[MSVL.MN(n).YR(2).d, MSVL.MN(n).YR(2).TIME, ~] = xlsread('MocksvilleMn_2402.xlsx','2008');
[MSVL.MN(n).YR(3).d, MSVL.MN(n).YR(3).TIME, ~] = xlsread('MocksvilleMn_2402.xlsx','2009');
[MSVL.MN(n).YR(4).d, MSVL.MN(n).YR(4).TIME, ~] = xlsread('MocksvilleMn_2402.xlsx','2010');
[MSVL.MN(n).YR(5).d, MSVL.MN(n).YR(5).TIME, ~] = xlsread('MocksvilleMn_2402.xlsx','2011');
[MSVL.MN(n).YR(6).d, MSVL.MN(n).YR(6).TIME, ~] = xlsread('MocksvilleMn_2402.xlsx','2012');
[MSVL.MN(n).YR(7).d, MSVL.MN(n).YR(7).TIME, ~] = xlsread('MocksvilleMn_2402.xlsx','2013');
[MSVL.MN(n).YR(8).d, MSVL.MN(n).YR(8).TIME, ~] = xlsread('MocksvilleMn_2402.xlsx','2014');
n=n+1;
[MSVL.MN(n).YR(1).d, MSVL.MN(n).YR(1).TIME, ~] = xlsread('MocksvilleMn_2403.xlsx','2007');
[MSVL.MN(n).YR(2).d, MSVL.MN(n).YR(2).TIME, ~] = xlsread('MocksvilleMn_2403.xlsx','2008');
[MSVL.MN(n).YR(3).d, MSVL.MN(n).YR(3).TIME, ~] = xlsread('MocksvilleMn_2403.xlsx','2009');
[MSVL.MN(n).YR(4).d, MSVL.MN(n).YR(4).TIME, ~] = xlsread('MocksvilleMn_2403.xlsx','2010');
[MSVL.MN(n).YR(5).d, MSVL.MN(n).YR(5).TIME, ~] = xlsread('MocksvilleMn_2403.xlsx','2011');
[MSVL.MN(n).YR(6).d, MSVL.MN(n).YR(6).TIME, ~] = xlsread('MocksvilleMn_2403.xlsx','2012');
[MSVL.MN(n).YR(7).d, MSVL.MN(n).YR(7).TIME, ~] = xlsread('MocksvilleMn_2403.xlsx','2013');
[MSVL.MN(n).YR(8).d, MSVL.MN(n).YR(8).TIME, ~] = xlsread('MocksvilleMn_2403.xlsx','2014');
n=n+1;
[MSVL.MN(n).YR(1).d, MSVL.MN(n).YR(1).TIME, ~] = xlsread('MocksvilleMn_2404.xlsx','2007');
[MSVL.MN(n).YR(2).d, MSVL.MN(n).YR(2).TIME, ~] = xlsread('MocksvilleMn_2404.xlsx','2008');
[MSVL.MN(n).YR(3).d, MSVL.MN(n).YR(3).TIME, ~] = xlsread('MocksvilleMn_2404.xlsx','2009');
[MSVL.MN(n).YR(4).d, MSVL.MN(n).YR(4).TIME, ~] = xlsread('MocksvilleMn_2404.xlsx','2010');
[MSVL.MN(n).YR(5).d, MSVL.MN(n).YR(5).TIME, ~] = xlsread('MocksvilleMn_2404.xlsx','2011');
[MSVL.MN(n).YR(6).d, MSVL.MN(n).YR(6).TIME, ~] = xlsread('MocksvilleMn_2404.xlsx','2012');
[MSVL.MN(n).YR(7).d, MSVL.MN(n).YR(7).TIME, ~] = xlsread('MocksvilleMn_2404.xlsx','2013');
[MSVL.MN(n).YR(8).d, MSVL.MN(n).YR(8).TIME, ~] = xlsread('MocksvilleMn_2404.xlsx','2014');
%%
filename = strcat(maindir,'\Mocks_MAIN_SUB');
delete(filename);
save(filename,'MSVL');
%}
load Mocks_MAIN_SUB.mat
%TIME       KW      KVAR    AMPS   PI_time   header
DOM=[...
2007  31  28  31  30  31  30  31  31  30  31  30  31
2008  31  29  31  30  31  30  31  31  30  31  30  31
2009  31  28  31  30  31  30  31  31  30  31  30  31
2010  31  28  31  30  31  30  31  31  30  31  30  31
2011  31  28  31  30  31  30  31  31  30  31  30  31
2012  31  29  31  30  31  30  31  31  30  31  30  31
2013  31  28  31  30  31  30  31  31  30  31  30  31
2014  31  28  31  30  31  30  31  31  30  31  30  31
2015  31  28  31  30  31  30  31  31  30  31  30  31];
%[MSVL.MN(n).YR(8).d
d_go=1;
d_sp=24;


for n=1:1:4
    %MSVL.SUB.YR(yr).KW_3PH(d_go:d_sp,1)=0;
    for yr=2:1:8
        for mn=1:1:12
            for dy=1:1:DOM(yr,mn+1)
                %Find all fields of interest:
                MSVL.MN(n).YR(yr).KW_3PH(d_go:d_sp,1)=0;
                MSVL.MN(n).YR(yr).KQ_3PH(d_go:d_sp,1)=0;
                for ph=1:1:3
                    shift = ph+(ph-1)*1;
                    shift_2= (ph-2)+3+(ph-1)*1;
                    fprintf('Column in Excel| %0.0f & %0.0f\n',shift,shift_2);
                    
                    MSVL.MN(n).YR(yr).KW(d_go:d_sp,ph)=MSVL.MN(n).YR(yr).d(d_go:d_sp,shift);
                    MSVL.MN(n).YR(yr).KQ(d_go:d_sp,ph)=MSVL.MN(n).YR(yr).d(d_go:d_sp,shift_2);
                    
                    MSVL.MN(n).YR(yr).KW_3PH(d_go:d_sp,1)=MSVL.MN(n).YR(yr).KW_3PH(d_go:d_sp,1)+(MSVL.MN(n).YR(yr).d(d_go:d_sp,shift))/1000;
                    MSVL.MN(n).YR(yr).KQ_3PH(d_go:d_sp,1)=MSVL.MN(n).YR(yr).KQ_3PH(d_go:d_sp,1)+(MSVL.MN(n).YR(yr).d(d_go:d_sp,shift_2))/1000;
                end             
                d_go=d_go+24;
                d_sp=d_sp+24;
            end
        end
        %reset spot:
        d_go=1;
        d_sp=24;
    end
end
%%
% if dy == 1
%                     MSVL.SUB(1).YR(yr).KW_3PH(d_go:d_sp,1)=zeros(24,1);
% end
% 
% MSVL.SUB(1).YR(yr).KW_3PH(d_go:d_sp,1)=MSVL.SUB.YR(yr).KW_3PH(d_go:d_sp,1)+MSVL.MN(n).YR(yr).KW_3PH(d_go:d_sp,1);

for n=1:1:4
    for yr=2:1:8
        if n == 1
            m=length(MSVL.MN(n).YR(yr).KW_3PH);
            MSVL.SUB.YR(yr).MW_3PH=zeros(m,1);
            MSVL.SUB.YR(yr).MQ_3PH=zeros(m,1);
        end
        
        for t=1:1:m
            MSVL.SUB.YR(yr).MW_3PH(t,1)=MSVL.SUB.YR(yr).MW_3PH(t,1)+MSVL.MN(n).YR(yr).KW_3PH(t,1);
            MSVL.SUB.YR(yr).MQ_3PH(t,1)=MSVL.SUB.YR(yr).MQ_3PH(t,1)+MSVL.MN(n).YR(yr).KQ_3PH(t,1);
            MSVL.SUB.YR(yr).MVA_3PH(t,1)=sqrt( (MSVL.SUB.YR(yr).MW_3PH(t,1)^2)+(MSVL.SUB.YR(yr).MQ_3PH(t,1))^2);
        end
    end
end
%%
fig=fig+1;
figure(fig)
%2008
n=2;
X=(1/24):(1/24):length(MSVL.SUB.YR(n).MVA_3PH(:,1))/24;
plot(X,MSVL.SUB.YR(n).MVA_3PH(:,1),'r-');
hold on
%2009
n = n +1;
X2=(1/24):(1/24):length(MSVL.SUB.YR(n).MVA_3PH(:,1))/24;
X2 = X2+max(X);
plot(X2,MSVL.SUB.YR(n).MVA_3PH(:,1),'b-');
hold on
%2010
n = n +1;
X3=(1/24):(1/24):length(MSVL.SUB.YR(n).MVA_3PH(:,1))/24;
X3 = X3+max(X2);
plot(X3,MSVL.SUB.YR(n).MVA_3PH(:,1),'g-');
hold on
%2011
n = n +1;
X4=(1/24):(1/24):length(MSVL.SUB.YR(n).MVA_3PH(:,1))/24;
X4 = X4+max(X3);
plot(X4,MSVL.SUB.YR(n).MVA_3PH(:,1),'k-');
hold on
%2012
n = n +1;
X5=(1/24):(1/24):length(MSVL.SUB.YR(n).MVA_3PH(:,1))/24;
X5 = X5+max(X4);
plot(X5,MSVL.SUB.YR(n).MVA_3PH(:,1),'c-');
hold on
%2013
n = n +1;
X6=(1/24):(1/24):length(MSVL.SUB.YR(n).MVA_3PH(:,1))/24;
X6 = X6+max(X5);
plot(X6,MSVL.SUB.YR(n).MVA_3PH(:,1),'m-');
hold on
%2014
n = n +1;
X7=(1/24):(1/24):length(MSVL.SUB.YR(n).MVA_3PH(:,1))/24;
X7 = X7+max(X6);
plot(X7,MSVL.SUB.YR(n).MVA_3PH(:,1),'y-');
hold on
legend('2008','2009','2010','2011','2012(PV)','2013(PV)','2014(2PV)');
xlabel('Day # from 1/1/2008','FontWeight','bold','FontSize',12);
ylabel('Substation Load ( S_{3{\phi}  }) [MVA]','FontWeight','bold','FontSize',12);
set(gca,'FontWeight','bold');
grid on


            
            






















%%
%{
%load MOCKS_MAIN.mat
%{
[MSVL_2401, Time_1, ~] = xlsread('MocksvilleMn_2401.xlsx', 'MocksvilleMn_2401');
[MSVL_2402, Time_2, ~] = xlsread('MocksvilleMn_2402.xlsx', 'MocksvilleMn_2402');
[MSVL_2403, Time_3, ~] = xlsread('MocksvilleMn_2403.xlsx', 'MocksvilleMn_2403');
[MSVL_2404, Time_4, ~] = xlsread('MocksvilleMn_2404.xlsx', 'MocksvilleMn_2404');

for j=1:1:4
    FEED.header = Time_1(2,:);
    if j == 1
        MSVL=MSVL_2401;
        FEED.TIME = Time_1(3:end,1);
    elseif j == 2
        MSVL=MSVL_2402;
        FEED.TIME = Time_2(3:end,1);
    elseif j == 3
        MSVL=MSVL_2403;
        FEED.TIME = Time_3(3:end,1);
    elseif j == 4
        MSVL=MSVL_2404;
        FEED.TIME = Time_4(3:end,1);
    end
    %Restructure:
    FEED.KW(:,1) = MSVL(:,1);
    FEED.KW(:,2) = MSVL(:,3);
    FEED.KW(:,3) = MSVL(:,5);
    FEED.KVAR(:,1) = MSVL(:,2);
    FEED.KVAR(:,2) = MSVL(:,4);
    FEED.KVAR(:,3) = MSVL(:,6);
    FEED.AMPS(:,1) = MSVL(:,7);
    FEED.AMPS(:,2) = MSVL(:,8);
    FEED.AMPS(:,3) = MSVL(:,9);
    FEED.PI_time = MSVL(:,10);
    if j == 1
        MOCKS_MAIN(1)=FEED;
    elseif j == 2
        MOCKS_MAIN(2)=FEED;
    elseif j == 3
        MOCKS_MAIN(3)=FEED;
    elseif j == 4
        MOCKS_MAIN(4)=FEED;
    end
end
%}
%TIME       KW      KVAR    AMPS   PI_time   header
DOM=[2007  31  28  31  30  31  30  31  31  30  31  30  31
2008  31  29  31  30  31  30  31  31  30  31  30  31
2009  0   0   0   0   0   0   0   31  30  31  30  31
2010  31  28  31  30  31  30  31  31  30  31  30  31
2011  31  28  31  30  31  30  31  31  30  31  30  31
2012  31  29  31  30  31  30  31  31  30  31  30  31
2013  31  28  31  30  31  30  31  31  30  31  30  31
2014  31  28  31  30  31  30  31  31  30  31  30  31
2015  31  28  31  30  31  30  31  31  30  31  30  31];
inc=1;
spot=0;
for j=1:1:1
    for yr=1:1:1
        for mnth=1:1:12
            if mnth < 8 && yr == 1
                fprintf('skip\n');
            else
                %Extract --------------
                if yr==1 && mnth == 8
                    dy_str=7;
                else
                    dy_str=1;
                end

                for dy=dy_str:1:DOM(yr,mnth)
%                     if dy_str == 1
%                         spot=spot+dy+(dy-1)*25
%                     else
%                         spot=1+(dy-8)*25
%                     end
                    MOCKS_YR(yr).KW(inc:inc+24,1:3)=MOCKS_MAIN(j).KW(inc:inc+24,1:3);
                    MOCKS_YR(yr).TIME(inc:inc+24,1)=MOCKS_MAIN(j).TIME(inc:inc+24,1);
                    inc = inc + 25
                end
            end
        end
        inc=1;
    end
end
%}
            