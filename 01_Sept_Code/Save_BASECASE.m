%Solve basecase & obtain beginning RESULTS row 1:
%Obtain V & I results from BASE CASE (0kW PVgen):        
%tic
Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
Voltages=Voltages';
max_V = zeros(2,2); %[3ph_mx,index;1ph_mx,index]
for i=1:1:length(Voltages)
    %Obtain peak 1-ph max Bus Voltage:
    if strcmp('1',ref_busVpu{i,2})==0       %ph A
        if Voltages(i,1) > max_V(2,1);
            max_V(1,1) = Voltages(i,1);
            max_V(1,2) = i;
        end
    elseif strcmp('2',ref_busVpu{i,2})==0   %ph B
         if Voltages(i,1) > max_V(1,1); 
            max_V(2,1) = Voltages(i,1);
            max_V(2,2) = i;
         end
    elseif strcmp('3',ref_busVpu{i,2})==0   %ph C
         if Voltages(i,1) > max_V(1,1);
            max_V(3,1) = Voltages(i,1);
            max_V(3,2) = i;
         end
    end   
end

Lines = getLineInfo_Currents(DSSCircObj);
Capacitors = getCapacitorInfo(DSSCircObj);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Calculate  %%ThermalRating  &  MAX(Phase Voltages in P.U.)
COUNT = 0;
if COUNT==0
    %Obtain thermal rating:
    thermal = zeros(length(Lines),3); %LINE_RATING | MAX sim PHASE CURRENT | %%THERMAL

    for i=1:1:length(thermal)
        if Lines(i,1).enabled == 0
            thermal(i,1) = 1;
        else
            thermal(i,1) = Lines(i,1).lineRating;
        end
    end
    COUNT=1; %to not grab linerating again
end

max_C = zeros(10,2); %reset max currents
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%Calculate %THERMAL
kk = 4; %Starting at 4 to skip buses within substation.
while kk<length(thermal)
    %Find last Sim's phase vltgs:
    %ansi84(kk,1) = max(Lines(kk,1).bus1PhaseVoltagesPU);
    %Find last Sim's line currents:


    if Lines(kk,1).enabled == 1
        thermal(kk,2) = max(Lines(kk,1).bus1PhaseCurrent);
        thermal(kk,3) = (thermal(kk,2)/thermal(kk,1))*100;
    else
        thermal(kk,3) = 0;
    end
    %Filter out 120V/240/480 Lines:

    if Lines(kk,1).bus1Voltage < 6000
        %We are only concerned about the primary lines:
        thermal(kk,3) = 0;
    end
%{                
    %NOW lets check for Voltage Profile
%                 if ansi84(kk,1) > max_V(1,1)
%                     max_V(1,1) = ansi84(kk,1);
%                     max_V(1,2) = kk;
%                 end
    %Pull line power flows:
    %L_Currents(kk,n)=Lines(kk,1).bus1PowerReal;
%}
    kk = kk + 1;
end
%Pull top 10 thermal(:,3) & store in max_C:
M = thermal(:,3);
[Msorted,AbsoluteIndices] = sort(M(:));
Mbiggest = Msorted(end:-1:end-9);
Mindices = AbsoluteIndices(end:-1:end-9);
max_C(:,1) = Mbiggest;
max_C(:,2) = Mindices;
%Check feeder load:
%
if  feeder_NUM == 0     %Bellhaven
    DSSCircuit.SetActiveElement('Line.259355408');
elseif feeder_NUM == 1  %Commonwealth
    DSSCircuit.SetActiveElement('Line.259355408');
elseif feeder_NUM == 2  %Flay
    DSSCircuit.SetActiveElement('Line.259363665');
elseif feeder_NUM == 3  %Roxboro
    DSSCircuit.SetActiveElement('Line.333');
end    
power = DSSCircuit.ActiveCktElement.Powers;
power = reshape(power,2,[]); %two rows for real and reactive
fDR_LD = sum(power(1,1:3));         
%Save Results:
jj = 1;
%Save results for this iteration:
RESULTS(jj,1:6)=[0,max(max_V(:,1)),0,max_C(1,1),max_C(2,1),0]; %|PV_KW|maxV_3ph|maxV_1ph|maxC1|maxC2|bus_name|kVAR_CAP1|kVAR_CAP2
if length(Capacitors) == 2
    RESULTS(jj,7)=Capacitors(1,1).powerReactive;
    RESULTS(jj,8)=Capacitors(2,1).powerReactive;
elseif length(Capacitors)== 3
    RESULTS(jj,7)=Capacitors(1,1).powerReactive;
    RESULTS(jj,8)=Capacitors(2,1).powerReactive;
    RESULTS(jj,10)=Capacitors(3,1).powerReactive;
end

%*** leave Columns 9,10 blank for post_Process_2.m ***
RESULTS(jj,11)=fDR_LD; %Feeder 3phase load in kW
%RESULTS(jj,12)=max(PV_VOLT(1,1:3)); %Maximum voltage voltage
%R_PV=(3*(RESULTS(jj,12)*((12.47e3)/sqrt(3)))^2)/(PV_size*1e3);
%RESULTS(jj,13)=R_PV; %Capture supposibly R_PV
