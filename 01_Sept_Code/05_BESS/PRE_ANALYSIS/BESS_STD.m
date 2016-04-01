clear
clc
close all
PV_rated=3000;

%load P_PV_6_1.mat
load SCADA.mat     %All other field measurements
load BESS_M.mat    %Measurements of CR/DR & SOC(t)
load YEAR_BESS.mat %reference CR & SOC

load SWC_STATE.mat
load LTC_STATE.mat
load MSTR_STATE.mat
%%
PV_P = [SCADA.PV_P];
dP_PV_S=zeros(length(PV_P)/5,2);
k = 1;
for t=6:5:length(PV_P)
    dP_PV_S(k,1)=abs(PV_P(t))-abs(PV_P(t-5));
    dP_PV_S(k,2)=dP_PV_S(k,1)/PV_rated;
    k = k+ 1;
end
figure(1)
plot(dP_PV_S(:,1),'r-');
figure(2)
plot(dP_PV_S(:,2),'bo');
%%
clc
clear TRBL
P_ON=0.10*PV_rated;
P_TH=0.015;
P_VIO=1.5*PV_rated;
alpha=0.5;
DR_k = 0;
%References that don't change:
SOC_ref=[YEAR_BESS.SOC]';
CR_ref=[YEAR_BESS.CR]';
k=2;

%t_s=round(11.4361*3600);
t_s = 41200;
t_f=t_s+40*5;
t_step=5;
for t=t_s:5:t_f
    fprintf('\t t=%d\n',t);
    %--I/O State Variables:
    %SWC_STATE
    cap_timer=SWC_STATE(t).SC_TMR;
    vio_time=SWC_STATE(t).VIO_TIME;
    SC_OP=SWC_STATE(t).SC_OP;
    SC_CL=SWC_STATE(t).SC_CL;
    %LTC_STATE
    vio_LTC_time=LTC_STATE(t).VIO_TIME;
    SVR_TMR=LTC_STATE(t).SVR_TMR;
    %HV=LTC_STATE(t).HV;
    %LV=LTC_STATE(t).LV;
    OLTC_V = SCADA(t).OLTC_V;
    dT=1/3600;
    
    LV = 1;
    HV = 0;
    %MSTR_STATE
    F_CAP_CL = MSTR_STATE(t).F_CAP_CL;
    F_CAP_OP = MSTR_STATE(t).F_CAP_OP;
    MS_SC_CL=MSTR_STATE(t).SC_CL_EN;
    MS_SC_OP=MSTR_STATE(t).SC_OP_EN;
    %BESS_STATE
    SOC_k = BESS_M(t).SOC;
    
    SOC_k1= BESS_M(t-1).SOC;
    DR_k1=BESS_M(t-1).DR;
    CR_k1=1.06*BESS_M(t-1).CR;
    
    
    %SCADA POINTS NEEDED
    P_PV_k=abs(SCADA(t).PV_P);
    P_PV_k1=abs(SCADA(t-t_step).PV_P);
    dP_PV_k=P_PV_k-P_PV_k1; %P(k)-P(k-1)
    dP_PV_kpu=dP_PV_k/PV_rated;
    
    P_meter=SCADA(t).Meter_P;
    V_meter=SCADA(t).Meter_V;
    
    %TROUBLE SHOOTING MATRIX:
    TRBL(k).SOC = SOC_k;
    TRBL(k).P_PV = P_PV_k;
    TRBL(k).dP_PV = dP_PV_k;
    TRBL(k).dP_PVpu = dP_PV_kpu;
    TRBL(k).time = t;
    k = k + 1;
    
    %logic:
    if P_PV_k > P_ON
        if HV == 1
            %Continue with normal charging rate.
            B_DCHA = 0;
            B_CHA = 1;
            fprintf('HV Present @ OLTC\n');
        elseif LV ~= 1
            %Wanting to continue Charge Rate Schedule, need to check SOC
            %of BESS first & make sure its on schedule.
            if abs(SOC_ref(t)-SOC_k) > 0.01
                %Short term Charging
                CR_k = CR_ref(t)+STC_coeff*((SOC_ref(t)-(SOC_ref(t-1)+CR_ref(t))*(1/3600))/(1/3600));
            else
                %Keep on schedule b/c everything is fine.
                CR_k = CR_ref(t);
            end
            
            B_DCHA = 0;
            B_CHA = 1;
            fprintf('No voltage violations @ OLTC, Follow CR=%0.3f\n',CR_k);
            
        else
            %OLTC is observing a LV event: Either Loss of Gen or Inc. Load
            if dP_PV_kpu < -1*P_TH
                %Temp loss in generation:
                fprintf('Move to Temp. Discharging b/c dP > thresh.\n');
                P_VIO = P_PV_k;
                DR_k=dP_PV_k+DR_k1+CR_k1;
                
            elseif P_PV_k > P_VIO
                %The generator is gaining kW now...
                %P_VIO_k=
                DR_k=DR_k1-alpha*(P_VIO-dP_PV_k);
                
            elseif V_meter-OLTC_V > 0
                %Observing inverse voltage profile, Reverse power flow..
                fprintf('Reverse Power Flow Observed\n');
                %Charings ----
                if abs(SOC_ref(t)-SOC_k) > 0.01
                %Short term Charging
                    
                    CR_k = CR_ref(t)+STC_coeff*((SOC_ref(t)-(SOC_ref(t-1)+CR_ref(t))*dT)/dT);
                else
                    %Keep on schedule b/c everything is fine.
                    CR_k = CR_ref(t);
                end
            
                B_DCHA = 0;
                B_CHA = 1;
                fprintf('Meter point > V then OLTC, Follow CR=%0.3f\n',CR_k);
                
            %elseif CR_k
            elseif V_meter-OLTC_V <= 0
                %No reverse power flow, but observed PV still on:
                %Charings ----
                CR_k = CR_ref(t);
                B_DCHA = 0;
                B_CHA = 1;
                fprintf('Charge Rate staying on Schedule...\n');
            end
            
            %Make sure DR is a positive #
            if DR_k < 0
                %Need to flip to charging:
                DR_k=0;
                CR=abs(DR);
                P_VIO = 1.5*PV_rated; %reset hold variable
                B_DCHA=0;
                B_CHA=1;
                fprintf('Switched from DR to CR\n');
            elseif B_CHA ~= 1
                fprintf('DR_k will be implemented\n');
                B_DCHA=1;
                B_CHA=0;
            end
            
        end
    else
        %PV generation not high enough, check if peak shaving 
        fprintf('P_PV not on...\n');
    end
    
    
    
    
    
    
    
    
end
    

