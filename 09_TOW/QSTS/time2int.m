function [ Datapos ] = time2int(DAY,HOUR,MIN)
%Day_hour will convert user command of the desired irradiance value from a
%specific day, hours, and minute & will return the position in the struct.

Datapos = (HOUR*60)+(60*24*(DAY-1))+(MIN+1);
end

