%playing with DoD Schedule:
clear
clc
close all
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\05_BESS');
load M_MOCKS.mat
load M_MOCKS_SC.mat
M_PVSITE_SC = M_MOCKS_SC;
%
for i=1:1:12
    M_PVSITE(i).DAY(:,:) = M_MOCKS(i).DAY(1:end-1,1:6);    
    M_PVSITE(i).RR_1MIN(:,:) = M_MOCKS(i).RR_1MIN(:,1:3);
    M_PVSITE(i).kW(:,:) = M_MOCKS(i).kW(1:end-1,1);
    M_PVSITE(i).GHI = M_MOCKS(i).GHI;
end
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
DOY = 1;
max_KW = 0;
for MNTH=1:1:12
    for DAY=1:1:MTH_LN(MNTH)
        kW_PV(:,DOY) = M_PVSITE(MNTH).kW(time2int(DAY,0,0):time2int(DAY,23,59),1); %PU
        if max(kW_PV(:,DOY)) > max_KW
            max_KW = max(kW_PV(:,DOY));
        end
        DOY = DOY + 1;
    end
end




kW_PU=kW_PV./max_KW;
fprintf('max kW=%0.4f\n',max_KW);

%%
SET_REG=zeros(365,3);
for DOY=1:1:365
    SET_REG(DOY,2)=M_PVSITE_SC(DOY,4); %VI
    SET_REG(DOY,3)=M_PVSITE_SC(DOY,5); %CI
    for min=1:1:1440
        SET_REG(DOY,1) = SET_REG(DOY,1)+kW_PU(min,DOY)/60; %PU*h
    end
end
%%
clc

max_DEY = max(SET_REG(:,1));
fprintf('max DEY=%0.4f\n',max_DEY);
max_kWh = max_DEY*3000;
fprintf('max kWh=%3.2f\n',max_kWh);
C_bat = 4000; %kWh
mean_kWh = mean(SET_REG(:,1))*3000;
fprintf('mean=%0.4f kWh\n',mean_kWh);

B_r = C_bat/mean_kWh;

%PU_HR = 4000/(B_r*3000);
DoD_max=0.33;
P_PV = 3000;
C_r = 12120;
PU_HR=(DoD_max*C_r)/(P_PV*B_r);
%GHI=M_PVSITE(MNTH).kW(time2int(DAY,0,0):time2int(DAY,23,59),1)/5000; %PU
%
%CI = 0.01:0.01:1;
%beta=0.33;
%beta=[0.44380209  0.01994886  6.51296679];
%beta=[-0.18518780 -0.02186158  7.87680417];
beta=[0.45193329  0.01344715  7.28591556 ];
%normalize=7.5503;
%beta=beta/normalize;
B0=beta(1);
B1=beta(2);
B2=beta(3);

for DOY=1:1:365
    VI=SET_REG(DOY,2);
    CI=SET_REG(DOY,3);
    E(DOY,1)=B0+B1*VI+B2*CI;
    %PU_HR = 5.33;
    if E(DOY,1) <= PU_HR %pu.hr
        DoD_tar(DOY,1)=(0.33/PU_HR)*E(DOY,1);
    else
        DoD_tar(DOY,1)=0.33;
    end
end
i =1;

for E_PUHR=0:0.1:max_DEY
    if E_PUHR <= PU_HR %pu.hr
        DoD_p(i,1)=(0.33/PU_HR)*E_PUHR;
    else
        DoD_p(i,1)=0.33;
    end
    DoD_p(i,2)=E_PUHR;
    i = i + 1;
end
%----------------
fig=1;
figure(fig);
plot([0 9],[33 33],'k--','LineWidth',2.5);
hold on
plot(DoD_p(:,2),DoD_p(:,1)*100,'b-','LineWidth',3)
hold on
plot([PU_HR PU_HR],[0 35],'r--','LineWidth',2.5);
hold on
plot(DoD_p(31,2),DoD_p(31,1)*100,'bo','LineWidth',3)

xlabel('Normalized Daily Energy Yield (DEY) [p.u.h]','FontWeight','bold','FontSize',12);
ylabel('Depth of Discharge Target ( DoD_{t} ) [ % ]','FontWeight','bold','FontSize',12);
set(gca,'FontWeight','bold');
grid on


%   to show the DoD estimator function:
%%
fig=fig+1;
figure(fig)
X=1:1:365;
plot(X,E(:,1),'r-');
hold on
plot(X,SET_REG(:,1),'b.');
fprintf('mean=%0.4f\n',mean(E(:,1)));
%---------------------------------

fig=fig+1;
figure(fig)
%plot(X,DoD_tar)
stairs(X,DoD_tar*100)
axis([1 365 0 35]);
xlabel('Day of Year (DoY)','FontWeight','bold','FontSize',12);
ylabel('Depth of Discharge Target ( DoD_{t} ) [ % ]','FontWeight','bold','FontSize',12);
set(gca,'xtick',[1:31:372])
set(gca,'FontWeight','bold');


%%
%---------------------------------
fig=fig+1;
figure(fig)
%plot3(SET_REG(:,3),SET_REG(:,2),SET_REG(:,1))
%scatter3(SET_REG(:,3),SET_REG(:,2),SET_REG(:,1))
Z=ones(365,365);
X=ones(365,365);
Y=ones(365,365);
%
SET_REG_1 = sortrows(SET_REG,2);
%SET_REG_1 = SET_REG(index);

for i=1:1:length(Z)
    X(:,i)=X(:,i).*SET_REG_1(:,3);
    Y(:,i)=Y(:,i).*SET_REG_1(:,2);
    
    Z(:,i)=Z(:,i).*SET_REG_1(:,1);
end
%Z=Z*SET_REG(:,1);
%surf(X,Y,Z,'EdgeColor','none')
%hold on
%contour3(X,Y,Z,20,'k')
%hold off
%contour(SET_REG_1(:,2),SET_REG_1(:,3),SET_REG_1(:,1))
%contour(X,Y,Z,20,'k')
%
%figure;
%[X,Y] = meshgrid(-8:.5:8);
%R = sqrt(X.^2 + Y.^2) + eps;
%Z = sin(R)./R;
%surf(X, Y, Z,'EdgeColor', 'None', 'facecolor', 'interp');
%view(2);
%axis equal; 
%axis off;
%scatter(Y(:,1),Z(:,1),[],X(:,1))
%scatter(X(:,1),Z(:,1),[],Y(:,1))
subplot(1,2,1)
scatter(X(:,1),Z(:,1),[],Y(:,1))
axis([0 1.1 0 8])
c=colorbar('location','eastoutside');
set(get(c,'title'),'string','Variability Index (VI)','Rotation',90.0,'FontSize',12);

pos=get(get(c,'title'),'position');
X_move=2.1;
Y_move=-26.9;
pos(1,1) = pos(1,1)+X_move;
pos(1,2) = pos(1,2)+Y_move;
set(get(c,'title'),'position',pos);
%}






VI_avg = mean(SET_REG_1(:,2));
BT2=[-0.343198   11.170313   -4.055665];
for DOY=1:1:365
    %VI=SET_REG(DOY,2);
    VI=VI_avg;
    CI=SET_REG(DOY,3);
    E_plot(DOY,1)=B0+B1*VI+B2*CI;
    
    PU_HR = 5.33;
    %{
    if E(DOY,1) <= PU_HR %pu.hr
        DoD_tar(DOY,1)=(0.33/PU_HR)*E(DOY,1);
    else
        DoD_tar(DOY,1)=0.33;
    end
    %}
end
i=1;
for CI=0:0.01:1
    E_plot_2(i,1)=B0+B1*VI+B2*CI;
    E_plot_2(i,2)=BT2(1)+BT2(2)*CI+CI^2;
    i = i + 1;
end

hold on
%plot([0:0.01:1],E_plot_2(:,2),'k-')
%hold on
plot([0:0.01:1],E_plot_2(:,1),'k-','LineWidth',2)
xlabel('Clear Sky Index (CI)','FontWeight','bold','FontSize',12);
ylabel('Normalized Daily Energy Yield  (DEY)','FontWeight','bold','FontSize',12);
set(gca,'FontWeight','bold');
%--------------------------------------
subplot(1,2,2)
scatter(Y(:,1),X(:,1),[],Z(:,1))
c=colorbar('location','eastoutside');
set(get(c,'title'),'string','Normalized Daily Energy Yield (DEY)','Rotation',90.0,'FontSize',12);
pos=get(get(c,'title'),'position');

X_move=1.8;
Y_move=-4.3;
pos(1,1) = pos(1,1)+X_move;
pos(1,2) = pos(1,2)+Y_move;
set(get(c,'title'),'position',pos);
%}
axis([0 40 0 1.1])
xlabel('Variability Index (VI)','FontWeight','bold','FontSize',12);
ylabel('Clear-Sky Index (CI)','FontWeight','bold','FontSize',12);
set(gca,'FontWeight','bold');

%{
c = colorbar('location','eastoutside');
    %Edit title string:
    set(get(c,'title'),'string','PV Size (MW)','Rotation',90.0,'FontWeight','bold');
    pos = get(get(c,'title'),'position');
    if ckt_num == 2
        X_move=1.8;
        Y_move=-5;
    else
        X_move=1.8;
        Y_move=-5;
    end
    pos(1,1) = pos(1,1)+X_move;
    pos(1,2) = pos(1,2)+Y_move;
    set(get(c,'title'),'position',pos);
%}




%%