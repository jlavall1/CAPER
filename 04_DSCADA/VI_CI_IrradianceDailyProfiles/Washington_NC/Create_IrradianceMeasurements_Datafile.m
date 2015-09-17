%"The variability index: A new and novel metric for quantifying irradiance
%and PV output variability.
clear
clc
%[EIB_9_5,txt7,~] = xlsread('PV_Power.xlsx','9_5_EIB');
[GHI_K,Date,~] = xlsread('WashingtonAP_5MW.xlsx','Washington');
%GHI_K = [100;-10000;-10000;150;105;104;103;102;-1000;100];

%Preprocess of Date & Time:
i = 1;
DOY = 1;
hr = 0;
min = 0;
day = 1;
month = 1;
MTH = zeros(2,12);
TIME_INT = zeros(length(GHI_K),4);
MTH(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
%%
%Creation of TIME_INT

while i < length(GHI_K)
    if hr < 24
        if min < 60
            %GHI_K(i,4) = hr;
            %GHI_K(i,5) = min;
        %Save seperate Array of times:
            TIME_INT(i,1) = month;
            TIME_INT(i,2) = day;
            TIME_INT(i,3) = hr;
            TIME_INT(i,4) = min;
            TIME_INT(i,5) = DOY;
            
            min = min + 1;
        end
    end
    
    %Check if next interval is at the top of the hour.
    if min == 60
        min = 0;
        hr = hr + 1;
        if hr == 24
            hr = 0;
            day = day + 1;
            DOY = DOY + 1;
        end
        %Check to see if it is a new month:
        if day > MTH(1,month)
            month = month + 1;
            day = 1;
        end
    end
    i = i + 1;
end
%%
%Preprocess of Filtering out Data Errors:

HOLD = zeros(2,10);
i = 1;
j = 1;
k = 1;
POS = 1;
while POS < 4 %Only filters columns 1 -> 3.
    while i < length(GHI_K)+1
        %Check to see if a digit exists:      
        if isnan(GHI_K(i,POS)) == 1       %Check for NaN.
            if i ~= 1
                HOLD(1,j+1) = j;
                if j ==1
                    HOLD(2,j) = GHI_K(i-1,POS); %grab last real value.
                    BEGIN = HOLD(2,j);
                end
                j = j + 1;
            end
        %Change Irrad. to actual reading.
        elseif GHI_K(i,POS) < -20
            HOLD(1,j+1) = j;
            if j ==1
                HOLD(2,j) = GHI_K(i-1,POS); %grab last real value.
                BEGIN = HOLD(2,j);
            end
            j = j + 1;
        elseif j ~= 1 && GHI_K(i,1) >= -20
            %ERROR String ENDED!
            %This is the case where a string of errors was discovered.
            HOLD(2,j+1) = GHI_K(i,POS); %grabs most recent real value.
            END = HOLD(2,j+1);
            NUM = HOLD(1,j);

            DIFF = (END-BEGIN)/(NUM+1);
            %Estimate & Replace Irradiance measurements:
            while k < NUM+1
                HOLD(2,k+1) = HOLD(2,k)+DIFF;
                GHI_K(i-j+k,POS) = HOLD(2,k+1); %replace exsisting:
                k = k + 1;
            end
            %Reset Variables:
            j = 1;
            k = 1;
            HOLD = zeros(2,10);
        end
        %Replace Irradiance to 0 if Altitude Angle not >0:
        if POS == 1 %If in the 1st column of GHI_K
            if GHI_K(i,4) < 0
                GHI_K(i,POS) = 0;
                if i ~= 525601
                    if GHI_K(i+1,4) < 0
                        GHI_K(i+1,POS) = 0;
                    end
                end
            end
        end
        %Rec
        i = i + 1;
    end
    i = 1;
    POS = POS + 1;
end
%{
%MTH = zeros(2,12);
%MTH(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];

%Save to new Struct caled "M_SHELBY(MNTH).DAY(:,1:6)"
i = 1;
j = 1;
while j < 13
    L = MTH(1,j)*24*60;
    M_SHELBY(j).DAY(:,1:5) = GHI_K(i:i+L,1:5);
    M_SHELBY(j).DAY(:,6) = TIME_INT(i:i+L,5);
    
    
    %Reset/Change Variables:
    MTH(2,j) = L;
    Date(i+L+1,1) %For display if did correctly.
    i = i + L
    
    j = j + 1; %will go to 12
end
%}

