%fix file sizes
clear
clc
%addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\Three_Month_Runs\POI_1_Avg');
%addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\Annual_Runs\TIME_INT_1YR');
%filedir='C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\Annual_Runs\DSS_INT_1YR';
filedir='C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\Annual_Runs\TIME_SQE_1YR';
addpath(filedir);

%load YR_SIM_CAPOP_FLAY_00.mat
%load YR_SIM_PQ_FLAY_00.mat
%load YR_SIM_LTC_FLAY_00.mat
%YEAR_SIM_V=YEAR_SIM_LTC.DSS_LTC_V;
%hold=YEAR_SIM_LTC.DSS_LTC_OP;
%clear YEAR_SIM_LTC
%YEAR_SIM_LTC_OP=hold;

load YR_SIM_Q_FLAY_00.mat
for DOY=1:1:364
    if DOY <= 60
        YEAR_SIM_Q_1(DOY).DSS_SUB=YEAR_SIM_Q(DOY).DSS_SUB;
    elseif DOY > 60 && DOY <= 120
        YEAR_SIM_Q_2(DOY).DSS_SUB=YEAR_SIM_Q(DOY).DSS_SUB;
    elseif DOY > 120 && DOY <= 200
        YEAR_SIM_Q_3(DOY).DSS_SUB=YEAR_SIM_Q(DOY).DSS_SUB;
    elseif DOY > 200 && DOY <= 280
        YEAR_SIM_Q_4(DOY).DSS_SUB=YEAR_SIM_Q(DOY).DSS_SUB;
    else
        YEAR_SIM_Q_5(DOY).DSS_SUB=YEAR_SIM_Q(DOY).DSS_SUB;
    end
end
%Save variables:
file='\YR_SIM_Q_1_FLAY_00';
save(strcat(filedir,file),'YEAR_SIM_Q_1');
file='\YR_SIM_Q_2_FLAY_00';
save(strcat(filedir,file),'YEAR_SIM_Q_2');
file='\YR_SIM_Q_3_FLAY_00';
save(strcat(filedir,file),'YEAR_SIM_Q_3');
file='\YR_SIM_Q_4_FLAY_00';
save(strcat(filedir,file),'YEAR_SIM_Q_4');
file='\YR_SIM_Q_5_FLAY_00';
save(strcat(filedir,file),'YEAR_SIM_Q_5');
%}
%%

load YR_SIM_P_FLAY_00.mat
for DOY=1:1:364
    if DOY <= 60
        YEAR_SIM_P_1(DOY).DSS_SUB=YEAR_SIM_P(DOY).DSS_SUB;
    elseif DOY > 60 && DOY <= 120
        YEAR_SIM_P_2(DOY).DSS_SUB=YEAR_SIM_P(DOY).DSS_SUB;
    elseif DOY > 120 && DOY <= 200
        YEAR_SIM_P_3(DOY).DSS_SUB=YEAR_SIM_P(DOY).DSS_SUB;
    elseif DOY > 200 && DOY <= 280
        YEAR_SIM_P_4(DOY).DSS_SUB=YEAR_SIM_P(DOY).DSS_SUB;
    else
        YEAR_SIM_P_5(DOY).DSS_SUB=YEAR_SIM_P(DOY).DSS_SUB;
    end
end
%Save variables:
file='\YR_SIM_P_1_FLAY_00';
save(strcat(filedir,file),'YEAR_SIM_P_1');
file='\YR_SIM_P_2_FLAY_00';
save(strcat(filedir,file),'YEAR_SIM_P_2');
file='\YR_SIM_P_3_FLAY_00';
save(strcat(filedir,file),'YEAR_SIM_P_3');
file='\YR_SIM_P_4_FLAY_00';
save(strcat(filedir,file),'YEAR_SIM_P_4');
file='\YR_SIM_P_5_FLAY_00';
save(strcat(filedir,file),'YEAR_SIM_P_5');
%}
%%
load YR_SIM_LTC_CTLFLAY_00.mat
load YR_SIM_SUBV_FLAY_00.mat

for DOY=1:1:364
    YEAR_LTCTAP(DOY).TAP_POS=YEAR_LTCSTATUS(DOY).TAP_POS;
    if DOY <= 60
        YEAR_LTCSTATUS_1(DOY).WDG_PT=YEAR_LTCSTATUS(DOY).WDG_PT;
    elseif DOY > 60 && DOY <= 120
        YEAR_LTCSTATUS_2(DOY).WDG_PT=YEAR_LTCSTATUS(DOY).WDG_PT;
    elseif DOY > 120 && DOY <= 200
        YEAR_LTCSTATUS_3(DOY).WDG_PT=YEAR_LTCSTATUS(DOY).WDG_PT;
    elseif DOY > 200 && DOY <= 280
        YEAR_LTCSTATUS_4(DOY).WDG_PT=YEAR_LTCSTATUS(DOY).WDG_PT;
    else
        YEAR_LTCSTATUS_5(DOY).WDG_PT=YEAR_LTCSTATUS(DOY).WDG_PT;
    end
    
    YEAR_SUB_1(DOY).max_V=YEAR_SUB(DOY).max_V;
    YEAR_SUB_1(DOY).min_V=YEAR_SUB(DOY).min_V;
end
file='\YR_SIM_LTC_TAP_POS';
save(strcat(filedir,file),'YEAR_LTCTAP');
file='\YR_SIM_LTC_PT_V_1';
save(strcat(filedir,file),'YEAR_LTCSTATUS_1');
file='\YR_SIM_LTC_PT_V_2';
save(strcat(filedir,file),'YEAR_LTCSTATUS_2');
file='\YR_SIM_LTC_PT_V_3';
save(strcat(filedir,file),'YEAR_LTCSTATUS_3');
file='\YR_SIM_LTC_PT_V_4';
save(strcat(filedir,file),'YEAR_LTCSTATUS_4');
file='\YR_SIM_LTC_PT_V_5';
save(strcat(filedir,file),'YEAR_LTCSTATUS_5');

file='\YR_SIM_SUBV_1_FLAY_00';
save(strcat(filedir,file),'YEAR_SUB_1');

%%
%{
YEAR_P(1).headers={'A','B','C'};
YEAR_Q(1).headers={'A','B','C'};
for DOY=1:1:364
    YEAR_P(DOY).P=YEAR_SIM_PQ(DOY).DSS_SUB_P;
    YEAR_Q(DOY).Q=YEAR_SIM_PQ(DOY).DSS_SUB_Q;
end
%}
%{
YEAR_LTCV(1).headers={'A','B','C'};
YEAR_LTCOP(1).headers={'A','B','C'};
YEAR_CAPSTATUS(1).headers={'Cap position','Reactive Power Contributed'}';
YEAR_CAPCNTRL(1).headers={'Substation average PF','PF lead=1 & lag=0'}';
for DOY=1:1:364
    YEAR_SUB(DOY).V=YEAR_SIM_LTC(DOY).DSS_LTC_V; %YR_SIM_SUBV_FLAY_00
    YEAR_LTC(DOY).OP=YEAR_SIM_LTC(DOY).DSS_LTC_OP;
    YEAR_CAPSTATUS(DOY).CAP_POS=CAP_OPS_DSS(DOY).CAP_POS; %YR_SIM_CAP1_FLAY_00
    YEAR_CAPSTATUS(DOY).Q_CAP=CAP_OPS_DSS(DOY).Q_CAP;
    YEAR_CAPCNTRL(DOY).CTL_PF=CAP_OPS_DSS(DOY).CTL_PF; %YR_SIM_CAP2_FLAY_00
    YEAR_CAPCNTRL(DOY).LD_LG=CAP_OPS_DSS(DOY).LD_LG;
end
%YEAR_SIM(:).P=[YEAR_SIM_PQ(1:364).DSS_SUB_P];
%YEAR_SIM_Q=YEAR_SIM_PQ.DSS_SUB_Q;
%}