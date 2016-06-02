% Start March 9th
% lat_long_load_substation matches

% read in lat_long_data.xls file
[num2,~,raw2] = xlsread('Lat_Long_data_allcounties.xls','Lat_Long_data');
% incrementing variable
i = 1;
j = 1;
k = 1;
% find size to determine end for the loop
[r c] = size(raw2);

% loop to set only the distribution, approved, solar, and carolina types
for i = 1:r
    if strcmpi(raw2(i,39),'Distribution')
        if strcmpi(raw2(i,42), 'Solar')
            if ~(strcmpi(raw2(i,48),'Cancelled'))
           % if strncmpi(raw2(i,50), 'Car',3)
                %if ~(num2(i-1,25) == 0) && ~(num2(i-1,24) == 0)
                        conn(j).COUNTY = raw2(i,37);
                        conn(j).LAT = num2(i-1,25);
                        conn(j).LONG = num2(i-1,24);
                        % check to see if we have a non zero value in
                        % either Power rated column. if not set it to zero.
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
%                 if strcmpi(raw2(i,52),'Connected')
%                     % do this to eliminate the ones we currently 
%                     %   dont have lat long coordinates for 
%                     if ~(num2(i-1,25) == 0) && ~(num2(i-1,24) == 0)
%                         conn(j).CITY = raw2(i,16);
%                         conn(j).LAT = num2(i-1,25);
%                         conn(j).LONG = num2(i-1,24);
%                         % check to see if we have a non zero value in
%                         % either Power rated column. if not set it to zero.
%                         if isnan(num2(i-1,55)) == 1
%                             if isnan(num2(i-1,41)) == 0
%                                 conn(j).KW = num2(i-1,41);
%                             else
%                                 conn(j).KW = 0;
%                             end
%                         else
%                             conn(j).KW = num2(i-1,55);
%                         end
%                         j = j + 1;
%                     end
%                 elseif strcmpi(raw2(i,52), 'Pending')
%                     if ~(num2(i-1,25) == 0) && ~(num2(i-1,24) == 0)
%                         pend(k).CITY = raw2(i,16);
%                         pend(k).LAT = num2(i-1,25);
%                         pend(k).LONG = num2(i-1,24);
%                     if isnan(num2(i-1,55)) == 1
%                         if isnan(num2(i-1,41)) == 0
%                             pend(k).KW = num2(i-1,41);
%                         else
%                             pend(k).KW = 0;
%                         end
%                             
%                     else
%                         pend(k).KW = num2(i-1,55);
%                     end
%                         k = k + 1;
%                     end  
%                 end
            %end
            %end
        end
    end
end

% [r2 c2] = size(conn');
% [r3 c3] = size(pend');
% i = 1;
% j = 1;
% % radius of earth in Miles
% R = 3961;
% for i = 1:r2
%     temp = 1e6;
%     for j = 1:length(dist) 
%         d = distance(dist(j).LONG,conn(i).LONG,dist(j).LAT,conn(i).LAT,R);
%         if d < temp
%             temp = d;
%             substation_number = j;
%         end
%     end
%     conn(i).SUBSTATION = substation_number;
%     conn(i).DISTANCE = temp;
% end
% 
% i = 1;
% j = 1;
% for i = 1:r3
%     temp = 1e6;
%     for j = 1:length(dist) 
%         d = distance(dist(j).LONG,pend(i).LONG,dist(j).LAT,pend(i).LAT,R);
%         if d < temp
%             temp = d;
%             substation_number = j;
%         end
%     end
%     pend(i).SUBSTATION = substation_number;
%     pend(i).DISTANCE = temp;
% end
%   
% % find sizes of the two structs
% 
% i = 1;
% j = 1;
% k = 1;
% l = 1;
% % if under 100KW set to residential
% % if 100KW - 499KW set to commercial
% % if 500KW or above set to utility
% for i = 1:r2
%     if conn(i).KW < 100
%         res_conn(j) = conn(i);
%         j = j + 1;
%     elseif conn(i).KW >= 100 && conn(i).KW < 500
%         comm_conn(k) = conn(i);
%         k = k + 1;
%     elseif conn(i).KW >= 500
%         utility_conn(l) = conn(i);
%         l = l + 1;
%     end
% end
% 
% i = 1;
% j = 1;
% k = 1;
% l = 1;
% % if under 100KW set to residential
% % if 100KW - 499KW set to commercial
% % if 500KW or above set to utility
% for i = 1:r3
%     if pend(i).KW < 100
%         res_pend(j) = pend(i);
%         j = j + 1;
%     elseif pend(i).KW >= 100 && pend(i).KW < 500
%         comm_pend(k) = pend(i);
%         k = k + 1;
%     elseif pend(i).KW >= 500
%         utility_pend(l) = pend(i);
%         l = l + 1;
%     end
% end
%         
% % printing the sum of KW of each struct
% fprintf('Connected MW: %3.3f\n',sum([conn.KW])/1000)
% fprintf('Pending MW: %3.3f\n',sum([pend.KW])/1000)
% fprintf('Total MW: %3.3f\n',sum([conn.KW])/1000+sum([pend.KW])/1000)
% % this is to run the plotGoogleMap function.

