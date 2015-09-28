%Create_SolarFarmMeasurments_Datafile

%OBJECT: To load in (4) NUG Solar Farm 2014 kW & kVAR 1min measurements:

%[EIB_9_5,txt7,~] = xlsread('PV_Power.xlsx','9_5_EIB');
%[GHI_K,Date,~] = xlsread('Shelby_1MW.xlsx',);
%GHI_K = [100;-10000;-10000;150;105;104;103;102;-1000;100];



%[PV_OUT,Date,~] = xlsread('Ararat_3_5MW.xlsx','Ararat'); %Power kW ; R.Power kVAR ; RECL Status
%Preprocess of Date & Time:
i = 1;
DOY = 1;
hr = 0;
min = 0;
day = 1;
month = 1;
MTH = zeros(2,12);
TIME_INT = zeros(length(PV_OUT),4);
MTH(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
%%
%Creation of TIME_INT

while i < length(PV_OUT)
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

HOLD = zeros(2,10); %A cache of troubled datapoints
i = 1;
j = 1;
k = 1;
POS = 1;
E_hold = 0;
E_count = 0;
Errors = zeros(3,2); 
while POS <= 2 %Only filters columns 1 & 2.
    while i < length(PV_OUT)+1
        %Check to see if a digit exists:      
        if isnan(PV_OUT(i,POS)) == 1       %Check for NaN.
            if i ~= 1
                HOLD(1,j+1) = j;
                if j ==1
                    HOLD(2,j) = PV_OUT(i-1,POS); %grab last real value.
                    BEGIN = HOLD(2,j);
                end
                j = j + 1;
            end
        %{
        %Change Irrad. to actual reading.
        elseif PV_OUT(i,POS) < -20
            HOLD(1,j+1) = j;
            if j ==1
                HOLD(2,j) = PV_OUT(i-1,POS); %grab last real value.
                BEGIN = HOLD(2,j);
            end
            j = j + 1;
        %}
            
        %A string of errors was discovred.
        elseif j ~= 1 && PV_OUT(i,1) > 5.1e3
            %ERROR String ENDED!
            HOLD(2,j+1) = PV_OUT(i,POS); %grabs most recent real value.
            END = HOLD(2,j+1);
            NUM = HOLD(1,j);

            DIFF = (END-BEGIN)/(NUM+1);
            %Estimate & Replace Irradiance measurements:
            while k < NUM+1
                HOLD(2,k+1) = HOLD(2,k)+DIFF;
                PV_OUT(i-j+k,POS) = HOLD(2,k+1); %replace exsisting:
                k = k + 1;
            end
            %Reset Variables:
            j = 1;
            k = 1;
            HOLD = zeros(2,10);
        end
        
        %Replace -kW with 0kW:
        if POS == 1 && PV_OUT(i,POS) < 0.5
            PV_OUT(i,POS)=0;
        end
        
            
        %Find any large missing holes in data:
        %{
        if i > 1
            E_hold = GHI_K(i-1,POS);
            if GHI_K(i,POS) == E_hold
                E_count = E_count + 1;
                if E_count > 20 && GHI_K(i,4) > 0
                    
            elseif GHI_K(i,
        %}
        
        %Replace Irradiance to 0 if Altitude Angle not >0:
        %{
        if POS == 1 %If in the 1st column of GHI_K
            if PV_OUT(i,4) < 0
                PV_OUT(i,POS) = 0;
                if i ~= 525601
                    if PV_OUT(i+1,4) < 0
                        PV_OUT(i+1,POS) = 0;
                    end
                end
            end
        end
        %}
        
        %Rec
        i = i + 1;
    end
    i = 1;
    POS = POS + 1;
end
%%
%MTH = zeros(2,12);
%MTH(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];

%Save to new Struct caled "M_SHELBY(MNTH).DAY(:,1:6)"
i = 1;
j = 1;
while j < 13
    L = MTH(1,j)*24*60;
    M_PVSITE(j).DAY(:,1:5) = PV_OUT(i:i+L,1:5);
    M_PVSITE(j).DAY(:,6) = TIME_INT(i:i+L,5);
    M_PVSITE(j).kW(:,1) = PV_OUT(i:i+L,1); %PV kw generation output
    M_PVSITE(j).Ctemp(:,1) = PV_OUT(i:i+L,3);
    
    
    %Reset/Change Variables:
    MTH(2,j) = L;
    Date(i+L+1,1) %For display if did correctly.
    i = i + L;
    
    j = j + 1; %will go to 12
end
%%
%Output Results:
if sim_type == 2
    if PV_Site == 1
        %Mocksville Solar Farm
        M_MOCKS = M_PVSITE;
        filename = strcat(PV_Site_path4,'\M_MOCKS.mat');
        save(filename,'M_MOCKS');
    elseif PV_Site == 2
        %Ararat Rock Solar Farm
        M_AROCK = M_PVSITE;
        filename = strcat(PV_Site_path5,'\M_AROCK.mat');
        save(filename,'M_AROCK');
    end
end

