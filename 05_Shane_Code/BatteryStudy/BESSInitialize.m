function BESSInitialize(DSSCircObj,date)
global SCADA BESS_M LTC_STATE SWC_STATE MSTR_STATE M_PVSITE M_PVSITE_SC SOC_ref CR_ref t_CR k
global PV BESS

DSSCircuit = DSSCircObj.ActiveCircuit;
DSSText = DSSCircObj.Text;

% Initializes variables for Joe's Controller
    %SCADA_PULL
    k=1;
    t_total=86400;
    BESS_M.SOC=zeros(t_total,1);
    BESS_M.DR=zeros(t_total,1);
    BESS_M.CR=zeros(t_total,1);
    
    SCADA.PV_P=zeros(t_total,1);
    SCADA.SC_Q=zeros(t_total,1);
    SCADA.SC_S=ones(t_total,1)*-1;
    SCADA.OLTC_V=ones(t_total,1);
    SCADA.OLTC_TAP=ones(t_total,1);
    %SCADA(t).Meter_P=ones(t_total,3);
    %(t).Meter_V
    SCADA.Sub_P=ones(t_total,3);
    SCADA.Sub_Q=ones(t_total,3);
    SCADA.Sub_3P=ones(t_total,1);
    SCADA.Sub_3Q=ones(t_total,1);
    SCADA.Sub_PF=ones(t_total,1);
    SCADA.Sub_LDLG=ones(t_total,1);
    
    
%-- Initialize State variables:
    LTC_STATE.VIO_TIME=zeros(t_total,1);
    LTC_STATE.SVR_TMR=zeros(t_total,1);
    LTC_STATE.HV =zeros(t_total,1);
    LTC_STATE.LV =zeros(t_total,1);

    SWC_STATE.VIO_TIME=zeros(t_total,1);
    SWC_STATE.SC_TMR =zeros(t_total,1);
    SWC_STATE.SC_OP =zeros(t_total,1);
    SWC_STATE.SC_CL =zeros(t_total,1);

    MSTR_STATE.F_CAP_CL=zeros(t_total,1);
    MSTR_STATE.F_CAP_OP=zeros(t_total,1);
    MSTR_STATE.SC_CL_EN=zeros(t_total,1);
    MSTR_STATE.SC_OP_EN=zeros(t_total,1);
    
    
    
%-- PV Historical Data
% Find CAPER directory
fid = fopen('pathdef.m','r');
rootlocation = textscan(fid,'%c')';
rootlocation = regexp(rootlocation{1}','C:[^.]*?CAPER\\','match','once');
fclose(fid);

PV_Site_path_1 = [rootlocation,'04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC'];   
addpath(PV_Site_path_1);
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
clearvars M_MOCKS_INFO M_MOCKS M_TAYLOR_INFO M_MOCKS_SC

%-- MEC-F1 (gen. reference CR, SOC, DOD_target
DATE = str2double(regexp(date,'\d+','match'));
DAY=DATE(2);
MNTH=DATE(1);

CSI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
BncI=M_PVSITE(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
CSI_TH=0.1;

DAY_I=datenum(date)-datenum('1/1/2014')+1;

PV_pmpp = PV(1).kW;
% -------------------------------------------------------------------DoD_tar_est NOT RECOGNIZED--------------------------------------------------
DoD_DAY_SRT = DoD_tar_est( M_PVSITE_SC(DAY_I,:),BESS,PV_pmpp);
fprintf('State of Charge @ start of Day: %0.3f %%\n',(1-DoD_DAY_SRT)*100);

DSSText.command=sprintf('Edit Storage.BESS1 %%stored=%s',num2str(100*(1-DoD_DAY_SRT)));
DSSText.command='Edit Storage.BESS1 %Charge=0 %Discharge=0 State=IDLING';

C=BESS.Crated;
[SOC_ref,CR_ref,t_CR]=SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD_DAY_SRT);


end

