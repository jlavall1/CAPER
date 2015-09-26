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
%{
if feeder_NUM == 7
    %EPRI CKT 7
    load reference_CKT7_Vpu.mat
end
%}