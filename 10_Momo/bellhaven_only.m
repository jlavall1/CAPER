



i = 1;
j = 1;
% bellhaven substation only
for i = 1:length(dist)
    d = distance(bell_long,dist(i).LONG,bell_lat,dist(i).LAT,R);
    if d <= 20
        substation_matches(j).SUBSTATION = i;
        j = j + 1;
    end
end

i = 1;
j = 1;
TAR_SUB = zeros(3,5); %col=1(conn) col2=(pending)
for i = 1:length(substation_matches)
    SUB = substation_matches(i).SUBSTATION;
    for j=1:1:length(conn)
        if conn(j).SUBSTATION == SUB
            KW = conn(j).KW;
            if KW < 100
                %resid
                TAR_SUB(1,1)=TAR_SUB(1,1)+KW;
            elseif KW >= 100 && KW < 500
                %comm
                TAR_SUB(2,1)=TAR_SUB(2,1)+KW;
            else
                TAR_SUB(3,1)=TAR_SUB(3,1)+KW;
                %utility
            end
        end
    end
    for j=1:1:length(pend)
        if pend(j).SUBSTATION == SUB
            KW = pend(j).KW;
            if KW < 100
                %resid
                TAR_SUB(1,2)=TAR_SUB(1,2)+KW;
            elseif KW >= 100 && KW < 500
                %comm
                TAR_SUB(2,2)=TAR_SUB(2,2)+KW;
            else
                TAR_SUB(3,2)=TAR_SUB(3,2)+KW;
                %utility
            end
        end
    end
end
TAR_SUB(1,3) = sum([res_conn.KW]);
TAR_SUB(2,3) = sum([comm_conn.KW]);
TAR_SUB(3,3) = sum([utility_conn.KW]);

TAR_SUB(1,4) = sum([res_pend.KW]);
TAR_SUB(2,4) = sum([comm_pend.KW]);
TAR_SUB(3,4) = sum([utility_pend.KW]);

TAR_SUB(1,5) = 100*(TAR_SUB(1,1)*0.2 + TAR_SUB(1,2)*0.8)/((TAR_SUB(1,3)*0.2 + TAR_SUB(1,4)*0.8));
TAR_SUB(2,5) = 100*(TAR_SUB(2,1)*0.2 + TAR_SUB(2,2)*0.8)/((TAR_SUB(2,3)*0.2 + TAR_SUB(2,4)*0.8));
TAR_SUB(3,5) = 100*(TAR_SUB(3,1)*0.2 + TAR_SUB(3,2)*0.8)/((TAR_SUB(3,3)*0.2 + TAR_SUB(3,4)*0.8));


%{
plot([conn_bell.LONG],[conn_bell.LAT],'.r','MarkerSize',20);
hold on
plot([pend_bell.LONG],[pend_bell.LAT],'.c','MarkerSize',20);
plotGoogleMap
%}

%{
i = 1;
j = 1;
% bellhaven substation only
for i = 1:r2
    d = distance(bell_long,conn(i).LONG,bell_lat,conn(i).LAT,R);
    if d <= 20
        conn_bell(j).LAT = conn(i).LAT;
        conn_bell(j).LONG = conn(i).LONG;
        conn_bell(j).DISTANCE = d;
        conn_bell(j).KW = conn(i).KW;
        j = j + 1;
    end
end

i = 1;
j = 1;
% bellhaven substation only
for i = 1:r3
    d = distance(bell_long,pend(i).LONG,bell_lat,pend(i).LAT,R);
    if d <= 20
        pend_bell(j).LAT = pend(i).LAT;
        pend_bell(j).LONG = pend(i).LONG;
        pend_bell(j).DISTANCE = d;
        pend_bell(j).KW = pend(i).KW;
        j = j + 1;
    end
end
%}