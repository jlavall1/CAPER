%Feeder Characteristics subplots:
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\Feeder_Data');
%Characteristics:
feeder_Name={'Bell','Common','Flay','Rox','Holly','E_Raleigh'};
feeder_Volt=[12.47,12.47,12.47,22.87,22.87,12.47];
feeder_PeakMW=zeros(1,6);%[9.529,7.9254,6.3586,0,0,0];
feeder_ValleyMW=zeros(1,6);
feeder_LTC_VREG=[1,1,1,6,1,1];
feeder_CAP_Fixed=zeros(1,6);
feeder_CAP_Switch=zeros(1,6);
feeder_length_mi=zeros(1,6);
feeder_length_ohm=zeros(1,6);
feeder_volt_peak_head=zeros(1,6);
feeder_volt_min_head=zeros(1,6);
feeder_conductor=zeros(1,6);
Load_Center_Resistance=zeros(1,6);




%subplot(4,4,1)
%1 - Bellhaven
n = 1;
load Annual_ls_BELL.mat
BELL_LS=MAX;
feeder_PeakMW(1,n)=(BELL_LS.YEAR.KW.A+BELL_LS.YEAR.KW.B+BELL_LS.YEAR.KW.C)/1000;
feeder_CAP_Fixed(1,n)=900;
feeder_CAP_Switch(1,n)=900+900;
feeder_length_mi(1,n)=5.652*0.621371;
feeder_length_ohm(1,n)=2.206;
feeder_volt_peak_head(1,n)=0.101;

feeder_conductor(1,n)=20.515; %mi
Load_Center_Resistance(1,n)=0.934; %ohm

%2 - Commonwealth
n = n + 1;
load Annual_ls_CMNWLTH.mat
CMN_LS=MAX;
feeder_PeakMW(1,n)=(CMN_LS.YEAR.KW.A+CMN_LS.YEAR.KW.B+CMN_LS.YEAR.KW.C)/1000;
feeder_CAP_Fixed(1,n)=300+600;
feeder_CAP_Switch(1,n)=0;
feeder_length_mi(1,n)=5.505*0.621371;
feeder_length_ohm(1,n)=2.3899;
feeder_volt_peak_head(1,n)=0.042;
feeder_conductor(1,n)=16.055; %mi
Load_Center_Resistance(1,n)=0.658; %ohm


%3 - Flay
n = n + 1;
load Annual_ls_FLAY.mat
FLAY_LS=MAX;
feeder_PeakMW(1,n)=(FLAY_LS.YEAR.KW.A+FLAY_LS.YEAR.KW.B+FLAY_LS.YEAR.KW.C)/1000;
feeder_CAP_Fixed(1,n)=600;
feeder_CAP_Switch(1,n)=450;
feeder_length_mi(1,n)=13.4747*0.621371;
feeder_length_ohm(1,n)=11.1166;
feeder_volt_peak_head(1,n)=0.045;
feeder_conductor(1,n)=55.876; %mi
Load_Center_Resistance(1,n)=1.008; %ohm

%4 - Roxboro
n = n + 1;
feeder_PeakMW(1,n)=9.763; %MW
feeder_CAP_Fixed(1,n)=1200*3;
feeder_CAP_Switch(1,n)=0;
feeder_length_mi(1,n)=18.9893*0.621371;
feeder_length_ohm(1,n)=17.33;
feeder_volt_peak_head(1,n)=.037;
feeder_conductor(1,n)=87.416; %mi
Load_Center_Resistance(1,n)=0.691; %ohm

%5 - Hollysprings
n = n + 1;
feeder_PeakMW(1,n)=10.35; %MW
feeder_CAP_Fixed(1,n)=1200*2;
feeder_CAP_Switch(1,n)=0;
feeder_length_mi(1,n)=21.1358*0.621371;
feeder_length_ohm(1,n)=0;
feeder_volt_peak_head(1,n)=0.026;
Load_Center_Resistance(1,n)=1.008; %ohm


feeder_conductor(1,n)=60.358; %mi

%6 - East Raleigh
n = n + 1;
feeder_CAP_Fixed(1,n)=600;
feeder_CAP_Switch(1,n)=0;
feeder_length_mi(1,n)=0;

%%
figure(1);
%-----------------------------
subplot(3,4,1);
barh(feeder_Volt);
axis([0 40 0 7]); 
xlabel('Voltage Class (kV)');
ylabel('Feeder','FontSize',16);
%-----------------------------
subplot(3,4,2);
barh(feeder_PeakMW);
axis([0 15 0 7]);
xlabel('Peak Load (MW)');
%-----------------------------
subplot(3,4,3);
barh(feeder_ValleyMW);
axis([0 5 0 7]);
xlabel('Valley Day Load (MW)');
%-----------------------------
subplot(3,4,4);
barh(feeder_CAP_Fixed);
axis([0 4000 0 7]);
xlabel('Fixed Caps (kVAR)');
%-----------------------------
subplot(3,4,5);
barh(feeder_LTC_VREG);
axis([0 8 0 7]);
xlabel('LTC & Line Regulators');
ylabel('Feeder','FontSize',16);
%-----------------------------
subplot(3,4,6);
barh(feeder_volt_peak_head);
axis([0 0.12 0 7]);
xlabel('Peak Load Headroom (Vpu)');
%-----------------------------
subplot(3,4,7);
barh(feeder_volt_min_head);
axis([0 0.06 0 7]);
xlabel('Valley Load Headroom (Vpu)');
%-----------------------------
subplot(3,4,8);
barh(feeder_CAP_Switch);
axis([0 4000 0 7]);
xlabel('Swtch Caps (kVAR)');
%-----------------------------
subplot(3,4,9);
barh(feeder_length_mi);
axis([0 15 0 7]);
xlabel('End Distance (mi)');
ylabel('Feeder','FontSize',16);
%-----------------------------
subplot(3,4,10);
barh(feeder_length_ohm);
axis([0 20 0 7]);
xlabel('End Resistance (ohm)');
%-----------------------------
subplot(3,4,11);
barh(feeder_conductor);
axis([0 100 0 7]);
xlabel('Feeder Conductor (mi)');
%-----------------------------
subplot(3,4,12);
barh(Load_Center_Resistance);
axis([0 3 0 7]);
xlabel('Load Center Resistance (ohm)');










