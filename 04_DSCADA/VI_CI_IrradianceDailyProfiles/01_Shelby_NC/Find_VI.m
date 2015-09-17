clear
clc
FIG = 1;
%-----------
%Site Specs:
ALT = 265; %[m] Shelby,NC
a_1 = (5.09 * 10 ^ (-5)) * ALT + 0.868;
a_2 = (3.92 * 10 ^ (-5)) * ALT + 0.0387;
f_h1 = exp(-1 * ALT / 8000);    %could be -1 as well.
f_h2 = exp(-1 * ALT / 1250);
b = 0.664 + 0.163/f_h1;

%-----------
%Static Constants:
I_sc = 1367; %W/m^2
T_L = 3; %(original Linke Constant)
%-----------
%Import Datasets:
load TIME_INT.mat       %MONTH;   DAY;    HOUR;   MIN;    DOY;
load M_SHELBY.mat       %W/m^2;   kW_out; TEMP;   ELEV;   AZIM;    DOY;
%GHI_k = zeros(24*60,4); %B_ncI;   G_hcI;      
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
%-----------
%Start Date: 1/1/2014 (FIND V.I.)
MNTH = 1;
DAY = 1;
%-----------
%Calculations:
min = 0;
hr = 0;
i = 1;
while MNTH < 13
    while DAY < MTH_LN(1,MNTH)+1
        while hr < 24
            while min < 60
                %Solar Elevation Angle:
                h = M_SHELBY(MNTH).DAY(time2int(DAY,hr,min),4);    

                %extraterrestrial irradiance on a plane perp. to Sun's:
                n = M_SHELBY(MNTH).DAY(time2int(DAY,hr,min),6);   
                I_o = I_sc *(1 + 0.034 * cos(deg2rad(2*pi * (n / 265.25))));
                
                %Beam clear sky (normal irradiance)
            %Old Method:
                %optical Air Mass:
                AM = 1/sin(deg2rad(h));
                B_ncI = b * I_o * exp(-0.09*AM*(T_L-1));

            %New Method to find B_ncI:
%                 AM = 1160 + 75*sin(deg2rad((360/365)*(n-275)));
%                 k = 0.174+0.035*sin(deg2rad((360/365)*(n-100)));
%                 m = (((708*sin(deg2rad(h))^2)+1417)^(1/2)-708*sin(deg2rad(h)));
%                 B_ncI = AM*exp(-1*k*m);
                
                
                
                T_LI = (11.1*log((b*I_o)/B_ncI)/AM)+1;
                if B_ncI > I_sc
                    B_ncI = 0; %Make to show no irrad. avail. w/out sun present.
                end
                %Global Sky Radiation reaching the ground on a horizontal surface.
                G_hcI = a_1 *I_o*sin(deg2rad(h))*exp(-1*a_2*AM*(f_h1+f_h2*(T_LI-1)));
                if G_hcI < 0
                    G_hcI = 0; %No Irradiance available to generate.
                end

                %Save Clear Sky vars to new matrix:
                %GHI_k(i,1) = B_ncI;
                %GHI_k(i,2) = T_LI;
                %GHI_k(i,3) = G_hcI;
                M_SHELBY(MNTH).GHI(time2int(DAY,hr,min),1) = B_ncI;
                M_SHELBY(MNTH).GHI(time2int(DAY,hr,min),2) = T_LI;
                M_SHELBY(MNTH).GHI(time2int(DAY,hr,min),3) = G_hcI;
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
Solar_Constants = zeros(365,5); %DoY | Month | DoM | VI | CI
Top = 0;
Bot = 0;
MEAS = 0;
CALC = 0;

while MNTH < 13
    while DAY < MTH_LN(1,MNTH)+1
        while hr < 24
            while min < 60
                %Measured Quantities:
                GHI_k = M_SHELBY(MNTH).DAY(time2int(DAY,hr,min),1);
                GHI_k1 = M_SHELBY(MNTH).DAY(time2int(DAY,hr,(min-1)),1);
                %Calculated Quantities:
                CSI_k = M_SHELBY(MNTH).GHI(time2int(DAY,hr,min),3);
                CSI_k1 = M_SHELBY(MNTH).GHI(time2int(DAY,hr,(min-1)),3);
                B_nck = M_SHELBY(MNTH).GHI(time2int(DAY,hr,min),1);
                if GHI_k ~= 0 && CSI_k ~= 0
                    %Find VI:
                    Top = Top + ((GHI_k-GHI_k1)^2 + 1)^(1/2);
                    Bot = Bot + ((CSI_k-CSI_k1)^2 + 1)^(1/2);
                    %Find CI:
                    MEAS = MEAS + GHI_k; %B_n (Direct Irradiance Profile.
                    CALC = CALC + B_nck;
                end
                
                min = min + 1;
            end
            hr = hr + 1;
            min = 1;
        end
        hr = 0;
        %Obtain results:
        day_num = M_SHELBY(MNTH).DAY(time2int(DAY,hr,min),6);
        Solar_Constants(day_num,1) = day_num;
        Solar_Constants(day_num,2) = MNTH;
        Solar_Constants(day_num,3) = DAY;
        
        %VI:
        VI = Top/Bot;
        Solar_Constants(day_num,4) = VI;
            Top = 0;
            Bot = 0;
            VI = 0;
        %CI:
        CI = MEAS/CALC;
        Solar_Constants(day_num,5) = CI;
            MEAS = 0;
            CALC = 0;
            CI = 0;
        
        DAY = DAY + 1;
    end
    DAY = 1;
    MNTH = MNTH + 1;
end
%plot Fig. 7 daily clearness index & VI for each day of the test year @ Shelby, NC
%%
figure(1);

%subplot(2,1,1);
plot(Solar_Constants(:,4),Solar_Constants(:,5),'bo');
%subplot(2,1,2);
%plot(


%Parameters:
title('Shelby,NC: Year = 2014','FontSize',12,'FontWeight','bold');
xlabel('Variability Index (VI)','FontSize',12,'FontWeight','bold');
ylabel('Daily Clearness Index','FontSize',12,'FontWeight','bold');

axis([0 30 0 1.2]);





















%%
%plot(GHI_k(:,1),'b-');
%hold on
%plot(GHI_k(:,3),'g-');
%hold on
FIG = FIG + 1;
figure(FIG);
D_S = 24; %Day Selection.
MNTH = 1;
plot(M_SHELBY(MNTH).DAY(time2int(D_S,0,0):time2int(D_S,23,59),1),'r--');
hold on
plot(M_SHELBY(MNTH).GHI(time2int(D_S,0,0):time2int(D_S,23,59),3),'b-');
hold on
plot(M_SHELBY(MNTH).GHI(time2int(D_S,0,0):time2int(D_S,23,59),1),'g-');

FIG = FIG + 1;
figure(FIG);
MNTH = 6;
D_S = 1; %New Day Selection.
plot(M_SHELBY(MNTH).DAY(time2int(D_S,0,0):time2int(D_S,23,59),1),'r--');
hold on
plot(M_SHELBY(MNTH).GHI(time2int(D_S,0,0):time2int(D_S,23,59),3),'b-');
hold on
plot(M_SHELBY(MNTH).GHI(time2int(D_S,0,0):time2int(D_S,23,59),1),'g-');
        
        


%GHI_K = M_SHELBY(MNTH).DAY(Day_hour(DAY,0,0):Day_hour(DAY,23,59),1:5);

%Calc Outputs:
%VI = Variability Index
%B_ncI = 


%%
SAMPLES = zeros(2,20);
SAMPLES(1,:) = [10;1;2;12;12;5;1;11;6;11;9;5;3;10;9;8;4;7;7;5];
SAMPLES(2,:) = [5; 28;22;21;9;12;17;30;9;18;13;1;4;15;7;12;9;29;17;19];
FIG = 3;
FIG = FIG + 1;
figure(FIG);
n = 1;
while n < 21
    subplot(5,4,n);
    MNTH = SAMPLES(1,n);
    D_S = SAMPLES(2,n);
    DoY = M_SHELBY(MNTH).DAY(time2int(D_S,0,0),6);
    CI = Solar_Constants(DoY,5);   %DoY | Month | DoM | VI | CI
    %Global Measurements:
    plot(M_SHELBY(MNTH).DAY(time2int(D_S,0,0):time2int(D_S,23,59),1),'b-');
    hold on
    %Calc. Cleark Sky:
    plot(M_SHELBY(MNTH).GHI(time2int(D_S,0,0):time2int(D_S,23,59),3),'r-');
    title(sprintf('VI = %s   &   CI = %2.2f',num2str(n),CI),'FontSize',14)
    set(gca,'YTickLabel',[]);
    set(gca,'XTickLabel',[]);
    n = n + 1;
end


