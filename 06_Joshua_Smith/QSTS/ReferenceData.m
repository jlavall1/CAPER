%Load Historical DSCADA
load CAP_Mult_60s_ROX.mat
load P_Mult_60s_ROX.mat
load Q_Mult_60s_ROX.mat
load LoadTotals.mat

%Component Names:
Caps.Name{1}='CAP1';
Caps.Name{2}='CAP2';
Caps.Name{3}='CAP3';
Caps.Swtch(1)=1200/3; 
Caps.Swtch(2)=1200/3; 
Caps.Swtch(3)=1200/3;
trans_name='T5240B12';
sub_line='A1';

timeseries_span = 2;

MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31]; %number of days/month

slt_DAY_RUN = 1;
% Scenarios
if slt_DAY_RUN == 1
    %One day run on 2/13
    DAY = 13;
    MNTH = 2;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY;
elseif slt_DAY_RUN == 2
    %3 mnth run 2/1 - 5/1
    DAY = 1;
    MNTH = 2;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F = DOY+MTH_LN(2)+MTH_LN(3)+MTH_LN(4)-1;
elseif slt_DAY_RUN == 3
    %Annual run
    DAY = 1;
    MNTH = 1;
    DOY=calc_DOY(MNTH,DAY);
    DAY_F=364;
end

int_select=2;
if int_select == 1
    %5sec load sim step:
    int_1m=12;
    s_step=5; %sec
    ss=1;
    NUM_INC=60;
elseif int_select == 2
    %60sec load sim step:
    int_1m=1;
    s_step=60; %sec
    ss=60;
    NUM_INC=1;
    sim_num=s_step*24;
elseif int_select == 3
    %5sec load sim step:
    int_1m=12;
    s_step=5; %sec
    ss=5;
    NUM_INC=60/5;
end


DAY_I=DOY;
eff_KVAR=ones(1,3);
% interpolate seconds between minutes
CAP_OPS_STEP2_1(DAY_I).kW(:,1) = interp(CAP_OPS_STEP2(DAY_I).kW(:,1),int_1m); %60s -> 5s
CAP_OPS_STEP2_1(DAY_I).kW(:,2) = interp(CAP_OPS_STEP2(DAY_I).kW(:,2),int_1m); %60s -> 5s
CAP_OPS_STEP2_1(DAY_I).kW(:,3) = interp(CAP_OPS_STEP2(DAY_I).kW(:,3),int_1m); %60s -> 5s
CAP_OPS_1(DAY_I).DSS(:,1) = eff_KVAR(1,1)*interp(CAP_OPS(DAY_I).DSS(:,1),int_1m);
CAP_OPS_1(DAY_I).DSS(:,2) = eff_KVAR(1,2)*interp(CAP_OPS(DAY_I).DSS(:,2),int_1m);
CAP_OPS_1(DAY_I).DSS(:,3) = eff_KVAR(1,3)*interp(CAP_OPS(DAY_I).DSS(:,3),int_1m);

s='C:\Users\jms6\Documents\GitHub\CAPER\CAPER\06_Joshua_Smith\DSS';
filelocation=strcat(s,'\');
fileID = fopen([filelocation,'Loadshape.dss'],'wt');
fprintf(fileID,['New loadshape.LS_PhaseA npts=%s sinterval=%s pmult=(',...
    sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,1)/LoadTotals.kWA),') qmult=(',...
    sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,1)/LoadTotals.kVARA),')\n\n'],num2str(sim_num),num2str(s_step));
fprintf(fileID,['New loadshape.LS_PhaseB npts=%s sinterval=%s pmult=(',...
    sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,2)/LoadTotals.kWB),') qmult=(',...
    sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,2)/LoadTotals.kVARB),')\n\n'],num2str(sim_num),num2str(s_step));
fprintf(fileID,['New loadshape.LS_PhaseC npts=%s sinterval=%s pmult=(',...
    sprintf('%f ',CAP_OPS_STEP2_1(DAY_I).kW(:,3)/LoadTotals.kWC),') qmult=(',...
    sprintf('%f ',CAP_OPS_1(DAY_I).DSS(:,3)/LoadTotals.kVARC),')\n\n'],num2str(sim_num),num2str(s_step));
fclose(fileID);


