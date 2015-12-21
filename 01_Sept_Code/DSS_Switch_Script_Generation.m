%Swtcontrol.dss script generation:
clear
clc
close all

feeder_NUM = 4;

if feeder_NUM == 5
    %Hollysprings-
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\HollySprings_Circuit_Opendss';
    %temp_dir = 'C:\Users\SJKIMBL\Documents\MATLAB\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss';
    addpath(temp_dir)
    %load Lines_Monitor.mat %Lines_Distance
    %For export .txt file --
    %filename = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\Monitors_GEN.txt';
    %filename = 'C:\Users\SJKIMBL\Documents\MATLAB\CAPER\03_OpenDSS_Circuits\Commonwealth_Circuit_Opendss\Monitors_GEN.txt';
    filename = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\HollySprings_Circuit_Opendss\Swt_Formed.txt';
    [RAW_DATA, ~, CELL] = xlsread('Swt_Load_Controls.xlsx', 'Sections_HOLLY');
    [RAW_DATA1, ~, LINES_OH] = xlsread('Swt_Load_Controls.xlsx','Lines_Overhead');
    [RAW_DATA2, ~, LINES_UG] = xlsread('Swt_Load_Controls.xlsx','Lines_UG');
    [RAW_DATA3, ~, LOADS] = xlsread('Swt_Load_Controls.xlsx','Loads');
    %holes in switches:
    CREATE=423; %101==990vio %201== worked || 451 did not
    C2 = 428;
    C3 = 1000;
elseif feeder_NUM == 4
    %Roxboro-
    temp_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\03_OpenDSS_Circuits\Roxboro_Circuit_Opendss';
    addpath(temp_dir)
    filename = strcat(temp_dir,'\Swt_Formed.txt');
    [RAW_DATA, ~, CELL] = xlsread('Swt_Load_Controls.xlsx', 'Sections_ROX');
    [RAW_DATA1, ~, LINES_OH] = xlsread('Swt_Load_Controls.xlsx','Lines_Overhead');
    [RAW_DATA2, ~, LINES_UG] = xlsread('Swt_Load_Controls.xlsx','Lines_UG');
    [RAW_DATA3, ~, LOADS] = xlsread('Swt_Load_Controls.xlsx','Loads');
    %Holes in switches:
    CREATE=200;
    C2 = 200;
    C3 = 250;
end

nn = 0;
nnn=0;
output_text = cell(length(CELL)/2,1);
found = 0;
ln = 1;
for i=1:2:length(CELL)
    if strcmp(CELL{i+1,5},'Action=Closed') == 1
        tar_bus{i,1}=char(CELL{i,3});
        %We will keep this section b/c it is closed.
        output_text{ln,1}=strcat(CELL{i,1},sprintf(' %s',CELL{i,2}));
        %1]
        %   Find out what phasing the line should be:
        for j=1:1:length(LINES_UG)
            sI_BUS1 = regexp(LINES_UG{j,3},'\.');
            sI_BUS2 = regexp(LINES_UG{j,4},'\.');
            n = length(LINES_UG{j,3});
            n2 = length(LINES_UG{j,4});
            if length(sI_BUS1)==1
                %single phase line:
                BUS1 = cellstr(LINES_UG{j,3}(6:sI_BUS1-1));
                ph = cellstr(LINES_UG{j,3}(sI_BUS1:n));
                BUS2 = cellstr(LINES_UG{j,4}(6:sI_BUS2-1));
            elseif length(sI_BUS1)==3
                %three phase line:
                BUS1 = cellstr(LINES_UG{j,3}(6:sI_BUS1(1,1)-1));
                ph = '.1.2.3';
                BUS2 = cellstr(LINES_UG{j,4}(6:sI_BUS2(1,1)-1));
            end
            
            %Now lets see if there is a match
            m=length(CELL{i,3});
            m2=length(CELL{i,4});
            if strcmp(CELL{i,3}(6:m),BUS1)==1 || strcmp(CELL{i,4}(6:m2),BUS1)==1 || strcmp(CELL{i,3}(6:m),BUS2)==1 || strcmp(CELL{i,4}(6:m2),BUS2)==1
                %A match.
                save_ph=ph;
                fprintf('(1)Section %d has %s phases\n',i,char(save_ph));
                found = 1;
                j=length(LINES_UG);
            end      
        end
        %2]
        %   Now check if any OH lines have selected bus:
        if found ~= 1
            for j=1:1:length(LINES_OH)
                sI_BUS1 = regexp(LINES_OH{j,5},'\.');
                sI_BUS2 = regexp(LINES_OH{j,6},'\.');
                n = length(LINES_OH{j,5});
                n2 = length(LINES_OH{j,6});
                if length(sI_BUS1)==1
                    %single phase line:
                    BUS1 = cellstr(LINES_OH{j,5}(6:sI_BUS1-1));
                    ph = cellstr(LINES_OH{j,5}(sI_BUS1:n));
                    BUS2 = cellstr(LINES_OH{j,6}(6:sI_BUS2-1));
                elseif length(sI_BUS1)==3
                    %three phase line:
                    BUS1 = cellstr(LINES_OH{j,5}(6:sI_BUS1(1,1)-1));
                    ph = '.1.2.3';
                    BUS2 = cellstr(LINES_OH{j,6}(6:sI_BUS2(1,1)-1));
                end
                if nnn == 0
                    OH_BUS{j,1}=BUS1;
                    OH_BUS{j,2}=BUS2;
                end
                %Now lets see if there is a match!
                m=length(CELL{i,3});
                m2=length(CELL{i,4});
                if strcmp(CELL{i,3}(6:m),BUS1)==1 || strcmp(CELL{i,4}(6:m2),BUS1)==1 || strcmp(CELL{i,3}(6:m),BUS2)==1 || strcmp(CELL{i,4}(6:m2),BUS2)==1
                    %A match.
                    save_ph=ph;
                    fprintf('(3)Section %d has %s phases\n',i,char(save_ph));
                    found = 1;
                    j=length(LINES_UG);
                end      
            end
            nnn = 1;
        end
        %3]
        %   Now check if any Load have the selected bus:
        count = 0;
        if found ~= 1
            for j=1:1:length(LOADS)
                sI_BUS1 = regexp(LOADS{j,5},'\.');
                n = length(LOADS{j,5});
                BUS1 = cellstr(LOADS{j,5}(1:sI_BUS1-1));
                if nn == 0
                    save_BUS1{j,1}=BUS1;
                end
                if strcmp(CELL{i,3},BUS1)==1
                    count = count + 1;
                    ph{1,count}=cellstr(LOADS{j,5}(sI_BUS1:n));
                end
            end
            nn = nn + 1;
            if count == 1
                save_ph=ph{1,1};
                fprintf('(2)Section %d has %s phases\n',i,char(save_ph));
                found =1;
            elseif count == 2
                save_ph=strcat(ph{1,1},ph{1,2});
                fprintf('(2)Section %d has %s phases\n',i,char(save_ph));
                found =1;
            elseif count == 3
                save_ph='.1.2.3';
                fprintf('(2)Section %d has %s phases\n',i,char(save_ph));
                found =1;
            end
        end
        %3]
        
        if found == 1
            found = 0;
        elseif found == 0
            fprintf('Section %s: %d has not been found\n',char(output_text{ln,1}),ln);
            save_ph='.';
        end
        
    %Continue str generation:
        %Bus1
        output_text{ln,1}=strcat(output_text{ln,1},sprintf(' %s',CELL{i,3}));
        if ln < CREATE || (C2 < ln)&&(ln < C3)
            output_text{ln,1}=strcat(output_text{ln,1},sprintf('%s',char(save_ph)));
        end
        %Bus2
        output_text{ln,1}=strcat(output_text{ln,1},sprintf(' %s',CELL{i,4}));
        if ln < CREATE || (C2 < ln)&&(ln < C3)
            output_text{ln,1}=strcat(output_text{ln,1},sprintf('%s',char(save_ph)));
        end
        %Linecode
        %output_text{ln,1}=strcat(output_text{ln,1},' LineCode=NONE Length=0.001 units=m');
        %
        if ln < CREATE || (C2 < ln)&&(ln < C3)
            if strcmp(save_ph,'.1')==1 || strcmp(save_ph,'.2')==1 || strcmp(save_ph,'.3')==1
                %output_text{ln,1}=strcat(output_text{ln,1},' LineCode=NONE1 Phases=1 Length=0.001 units=m');
                output_text{ln,1}=strcat(output_text{ln,1},' Phases=1');
            else
                %output_text{ln,1}=strcat(output_text{ln,1},' LineCode=NONE Phases=3 Length=0.001 units=m');
                output_text{ln,1}=strcat(output_text{ln,1},' Phases=3');
            end
        end
        %
        output_text{ln,1}=strcat(output_text{ln,1},' Switch=T'); %R1=0.001 & X1=0
        %end
        
        
        
        %output_text{i,1}=strcat(output_text{i,1},sprintf(' %s',CELL{i,3}));
        %increment to next line:
        ln = ln + 1;
    else
        %disp(i)
    end
end
filename=strcat(temp_dir,'\Swt_Formed.txt');
fileID=fopen(filename,'w');
for j=1:1:length(output_text)
    fprintf(fileID,'%s\r\n',output_text{j,1});
end
fclose(fileID);

fprintf('The new Swt.dss text file has been generated!\n');
    