% Start March 3. Morey Agnew

% Read from excel fil with all lat long coordinates
% num has only numerical values, txt has only strings, 
% raw has both but considered strings
[num,txt,raw] = xlsread('DEC_PV_LIST.xlsm','Carolinas_Substation_Long-lat');

% we only want distribution type substations
substation_types = raw(:,3);
% loop variable for setting only distribution substations.
j = 1;
% use to check for distrubution types
dis = 'DISTRIBUTION';

% 2037 because thats how many rows there are
for i = 1:2037
    % if strcmp returns true then set values for dis, lat, and lon and
    % increment j
    if strcmp(dis,substation_types(i,1))
        dis_vector(j,:) = raw(i,:);
        lat_dis(j,1) = num(i-1,4);
        lon_dis(j,1) = num(i-1,5);
        j = j + 1;
    end
end

%Type in command window to bring up all distribution type points
%lat = lat_dis;
%lon = lon_dis;
%plot(lon,lat,'.r','MarkerSize',20)
%plotGoogleMap

