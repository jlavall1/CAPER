% amount of KW in each city/town
index = conn(1).CITY;
i = 1;
j = 1;
TOTKW(j).KW = 0;
for i = 1:length(conn)
    if strcmpi(index,conn(i).CITY)
        TOTKW(j).CITY = index;
        TOTKW(j).KW = TOTKW(j).KW + conn(i).KW;
    else
        index = conn(i).CITY;
        j = j + 1;
        TOTKW(j).KW = conn(i).KW;
        TOTKW(j).CITY = index;   
    end
end

% number of Substations in each city
index = dist(1).CITY;
i = 1;
j = 1;
k = 0;
for i = 1:length(dist)
    if strcmpi(index,dist(i).CITY)
       TOTSUB(j).CITY = index;
       k = k + 1;
       TOTSUB(j).NUM = k;
       
    else
        index = dist(i).CITY;
        j = j + 1;
        TOTSUB(j).CITY = index;
        k = 1;
        TOTSUB(j).NUM = k;
    end
end

