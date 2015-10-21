%Max Function
clear
clc

gui_response = GUI_DSCADA_Locations;
base_path = gui_response{1,1};
feeder_NUM = gui_response{1,2}; %0 to 8 (1-9)
action = gui_response{1,3};
maindir = gui_response{1,4};
maindir=strcat(maindir,'\04_DSCADA');
addpath(maindir);
path = strcat(maindir,'\Feeder_Data');
addpath(path);


if feeder_NUM == 0
    load BELL.mat
    FEEDER = BELL;
    clearvars BELL
    kW_peak = [0,0,0];
elseif feeder_NUM == 1
    load COMN.mat
    FEEDER = COMN;
    clearvars COMN
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
% Finds max P & Q for year
MAX.YEAR.KW.A = max(FEEDER.kW.A);
MAX.YEAR.KW.B = max(FEEDER.kW.B);
MAX.YEAR.KW.C = max(FEEDER.kW.C);
MAX.YEAR.KVAR.A = max(FEEDER.kVAR.A);
MAX.YEAR.KVAR.B = max(FEEDER.kVAR.B);
MAX.YEAR.KVAR.C = max(FEEDER.kVAR.C);


months = [31,28,31,30,31,30,31,31,30,31,30,31];
Points = zeros(12,1);
Days = zeros(12,1);

tot = 0;

% Finds maxes for each month
for i=1:12
    
    Days(i) = months(i);
    Points(i) = Days(i)*60*24;
    MAX.MONTH.KW.A(i,1) = 0;
    MAX.MONTH.KW.B(i,1) = 0;
    MAX.MONTH.KW.C(i,1) = 0;
    MAX.MONTH.KVAR.A(i,1) = -1000;
    MAX.MONTH.KVAR.B(i,1) = -1000;
    MAX.MONTH.KVAR.C(i,1) = -1000;
    k = 1;
    TOT = 0;
    WINDOW.KW.A = 0;
    for j=tot+1:Points(i)+tot
        
        DOY = j/(24*60);
        HOUR = 24*(DOY-floor(DOY));
        MIN = 60*(HOUR-floor(HOUR));
        
        % Window of 10am - 4pm
        if HOUR >= 10 && HOUR < 16    
            
            % First column is every data point within window
            WINDOW.KW.A(k,1) = FEEDER.kW.A(j,1);
            WINDOW.KW.B(k,1) = FEEDER.kW.B(j,1);
            WINDOW.KW.C(k,1) = FEEDER.kW.C(j,1);
            WINDOW.KVAR.A(k,1) = FEEDER.kVAR.A(j,1);
            WINDOW.KVAR.B(k,1) = FEEDER.kVAR.B(j,1);
            WINDOW.KVAR.C(k,1) = FEEDER.kVAR.C(j,1);
            
         
            WINDOW.KW.A(i,3) = 100e3;
            WINDOW.KW.B(i,3) = 100e3;
            WINDOW.KW.C(i,3) = 100e3;
            WINDOW.KVAR.A(i,3) = 100e3;
            WINDOW.KVAR.B(i,3) = 100e3;
            WINDOW.KVAR.C(i,3) = 100e3;
            
            % Third column is min per month
            if FEEDER.kW.A(j,1) < WINDOW.KW.A(i,3)
                WINDOW.KW.A(i,3) = FEEDER.kW.A(j,1);
            end
            if FEEDER.kW.B(j,1) < WINDOW.KW.B(i,3)
                WINDOW.KW.B(i,3) = FEEDER.kW.B(j,1);
            end
            if FEEDER.kW.C(j,1) < WINDOW.KW.C(i,3)
                WINDOW.KW.C(i,3) = FEEDER.kW.C(j,1);
            end            
            if FEEDER.kVAR.A(j,1) < WINDOW.KVAR.A(i,3)
                WINDOW.KVAR.A(i,3) = FEEDER.kVAR.A(j,1);
            end            
            if FEEDER.kVAR.B(j,1) < WINDOW.KVAR.B(i,3)
                WINDOW.KVAR.B(i,3) = FEEDER.kVAR.B(j,1);
            end
            if FEEDER.kVAR.C(j,1) < WINDOW.KVAR.C(i,3)
                WINDOW.KVAR.C(i,3) = FEEDER.kVAR.C(j,1);
            end
            
            
            if FEEDER.kW.A(j,1) > MAX.MONTH.KW.A(i,1)
                MAX.MONTH.KW.A(i,1) = FEEDER.kW.A(j,1);
                
                % Fourth column is max per month
                WINDOW.KW.A(i,4) = FEEDER.kW.A(j,1);
                
                MAX.MONTH.KW.A(i,2) = j;                        
                MAX.MONTH.KW.A(i,3) = floor(DOY);
                MAX.MONTH.KW.A(i,4) = floor(HOUR);     
                MAX.MONTH.KW.A(i,5) = floor(MIN);
            end
            

            
            if FEEDER.kW.B(j,1) > MAX.MONTH.KW.B(i,1)
                MAX.MONTH.KW.B(i,1) = FEEDER.kW.B(j,1);
                WINDOW.KW.B(i,4) = FEEDER.kW.B(j,1);
                MAX.MONTH.KW.B(i,2) = j;           
                MAX.MONTH.KW.B(i,3) = floor(DOY);
                MAX.MONTH.KW.B(i,4) = floor(HOUR);     
                MAX.MONTH.KW.B(i,5) = floor(MIN);

            end
            if FEEDER.kW.C(j,1) > MAX.MONTH.KW.C(i,1)
                MAX.MONTH.KW.C(i,1) = FEEDER.kW.C(j,1);
                WINDOW.KW.C(i,4) = FEEDER.kW.C(j,1);
                MAX.MONTH.KW.C(i,2) = j;
                MAX.MONTH.KW.C(i,3) = floor(DOY);
                MAX.MONTH.KW.C(i,4) = floor(HOUR);     
                MAX.MONTH.KW.C(i,5) = floor(MIN);

            end

            % Concerns about vars - several months with 0
            if FEEDER.kVAR.A(j,1) > MAX.MONTH.KVAR.A(i,1)
                MAX.MONTH.KVAR.A(i,1) = FEEDER.kVAR.A(j,1);
                WINDOW.KVAR.A(i,4) = FEEDER.kVAR.A(j,1);
                MAX.MONTH.KVAR.A(i,2) = j;         
                MAX.MONTH.KVAR.A(i,3) = floor(DOY);
                MAX.MONTH.KVAR.A(i,4) = floor(HOUR);     
                MAX.MONTH.KVAR.A(i,5) = floor(MIN);

            end
            if FEEDER.kVAR.B(j,1) > MAX.MONTH.KVAR.B(i,1)
                MAX.MONTH.KVAR.B(i,1) = FEEDER.kVAR.B(j,1);
                WINDOW.KVAR.B(i,4) = FEEDER.kVAR.B(j,1);
                MAX.MONTH.KVAR.B(i,2) = j;
                MAX.MONTH.KVAR.B(i,3) = floor(DOY);
                MAX.MONTH.KVAR.B(i,4) = floor(HOUR);     
                MAX.MONTH.KVAR.B(i,5) = floor(MIN);

            end
            if FEEDER.kVAR.C(j,1) > MAX.MONTH.KVAR.C(i,1)
                MAX.MONTH.KVAR.C(i,1) = FEEDER.kVAR.C(j,1);
                WINDOW.KVAR.C(i,4) = FEEDER.kVAR.C(j,1);
                MAX.MONTH.KVAR.C(i,2) = j;           
                MAX.MONTH.KVAR.C(i,3) = floor(DOY);
                MAX.MONTH.KVAR.C(i,4) = floor(HOUR);     
                MAX.MONTH.KVAR.C(i,5) = floor(MIN);

            end
            k = k+1;
            
        end
                    % Fifth column is average per month
            %%%%%%%%
            %avg(i) = WINDOW.KW.A(TOT+1:k+TOT,1)
            
            WINDOW.KW.A(i,5) = mean(WINDOW.KW.A(TOT+1:k+TOT,1));
            TOT = TOT+k;
    end
    
    tot = tot + Points(i);
end

%% Hours 10 - 16 window dataset

% Second column is data sorted low to high
[~,index] = sortrows([WINDOW.KW.A]); 
WINDOW.KW.A(:,2) = WINDOW.KW.A(index); %Lines_Distance ==> sorted column 
clear index
[~,index] = sortrows([WINDOW.KW.B]); 
WINDOW.KW.B(:,2) = WINDOW.KW.B(index); %Lines_Distance ==> sorted column 
clear index
[~,index] = sortrows([WINDOW.KW.C]); 
WINDOW.KW.C(:,2) = WINDOW.KW.C(index); %Lines_Distance ==> sorted column 
clear index
[~,index] = sortrows([WINDOW.KVAR.A]); 
WINDOW.KVAR.A(:,2) = WINDOW.KVAR.A(index); %Lines_Distance ==> sorted column 
clear index
[~,index] = sortrows([WINDOW.KVAR.B]); 
WINDOW.KVAR.B(:,2) = WINDOW.KVAR.B(index); %Lines_Distance ==> sorted column 
clear index
[~,index] = sortrows([WINDOW.KVAR.C]); 
WINDOW.KVAR.C(:,2) = WINDOW.KVAR.C(index); %Lines_Distance ==> sorted column 
clear index

%{
h=1;
g=1;
for z=1:length(WINDOW.KW.A)
if WINDOW.KW.A(z,2) < 500
    low(h,1) = WINDOW.KW.A(z,2);
    h=h+1;
elseif WINDOW.KW.A(z,2) > 500 && WINDOW.KW.A(z,2) < 750
    mid(g,1) = WINDOW.KW.A(z,2);
    g=g+1;
end
end
%}
figure
hist(WINDOW.KW.A(:,2))

























