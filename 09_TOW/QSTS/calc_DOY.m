function [ DOY ] = calc_DOY(MNTH,DAY)
%Objective: To Calculate the DOY from MNTH & DAY
    DOY=0;
    MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
    for i=1:1:12
        if i < MNTH
            DOY=DOY+MTH_LN(i);
        elseif i == MNTH
            DOY=DOY+DAY;
        end
    end
end

