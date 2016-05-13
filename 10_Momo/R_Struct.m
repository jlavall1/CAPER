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

   