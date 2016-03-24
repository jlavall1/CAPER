function [ SOC_ref ,CR_ref, t_CR ] = SOCref_CR(BncI,CSI,CSI_TH,BESS,C,DoD)
%Input Arguments:
    %------------------
    %BncI=Beam normal Clear sky Irradiance Profile
    %CSI=Clear SKy Iradiance, Global.
    %CSI_TH=threshold to estimate time when PV in generating.
    %BESS=Struct with battery specs.
    %C = Available energy at beginning of Charging Window.
    %------------------
%Variables:
    %PAR_CB_min = minimum ratio during year at specific site.
    %ToS_2,SCR (decided in here)
    %T = (hrs) Time interval when Battery is set to charge.
    %------------------
%Obtain Battery Specifications:
    EFF_DR=BESS.Eff_DR;
    EFF_CR=BESS.Eff_CR;
    %COMP_CR=1+(1-EFF_CR);
    COMP_CR=1/EFF_CR;
    %COMP_CR=1-EFF_CR;
    DoD_max=BESS.DoD_max;
    C_r=BESS.Crated;
%1]
    %Find time to start / finish charging period:
    CSI_PU=CSI/max(CSI);
    %BncI_PU=BncI/max(BncI);
    ON = 0;
    OFF = 0;
    for m=1:1:length(CSI)
        if CSI_PU(m,1) > CSI_TH && ON == 0
            T_ON=round((m/1440)*24);
            ON = 1;
        elseif CSI_PU(m,1) < CSI_TH && ON == 1 && OFF == 0
            T_OFF=round((m/1440)*24);
            OFF = 1;
        end
    end
%2]
    %Find ToS_2 & SCR to construct Charge Rate Shape:
    T=T_OFF-T_ON;
    %h_1=(1+(1-EFF_CR))*C/T;
    %h_1=(COMP_CR*C*DoD)/T; %jus
    h_1=(C*DoD)/T;
    ToS2=0.95; %Always keep a 5% threshold for downramp of CR to end of Solar Interval. 
        %typically 3hr ramp at h_1 will yield 0.95*h_1 (485kWh) for 8000kWh
    [ToS1,PAR_CB]=ToS1_EST(BncI,CSI,DoD);
    fprintf('ToS1=%0.4f & ToS2=%0.4f\n',ToS1,ToS2);
    fprintf('Solar Irradiance has a PAR_CB = %0.3f\n',PAR_CB);
    f=@(x)solve_SCR_h2(x,T,C,h_1,ToS1,ToS2);
    x0=[h_1,0.1];
    [x_e,fval]=fsolve(f,x0);
    fprintf('To construct Trap shape:\n \th_2 = %0.2f\n',x_e(1));
    fprintf('h_1 = %0.4f\n',h_1);
    h_2=x_e(1);
    SCR=x_e(2);
    fprintf('\tSCR=%0.4f\n',x_e(1));
    %SCR=SCR*COMP_CR;
    %back calc the known CR datapoints:
    t_1 = ((h_1)/SCR)+T_ON;
    t_2 = ((h_1+h_2)/SCR)+T_ON;
    t_3 = T_OFF+(h_1+h_2)/(-1*SCR);
    fprintf('\nImportant times:\n');
    fprintf('t_1=%0.3f \nt_2=%0.3f \t t_3=%0.3f \n',t_1,t_2,t_3);
    fprintf('\t(Time with constant CR: %0.3f) \n',t_3-t_2);
    t_4 = T_OFF+(h_1)/(-1*SCR);
    t_5 = t_4-(h_1)/(-1*SCR);
    fprintf('t_4=%0.3f \t t_5=%0.3f \n',t_4,t_5);
    t_CR=[T_ON,t_1,t_2,t_3,t_4,t_5,T_OFF];
    %CR=[0,h_1,h_1+h_2,h_1+h_2,h_1,0];
%3]
    %Construct SOC_reference from critical times:
    
    %   Convert hour to a 1sec CR_ref:
    t_int=3600;
    CR_m(1,1)=0; %0kW initially
    CR_ref=zeros(24*3600,1);
    %   Find initial Energy Available (from input)
    kWh_ref(1,1)=C*(1-DoD);
    %   Initialize Variables Required
    SOC_ref=ones(24*3600,1)*kWh_ref(1,1)/C_r; %SOC
    i =2;
    
    %   Transform from hourly to 1 second SOC profile
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
        CR_ref(t,1)=CR_m(i,1);
        i = i + 1;
    end
    CR_ref=CR_ref*COMP_CR;
    i = 2;
    for t=T_ON*t_int+1:1:T_OFF*t_int
        %Calculate Energy Charged per kth interval:
        kWh_ref(i,1)=kWh_ref(i-1,1)+EFF_CR*CR_ref(t,1)*(1/3600); %kWh
        
        %Save for reference w/ QSTS:
        SOC_ref(t,1)=kWh_ref(i,1)/C_r;
        %CR_ref(t,1)=CR_m(i,1);
        i = i + 1;
    end
    %CR_ref=CR_ref*COMP_CR;
end

