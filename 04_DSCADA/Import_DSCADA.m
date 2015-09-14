%Data from DEP_CAPER_FEEDER_LOADS IN THE 04_DSCADA FOLDER

clear
clc

% Import data from Excel file
[RidgeRd, titles, raw] = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'RidgeRd');

n = length(RidgeRd);

% Organize into structs
load.Voltage.A = RidgeRd(1:n, 6);
load.Voltage.B = RidgeRd(1:n, 8);
load.Voltage.C = RidgeRd(1:n, 10);

load.Amp.A = RidgeRd(1:n, 7);
load.Amp.B = RidgeRd(1:n, 9);
load.Amp.C = RidgeRd(1:n, 11);

load.kW.A = RidgeRd (1:n, 13);
load.kW.B = RidgeRd (1:n, 15);
load.kW.C = RidgeRd (1:n, 17);

load.kVAR.A = RidgeRd (1:n, 14);
load.kVAR.B = RidgeRd (1:n, 16);
load.kVAR.C = RidgeRd (1:n, 18);


months = [31,28,31,30,31,30,31,31,30,31,30,31,31,28,31];

ref = zeros(n,5);

M=1;
D=1;
H=1;
MIN=0;

% loop runs through entire set of data
for i = 1:1:n
    ref(i,1) = M;       % updates to reference matrix
    ref(i,2) = D;
    ref(i,3) = H;
    ref(i,4) = MIN;
    
   MIN=MIN+15;          % increment minute for every 15
   
   if MIN ==60
       MIN = 0;
       H=H+1;           % increment hour every 60 mins
       
       if H==24
           H=1;
           D=D+1;       % increment day every 24 hours
           
           if D>months(M);
               D=1;
               M=M+1;   % increment month 
           end
       end
   end
end

%FV = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'feltonsville');
%WilmSt = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'WilmingtonSt');

