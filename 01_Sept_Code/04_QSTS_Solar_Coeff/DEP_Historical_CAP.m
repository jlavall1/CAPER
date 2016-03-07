%DEP Historical CAP
%Variables already loaded:
%   FEEDER.PI_time FEEDER.kW FEEDER.kVAR
[num1,~,cell1]=xlsread('DEP_Cap_Bank_Operations.xlsx','E1183');
[num2,~,cell2]=xlsread('DEP_Cap_Bank_Operations.xlsx','E2M13');
[num3,~,cell3]=xlsread('DEP_Cap_Bank_Operations.xlsx','EXF80');

%Construct associated swt_cap pseudo datasets
%
%Datapos = (HOUR*60)+(60*24*(DAY-1))+(MIN+1);
DAY_FIN=364;
CAP_OPS(1).oper(1,1)=0;
CAP_OPS(1).oper(1,2)=0;
CAP_OPS(1).oper(1,3)=1;
i = 1;
j = 2;

for cap_n=1:1:3
    for DOY=1:1:DAY_FIN
        %15minute intervals
        for m=1:1:4*24 
            Datapos = m+(DOY-1)*4*24;
            if cap_n == 1
                time_stp=cell1{j,3};
                cap_pos=cell1{j,4};
                n = length(cell1);
                kVAR_diff=cell1{j,9};
            elseif cap_n == 2
                time_stp=cell2{j,3};
                cap_pos=cell2{j,4};
                n = length(cell2);
            elseif cap_n == 3
                time_stp=cell3{j,3};
                cap_pos=cell3{j,4};
                n = length(cell3);
            end
                
            time_diff = abs(time_stp - FEEDER.PI_time(Datapos,1));
            if  time_diff < 0.001
                %fprintf('Cap Op here: %d\n',Datapos);
                if strcmp(cap_pos,'CLOSE') == 1
                    CAP_OPS(DOY).oper(i,cap_n) = 1;
                    kVAR(DOY).oper(i,cap_n) = -1*kVAR_diff;
                    j = j + 1;
                else
                    CAP_OPS(DOY).oper(i,cap_n) = 0;
                    kVAR(DOY).oper(i,cap_n) = kVAR_diff;
                    j = j + 1;
                end
            else
                %Keep the same
                if i ~= 1
                    CAP_OPS(DOY).oper(i,cap_n) = CAP_OPS(DOY).oper(i-1,cap_n);
                    kVAR(DOY).oper(i,cap_n) = 0; %no change
                end
            end
            i = i + 1;
            if j > n
                j = n;
            end
        end
        i = 1;
        %grab state from day:
        CAP_OPS(DOY+1).oper(1,cap_n) = CAP_OPS(DOY).oper(4*24,cap_n);
    end
    %fprintf('\n Next S.C.\n');
    j = 2;
    i = 1;
end
%%
i = 1;
j = 1;
%1] Make into 15min load data again:
for DOY=1:1:364
    for m=1:1:24*60
        if mod(m-1,15) == 0
            Datapos = m+(DOY-1)*60*24;
            KVAR_ACTUAL.DSS(j,1)=FEEDER.kVAR.A(Datapos,1);
            KVAR_ACTUAL.DSS(j,2)=FEEDER.kVAR.B(Datapos,1);
            KVAR_ACTUAL.DSS(j,3)=FEEDER.kVAR.C(Datapos,1);
            j = j + 1;
        end
    end
end
%2] Adjust reactive profile accordingly:
i = 1;
for cap_n=1:1:3
    for DOY=1:1:364
        for m=1:1:24*4
            cap_save = CAP_OPS(DOY).oper(m,cap_n);
            if cap_save == 1
                %Select DSCADA measurements:
                Datapos = m+(DOY-1)*4*24;
                %Alter DSCADA to DSS Loadshape:
                for ph=1:1:3
                    KVAR_ACTUAL.DSS(Datapos,ph)=KVAR_ACTUAL.DSS(Datapos,ph)+CAP_OPS(DOY).oper(m,cap_n)*1200/3;
                        
                end
            end
            i = i + 1;
        end
    end
end
%3] Smooth spikes:
for cap_n=1:1:3
    for DOY=1:1:364
        for m=1:1:24*4
            Datapos = m+(DOY-1)*4*24;
            if Datapos ~= 1
                for ph=1:1:3
                    if abs(KVAR_ACTUAL.DSS(Datapos-1,ph)-KVAR_ACTUAL.DSS(Datapos,ph)) > 200
                        KVAR_ACTUAL.DSS(Datapos,ph)=(KVAR_ACTUAL.DSS(Datapos-1,ph)+KVAR_ACTUAL.DSS(Datapos+1,ph))/2;
                    end
                end
            end
        end
    end
end
%%
            
        

%{
for cap_n=1:1:3
    for DOY=1:1:364
        for m=1:1:24*60
            %Change cap op state from 15 min to 1 min:
            if mod(m-1,15) == 0
                    cap_save = CAP_OPS(DOY).oper(j,cap_n);
                    j = j + 1;
            end
            CAP_OPS_1M(DOY).oper(i,cap_n)=cap_save;
            Datapos = m+(DOY-1)*60*24;
            KVAR_ACTUAL.data(Datapos,cap_n)=cap_save;
            if cap_save == 1
                %Select DSCADA measurements:
                
                KVAR_ACTUAL.DSS(Datapos,1)=FEEDER.kVAR.A(Datapos,1);
                KVAR_ACTUAL.DSS(Datapos,2)=FEEDER.kVAR.B(Datapos,1);
                KVAR_ACTUAL.DSS(Datapos,3)=FEEDER.kVAR.C(Datapos,1);
                %Alter DSCADA to DSS Loadshape:
                for ph=1:1:3
                    KVAR_ACTUAL.DSS(Datapos,ph)=KVAR_ACTUAL.DSS(Datapos,ph)+CAP_OPS_1M(DOY).oper(i,cap_n)*1200/3;
                end
            end
            i = i + 1;
        end
        j = 1;
        i = 1;
        fprintf('CAP %d, DOY = %d\n',cap_n,DOY);
    end
end
%}            
            

%%
figure(1)
%X=[0:15:24*60-15]/1440;
i=1;
for DOY=1:1:DAY_FIN
    %X(1,i:i+95) = [(i*15-15):15:(i)*1425];
    Y(i:i+95,1) = CAP_OPS(DOY).oper(:,1);
    Y(i:i+95,2) = CAP_OPS(DOY).oper(:,2)+1;
    Y(i:i+95,3) = CAP_OPS(DOY).oper(:,3)+2;
    i = i + 96;
    %plot(X,CAP_OPS(DOY).oper(:,1),'b-');
    %hold on
end
X=[0:(15):DAY_FIN*24*60-15];
plot(X/1440,Y)
axis([0 DAY_FIN -0.5 3.5]);
%-------------------------
figure(3)
plot(KVAR_ACTUAL.DSS)
%{
figure(2)
i=1;
for DOY=1:1:DAY_FIN
    %X(1,i:i+95) = [(i*15-15):15:(i)*1425];
    Y(i:i+1439,1) = CAP_OPS_1M(DOY).oper(:,1);
    Y(i:i+1439,2) = CAP_OPS_1M(DOY).oper(:,2)+1;
    Y(i:i+1439,3) = CAP_OPS_1M(DOY).oper(:,3)+2;
    i = i + 1440;
    %plot(X,CAP_OPS(DOY).oper(:,1),'b-');
    %hold on
end
X=[0:(1):DAY_FIN*24*60-1];
plot(X/1440,Y)
axis([0 DAY_FIN -0.5 3.5]);
%}
