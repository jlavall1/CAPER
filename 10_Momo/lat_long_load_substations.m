% Start March 3. Morey Agnew

% Read from excel fil with all lat long coordinates
% num has only numerical values, txt has only strings, 
% raw has both but considered strings
[num,~,raw] = xlsread('DEC_PV_LIST.xlsm','Carolinas_Substation_Long-lat');

% we only want distribution type substations
substation_types = raw(:,3);
% loop variable for setting only distribution substations.
j = 1;
% use to check for distrubution types
dis = 'DIST';

% length is how many rows there are
for i = 1:length(substation_types)
    % if strcmp returns true then set values for dis, lat, and lon and
    %   increment j
    if strncmp(substation_types(i,1),dis,4)
        dist(j).LAT = num(i-1,4);
        dist(j).LONG = num(i-1,5);
        j = j + 1;
    end
end
% number 344 is dist struct is bellhaven.
%this is used to run the plotGoogleMap function
%plot([dist.LONG],[dist.LAT],'xw','MarkerSize',5);
%plotGoogleMap

