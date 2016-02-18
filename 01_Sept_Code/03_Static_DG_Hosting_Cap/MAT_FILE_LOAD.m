%The .m file will load the desired circuit information:
%Create a matrix with

Voltages=DSSCircObj.ActiveCircuit.AllBusVmagPu;
Voltages=Voltages';
ref_busVpu = cell(length(Voltages),2);

ii = 1; %Index for ref_busVpu
jj = 1;
while jj<length(Buses_Base)+1
    %Buses.name
    %Buses.node
    if length(Buses_Base(jj,1).nodes)==3 %3phase bus (easy)
        %Phase A:
        ref_busVpu{ii,1}=Buses_Base(jj,1).name;
        ref_busVpu{ii,2}=num2str(1);
        ii = ii + 1;
        %Phase B;
        ref_busVpu{ii,1}=Buses_Base(jj,1).name;
        ref_busVpu{ii,2}=num2str(2);
        ii = ii + 1;
        %Phase C;
        ref_busVpu{ii,1}=Buses_Base(jj,1).name;
        ref_busVpu{ii,2}=num2str(3);
        ii = ii + 1;
        %fprintf('3ph Hit at %1.1f\n',jj);
    elseif length(Buses_Base(jj,1).nodes)==1
        ref_busVpu{ii,1}=Buses_Base(jj,1).name;
        ref_busVpu{ii,2}=num2str(Buses_Base(jj,1).nodes);
        ii = ii + 1;
    elseif length(Buses_Base(jj,1).nodes)==2
        %fprintf('This is 2ph @ %1.1f\n',jj);
        %Phase B;
        ref_busVpu{ii,1}=Buses_Base(jj,1).name;
        ref_busVpu{ii,2}=num2str(Buses_Base(jj,1).nodes(1,1));
        ii = ii + 1;
        %Phase C;
        ref_busVpu{ii,1}=Buses_Base(jj,1).name;
        ref_busVpu{ii,2}=num2str(Buses_Base(jj,1).nodes(1,2));
        ii = ii + 1;
    
    end
    jj = jj + 1;
end
%%
%Set Voltage Regulating Devices:
if scenerio_NUM == 1
    %UPPER VOLTAGE BAND
    cap_on = 0;
    %tap = 8;
    vreg = 125;
elseif scenerio_NUM == 2
    %LOWER VOLTAGE BAND
    cap_on = 1;
    %tap = -8;
    vreg = 118;
elseif scenerio_NUM == 3
    %Normal VREG Operation
    %   Now lets set original V_target Settings
    if feeder_NUM == 0
        %Bellhaven
        vbase = 7;
        cap_on = 0;
        vreg = 120;
    elseif feeder_NUM == 1
        %Commonwealth
        vbase = 7;
        cap_on = 0;
        vreg = 122.98;
    elseif feeder_NUM == 2
        %Flay
        vbase = 7;
        cap_on = 0;
        vreg = 124;
    elseif feeder_NUM == 3
        %Roxboro
        vbase = 13;
        cap_on = 0;
        vreg = 123.98;
    elseif feeder_NUM == 4
        %Hollysprings
        vbase = 13;
        cap_on = 0;
        vreg = 123.98;
    elseif feeder_NUM == 5
        %E. Raleigh
        vbase = 7;
        cap_on = 1;
        vreg = 124.04;
    end
end
    


%{
if feeder_NUM == 7
    %EPRI CKT 7
    load reference_CKT7_Vpu.mat
end
%}