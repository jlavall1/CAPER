clear
clc
close all
PV_rated=3000;

load P_PV_6_1.mat
load SCADA.mat
load BESS_M.mat
load SWC_STATE.mat
load LTC_STATE.mat
load MSTR_STATE.mat
dP_PV_S=zeros(length(PV_P),2);
for t=2:1:length(PV_P)
    dP_PV_S(t,1)=PV_P(t)-PV_P(t-1);
    dP_PV_S(t,2)=dP_PV_S(t)/PV_rated;
end
figure(1)
plot(dP_PV_S(:,1),'r-');
figure(2)
plot(dP_PV_S(:,2),'b-');
%%
P_ON=0.10*PV_rated;
P_TH=0.015;


t_s=10*3600;
t_f=t_s+20;

for t=t_s:1:t_f
    %--I/O State Variables:
    %SWC_STATE
    cap_timer=SWC_STATE(t).SC_TMR;
    vio_time=SWC_STATE(t).VIO_TIME;
    SC_OP=SWC_STATE(t).SC_OP;
    SC_CL=SWC_STATE(t).SC_CL;
    %LTC_STATE
    vio_LTC_time=LTC_STATE(t).VIO_TIME;
    SVR_TMR=LTC_STATE(t).SVR_TMR;
    HV=LTC_STATE(t).HV;
    LV=LTC_STATE(t).LV;
    %MSTR_STATE
    F_CAP_CL = MSTR_STATE(t).F_CAP_CL;
    F_CAP_OP = MSTR_STATE(t).F_CAP_OP;
    MS_SC_CL=MSTR_STATE(t).SC_CL_EN;
    MS_SC_OP=MSTR_STATE(t).SC_OP_EN;
    %BESS_STATE
    
    %SCADA POINTS NEEDED
    P_PV_k=abs(SCADA(t).PV_P);
    P_PV_k1=abs(SCADA(t-1).PV_P);
    dP_PV_k=P_PV_k-P_PV_k1; %P(k)-P(k-1)
    dP_PV_kpu=dP_PV_k/PV_rated;
    
    P_meter=SCADA(t).Meter_P;
    DR_k1=BESS_M(t-1).DR;
    CR_k1=BESS_M(t-1).CR;
    
    %logic:
    if P_PV_k > P_ON
        if HV == 1
            %Continue with normal charging rate.
            B_DCHA = 0;
            B_CHA = 1;
            fprintf('HV Present @ OLTC\n');
        elseif LV ~= 1
            %Continue with normal charging rate.
            B_DCHA = 0;
            B_CHA = 1;
            fprintf('No voltage violations @ OLTC, Follow CR\n');
        else
            %OLTC is observing a LV event: Either Loss of Gen or Inc. Load
            if dP_PV_kpu < -1*P_TH
                %Temp loss in generation:
                fprintf('C\n');
                P_VIO = P_PV_k;
                DR_k=dP_PV_k+DR_k1+CR_k1;
            elseif P_PV_k > P_VIO
                %The generator is gaining kW now...
                %P_VIO_k=
                DR_k=DR_k1-alpha*(P_VIO-dP_PV_k);
                
            elseif P_meter < 0
                %Reverse Power Flow
                fprintf('Reverse Power Flow Observed\n');
            %elseif CR_k
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
            else
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
    

