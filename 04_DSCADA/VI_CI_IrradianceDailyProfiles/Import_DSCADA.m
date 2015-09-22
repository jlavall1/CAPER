%Data from DEP_CAPER_FEEDER_LOADS IN THE 04_DSCADA FOLDER

clear
clc
addpath('C:\Users\Brian\Documents\GitHub\CAPER\04_DSCADA')


% Import data from Excel file
[RidgeRd, ~, ~] = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'RidgeRd');

n = length(RidgeRd);

% Organize into structs
ROX.Voltage.A = RidgeRd(1:n, 6);
ROX.Voltage.B = RidgeRd(1:n, 8);
ROX.Voltage.C = RidgeRd(1:n, 10);
ROX.Amp.A = RidgeRd(1:n, 7);
ROX.Amp.B = RidgeRd(1:n, 9);
ROX.Amp.C = RidgeRd(1:n, 11);
ROX.kW.A = RidgeRd (1:n, 13);
ROX.kW.B = RidgeRd (1:n, 15);
ROX.kW.C = RidgeRd (1:n, 17);
ROX.kVAR.A = RidgeRd (1:n, 14);
ROX.kVAR.B = RidgeRd (1:n, 16);
ROX.kVAR.C = RidgeRd (1:n, 18);
%ROX.PI_time = txt(2:end,3);

months = [31,28,31,30,31,30,31,31,30,31,30,31,31,28,31];

ref = zeros(n,5);
Y = 2014;
M=1;
D=1;
H=0;
MIN=0;

% loop runs through entire set of data
for i = 1:1:n
    ref(i,1) = M;       % updates to reference matrix
    ref(i,2) = D;
    ref(i,3) = H;
    ref(i,4) = MIN;
    ref(i,5) = datenum(Y,M,D,H,MIN,0);
   MIN=MIN+15;          % increment minute for every 15
   
   if MIN ==60
       MIN = 0;
       H=H+1;           % increment hour every 60 mins
       if H==24
           H=0;
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
%ROX.PI_time
%%
%T.Date = datetime(ROX.PI_time,'ConvertFrom','excel');
ROX.PI_time = RidgeRd(1:end,3);
DateTime = sum(ROX.PI_time,2);
str = datestr(DateTime+datenum('30-Dec-1899'));
for i=1:1:length(ROX.PI_time);
    ROX.excel_time{i,1} = cellstr(str(i,1:20));
    ROX.NUM_time(i,1) = datenum(ROX.excel_time{i,1});
    ROX.ref_time{i,1} = datestr(ref(i,5));
    if (ROX.NUM_time(i,1) ~= ref(i,5))
        diff(i) = ROX.NUM_time(i,1) - ref(i,5);
    end
end

