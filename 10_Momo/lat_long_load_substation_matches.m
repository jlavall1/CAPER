% Start March 9th
% lat_long_load_substation matches

% read in lat_long_data.xls file
[num2,~,raw2] = xlsread('Lat_Long_data.xls','Lat_Long_data');
% incrementing variable
j = 1;
k = 1;
% find size to determine end for the loop
[r c] = size(raw2);

% loop to set only the distribution, approved, solar, and carolina types
for i = 1:r
    if strcmpi(raw2(i,39),'Distribution')
        if strcmpi(raw2(i,42), 'Solar')
            if strncmpi(raw2(i,50), 'Car',3)
                if strcmpi(raw2(i,52),'Connected')
                    % do this to eliminate the ones we currently 
                    %   dont have lat long coordinates for 
                    if ~(num2(i-1,25) == 0) && ~(num2(i-1,24) == 0)
                        conn(j).LAT = num2(i-1,25);
                        conn(j).LONG = num2(i-1,24);
                        if isnan(num2(i-1,55)) == 1
                            if isnan(num2(i-1,41)) == 0
                                conn(j).KW = num2(i-1,41);
                            else
                                conn(j).KW = 0;
                            end
                        else
                            conn(j).KW = num2(i-1,55);
                        end
                        j = j + 1;
                    end
                elseif strcmpi(raw2(i,52), 'Pending')
                    if ~(num2(i-1,25) == 0) && ~(num2(i-1,24) == 0)
                        pend(k).LAT = num2(i-1,25);
                        pend(k).LONG = num2(i-1,24);
                    if isnan(num2(i-1,55)) == 1
                        if isnan(num2(i-1,41)) == 0
                            pend(k).KW = num2(i-1,41);
                        else
                            pend(k).KW = 0;
                        end
                            
                    else
                        pend(k).KW = num2(i-1,55);
                    end
                        k = k + 1;
                    end  
                end
            end
        end
    end
end
% printing the sum of KW of each struct
fprintf('Connected MW: %3.3f\n',sum([conn.KW])/1000)
fprintf('Pending MW: %3.3f\n',sum([pend.KW])/1000)
fprintf('Total MW: %3.3f\n',sum([conn.KW])/1000+sum([pend.KW])/1000)
% this is to run the plotGoogleMap function.
plot([conn.LONG]',[conn.LAT]','.r','MarkerSize',10);
hold on
plot([pend.LONG]',[pend.LAT]','.b','MarkerSize',10);
plotGoogleMap;

        