addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\04_Mocksville_NC');
load M_MOCKS.mat

%One day run on 6/1:
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
i =1;
DoD_max=0.33; %0.33
ToS1_min=(1-DoD_max)+0.05;
for MNTH=1:1:12
    for DAY=1:1:MTH_LN(MNTH)
        BncI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
        CSI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),3);
        save(i,1)=max(BncI);
        save(i,2)=mean(BncI);
        save(i,3)=save(i,1)/save(i,2);
        save(i,4)=max(CSI);
        save(i,5)=mean(CSI);
        save(i,6)=save(i,4)/save(i,5);
        
        
        save(i,7)=save(i,1)-save(i,4);
        save(i,8)=save(i,3)/save(i,6);
        save(i,9)=1/save(i,8);
        i = i + 1;
    end
end

PAR_BC=save(:,9);

for i=1:1:length(PAR_BC)
    TOS1(i)=ToS1_min+(PAR_BC(i)-min(PAR_BC))*min(PAR_BC);
end

%{
DAY = 1;
MNTH = 6;
DOY=calc_DOY(MNTH,DAY);
DOY=1:1:365

    BncI=M_MOCKS(MNTH).GHI(time2int(DAY,0,0):time2int(DAY,23,59),1); %1minute interval:
    GHI=M_MOCKS(MNTH).kW(time2int(DAY,0,0):time2int(DAY,23,59),1)/5000; %PU
%}


