%3D Plot Help:
clear
clc
close all

[sort_Results,~,cell] = xlsread('Lat_Long_data.xls','Lat_Long_data');
j = 1;
for i=2:1:length(cell)
    if strcmpi(cell{i,42},'Solar') == 1 && cell{i,24} ~= 0
        if isnan(cell{i,55}) == 0 && strcmpi(cell{i,39},'Transmission') ~= 1
            DER_PV_SITE(j).X = cell{i,24};
            DER_PV_SITE(j).Y = cell{i,25};
            DER_PV_SITE(j).PPA = cell{i,55};
            j = j + 1;
        end
    end
end

load DER_PV_SITE.mat
%%

XX=[DER_PV_SITE.X];
YY=[DER_PV_SITE.Y];
ZZ=[DER_PV_SITE.PPA];
%Set up basis:
for j=1:1:length(XX)
    X_3(:,j)=ones(length(XX),1)*XX(j);
    Y_3(j,:)=ones(1,length(YY))*YY(j);
end
Z_3=zeros(length(XX),length(YY));

hit = 0;
j = 1;
i = 1;
for k=1:1:length(ZZ)
    while j <= length(XX) && hit == 0
        while i <= length(YY) && hit == 0
            if DER_PV_SITE(k).X == X_3(j,i)
                if DER_PV_SITE(k).Y == Y_3(j,i)
                    Z_3(j,i) = Z_3(j,i)+DER_PV_SITE(k).PPA;
                    hit = 1;
                end
            end
            i = i + 1;
        end
        i = 1;
        j = j + 1;
    end
    j = 1;
    disp(k)
    hit = 0;
end

for k=1:1:length(ZZ)
    Z_3(k,k)=Z_3(k,k)+DER_PV_SITE(k).PPA;
end
            
        

%%
%Y=[DER_PV_SITE(:).Y];
%Z=[DER_PV_SITE(:).PPA,DER_PV_SITE(:).PPA;DER_PV_SITE(:).PPA,DER_PV_SITE(:).PPA];
figure(1);
contour3(X_3,Y_3,Z_3,100,'k');
%hold on;
%surf(X_3,Y_3,Z_3,'Edgecolor','none');
%}
%%
[X,Y,Z] = peaks(32);
figure
contour3(X,Y,Z,15,'k');
hold on;
surf(X,Y,Z, 'Edgecolor', 'none');
