%This is to show an overall trend on the dPV/dt on (4) select days:
clear
clc
close all
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\05_BESS');


load M_TAYLOR_INFO.mat
load M_MOCKS_INFO.mat
M_PVSITE_INFO_1.RR_distrib = M_MOCKS_INFO.RR_distrib;
M_PVSITE_INFO_1.kW = M_MOCKS_INFO.kW;
M_PVSITE_INFO_1.name = M_MOCKS_INFO.name;
M_PVSITE_INFO_1.VI = M_TAYLOR_INFO.VI;
M_PVSITE_INFO_1.CI = M_TAYLOR_INFO.CI;
load M_MOCKS.mat

for i=1:1:12
    M_PVSITE(i).DAY(:,:) = M_MOCKS(i).DAY(1:end-1,1:6);    
    M_PVSITE(i).RR_1MIN(:,:) = M_MOCKS(i).RR_1MIN(:,1:3);
    M_PVSITE(i).PU(:,:) = M_MOCKS(i).kW(1:end-1,1)./M_PVSITE_INFO_1.kW;
    M_PVSITE(i).GHI = M_MOCKS(i).GHI;
end
load M_MOCKS_SC.mat
M_PVSITE_SC = M_MOCKS_SC;
i = 1;
for d=1:1:length(M_PVSITE_SC)
    VI=M_PVSITE_SC(d,4);
    CI=M_PVSITE_SC(d,5);
    
    if VI < 2 && CI <= 0.5
        M_PVSITE_SC(d,10)=1; %overcast
    elseif VI < 2 && CI > 0.5
        M_PVSITE_SC(d,10)=2; %clear
    elseif VI >= 2 && VI < 5 
        M_PVSITE_SC(d,10)=3; %mild
    elseif VI >= 5 && VI < 10
        M_PVSITE_SC(d,10)=4; %moderate
    elseif VI >= 10 
        M_PVSITE_SC(d,10)=5;
    end
end
%Taking a sample of the (4) worse condition days:
S_DAYS(1,:)=[209,7,28]; %cat 5
S_SCS(1,:)=[21.7235554777371,0.972441126648467,145.016488642096];

S_DAYS(2,:)=[67,3,8];
S_SCS(2,:)=[8.12253141845509,0.971278345088758,35.8300552164911];

S_DAYS(3,:)=[307,11,3];
S_SCS(3,:)=[4.71517497193514,0.849405256802328,11.6368807456493];

S_DAYS(4,:)=[70,3,11];
S_SCS(4,:)=[1.55177599940014,1.00430061073820,8.08834187287093];


%S_SCS=[21.7235554777371,0.972441126648467,145.016488642096;13.3784058163030,0.980596235777641,84.8408758473397;11.9454621812089,0.997298751627138,29.5323798068762;14.1243161120897,1.00009564663106,70.5540170796514];
%S_DAYS(3,:)=[300,10,27];

PV_ON_OFF=2;

n=1;
MNTH=S_DAYS(n,2);
DAY=S_DAYS(n,3);
PV_loadshape_daily = (PV_ON_OFF-1)*M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
PV_P(n).kW = interp(PV_loadshape_daily,12);
n=n+1;
MNTH=S_DAYS(n,2);
DAY=S_DAYS(n,3);
PV_loadshape_daily = (PV_ON_OFF-1)*M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
PV_P(n).kW = interp(PV_loadshape_daily,12);
n=n+1;
MNTH=S_DAYS(n,2);
DAY=S_DAYS(n,3);
PV_loadshape_daily = (PV_ON_OFF-1)*M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
PV_P(n).kW = interp(PV_loadshape_daily,12);
n=n+1;
MNTH=S_DAYS(n,2);
DAY=S_DAYS(n,3);
PV_loadshape_daily = (PV_ON_OFF-1)*M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
PV_P(n).kW = interp(PV_loadshape_daily,12);
PV_rated=5000;
P_TH=0.01; %kw/5sec
COUNT = 0;
for n=1:1:4
    PV_P_w = [PV_P(n).kW ];
    dP_PV_S=zeros(length(PV_P_w),2);
    k = 1;
    for t=2:1:length(PV_P_w)
        dP_PV_S(k,1)=abs(PV_P_w(t))-abs(PV_P_w(t-1));
        dP_PV_S(k,2)=dP_PV_S(k,1)/PV_rated;
        
        if dP_PV_S(k,1) > P_TH
            COUNT = COUNT + 1;
        end
        k = k+ 1;
    end
    PV_P(n).CT=COUNT;
    COUNT = 0;
    PV_P(n).dP=dP_PV_S;
end
%%
COUNT=0;
COUNT_1=0;
for n=1:1:length(M_PVSITE_SC)
    MNTH=M_PVSITE_SC(n,2);
    DAY=M_PVSITE_SC(n,3);
    
    PV_loadshape_daily = (PV_ON_OFF-1)*M_PVSITE(MNTH).PU(time2int(DAY,0,0):time2int(DAY,23,59),1);%1minute interval --
    PV_YR(n).kW = interp(PV_loadshape_daily,12);
    
    PV_P_w = [PV_YR(n).kW ];
    dP_PV_S=zeros(length(PV_P_w),2);
    k = 1;
    for t=2:1:length(PV_P_w)
        dP_PV_S(k,1)=abs(PV_P_w(t))-abs(PV_P_w(t-1));
        dP_PV_S(k,2)=dP_PV_S(k,1)/PV_rated;
        
        if dP_PV_S(k,1) > P_TH
            COUNT = COUNT + 1;
        end
        if PV_P_w(t) > 0.0001
            COUNT_1= COUNT_1 + 1;
        end
        
        k = k+ 1;
    end
    
    PV_YR(n).CNT=COUNT*5;
    PV_YR(n).CNT_T=COUNT_1*5;
    PV_YR(n).PERC=PV_YR(n).CNT/PV_YR(n).CNT_T;
    COUNT_1 = 0;
    COUNT = 0;
    PV_YR(n).dP=dP_PV_S;
    PV_YR(n).VI=M_PVSITE_SC(n,4);
    PV_YR(n).CI=M_PVSITE_SC(n,5);
    PV_YR(n).CAT=M_PVSITE_SC(n,10);
end

PERC_VIO=zeros(6,2);
for n=1:1:365
    for cc=1:1:5
        if isnan(PV_YR(n).PERC) == 0
            if PV_YR(n).CAT == cc
                PERC_VIO(cc,1)=PERC_VIO(cc,1)+[PV_YR(n).PERC];
                PERC_VIO(cc,2)=PERC_VIO(cc,2)+1;
            end
        end
    end

end

PERC_VIO(:,3)=(PERC_VIO(:,1)./PERC_VIO(:,2))*100;



sum([PV_YR(:).CNT])/sum([PV_YR(:).CNT_T])*100




%%
figure(1)
X=[5/3600:5/3600:24]';
n=1;
subplot(2,2,n);
plot(X,PV_P(n).dP(:,1))
hold on
plot(X,ones(length(PV_P_w),1)*P_TH,'r:');
hold on
plot(X,ones(length(PV_P_w),1)*-1*P_TH,'r:');
hold on
text(6,0.05,sprintf('%d Instances of Violations',PV_P(n).CT),'FontWeight','bold','FontSize',12);
text(6,0.04,sprintf('VI=%0.3f',S_SCS(n,1)),'FontWeight','bold','FontSize',12);
text(6,0.03,sprintf('CI=%0.3f',S_SCS(n,2)),'FontWeight','bold','FontSize',12);
text(15,0.05,sprintf('High Variability'),'FontWeight','bold','Color','r');
%   Settings:
xlabel('Hour of Day','FontWeight','bold','FontSize',12);
ylabel('5sec. Power Deviations ( dP_{PV}/dt ) [ kW/5sec ]','FontWeight','bold','FontSize',12);
set(gca,'FontWeight','bold','FontSize',12);
axis([5 20 -0.06 0.06]);
%-----------------
n=n+1;
subplot(2,2,n);
plot(X,PV_P(n).dP(:,1))
hold on
plot(X,ones(length(PV_P_w),1)*P_TH,'r:');
hold on
plot(X,ones(length(PV_P_w),1)*-1*P_TH,'r:');
hold on
text(6,0.05,sprintf('%d Instances of Violations',PV_P(n).CT),'FontWeight','bold','FontSize',12);
text(6,0.04,sprintf('VI=%0.3f',S_SCS(n,1)),'FontWeight','bold','FontSize',12);
text(6,0.03,sprintf('CI=%0.3f',S_SCS(n,2)),'FontWeight','bold','FontSize',12);
text(15,0.05,sprintf('Moderate Variability'),'FontWeight','bold','Color','r');
%   Settings:
xlabel('Hour of Day','FontWeight','bold','FontSize',12);
ylabel('5sec. Power Deviations ( dP_{PV}/dt ) [ kW/5sec ]','FontWeight','bold','FontSize',12);
axis([5 20 -0.06 0.06]);
set(gca,'FontWeight','bold','FontSize',12);
%-----------
n=n+1;
subplot(2,2,n);
plot(X,PV_P(n).dP(:,1))
hold on
plot(X,ones(length(PV_P_w),1)*P_TH,'r:');
hold on
plot(X,ones(length(PV_P_w),1)*-1*P_TH,'r:');
hold on
text(6,0.05,sprintf('%d Instances of Violations',PV_P(n).CT),'FontWeight','bold','FontSize',12);
text(6,0.04,sprintf('VI=%0.3f',S_SCS(n,1)),'FontWeight','bold','FontSize',12);
text(6,0.03,sprintf('CI=%0.3f',S_SCS(n,2)),'FontWeight','bold','FontSize',12);
text(15,0.05,sprintf('Mild Variability'),'FontWeight','bold','Color','r');
%   Settings:
xlabel('Hour of Day','FontWeight','bold','FontSize',12);
ylabel('5sec. Power Deviations ( dP_{PV}/dt ) [ kW/5sec ]','FontWeight','bold','FontSize',12);
axis([5 20 -0.06 0.06]);
set(gca,'FontWeight','bold','FontSize',12);
%-------------
n=n+1;
subplot(2,2,n);
plot(X,PV_P(n).dP(:,1))
hold on
plot(X,ones(length(PV_P_w),1)*P_TH,'r:');
hold on
plot(X,ones(length(PV_P_w),1)*-1*P_TH,'r:');
hold on
text(6,0.05,sprintf('%d Instances of Violations',PV_P(n).CT),'FontWeight','bold','FontSize',12);
text(6,0.04,sprintf('VI=%0.3f',S_SCS(n,1)),'FontWeight','bold','FontSize',12);
text(6,0.03,sprintf('CI=%0.3f',S_SCS(n,2)),'FontWeight','bold','FontSize',12);
text(15,0.05,sprintf('Low Variability'),'FontWeight','bold','Color','r');
%   Settings:
xlabel('Hour of Day','FontWeight','bold','FontSize',12);
ylabel('5sec. Power Deviations ( dP_{PV}/dt ) [ kW/5sec ]','FontWeight','bold','FontSize',12);
axis([5 20 -0.06 0.06]);
set(gca,'FontWeight','bold','FontSize',12);
