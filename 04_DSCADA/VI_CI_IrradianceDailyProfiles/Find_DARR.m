
%%
%load M_SHELBY.mat       %W/m^2;   kW_out; TEMP;   ELEV;   AZIM;    DOY;
load TIME_INT.mat       %MONTH;   DAY;    HOUR;   MIN;    DOY;

tic

%GHI_k = zeros(24*60,4); %B_ncI;   G_hcI;      
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
%-----------
%Start Date: 1/1/2014 (FIND V.I.)
MNTH = 1;
DAY = 1;
%-----------
%Preset GHI from closest irradiance site:
min = 0;
hr = 0;
i = 1;
while MNTH < 13
    while DAY < MTH_LN(1,MNTH)+1
        while hr < 24
            while min < 60
                M_PVSITE(MNTH).GHI(time2int(DAY,hr,min),1) = M_PSEUDO(MNTH).GHI(time2int(DAY,hr,min),1);
                M_PVSITE(MNTH).GHI(time2int(DAY,hr,min),2) = M_PSEUDO(MNTH).GHI(time2int(DAY,hr,min),2); %T_LI
                M_PVSITE(MNTH).GHI(time2int(DAY,hr,min),3) = M_PSEUDO(MNTH).GHI(time2int(DAY,hr,min),3); %G_hcI
                %Inc. Variables:
                min = min + 1;
                i = i + 1;
            end
            min = 0;
            hr = hr + 1;
        end
        hr = 0;
        min = 0;
        DAY = DAY + 1;
    end
    DAY = 1;
    MNTH = MNTH + 1
end


%%
%Time to calculate the V.I. & C.I.:

%-----------
%Calculations:
MNTH = 1;
DAY = 1;
min = 1; % +1 inc. b/c referencing 
hr = 0;
i = 1;
%-----------
%End Results:
%Solar_Constants = zeros(365,5); %DoY | Month | DoM | VI | CI
Solar_Constants(:,6) = zeros(365,1); %Clear DARR
Top = 0;
Bot = 0;
MEAS = 0;
CALC = 0;
SUM_DARR = 0;
while MNTH < 13
    while DAY < MTH_LN(1,MNTH)+1
        while hr < 24
            while min < 60
                %Measured Quantities:
                GHI_k = M_PVSITE(MNTH).DAY(time2int(DAY,hr,min),1);
                GHI_k1 = M_PVSITE(MNTH).DAY(time2int(DAY,hr,(min-1)),1);
                %Calculated Quantities:
                CSI_k = M_PVSITE(MNTH).GHI(time2int(DAY,hr,min),3);
                CSI_k1 = M_PVSITE(MNTH).GHI(time2int(DAY,hr,(min-1)),3);
                B_nck = M_PVSITE(MNTH).GHI(time2int(DAY,hr,min),1);
                if GHI_k ~= 0 && CSI_k ~= 0
                    %Find VI:
                    Top = Top + ((GHI_k-GHI_k1)^2 + 1)^(1/2);
                    Bot = Bot + ((CSI_k-CSI_k1)^2 + 1)^(1/2);
                    %Find CI:
                    MEAS = MEAS + GHI_k; %B_n (Direct Irradiance Profile.
                    CALC = CALC + B_nck;
                    %Find DARR:
                    SUM_DARR = SUM_DARR + abs(GHI_k - GHI_k1)/1000;
                end
                %Find Ramp Rate:
                PV_KW = M_PVSITE(MNTH).DAY(time2int(DAY,hr,min),1);
                PV_KW1 = M_PVSITE(MNTH).DAY(time2int(DAY,hr,min-1),1);
                M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),1) = PV_KW - PV_KW1;
                M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),2) = M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),1)/PV1_MW.kW;
                M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),3) = abs(M_PVSITE(MNTH).RR_1MIN(time2int(DAY,hr,min),2));
                %Inc:
                min = min + 1;
            end
            hr = hr + 1;
            min = 1;
        end
        hr = 0;
        %Obtain results:
        day_num = M_PVSITE(MNTH).DAY(time2int(DAY,hr,min),6);
        Solar_Constants(day_num,1) = day_num;
        Solar_Constants(day_num,2) = MNTH;
        Solar_Constants(day_num,3) = DAY;
        Solar_Constants(day_num,4) = M_PVSITE_SC(day_num,4);%VI
        Solar_Constants(day_num,5) = M_PVSITE_SC(day_num,5);%CI
        
        %DARR:
        DARR = SUM_DARR;
        Solar_Constants(day_num,6) = DARR;
            SUM_DARR = 0;
            DARR = 0;
        
            
        DAY = DAY + 1;
    end
    DAY = 1;
    MNTH = MNTH + 1;
end
%plot Fig. 7 daily clearness index & VI for each day of the test year @ Shelby, NC
%%

if FIG_type == 1 || FIG_type == 3
    %---------------------------------
    fig = fig + 1;
    figure(fig);
    plot(Solar_Constants(:,4),Solar_Constants(:,5),'bo');

    %Parameters:
    if sim_type == 1 && PV_Site == 1
        title('Shelby,NC: Year = 2014','FontSize',12,'FontWeight','bold');
    elseif sim_type == 1 && PV_Site == 2
        title('Murphy,NC: Year = 2014','FontSize',12,'FontWeight','bold');
    elseif sim_type == 1 && PV_Site == 3
        title('Taylorsville,NC: Year = 2014','FontSize',12,'FontWeight','bold');
    end
    xlabel('Variability Index (VI)','FontSize',12,'FontWeight','bold');
    ylabel('Daily Clearness Index','FontSize',12,'FontWeight','bold');
    axis([0 30 0 1.2]);
    set(gca,'FontWeight','bold');
end
if FIG_type == 2 || FIG_type == 3
    %---------------------------------
    %Plot Sampled Days to display VI from 1 --> 20.
    SAMPLES = zeros(2,20);
    if sim_type == 1 && PV_Site == 1
        SAMPLES(1,:) = [10;1;2;12;12;5;1;11;6;11;9;5;3;10;9;8;4;7;7;5];
        SAMPLES(2,:) = [5; 28;22;21;9;12;17;30;9;18;13;1;4;15;7;12;9;29;17;19];
    elseif sim_type == 1 && PV_Site == 2
        %Change these --
        SAMPLES(1,:) = [3;11;2;9;5;12;7;7;4;12;4;11;10;10;8;5;12;1;6;2]; %Month
        SAMPLES(2,:) = [10;20;1;29;9;29;16;7;22;25;12;25;20;24;17;20;16;1;4;19]; %Day of Month   
    elseif sim_type == 1 && PV_Site == 3
        %Change these --
        SAMPLES(1,:) = [4;12;5;1;6;8;9;5;9;8;6;3;1;8;3;5;2;9;6;8]; %Month
        SAMPLES(2,:) = [18;20;24;7;18;24;8;7;27;2;28;31;29;6;5;16;2;4;12;5]; %Day of Month   
    end

    fig = fig + 1;
    figure(fig);
    n = 1;
    while n < 21
        subplot(5,4,n);
        MNTH = SAMPLES(1,n);
        D_S = SAMPLES(2,n);
        DoY = M_PVSITE(MNTH).DAY(time2int(D_S,0,0),6);
        CI = Solar_Constants(DoY,5);   %DoY | Month | DoM | VI | CI
        %Global Measurements:
        plot(M_PVSITE(MNTH).DAY(time2int(D_S,0,0):time2int(D_S,23,59),1),'b-');
        hold on
        %Calc. Cleark Sky:
        plot(M_PVSITE(MNTH).GHI(time2int(D_S,0,0):time2int(D_S,23,59),3),'r-');
        title(sprintf('VI = %s   &   CI = %2.2f',num2str(n),CI),'FontSize',14)
        set(gca,'YTickLabel',[]);
        set(gca,'XTickLabel',[]);
        n = n + 1;
    end
end
if FIG_type == 4
    %---------------------------------
    %Plot some Irradiance Profiles:
    fig = fig + 1;
    figure(fig);
    D_S = 24; %Day Selection.
    MNTH = 1;
    plot(M_PVSITE(MNTH).DAY(time2int(D_S,0,0):time2int(D_S,23,59),1),'r--');
    hold on
    plot(M_PVSITE(MNTH).GHI(time2int(D_S,0,0):time2int(D_S,23,59),3),'b-');
    hold on
    plot(M_PVSITE(MNTH).GHI(time2int(D_S,0,0):time2int(D_S,23,59),1),'g-');

    fig = fig + 1;
    figure(fig);
    MNTH = 6;
    D_S = 1; %New Day Selection.
    plot(M_PVSITE(MNTH).DAY(time2int(D_S,0,0):time2int(D_S,23,59),1),'r--');
    hold on
    plot(M_PVSITE(MNTH).GHI(time2int(D_S,0,0):time2int(D_S,23,59),3),'b-');
    hold on
    plot(M_PVSITE(MNTH).GHI(time2int(D_S,0,0):time2int(D_S,23,59),1),'g-');
end
%%



%SAVE PV Site struct!!
%Output Results:
%M_PVSITE.Daily_SolarConstants = Solar_Constants(:,6);
if sim_type == 2
    if PV_Site == 1
        %4.5MW - Mocksville Solar Farm
        M_MOCKS = M_PVSITE;
        filename = strcat(PV_Site_path4,'\M_MOCKS.mat');
        delete(filename);
        save(filename,'M_MOCKS');
        %   Solar Constants:
        M_MOCKS_SC = Solar_Constants;
        filename = strcat(PV_Site_path4,'\M_MOCKS_SC.mat');
        delete(filename);
        save(filename,'M_MOCKS_SC');
        
    elseif PV_Site == 2
        %3.5MW - Ararat Rock Solar Farm
        M_AROCK = M_PVSITE;
        filename = strcat(PV_Site_path5,'\M_AROCK.mat');
        delete(filename);
        save(filename,'M_AROCK');
        %Solar Constants
        %{
        for i=1:1:365
            %Filter out missing datapoints (DOY=234 to 240; 7Day Gap)
            if i >= 234 && i <= 240
                Solar_Constants(i,4:6) = [0,0,0];
            end
        end
        %}
        M_AROCK_SC = Solar_Constants;
        filename = strcat(PV_Site_path5,'\M_AROCK_SC.mat');
        delete(filename);
        save(filename,'M_AROCK_SC');
        
    elseif PV_Site == 3
        %1.5MW - Old Dominion (ODOM)
        M_ODOM = M_PVSITE;
        filename = strcat(PV_Site_path6,'\M_ODOM.mat');
        delete(filename);
        save(filename,'M_ODOM');
        %Solar Constants
        for i=1:1:365
            %Filter out missing datapoint days (DOY=66 & DOY=347 to 351)
            if i>=347 && i <= 351 || i==66
                Solar_Constants(i,4:6) = [0,0,0];
            end
        end
        M_ODOM_SC = Solar_Constants;
        filename = strcat(PV_Site_path6,'\M_ODOM_SC.mat');
        delete(filename);
        save(filename,'M_ODOM_SC');
    elseif PV_Site == 4
        %1.0MW - Mayberry (MAYB)
        M_MAYB = M_PVSITE;
        filename = strcat(PV_Site_path7,'\M_MAYB.mat');
        delete(filename);
        save(filename,'M_MAYB');
        %Solar Constants
        for i=1:1:365
            %Filter out missing datapoint days (DOY=347 to 351)
            if i>=347 && i <= 351
                Solar_Constants(i,4:6) = [0,0,0];
            end
        end
        M_MAYB_SC = Solar_Constants;
        filename = strcat(PV_Site_path7,'\M_MAYB_SC.mat');
        delete(filename);
        save(filename,'M_MAYB_SC');
        
    end
end


