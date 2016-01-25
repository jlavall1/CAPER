%Chapter 3: Static Hosting Capacity Plots:
clear
clc
close all
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);

action=menu('Which Plot would you like to initiate?','Cummulation of kW vs time','FDR 1-6 Boxplots of summer vs. winter','W&S mu+/-1.5s');
while action<1
    action=menu('Which Plot would you like to initiate?','Cummulation of kW vs time','FDR 1-6 Boxplots of summer vs. winter','W&S mu+/-1.5s');
end
%Load (2) Datasets per Feeder saving in DATA.FDR_LD(n) & DATA.FDR_PV(n)
n=0;
%%
%feeder_NUM == 1
n = n + 1;
load BELL.mat
load Annual_daytime_load_BELL.mat
DATA.FDR_LD(n).kW = BELL.kW;
DATA.FDR_LD(n).kVAR = BELL.kVAR;
DATA.FDR_PV(n) = WINDOW;
clearvars BELL
clearvars WINDOW
kW_peak = [2940.857,2699.883,3092.130];
str_FDR = '_BELL.mat';

%feeder_NUM == 2
n = n + 1;
load FLAY.mat
load Annual_daytime_load_FLAY.mat
DATA.FDR_LD(n).kW = FLAY.kW;
DATA.FDR_LD(n).kVAR = FLAY.kVAR;
DATA.FDR_PV(n) = WINDOW;
clearvars FLAY
clearvars WINDOW
kW_peak = [1.424871573296857e+03,1.347528364235151e+03,1.716422704604557e+03];
str_FDR = '_FLAY.mat';

%elseif feeder_NUM == 3
n = n + 1;
load CMNWLTH.mat
load Annual_daytime_load_CMNWLTH.mat
DATA.FDR_LD(n).kW = CMNWLTH.kW;
DATA.FDR_LD(n).kVAR = CMNWLTH.kVAR;
DATA.FDR_PV(n) = WINDOW;
clearvars CMNWLTH
clearvars WINDOW
kW_peak = [2.475021572579630e+03,2.609588847297235e+03,2.086659558753901e+03];
str_FDR = '_CMNWLTH.mat';

%elseif feeder_NUM == 4
n = n + 1;
load ROX.mat
load Annual_daytime_load_ROX.mat
DATA.FDR_LD(n).kW = ROX.kW;
DATA.FDR_LD(n).kVAR = ROX.kVAR;
DATA.FDR_PV(n) = WINDOW;
clearvars ROX
clearvars WINDOW
kW_peak = [3.189154306704542e+03,3.319270338767296e+03,3.254908188719974e+03];
str_FDR = '_ROX.mat';

%elseif feeder_NUM == 5
n = n + 1;
load HOLLY.mat
load Annual_daytime_load_HOLLY.mat
DATA.FDR_LD(n).kW = HOLLY.kW;
DATA.FDR_LD(n).kVAR = HOLLY.kVAR;
DATA.FDR_PV(n) = WINDOW;
clearvars HOLLY
clearvars WINDOW
kW_peak = [3585.700,4021.705,2741.913];
str_FDR = '_HOLLY.mat';

%elseif feeder_NUM == 6
n = n + 1;
load ERALEIGH.mat
load Annual_daytime_load_ERALEIGH.mat
DATA.FDR_LD(n).kW = ERALEIGH.kW;
DATA.FDR_LD(n).kVAR = ERALEIGH.kVAR;
DATA.FDR_PV(n) = WINDOW;
clearvars ERALEIGH
clearvars WINDOW
kW_peak = [1545.687,1606.278,1569.691];
str_FDR = '_ERALEIGH.mat';
%end
%%
if action == 1
    %Annual distribution, 3ph:
    figure(1)
    for n=1:1:6
        DATA.FDR_LD(n).kW3ph=sort(DATA.FDR_LD(n).kW.A+DATA.FDR_LD(n).kW.B+DATA.FDR_LD(n).kW.C,'descend');
        DATA.FDR_LD(n).kVAR3ph=DATA.FDR_LD(n).kVAR.A+DATA.FDR_LD(n).kVAR.B+DATA.FDR_LD(n).kVAR.C;
    end
    X=(1/60):(1/60):(365*24);
    X1=(1/60):(1/60):(365*24);
    X1=X1(1,1:525585);
    plot(X,DATA.FDR_LD(1).kW3ph/1000,'b-','linewidth',3)
    hold on
    plot(X,DATA.FDR_LD(2).kW3ph/1000,'g-','linewidth',3)
    hold on
    plot(X,DATA.FDR_LD(3).kW3ph/1000,'r-','linewidth',3)
    hold on
    plot(X1,DATA.FDR_LD(4).kW3ph/1000,'c-','linewidth',3)
    hold on
    plot(X1,DATA.FDR_LD(5).kW3ph/1000,'m-','linewidth',3)
    hold on
    plot(X1,DATA.FDR_LD(6).kW3ph/1000,'k-','linewidth',3)
    
    legend('Feeder 1','Feeder 2','Feeder 3','Feeder 4','Feeder 5','Feeder 6');
    axis([0 8760 0 12]);
    ylabel('Total Load (P_{3\phi}) [MW]','FontSize',12,'FontWeight','bold');
    xlabel('Hours (h)','FontSize',12,'FontWeight','bold');
    grid on
    set(gca,'FontWeight','bold');
    
    %Now lets plot monthly averages during solar peak interval:
    % Aggregate to 3ph:
    for n=1:1:6
        DATA.FDR_PV(n).kW3ph_MNTH=abs(DATA.FDR_PV(n).KW.A)+abs(DATA.FDR_PV(n).KW.B)+abs(DATA.FDR_PV(n).KW.C);
    end
    months = [31,28,31,30,31,30,31,31,30,31,30,31];
    mn_max = 0;
    for n=1:1:6
        %Reset working vars:
        t_w=0;  
        tt =0;
        sum = 0;
        %Increment through the months & find averages
        for i=1:12
            x_w=60*6*months(i);
            for ii=tt+1:x_w+tt
                if isnan(DATA.FDR_PV(n).kW3ph_MNTH(ii,1))
                    %fprintf('fuck you\n');
                else
                    sum = DATA.FDR_PV(n).kW3ph_MNTH(ii,1) + sum;
                end
            end
            tt = tt+x_w;
            DATA.FDR_LD(n).kWavg(i,1) = sum/x_w;
            sum = 0;
        end
    end
    
    %%
    figure(2)
    X2=1:1:12;
    h(1)=plot(X2,DATA.FDR_LD(1).kWavg(:,1)/1000,'b-','linewidth',2.5);
    hold on
    h(2)=plot(X2,DATA.FDR_LD(2).kWavg(:,1)/1000,'g-','linewidth',2.5);
    hold on
    h(3)=plot(X2,DATA.FDR_LD(3).kWavg(:,1)/1000,'r-','linewidth',2.5);
    hold on
    h(4)=plot(X2,DATA.FDR_LD(4).kWavg(:,1)/1000,'c-','linewidth',2.5);
    hold on
    h(5)=plot(X2,DATA.FDR_LD(5).kWavg(:,1)/1000,'m-','linewidth',2.5);
    hold on
    h(6)=plot(X2,DATA.FDR_LD(6).kWavg(:,1)/1000,'k-','linewidth',2.5);
    hold on
    [C,I]=max(DATA.FDR_LD(1).kWavg(:,1));
    plot(I,C/1000,'bo','linewidth',4);
    hold on
    [C,I]=max(DATA.FDR_LD(2).kWavg(:,1));
    plot(I,C/1000,'go','linewidth',4);
    hold on
    [C,I]=max(DATA.FDR_LD(3).kWavg(:,1));
    plot(I,C/1000,'ro','linewidth',4);
    hold on
    [C,I]=max(DATA.FDR_LD(4).kWavg(:,1));
    plot(I,C/1000,'co','linewidth',4);
    hold on
    [C,I]=max(DATA.FDR_LD(5).kWavg(:,1));
    plot(I,C/1000,'mo','linewidth',4);
    hold on
    [C,I]=max(DATA.FDR_LD(6).kWavg(:,1));
    plot(I,C/1000,'ko','linewidth',4);
    hold on
    plot(5*ones(6,1),[0,2,4,6,8,10],'k--','linewidth',3);
    hold on
    plot(10*ones(6,1),[0,2,4,6,8,10],'k--','linewidth',3);
    hold on
    %Plot Settings:
    legend([h(1),h(2),h(3),h(4),h(5),h(6)],'Feeder 1','Feeder 2','Feeder 3','Feeder 4','Feeder 5','Feeder 6','Location','NorthWest');
    axis([1 12 0 10]);
    set(gca,'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'},'XTick',1:12);
    ylabel('Average Load (P_{avg}) [MW]','FontSize',12,'FontWeight','bold');
    xlabel('Month of Year','FontSize',12,'FontWeight','bold');
    grid on
    set(gca,'FontWeight','bold');
    %%
elseif action == 2
    %Box plots comparing winter summer:

    % Aggregate to 3ph:
    for n=1:1:6
        DATA.FDR_PV(n).kW3ph_W=abs(DATA.FDR_PV(n).WINT.KW.A(:,1))+abs(DATA.FDR_PV(n).WINT.KW.B(:,1))+abs(DATA.FDR_PV(n).WINT.KW.C(:,1));
        DATA.FDR_PV(n).kW3ph_S=abs(DATA.FDR_PV(n).SUM.KW.A(:,1))+abs(DATA.FDR_PV(n).SUM.KW.B(:,1))+abs(DATA.FDR_PV(n).SUM.KW.C(:,1));
    end
    
    %Column vector of Winter 3ph kW~
    dataW = [DATA.FDR_PV(1).kW3ph_W; DATA.FDR_PV(2).kW3ph_W;...
            DATA.FDR_PV(3).kW3ph_W; DATA.FDR_PV(4).kW3ph_W;...
            DATA.FDR_PV(5).kW3ph_W; DATA.FDR_PV(6).kW3ph_W];      
    TOT = 0;
    L = length(DATA.FDR_PV(1).kW3ph_W);
    for i =TOT+1:1:L+TOT
        charW(i) = {'1'};
    end
    TOT = TOT+L;
    L = length(DATA.FDR_PV(2).kW3ph_W); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'2'};
    end
    TOT = TOT+L;
    L = length(DATA.FDR_PV(3).kW3ph_W); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'3'};
    end
    TOT = TOT+L;
    L = length(DATA.FDR_PV(4).kW3ph_W); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'4'};
    end
    TOT = TOT+L;
    L = length(DATA.FDR_PV(5).kW3ph_W); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'5'};
    end
    TOT = TOT+L;
    L = length(DATA.FDR_PV(6).kW3ph_W); 
    for i =TOT+1:1:L+TOT
        charW(i) = {'6'};
    end
    %}
    %-----------------------------------
    %Column vector of Summer 3ph kW~
    dataS = [DATA.FDR_PV(1).kW3ph_S; DATA.FDR_PV(2).kW3ph_S;...
            DATA.FDR_PV(3).kW3ph_S; DATA.FDR_PV(4).kW3ph_S;...
            DATA.FDR_PV(5).kW3ph_S; DATA.FDR_PV(6).kW3ph_S];
    TOT = 0;    
    L = length(DATA.FDR_PV(1).kW3ph_S);
    for i =TOT+1:1:L+TOT
        charS(i) = {'1'};
    end
    TOT = TOT+L;
    L = length(DATA.FDR_PV(2).kW3ph_S); 
    for i =TOT+1:1:L+TOT
        charS(i) = {'2'};
    end
    TOT = TOT+L;
    L = length(DATA.FDR_PV(3).kW3ph_S); 
    for i =TOT+1:1:L+TOT
        charS(i) = {'3'};
    end
    TOT = TOT+L;
    L = length(DATA.FDR_PV(4).kW3ph_S); 
    for i =TOT+1:1:L+TOT
        charS(i) = {'4'};
    end
    TOT = TOT+L;
    L = length(DATA.FDR_PV(5).kW3ph_S); 
    for i =TOT+1:1:L+TOT
        charS(i) = {'5'};
    end
    TOT = TOT+L;
    L = length(DATA.FDR_PV(6).kW3ph_S); 
    for i =TOT+1:1:L+TOT
        charS(i) = {'6'};
    end
    %%
    %Plot (2) Figures W & S:
    figure(1)
    boxplot(dataW/1000,charW)
    %title('Seasonal Comparison during Peak Solar Interval','Fontsize',14,'FontWeight','bold')
    xlabel('Feeder Number','Fontsize',12,'FontWeight','bold')
    ylabel('Three-Phase Load (P) [kW]','Fontsize',12,'FontWeight','bold')
    set(gca,'FontWeight','bold','FontSize',12);
    axis([0.5 6.5 0 11])
    %%
    figure(2)
    boxplot(dataS/1000,charS)
    xlabel('Feeder Number','Fontsize',12,'FontWeight','bold')
    ylabel('Three-Phase Load (P) [kW]','Fontsize',12,'FontWeight','bold')
    set(gca,'FontWeight','bold','FontSize',12);
    axis([0.5 6.5 0 11])
end
    