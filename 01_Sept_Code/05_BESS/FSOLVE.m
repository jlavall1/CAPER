clear
clc
%close all
%This is to try and solve for:
%T_ON=10;
%T_OFF=16;
%Try to find correct T_ON & T_OFF:
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
load M_MOCKS.mat
load M_MOCKS_SC.mat
M_PVSITE_SC_1 = M_MOCKS_SC;
%
for i=1:1:12
    M_PVSITE(i).GHI = M_MOCKS(i).GHI;
    M_PVSITE(i).kW = M_MOCKS(i).kW;
end
load P_Mult_60s_Flay.mat

%One day run on 6/1:
%{
DAY = 1;
MNTH = 6;
%}
DAY = 3;
MNTH = 2;
%{
DAY = 1;
MNTH = 1;
%}
DOY=calc_DOY(MNTH,DAY);


%-----------------
CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
GHI=M_PVSITE(MNTH).kW(time2int(DAY,0,0):time2int(DAY,23,59),1)/5000; %PU
%convert to P.U.
%inputs:

CSI_TH=0.1;
BESS.Prated=1000;
BESS.Crated=12121; %4000kWh
BESS.DoD_max=0.33;
BESS.Eff_DR=.967;
BESS.Eff_CR=.93;
%{
BESS.Eff_DR=.967;
BESS.Eff_CR=.93;
BESS.DoD_max=0.33;
BESS.Crated=10000;
%}
%C=BESS.Crated*BESS.DoD_max; %this will change....

C=BESS.Crated;




DoD=BESS.DoD_max; %current DoD at start of day:
[SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,BESS.DoD_max);

BESS_INFO.CSI=CSI;
BESS_INFO.BncI=BncI;
BESS_INFO.SOC_start=BESS.DoD_max;
BESS_INFO.SOC_ref=SOC_ref;
BESS_INFO.CR_ref=CR_ref;
BESS_INFO.t_CR=t_CR;
%}
%
%{


CSI=CSI/max(CSI);
BncI=BncI/max(BncI);
CSI_TH=0.2;
ON = 0;
OFF = 0;

for m=1:1:length(CSI)
    if CSI(m,1) > 0.2 && ON == 0
        T_ON=round((m/1440)*24);
        ON = 1;
    elseif CSI(m,1) < 0.2 && ON == 1 && OFF == 0
        T_OFF=round((m/1440)*24);
        OFF = 1;
    end
end
%%
%{
j =1;
t_A = t_max-1;
t_B = t_max+1;
%t_A = 16*60;
%t_B = 18*60;
end_loop = 0;

while end_loop ~= 1
    %Find new time interval:
    peak(j).t_A = t_A;
    peak(j).t_B = t_B;
    time=t_A:1:t_B;
    %Find energy under curve (discrete)
    peak(j).top = trapz(time,P_DAY1(time))/60;

    %Now find bottom energy:
    P_DAY1_bot(1,1)=P_DAY1(t_A);
    P_DAY1_srt = P_DAY1_bot(1,1);
    P_DAY1_bot(1,2)=t_A;
    for i=2:1:(t_B-t_A+1)
        %P_DAY1_bot(i,1)=P_DAY1_bot(i-1)+(P_DAY1(t_B)-P_DAY1(t_A))/(t_B-t_A+1);
        if P_DAY1_srt > P_DAY1(t_A+i-1)
            %this means the actual load dipped below starting kW:
            P_DAY1_bot(i,1) = P_DAY1(t_A+i-1);
        else
            P_DAY1_bot(i,1) = P_DAY1_srt;
        end
        P_DAY1_bot(i,2)=t_A+i-1;
    end
    peak(j).bot = trapz(P_DAY1_bot(:,2),P_DAY1_bot(:,1))/60; %kWh
    
    %Find energy that will be covered:
    peak(j).en = peak(j).top - peak(j).bot;

    %Find Energy Error:
    peak(j).error = peak(j).en - bat_en;
    if peak(j).error < -1*bat_en*sigma
        %not enough energy covered, need to increase time span:
        if j ~= 1
            if peak(j-1).error > peak(j).error && t_A-1 < t_B && t_A-1 < t_max 
                t_A = t_A - 1; %move backward
            elseif t_B+1 > t_A 
                t_B = t_B + 1; %move forward
            end
        end
    elseif peak(j).error > bat_en*sigma
        %too much energy covered, decrement time span:
        if j ~= 1
            if peak(j-1).error < peak(j).error && t_A-1 < t_B
                t_A = t_A - 1;
            elseif t_B-1 > t_A
                t_B = t_B - 1;
            end
        end
    else
        end_loop = 1;
        %stop iterations:
    end
    j = j + 1;
end
%}      
%%

T=T_OFF-T_ON;
En_Cap=8000; %kWh+
EFF_DR=.967;
EFF_CR=.93;
EFF_BAT=EFF_DR*EFF_CR;
C_r=10000;

DoD_max=0.33;
%C=8000; %kWh
C=C_r*DoD_max; %this can change...
h_1=(1+(1-EFF_CR))*C/T;

ToS2=0.95; %Always keep a 5% threshold for downramp of CR to end of Solar Interval. 
%typically 3hr ramp at h_1 will yield 0.95*h_1 (485kWh) for 8000kWh
%ToS1=0.92;%0.85;
[ToS1,PAR_CB]=ToS1_EST(BncI,CSI,DoD_max);
fprintf('Solar Irradiance has a PAR_CB = %0.3f\n',PAR_CB);

f=@(x)solve_SCR_h2(x,T,C,h_1,ToS1,ToS2);
x0=[h_1,0.1];
[x_e,fval]=fsolve(f,x0);
fprintf('Amount of increase in the constant charging rate to recover lost E: \nh_2 = %0.2f\n',x_e(1));
h_2=x_e(1);
SCR=x_e(2);
fprintf('SCR=%0.4f\n',x_e(1));

%back calc the known CR datapoints:
t_1 = ((h_1)/SCR)+T_ON;
t_2 = ((h_1+h_2)/SCR)+T_ON;
t_3 = T_OFF+(h_1+h_2)/(-1*SCR);
fprintf('t_1=%0.3f \nt_2=%0.3f \t t_3=%0.3f \n',t_1,t_2,t_3);
fprintf('Time with constant CR: %0.3f \n',t_3-t_2);
t_4 = T_OFF+(h_1)/(-1*SCR);
t_5 = t_4-(h_1)/(-1*SCR);
fprintf('\nt_4=%0.3f \t t_5=%0.3f \n',t_4,t_5);

CR=[0,h_1,h_1+h_2,h_1+h_2,h_1,0];

%Convert hour to a 1sec CR_ref:
t_int=3600;

CR_m(1,1)=0;
%SOC_ref(1,1)=(1-DoD_max)*En_Cap;
kWh_ref(1,1)=C_r-C;

SOC_ref_CR=ones(24*3600,1)*kWh_ref(1,1)/C_r; %SOC
i =2;
for t=T_ON*t_int+1:1:T_OFF*t_int
    if t < t_2*t_int
        CR_m(i,1)=CR_m(i-1,1)+SCR/(1*t_int); %kW
        
    elseif t >= t_2*t_int && t <= t_3*t_int
        CR_m(i,1)=h_1+h_2; %kW
    elseif t > t_3*t_int && t < T_OFF*t_int
        CR_m(i,1)=CR_m(i-1,1)-SCR/(1*t_int); %kW
    else
        CR_m(i,1)=0;
    end
    
    kWh_ref(i,1)=kWh_ref(i-1,1)+(CR_m(i,1)*(1/3600)*EFF_CR); %kWh
    %Save for reference w/ QSTS:
    SOC_ref_CR(t,1)=kWh_ref(i,1)/C_r;
    
    i = i + 1;
end
%kWh_ref=kWh_ref/C;

%}
%
%
%Now lets calc Discharge:
%=======================
%   Attempting to find Discharge Interval...
P_DAY1=CAP_OPS_STEP2(DOY).kW(:,1)+CAP_OPS_STEP2(DOY).kW(:,2)+CAP_OPS_STEP2(DOY).kW(:,3);
P_DAY2=CAP_OPS_STEP2(DOY+1).kW(:,1)+CAP_OPS_STEP2(DOY+1).kW(:,2)+CAP_OPS_STEP2(DOY+1).kW(:,3);
[t_max,DAY_NUM,P_max,E_kWh]=Peak_Estimator_MSTR(P_DAY1,P_DAY2);

%{
hr=1;
sum1=0;
sum2=0;
P_max=zeros(2,2);
for m=1:1:length(P_DAY1)
    if m < hr*60
        sum1=sum1+P_DAY1(m);
        sum2=sum2+P_DAY2(m);
    elseif m == hr*60
        sum1=sum1+P_DAY1(m);
        sum2=sum2+P_DAY2(m);
        E_kWh(hr,1)=sum1/60;
        E_kWh(hr,2)=sum2/60;
        hr = hr + 1;
        sum1 = 0;
        sum2 = 0;
    end
    E_DAY1(m,1)=P_DAY1(m)/(1440/60);
    E_DAY2(m,1)=P_DAY2(m)/(1440/60);
    %now look for maximums:
    if P_DAY1(m) > P_max(1,1)
        P_max(1,1) = P_DAY1(m);
        P_max(2,1) = m;
    end
    if P_DAY2(m) > P_max(1,2)
        P_max(1,2) = P_DAY2(m);
        P_max(2,2) = m;
    end
end
%
if P_max(2,2)/60 < 9
    %then we have a peak during the morning, save energy!
    t_max=P_max(2,2)+24*60; %hours
else
    t_max=P_max(2,1);
end
fprintf('\nTarget PEAK KW - kth min: %0.2f\n',t_max);
%}
%Initial conditions:
SOC_n=1; %  100%

C_r=BESS.Crated;
DoD_max=BESS.DoD_max;

sigma=0.1;
%{
CI_k1 = M_PVSITE_SC_1(DOY+1,5);
if CI_k1 > 1
    CI_k1 = 1;
end
VI_k1 = M_PVSITE_SC_1(DOY+1,4);
beta=[0.44380209  0.01994886  6.51296679];
P_PV = 3000; %KW
PU_HR=(DoD_max*C_r)/(P_PV*0.25);
E_pu(DOY,1)=beta(1)+beta(2)*VI_k1+beta(3)*CI_k1;

%PU_HR = 5.33;
if E_pu(DOY,1) <= PU_HR %pu.hr
    DoD_tar(DOY,1)=(0.33/PU_HR)*E_pu(DOY,1);
else
    DoD_tar(DOY,1)=DoD_max;
end
%}
%{
DoD_est = (C_r*SOC_n*CI_k)/C_r;
if DoD_est < DoD_max
    DoD_est = DoD_max;
end
%}
%bat_en = SOC_n*C_r*DoD_tar(DOY,1); %kWh available (estimate then actual after CR period over.
%%

[peak,P_DR_ON,T_DR_ON] = DR_INT(t_max,P_DAY1,M_PVSITE_SC_1(DOY+1,:),sigma,BESS,1);
n=length(peak);
%C=bat_en;
%T_ON_1=round(peak(n).t_A/60);
T_ON_1=T_DR_ON;
T_OFF_1=round(peak(n).t_B/60);
fprintf('Battery will begin Discharge...\n');
fprintf('T_ON=%0.3f \t T_OFF=%0.3f\n',peak(n).t_A,peak(n).t_B);
fprintf('Target kW=%0.3f \n',P_DR_ON);
%Estimate:
%T_ON_1=17;
%T_OFF_1=21;
T_D=T_OFF_1-T_ON_1;
%ToS2=0.9;
%ToS1=0.83;

%select kW profile
P_DAY1_bot=[peak(n).P_DAY1_bot];
P_BESS=[peak(n).P_BESS];
%SOC_ref_DR=ones(24*3600,1)*SOC_ref(1,1);

%for t=T_ON_1*t_int+1:1:T_OFF_1*t_int
    
    
    
    
    
%{
h_1=DoD_max*C/abs(T_D);

f=@(x)solve_SCR_h2(x,T_D,C,h_1,ToS1,ToS2);
x0=[h_1,0.1];
[x_e_1,fval]=fsolve(f,x0);
h_2=x_e_1(1);
SDR=x_e_1(2);

t_1 = ((h_1)/SDR)+T_ON_1;
t_2 = ((h_1+h_2)/SDR)+T_ON_1

t_3 = T_OFF_1+(h_1+h_2)/(-1*SDR)
t_4 = T_OFF_1+(h_1)/(-1*SDR)
t_5 = t_4-(h_1)/(-1*SDR)
%}

%t=[T_ON_1,t_1,t_2,t_3,t_4,t_5];
%DR=[0,h_1,h_1+h_2,h_1+h_2,h_1,0];

Energy_Coord_Plots




