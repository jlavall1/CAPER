% amount of KW in each city/town
index = conn(1).COUNTY;
i = 1;
j = 1;
TOTKW(j).KW = 0;
for i = 1:length(conn)
    if strcmpi(index,conn(i).COUNTY)
        TOTKW(j).COUNTY = index;
        TOTKW(j).KW = TOTKW(j).KW + conn(i).KW;
    else
        index = conn(i).COUNTY;
        j = j + 1;
        TOTKW(j).KW = conn(i).KW;
        TOTKW(j).COUNTY = index;   
    end
end

% number of Substations in each city
index = dist(1).COUNTY;
i = 1;
j = 1;
k = 0;
for i = 1:length(dist)
    if strcmpi(index,dist(i).COUNTY)
       TOTSUB(j).COUNTY = index;
       k = k + 1;
       TOTSUB(j).NUM = k;
       
    else
        index = dist(i).COUNTY;
        j = j + 1;
        TOTSUB(j).COUNTY = index;
        k = 1;
        TOTSUB(j).NUM = k;
    end
end

