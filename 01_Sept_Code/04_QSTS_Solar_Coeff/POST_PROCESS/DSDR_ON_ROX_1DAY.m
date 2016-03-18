%1 day sample:
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\04_ROX\DAY_44');
load YR_SIM_CAP1_ROX_00.mat    %YEAR_CAPSTATUS
load YR_SIM_CAP2_ROX_00.mat    %YEAR_CAPCNTRL
load YR_SIM_MEAS_ROX_00.mat    %DATA_SAVE
load YR_SIM_OLTC_ROX_00.mat    %YEAR_LTC
load YR_SIM_P_ROX_00.mat       %YEAR_SIM_P
load YR_SIM_Q_ROX_00.mat       %YEAR_SIM_Q
load YR_SIM_SUBV_ROX_00.mat    %YEAR_SUB
load YR_SIM_TVD_ROX_00.mat     %Settings
load YR_SIM_LTC_CTLROX_00.mat  %YEAR_LTCSTATUS
%Background files:
load CAP_Mult_60s_ROX.mat   %CAP_OPS_STEP1
load P_Mult_60s_ROX.mat     %CAP_OPS_STEP2
load Q_Mult_60s_ROX.mat     %CAP_OPS.DSS & .oper

fig=fig+1;
j=1;
for i=1:1:length(YEAR_SIM_P(44).DSS_SUB)
    if mod(i,60)==0
        DSS_LOAD(j,1)=YEAR_SIM_Q(44).DSS_SUB(i,1);
        DSS_LOAD(j,2)=YEAR_SIM_Q(44).DSS_SUB(i,2);
        DSS_LOAD(j,3)=YEAR_SIM_Q(44).DSS_SUB(i,3);
        DSS_LOAD(j,4)=YEAR_SIM_P(44).DSS_SUB(i,1);
        DSS_LOAD(j,5)=YEAR_SIM_P(44).DSS_SUB(i,2);
        DSS_LOAD(j,6)=YEAR_SIM_P(44).DSS_SUB(i,3);

        j = j + 1;
    end
end
%-------------------------
figure(fig);
DOY=44;
plot(CAP_OPS_STEP1(DOY).data(:,4),'r--');
hold on
plot(CAP_OPS_STEP1(DOY).data(:,5),'b--');
hold on
plot(CAP_OPS_STEP1(DOY).data(:,6),'g--');
hold on
plot(DSS_LOAD(:,4),'r-');
hold on
plot(DSS_LOAD(:,5),'b-');
hold on
plot(DSS_LOAD(:,6),'g-');
%-------------------------
%now look at reactive power:
fig = fig + 1;
figure(fig);
plot(CAP_OPS_STEP1(DOY).data(:,1),'r--');
hold on
plot(CAP_OPS_STEP1(DOY).data(:,2),'b--');
hold on
plot(CAP_OPS_STEP1(DOY).data(:,3),'g--');
hold on
plot(DSS_LOAD(:,1),'r-');
hold on
plot(DSS_LOAD(:,2),'b-');
hold on
plot(DSS_LOAD(:,3),'g-');
%-------------------------
fig=fig+1;
figure(fig)
%X=[0:15:24*60-15]/1440;
i=1;
DAY_FIN=364;
for DOY=1:1:DAY_FIN
    %X(1,i:i+95) = [(i*15-15):15:(i)*1425];
    Y(i:i+95,1) = CAP_OPS(DOY).oper(:,1);
    Y(i:i+95,2) = CAP_OPS(DOY).oper(:,2)+1;
    Y(i:i+95,3) = CAP_OPS(DOY).oper(:,3)+2;
    i = i + 96;
    %plot(X,CAP_OPS(DOY).oper(:,1),'b-');
    %hold on
end
X=[0:(15):DAY_FIN*24*60-15];
plot(X/1440,Y)
axis([0 DAY_FIN -0.5 3.5]);
%-------------------------