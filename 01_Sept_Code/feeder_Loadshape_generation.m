%feeder_Loadshape_generation: This .m file will generate the .txt single
%phase files of the desired day user define.
%%
%Temp init. vars/actions
%{
clear
clc
base_path = 'C:\Users\jlavall\Documents\GitHub\CAPER';
ckt_direct = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Flay_Circuit_Opendss\Run_Master_Allocate.dss';
feeder_NUM = 2;
timeseries_span = 1;
DOY = 40;
%}
%%
%As of 10/12 - user pre-defines and it is not dynamic yet.
path = strcat(base_path,'\04_DSCADA\Feeder_Data');
addpath(path);

if feeder_NUM == 0
    load BELL.mat
    FEEDER = BELL;
    clearvars BELL
    kW_peak = [0,0,0];
elseif feeder_NUM == 1
    load CMNWLTH.mat
    FEEDER = CMNWLTH;
    clearvars CMNWLTH
    kW_peak = [2.475021572579630e+03,2.609588847297235e+03,2.086659558753901e+03];
elseif feeder_NUM == 2
    load FLAY.mat
    FEEDER = FLAY;
    clearvars FLAY
    kW_peak = [1.424871573296857e+03,1.347528364235151e+03,1.716422704604557e+03];
elseif feeder_NUM == 3
    load ROX.mat
    FEEDER = ROX;
    clearvars ROX
    kW_peak = [3.189154306704542e+03,3.319270338767296e+03,3.254908188719974e+03];
elseif feeder_NUM == 4
    load HOLLY.mat
elseif feeder_NUM == 5
    load ERalh.mat
end
%%
%Select DOY & convert to P.U. --
%   DOY already decided from PV_Loadshape_generation.
if timeseries_span == 1
    %10AM to 4PM --
    LS_PhaseA(:,1) = FEEDER.kW.A(time2int(DOY,10,0):time2int(DOY,15,59),1)./kW_peak(1,1);
    LS_PhaseB(:,1) = FEEDER.kW.B(time2int(DOY,10,0):time2int(DOY,15,59),1)./kW_peak(1,2);
    LS_PhaseC(:,1) = FEEDER.kW.C(time2int(DOY,10,0):time2int(DOY,15,59),1)./kW_peak(1,3);    
elseif timeseries_span == 2
    %24HR Sim    -- 
    LS_PhaseA(:,1) = FEEDER.kW.A(time2int(DOY,0,0):time2int(DOY,23,59),1)./kW_peak(1,1);
    LS_PhaseB(:,1) = FEEDER.kW.B(time2int(DOY,0,0):time2int(DOY,23,59),1)./kW_peak(1,2);
    LS_PhaseC(:,1) = FEEDER.kW.C(time2int(DOY,0,0):time2int(DOY,23,59),1)./kW_peak(1,3);
elseif timeseries_span == 3
    %1 Week Sim  -- @1min incs.
    LS_PhaseA(:,1) = FEEDER.kW.A(time2int(DOY,0,0):time2int(DOY+6,23,59),1)./kW_peak(1,1);
    LS_PhaseB(:,1) = FEEDER.kW.B(time2int(DOY,0,0):time2int(DOY+6,23,59),1)./kW_peak(1,2);
    LS_PhaseC(:,1) = FEEDER.kW.C(time2int(DOY,0,0):time2int(DOY+6,23,59),1)./kW_peak(1,3);
elseif timeseries_span == 4
    % Month Sim -- @10min incs.
    LS_PhaseA(:,1) = FEEDER.kW.A(time2int(DOY,0,0):time2int(DOY+shift,23,59),1)./kW_peak(1,1);
    LS_PhaseB(:,1) = FEEDER.kW.B(time2int(DOY,0,0):time2int(DOY+shift,23,59),1)./kW_peak(1,2);
    LS_PhaseC(:,1) = FEEDER.kW.C(time2int(DOY,0,0):time2int(DOY+shift,23,59),1)./kW_peak(1,3);    
elseif timeseries_span == 5
    %1 YEAR Sim -- @10min incs.
    MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
    MNTH= 1;
    DAY = 1;
    hr = 0;
    min = 0;
    i = 1;
    LS_PhaseA = zeros(365*24*60/10,1);
    LS_PhaseB = zeros(365*24*60/10,1);
    LS_PhaseC = zeros(365*24*60/10,1);
   while MNTH < 13
       while DAY < MTH_LN(1,MNTH)+1
           while hr < 24
               while min < 60
                   LS_PhaseA(i,1) = FEEDER.kW.A(time2int(DAY,hr,min),1)./kW_peak(1,1);
                   LS_PhaseB(i,1) = FEEDER.kW.B(time2int(DOY,hr,min),1)./kW_peak(1,2);
                   LS_PhaseC(i,1) = FEEDER.kW.C(time2int(DOY,hr,min),1)./kW_peak(1,3);
                   i = i + 1;
                   min = min + 10;
               end
               min = 0;
               hr = hr + 1;
           end
           hr = 0;
           DAY = DAY + 1;
       end
       DAY = 1;
       MNTH = MNTH + 1;
   end
end
%%
%Save .txt per phase --
s = ckt_direct(1:end-23); % <--------THIS MIGHT CHANGE PER FEEDER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
str = ckt_direct;
idx = strfind(str,'\');
str = str(1:idx(8)-1);
if timeseries_span == 1
    %10AM to 4PM, at 1minute intervals
    s_kwA = strcat(s,'LS1_PhaseA.txt');
    s_kwB = strcat(s,'LS1_PhaseB.txt');
    s_kwC = strcat(s,'LS1_PhaseC.txt');
    FEEDER.SIM.npts= 6*60;  %simulating 6 hours
    FEEDER.SIM.stepsize = 60; %60sec sim intervals
    idx = strfind(ckt_direct,'.');
    ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_6hr.dss');
elseif timeseries_span == 2
    %24 Hours, 1 DAY at 1minute intervals
    s_kwA = strcat(s,'LS2_PhaseA.txt');
    s_kwB = strcat(s,'LS2_PhaseB.txt');
    s_kwC = strcat(s,'LS2_PhaseC.txt');
    FEEDER.SIM.npts= 24*60;     %simulating 24 hours
    FEEDER.SIM.stepsize = 60;   %60 second sim intervals
    idx = strfind(ckt_direct,'.');
    ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_24hr.dss');
elseif timeseries_span == 3
    %1 Week simulation
    s_kwA = strcat(s,'LS3_PhaseA.txt');
    s_kwB = strcat(s,'LS3_PhaseB.txt');
    s_kwC = strcat(s,'LS3_PhaseC.txt');
    FEEDER.SIM.npts= 7*24*60;   %simulating 168 hours
    FEEDER.SIM.stepsize = 60;   %1 minute intervals
    idx = strfind(ckt_direct,'.');
    ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_168hr.dss');
elseif timeseries_span == 4
    %1 Month simulation
    FEEDER.SIM.npts= MTH_LN(1,monthly_span)*24*60;   %simulating one month 29-31days
    FEEDER.SIM.stepsize = 60;   %1 minute intervals
    if shift+1 == 28        %40320 datapoints
        s_kwA = strcat(s,'LS4_PhaseA.txt');
        s_kwB = strcat(s,'LS4_PhaseB.txt');
        s_kwC = strcat(s,'LS4_PhaseC.txt');
        idx = strfind(ckt_direct,'.');
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth28.dss');
    elseif shift+1 == 30    %43200 datapoints
        s_kwA = strcat(s,'LS5_PhaseA.txt');
        s_kwB = strcat(s,'LS5_PhaseB.txt');
        s_kwC = strcat(s,'LS5_PhaseC.txt');
        idx = strfind(ckt_direct,'.');
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth30.dss');
    elseif shift+1 == 31    %44640 datapoints
        s_kwA = strcat(s,'LS6_PhaseA.txt');
        s_kwB = strcat(s,'LS6_PhaseB.txt');
        s_kwC = strcat(s,'LS6_PhaseC.txt');
        idx = strfind(ckt_direct,'.');
        ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_1mnth31.dss');
    end
    %{
    MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
    MTH_DY(2,1:12) = [1,32,60,91,121,152,182,213,244,274,305,335];
    DOY = MTH_DY(2,monthly_span);   %From top--> monthly_span:
    shift = MTH_LN(1,monthly_span)-1;
    %}
elseif timeseries_span == 5
    %1 YEAR simulation
    s_kwA = strcat(s,'LS7_PhaseA.txt');
    s_kwB = strcat(s,'LS7_PhaseB.txt');
    s_kwC = strcat(s,'LS7_PhaseC.txt');
    FEEDER.SIM.npts= 365*24*60/10;  %simulating full 365days
    FEEDER.SIM.stepsize = 60*10;    %10 minute intervals
    idx = strfind(ckt_direct,'.');
    ckt_direct_prime = strcat(ckt_direct(1:idx(1)-1),'_365dy.dss');
end
csvwrite(s_kwA,LS_PhaseA)
csvwrite(s_kwB,LS_PhaseB)
csvwrite(s_kwC,LS_PhaseC)
