% Start March 9th
% lat_long_load_substation matches

% read in lat_long_data.xls file
[num2,~,raw2] = xlsread('Lat_Long_data.xls','Lat_Long_data');
% incrementing variable
j = 1;
% find size to determine end for the loop
[r c] = size(raw2);

% loop to set only the distribution, approved, solar, and carolina types
for i = 1:r
    if strcmpi(raw2(i,39),'Distribution')
        if strcmpi(raw2(i,48),'Approved')
            if strcmpi(raw2(i,42), 'Solar')
                if strncmpi(raw2(i,50), 'Car',3)
                    % do this to eliminate the ones we currently 
                    %   dont have lat long coordinates for 
                    if ~(num2(i-1,25) == 0) && ~(num2(i-1,24) == 0)
                        matrix(j,:) = raw2(i,:);
                        lat_vector(j,1) = num2(i-1,25);
                        lon_vector(j,1) = num2(i-1,24);
                        j = j + 1;
                    end
                end
            end
        end
    end
end

% this is to run the plotGoogleMap function.
lat = lat_vector;
lon = lon_vector;
plot(lon,lat,'.r','MarkerSize',20);
plotGoogleMap;

        