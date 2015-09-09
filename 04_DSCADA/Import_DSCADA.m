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


%FV = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'feltonsville');

%WilmSt = xlsread('DEP_CAPER_FEEDER_LOADS.xlsx', 'WilmingtonSt');

