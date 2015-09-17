%%*******************************************************%
%          Input Irradiance and Temperature Data         %
%********************************************************%

%This is a script that will take daily solar irradiance and temperature
%data from a MATLAB workspace cell and input create loadshapes and
%temperature plots for each day.


%Input Data
irradianceData=YearDailySolarPower_6kw;
temperatureData = Temp_NC_year;

%Initialize an array of DSSText Commands for inputting irradiance loadshapes
irradianceCOM = cell(length(irradianceData),1);
%Initialize an array of DSSText Commands for inputting temperature graphs
temperatureCOM = cell(length(temperatureData),1);

%Iterate through all of the days. Convert each day's data to P.U.
for i = 1:length(irradianceData)
   %Iterate through each data point
   for ii = 1:length(irradianceData(i, :))
       %Convert the data to Per-Unit
      irradianceData(i, ii) = irradianceData(i, ii)/6; 
   end
end

%Iterate through all of the days. Input a text command into irradianceCOM,
%with 96 data points :(

for i = 1:length(irradianceData)
    
    DSSCommand = sprintf('New Loadshape.MyIrradDay_%s npts=%s interval=%s mult=[%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s ]', num2str(i), num2str(length(irradianceData(i, :))), num2str(24/length(irradianceData(i, :))), num2str(irradianceData(i, 1:96)));
    irradianceCOM{i} = DSSCommand;
    DSSText.Command = DSSCommand;
end

%Iterate through all of the days. Input a text command into temperatureCOM,
%with 24 data points :)

for i = 1:length(temperatureData)
    
   DSSCommand = sprintf('New Tshape.MyTempDay_%s npts=%s interval=%s temp=[%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s ]', num2str(i), num2str(length(temperatureData(1,:))), num2str(24/length(temperatureData(1,:))), num2str(temperatureData(i, 1:24)) );
   temperatureCOM{i} = DSSCommand;
   DSSText.Command = DSSCommand;
    
end
