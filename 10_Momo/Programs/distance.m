function [ d ] = distance( lon2, lon1, lat2, lat1, R )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
dlon = lon2 - lon1;
dlat = lat2 - lat1;
a = (sin(deg2rad(dlat/2)))^2 + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * (sin(deg2rad(dlon/2)))^2;
b = 2 * atan2(sqrt(a), sqrt(1-a));
d = R * b;

end

