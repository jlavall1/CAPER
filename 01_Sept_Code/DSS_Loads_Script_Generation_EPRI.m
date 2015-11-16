%Read in a Loads.DSS and insert either LS_PhaseA LS_PhaseB LS_PhaseC
clear
clc
close all
fileloc_base='C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits';
%USER_INPUT --
feeder_NUM=8;

if feeder_NUM == 0
    fileloc=strcat(fileloc_base,'\Bellhaven_Circuit_Opendss');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('Loads_Text.xlsx', 'Loads_BASE');
elseif feeder_NUM == 1
    fileloc=strcat(fileloc_base,'\Commonwealth_Circuit_Opendss');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('Loads_Text.xlsx', 'Loads_NCSU');
elseif feeder_NUM == 2
    fileloc=strcat(fileloc_base,'\Flay_Circuit_Opendss');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('string_data.xlsx', 'Loads_Flay');
    load Alloc_base.mat %allocationFactor
elseif feeder_NUM == 8
    fileloc=strcat(fileloc_base,'\EPRI_ckt24');
    cd(fileloc);
    [RAW_DATA, A, CELL] = xlsread('string_data.xlsx', 'Loads_ckt24');
    [RAW_PULOAD, B, CELL2] = xlsread('string_data.xlsx','Loadshapes');
end
%
if feeder_NUM == 8
    %Only for EPRI format!
    SAME=1;
    output_text = cell(length(CELL),1);
    
    for i=1:1:length(CELL) %goes through each load (row)
        [startIndex,endIndex]=regexp(CELL{i,5},'.');
        n = length(CELL{1,5});

        %output_text{i,1}=strcat(CELL{i,1},sprintf(' %s',CELL{i,2}));
        output_text{i,1}=strcat(CELL{i,1},sprintf(' %s',CELL{i,2}));
        
        
        for j=3:1:13
            if j < 13
                %Do not change anything:
                output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',CELL{i,j}));
            else
                if SAME==1
                    if strcmp('yearly=LS_PhaseA',CELL{i,j})
                        output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',CELL{i,j}));
                        output_text{i,1}=strcat(output_text{i,1},' daily=LS_PhaseA');
                        output_text{i,1}=strcat(output_text{i,1},' duty=LS1_PhaseA');
                    elseif strcmp('yearly=LS_PhaseB',CELL{i,j})
                        output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',CELL{i,j}));
                        output_text{i,1}=strcat(output_text{i,1},' daily=LS_PhaseB');
                        output_text{i,1}=strcat(output_text{i,1},' duty=LS1_PhaseB');
                    elseif strcmp('yearly=LS_PhaseC',CELL{i,j})
                        output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',CELL{i,j}));
                        output_text{i,1}=strcat(output_text{i,1},' daily=LS_PhaseC');
                        output_text{i,1}=strcat(output_text{i,1},' duty=LS1_PhaseC');
                    elseif strcmp('yearly=LS_ThreePhase',CELL{i,j})
                        output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',CELL{i,j}));
                        output_text{i,1}=strcat(output_text{i,1},' daily=LS_ThreePhase');
                        output_text{i,1}=strcat(output_text{i,1},' duty=LS1_ThreePhase');
                        %disp(i);
                    elseif strcmp('yearly=Other_Bus_Load',CELL{i,j})
                        output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',CELL{i,j}));
                        output_text{i,1}=strcat(output_text{i,1},' daily=Other_Bus_Load');
                        output_text{i,1}=strcat(output_text{i,1},' duty=LS1_OtherLoad');
                        disp(i);
                    end
                elseif SAME==0
                    if strcmp('yearly=LS_PhaseA',CELL{i,j})
                        output_text{i,1}=strcat(output_text{i,1},sprintf(' %s','duty=LS_PhaseA'));
                    elseif strcmp('yearly=LS_PhaseB',CELL{i,j})
                        output_text{i,1}=strcat(output_text{i,1},sprintf(' %s','duty=LS_PhaseB'));
                    elseif strcmp('yearly=LS_PhaseC',CELL{i,j})
                        output_text{i,1}=strcat(output_text{i,1},sprintf(' %s','duty=LS_PhaseC'));
                    elseif strcmp('yearly=LS_ThreePhase',CELL{i,j})
                        output_text{i,1}=strcat(output_text{i,1},sprintf(' %s','duty=LS_ThreePhase'));
                        %disp(i);
                    elseif strcmp('yearly=Other_Bus_Load',CELL{i,j})
                        output_text{i,1}=strcat(output_text{i,1},sprintf(' %s','duty=Other_Bus_Load'));
                        disp(i);
                    end
                end
            end
        end
    end
elseif feeder_NUM == 2
    output_text = cell(length(CELL),1);
    output_alloc = cell(length(CELL),1);
    for i=1:1:length(CELL) %goes through each load (row)
        [startIndex,endIndex]=regexp(CELL{i,5},'.');
        n = length(CELL{1,5});

        %output_text{i,1}=strcat(CELL{i,1},sprintf(' %s',CELL{i,2}));
        output_text{i,1}=strcat(CELL{i,1},sprintf(' %s',CELL{i,2}));
        %Create allocationFactors_Base.Txt:
        output_alloc{i,1}=strcat(CELL{i,2},sprintf('.AllocationFactor=%0.4f',allocationFactor(i,1)));
        
        for j=3:1:11
            if j == 4 || j == 10
                %special case because numbers.
                output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',num2str(CELL{i,j})));
            elseif j == 7
                %Reset voltage:
                output_text{i,1}=strcat(output_text{i,1},'7.1996'); 
            elseif j < 11
                %Do not change anything:
                output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',CELL{i,j}));
            else %j=11
                %[startIndex,endIndex]=regexp(CELL{i,5},'.');
                %CELL{i,5}((endIndex-1):endIndex)
                Phase=CELL{i,5}(end-1:end);
                
                if strcmp(Phase,'.1') == 1
                    output_text{i,1}=strcat(output_text{i,1},' status=variable');
                    output_text{i,1}=strcat(output_text{i,1},' Vminpu=0.7');             
                    output_text{i,1}=strcat(output_text{i,1},' yearly=LS_PhaseA');
                    output_text{i,1}=strcat(output_text{i,1},' daily=LS_PhaseA');
                    output_text{i,1}=strcat(output_text{i,1},' duty=LS_PhaseA');
                elseif strcmp(Phase,'.2') == 1
                    output_text{i,1}=strcat(output_text{i,1},' status=variable');
                    output_text{i,1}=strcat(output_text{i,1},' Vminpu=0.7');   
                    output_text{i,1}=strcat(output_text{i,1},' yearly=LS_PhaseB');
                    output_text{i,1}=strcat(output_text{i,1},' daily=LS_PhaseB');
                    output_text{i,1}=strcat(output_text{i,1},' duty=LS_PhaseB');
                elseif strcmp(Phase,'.3') == 1
                    output_text{i,1}=strcat(output_text{i,1},' status=variable');
                    output_text{i,1}=strcat(output_text{i,1},' Vminpu=0.7');   
                    output_text{i,1}=strcat(output_text{i,1},' yearly=LS_PhaseC');
                    output_text{i,1}=strcat(output_text{i,1},' daily=LS_PhaseC');
                    output_text{i,1}=strcat(output_text{i,1},' duty=LS_PhaseC');
                end
                
            end
        end
    end
end
    
%
%Export strings to .txt file:
filename=strcat(fileloc,'\Loads_text.txt');
fileID=fopen(filename,'w');
for j=1:1:length(output_text)
    fprintf(fileID,'%s\r\n',output_text{j,1});
end
fclose(fileID);
if feeder_NUM == 2
    filename2=strcat(fileloc,'\Loads_Allocation.txt');
    fileID=fopen(filename2,'w');
    for j=1:1:length(output_alloc)
        fprintf(fileID,'%s\r\n',output_alloc{j,1});
    end
    fclose(fileID);
end

fprintf('The new loads.dss text file has been generated!\n');

%%
%Export to .txt files:
s=strcat(fileloc_base,'\EPRI_ckt24\');
%Decide what type of loadshape do you want:
TYP=4;

if TYP==1
    %kW_A kW_B kW_C kW_ThreePhase kW_OTHER
    for i=1:1:5
        KW_1MIN(:,i)=interp(RAW_PULOAD(1:8760,i),60);
    end
    s_kwA = strcat(s,'LS1_PhaseA.txt');
    s_kwB = strcat(s,'LS1_PhaseB.txt');
    s_kwC = strcat(s,'LS1_PhaseC.txt');
    s_kw3 = strcat(s,'LS1_ThreePhase.txt');
    s_kwO = strcat(s,'LS1_Other.txt');
    csvwrite(s_kwA,KW_1MIN(:,1))
    csvwrite(s_kwB,KW_1MIN(:,2))
    csvwrite(s_kwC,KW_1MIN(:,3))
    csvwrite(s_kw3,KW_1MIN(:,4))
    csvwrite(s_kwO,KW_1MIN(:,5))
elseif TYP==2
    %kW_A kW_B kW_C kW_ThreePhase kW_OTHER
    for i=1:1:5
        KW_1MIN(:,i)=interp(RAW_PULOAD(1:24,i),60); %Now we will go up to 1min intervals
    end
    s_kwA = strcat(s,'LS2_PhaseA.txt');
    s_kwB = strcat(s,'LS2_PhaseB.txt');
    s_kwC = strcat(s,'LS2_PhaseC.txt');
    s_kw3 = strcat(s,'LS2_ThreePhase.txt');
    s_kwO = strcat(s,'LS2_Other.txt');
    
    csvwrite(s_kwA,KW_1MIN(:,1))
    csvwrite(s_kwB,KW_1MIN(:,2))
    csvwrite(s_kwC,KW_1MIN(:,3))
    csvwrite(s_kw3,KW_1MIN(:,4))
    csvwrite(s_kwO,KW_1MIN(:,5))
elseif TYP==3
    %30sec, 24hr dataset:
        %kW_A kW_B kW_C kW_ThreePhase kW_OTHER
    for i=1:1:5
        KW_1MIN(:,i)=interp(RAW_PULOAD(1:24,i),60*2); %Now we will go down to 30sec load intervals
    end
    s_kwA = strcat(s,'LS3_PhaseA.txt');
    s_kwB = strcat(s,'LS3_PhaseB.txt');
    s_kwC = strcat(s,'LS3_PhaseC.txt');
    s_kw3 = strcat(s,'LS3_ThreePhase.txt');
    s_kwO = strcat(s,'LS3_Other.txt');
    
    csvwrite(s_kwA,KW_1MIN(:,1))
    csvwrite(s_kwB,KW_1MIN(:,2))
    csvwrite(s_kwC,KW_1MIN(:,3))
    csvwrite(s_kw3,KW_1MIN(:,4))
    csvwrite(s_kwO,KW_1MIN(:,5))
elseif TYP==4
     %5sec, 24hr dataset:
        %kW_A kW_B kW_C kW_ThreePhase kW_OTHER
    for i=1:1:5
        KW_1MIN(:,i)=interp(RAW_PULOAD(1:24,i),60*12); %Now we will go down to 30sec load intervals
    end
    s_kwA = strcat(s,'LS4_PhaseA.txt');
    s_kwB = strcat(s,'LS4_PhaseB.txt');
    s_kwC = strcat(s,'LS4_PhaseC.txt');
    s_kw3 = strcat(s,'LS4_ThreePhase.txt');
    s_kwO = strcat(s,'LS4_Other.txt');
    
    csvwrite(s_kwA,KW_1MIN(:,1))
    csvwrite(s_kwB,KW_1MIN(:,2))
    csvwrite(s_kwC,KW_1MIN(:,3))
    csvwrite(s_kw3,KW_1MIN(:,4))
    csvwrite(s_kwO,KW_1MIN(:,5))
end
    

