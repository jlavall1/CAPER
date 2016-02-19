function [ KVAR_ACTUAL,error,op_count] = Find_Cap_Ops_1(KVAR_ACTUAL,KVAR_ACTUAL_1,sim_num,s_step,Caps,KW_ACTUAL,KW_ACTUAL_1,cap_pos)
%Goal: Find Capacitor operations based on profile
sim_num = str2num(sim_num);
%sim_num=1440
%s_step=60s

%1] Calculate delta_t=10intervals Q slope.
k = 1; %Used to loook to the next day for last 10 points
error = 0;
op_count = 0;
for i=1:1:sim_num
    for ph=1:1:3
        if i <= sim_num-10
            KVAR_diff = KVAR_ACTUAL.data(i+10,ph)-KVAR_ACTUAL.data(i,ph); %Look 10 minutes in the future
            KW_diff = KW_ACTUAL(i+10,ph)-KW_ACTUAL(i,ph);
        else
            KVAR_diff = KVAR_ACTUAL_1.data(k,ph)-KVAR_ACTUAL.data(i,ph); %Look 10 minutes in the future
            KW_diff = KW_ACTUAL_1(k,ph)-KW_ACTUAL(i,ph);
        end
        KVAR_ACTUAL.data(i,ph+6)=KVAR_diff;
        KVAR_ACTUAL.dP(i,ph)=KW_diff;
    end
    if i > sim_num-10
        k = k + 1;
    end
end
instance_neg = 0;
count_neg = 0;
instance_pos = 0;
count_pos = 0;
%2] Interp dQ's.
KVAR_diff = 0;
KVAR_mag = 0;
KW_diff = 0;
for i=1:1:sim_num
    for ph=1:1:3
        %Calculate 3-Phase Terms:
        KVAR_diff = KVAR_diff + KVAR_ACTUAL.data(i,ph+6);
        KVAR_mag= KVAR_mag+ abs(KVAR_ACTUAL.data(i,ph+6));
        KW_diff = KW_diff + KVAR_ACTUAL.dP(i,ph);
        
        %Caclulate single-phase PF:
        Q=KVAR_ACTUAL.data(i,ph);
        P=KW_ACTUAL(i,ph);
        S=sqrt(Q^2+P^2);
        PF = abs(P)/S;
        KVAR_ACTUAL.PF(i,ph)=PF;
    end
    KVAR_ACTUAL.PF(i,4)=(KVAR_ACTUAL.PF(i,1)+KVAR_ACTUAL.PF(i,2)+KVAR_ACTUAL.PF(i,3))/3;
    
    KVAR_ACTUAL.data(i,10) = KVAR_diff; %3ph dQ
    KVAR_ACTUAL.data(i,11) = KVAR_mag;  % |dQ_3ph|
    KVAR_ACTUAL.dP(i,4) = abs(KW_diff); %3ph dP
    
    if KVAR_ACTUAL.dP(i,4) < 250 %&& KVAR_ACTUAL.PF(i,4) < 0.98 %To filter out any events:
        
        if KVAR_diff < 0 && KVAR_mag > .45*Caps.Swtch*3
            count_neg = count_neg + 1;
            if count_neg > 1
                if instance_neg == 0
                    instance_neg = i;
                    cap_pos = cap_pos +1;
                    op_count = op_count + 1;
                    if cap_pos > 1
                        cap_pos = 1;
                        error = 1;
                    end
                elseif instance_neg+20 < i
                    instance_neg = i;
                    cap_pos = cap_pos + 1;
                    op_count = op_count + 1;
                    if cap_pos > 1
                        cap_pos = 1;
                        error = 1;
                    end
                end
                count_neg=0;
            end
            
        elseif KVAR_diff > 0 && KVAR_mag > .45*Caps.Swtch*3
            count_pos = count_pos + 1;
            if count_pos > 1
                if instance_pos == 0
                    instance_pos = i;
                    cap_pos = cap_pos - 1;
                    op_count = op_count + 1;
                    if cap_pos < 0
                        cap_pos = 0;
                        error = 1;
                    end

                elseif instance_pos+20 < i
                    instance_pos = i;
                    cap_pos = cap_pos - 1;
                    op_count = op_count + 1;
                    if cap_pos < 0
                        cap_pos = 0;
                        error = 1;
                    end
                end
                count_pos=0;
            end
        end
    end
    %KVAR_ACTUAL.sw_cap(i,ph)=cap_pos;
    KVAR_ACTUAL.data(i,4)=cap_pos;
    KVAR_ACTUAL.PF(i,5)=cap_pos;
    KVAR_diff = 0;
    KW_diff = 0;
    KVAR_mag = 0;
end
%Shift cap_ops over 5 into the future:
i = 2;
min_shift = 9*sim_num/1440;
while i <= sim_num
    if KVAR_ACTUAL.data(i,4) ~= KVAR_ACTUAL.data(i-1,4)
        %Op occured...
        save_pos = KVAR_ACTUAL.data(i-1,4);
        KVAR_ACTUAL.data(i,4)=save_pos;
        if i < sim_num-min_shift+2
            for j=0:1:min_shift
                KVAR_ACTUAL.data(i+j,4)=save_pos;
            end
            i = i + min_shift + 1;
        end
    end
    i = i + 1;
end

%{
%2] Understand how many peaks there were.
disp(neg_peak_count)
if neg_peak_count/3 < 16 && neg_peak_count > 0
    ROW_1 = 2;
    fprintf('(1) Closed Op\n');
elseif neg_peak_count/3 < 32 && neg_peak_count > 0
    ROW_1 = 4;
    fprintf('(2) Closed Ops\n');
else
    ROW_1 = 1;
end

disp(pos_peak_count)
if pos_peak_count/3 < 16 && neg_peak_count > 0
    ROW_2 = 2;
    fprintf('(1) Opened Op\n');
elseif pos_peak_count/3 < 32 && neg_peak_count > 0
    ROW_2 = 4;
    fprintf('(2) Opened Op\n');
else
    ROW_2 = 1;
end

%3] Interp neg_peak_time
if ROW_1 > 1
    fprintf('----\n');
    disp(neg_peak_time)
    for i=2:1:length(neg_peak_time)
        diff_time = neg_peak_time(i,1)-neg_peak_time(i-1,1);
        if diff_time > 20
            disp(neg_peak_time)
            fprintf('found here: %d\n',i);
            %change in instance in operation!
        end
    end
end

%  Find times of peak of cap operation of closing.
KVAR_neg_peak= ones(ROW_1,3)*400;
for j=1:1:ROW_1-1
    for i=1:1:sim_num
        for ph=1:1:3
            if KVAR_ACTUAL.data(i,ph+6) < KVAR_neg_peak(j,ph)
                KVAR_neg_peak(j,ph) = KVAR_ACTUAL.data(i,ph+6);
                KVAR_neg_peak(j+1,ph) = i;
            end
        end
    end
end
%  Find times of peak of cap operation of opening.
KVAR_pos_peak= ones(ROW_2,3)*-400;
j = 1;
while j < ROW_2
    for i=1:1:sim_num
        for ph=1:1:3
            if KVAR_ACTUAL.data(i,ph+6) > KVAR_pos_peak(j,ph)
                %if j > 2
                    %if KVAR_ACTUAL(i,ph+6) ~= KVAR_pos_peak(j-2,ph)
                        KVAR_pos_peak(j,ph) = KVAR_ACTUAL.data(i,ph+6);
                        KVAR_pos_peak(j+1,ph) = i;
                    %end
                %end
            end
        end
    end
    j = j + 2;
end

%4] generate 1=CLOSED & 0=OPEN (add +5 to times recorded b/c looking +10 in
%   future. 1=when dQ is neg. & 0=when dQ is pos.
%   cap_pos = 1; %Assume init closed.

if ROW_1 == 2 && ROW_2 == 2
    %Only two operations occured.
    time_closed(1) = round(mean(KVAR_neg_peak(ROW_1,:)))+5;
    time_closed(2) = 0;
    time_opened(1) = round(mean(KVAR_pos_peak(ROW_2,:)))+5;
    time_opened(2) = 0;
elseif ROW_1 == 4 && ROW_2 == 2
    %(2) Closed ops & (1) Open op
    time_closed(1) = round(mean(KVAR_neg_peak(ROW_1-2,:)))+5;
    time_closed(2) = round(mean(KVAR_neg_peak(ROW_1,:)))+5;
    time_opened(1) = round(mean(KVAR_pos_peak(ROW_2,:)))+5;
    time_opened(2) = 0;
elseif ROW_1 == 2 && ROW_2 == 4
    %(1) Closed op & (2) Opened Ops
    time_closed(1) = round(mean(KVAR_neg_peak(ROW_1,:)))+5;
    time_closed(2) = 0;
    time_opened(1) = round(mean(KVAR_pos_peak(ROW_2-2,:)))+5;
    time_opened(2) = round(mean(KVAR_pos_peak(ROW_2,:)))+5;
    fprintf('time_closed:\n');
    disp(time_closed)
    disp(KVAR_neg_peak)
    fprintf('time_opened:\n');
    disp(time_opened)
    disp(KVAR_pos_peak)
elseif ROW_1 == 4 && ROW_2 == 4
    %(2) Closed ops & (2) Opened Ops
    time_closed(1) = round(mean(KVAR_neg_peak(ROW_1-2,:)))+5;
    time_closed(2) = round(mean(KVAR_neg_peak(ROW_1,:)))+5;
    time_opened(1) = round(mean(KVAR_pos_peak(ROW_2-2,:)))+5;
    time_opened(2) = round(mean(KVAR_pos_peak(ROW_2,:)))+5;
else
    time_closed(1) = 0;
    time_closed(2) = 0;
    time_opened(1) = 0;
    time_opened(2) = 0;
end
    
EVENT_1 = 1;
EVENT_2 = 1;
for i=1:1:sim_num
    if ROW_1 > 1
        if i == time_closed(EVENT_1)
            cap_pos = cap_pos + 1;
            EVENT_1 = EVENT_1 + 1;
        end
    end
    if ROW_2 > 1
        if i == time_opened(EVENT_2)
            cap_pos = cap_pos -1;
            EVENT_2 = EVENT_2 + 1;
        end
    end
    KVAR_ACTUAL.data(i,4)=cap_pos;
    KVAR_ACTUAL.sw_cap(i,1)=cap_pos;
end
%}

%5] generate 3ph reactive power:
for i=1:1:sim_num
    KVAR_ACTUAL.data(i,5) = KVAR_ACTUAL.data(i,1)+KVAR_ACTUAL.data(i,2)+KVAR_ACTUAL.data(i,3);
    P_3ph = KW_ACTUAL(i,1)+KW_ACTUAL(i,2)+KW_ACTUAL(i,3);
    %Find PF:
    S = sqrt((P_3ph^2)+(KVAR_ACTUAL.data(i,5)^2));
    PF = abs(P_3ph)/S;
    KVAR_ACTUAL.data(i,6) = PF;
end
KVAR_ACTUAL.datanames={'phA','phB','phC','Cap_Status','3ph_Q','3ph,PF','dQA','dQB','dQC','dQ3ph','|dQ3ph|'};

%6] generate reactive power for DSS loads:
KVAR_ON=[2.173495346357307e+02,1.976303522549747e+02,2.802254460650596e+02];
KVAR_OFF=[5.773752746613869e+02,5.602529605242753e+02,6.308542533514893e+02];
DIFF=KVAR_OFF-KVAR_ON;
%ph_perc=350./DIFF;
ph_perc=[.925,.9698,.9];

%Find actual reactive power being consumed by loads:
KVAR_ACTUAL.DSS(:,1)=KVAR_ACTUAL.data(:,1)+(Caps.Fixed(1)+KVAR_ACTUAL.data(:,4)*Caps.Swtch(1))*ph_perc(1,1);
KVAR_ACTUAL.DSS(:,2)=KVAR_ACTUAL.data(:,2)+(Caps.Fixed(1)+KVAR_ACTUAL.data(:,4)*Caps.Swtch(1))*ph_perc(1,2);
KVAR_ACTUAL.DSS(:,3)=KVAR_ACTUAL.data(:,3)+(Caps.Fixed(1)+KVAR_ACTUAL.data(:,4)*Caps.Swtch(1))*ph_perc(1,3);
%Smooth any crazy jumps:
for i=1:1:sim_num-1
    KVAR_ACTUAL.DSS(i,4)=KVAR_ACTUAL.DSS(i+1,1)-KVAR_ACTUAL.DSS(i,1);
end

for i=1:1:sim_num
    if KVAR_ACTUAL.DSS(i,4) > 80 || KVAR_ACTUAL.DSS(i,4) < -80
        for ph=1:1:3
            y2=KVAR_ACTUAL.DSS(i+4,ph);
            y1=KVAR_ACTUAL.DSS(i-5,ph); %9
            m=(y2-y1)/10;
            for ee=0:1:8
                KVAR_ACTUAL.DSS(i+ee-4,ph) = KVAR_ACTUAL.DSS(i+ee-5,ph)+m;
            end
        end
        i = i + 8;
    end
end

end

