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
feeder_volt_min_head(1,n)=0.058;

feeder_conductor(1,n)=20.515; %mi
Load_Center_Resistance(1,n)=0.934; %ohm

load Annual_daytime_load_BELL.mat   %WINDOW.DAYTIME.KW.A
KW_3PH=WINDOW.DAYTIME.KW.A(:,1)+WINDOW.DAYTIME.KW.B(:,1)+WINDOW.DAYTIME.KW.C(:,1);
KW_3PH_MAX=0;
KW_3PH_MIN=100e6;
for i=1:1:length(KW_3PH)
    if KW_3PH(i,1) < KW_3PH_MIN
        KW_3PH_MIN = KW_3PH(i,1);
    end
    if KW_3PH(i,1) > KW_3PH_MAX
        KW_3PH_MAX = KW_3PH(i,1);
    end
end
feeder_ValleyMW(1,n)=KW_3PH_MIN/1e3;




%%
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
feeder_volt_min_head(1,n)=0.026;
feeder_conductor(1,n)=16.055; %mi
Load_Center_Resistance(1,n)=0.658; %ohm

load Annual_daytime_load_CMNWLTH.mat   %WINDOW.DAYTIME.KW.A
KW_3PH=WINDOW.DAYTIME.KW.A(:,1)+WINDOW.DAYTIME.KW.B(:,1)+WINDOW.DAYTIME.KW.C(:,1);
KW_3PH_MAX=0;
KW_3PH_MIN=100e6;
for i=1:1:length(KW_3PH)
    if KW_3PH(i,1) < KW_3PH_MIN
        KW_3PH_MIN = KW_3PH(i,1);
    end
    if KW_3PH(i,1) > KW_3PH_MAX
        KW_3PH_MAX = KW_3PH(i,1);
    end
end
feeder_ValleyMW(1,n)=KW_3PH_MIN/1e3;
%%
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
feeder_volt_min_head(1,n)=0.032;
feeder_conductor(1,n)=55.876; %mi
Load_Center_Resistance(1,n)=1.008; %ohm

load Annual_daytime_load_FLAY.mat   %WINDOW.DAYTIME.KW.A
KW_3PH=WINDOW.DAYTIME.KW.A(:,1)+WINDOW.DAYTIME.KW.B(:,1)+WINDOW.DAYTIME.KW.C(:,1);
KW_3PH_MAX=0;
KW_3PH_MIN=100e6;
for i=1:1:length(KW_3PH)
    if KW_3PH(i,1) < KW_3PH_MIN
        KW_3PH_MIN = KW_3PH(i,1);
    end
    if KW_3PH(i,1) > KW_3PH_MAX
        KW_3PH_MAX = KW_3PH(i,1);
    end
end
%feeder_ValleyMW(1,n)=KW_3PH_MIN/1e3;
feeder_ValleyMW(1,n)=1200/1e3;
%%
%4 - Roxboro
n = n + 1;
load Annual_ls_ROX.mat
%feeder_PeakMW(1,n)=9.763; %MW
feeder_PeakMW(1,n)=(MAX.YEAR.KW.A+MAX.YEAR.KW.B+MAX.YEAR.KW.C)/1000;
feeder_CAP_Fixed(1,n)=1200*3;
feeder_CAP_Switch(1,n)=0;
feeder_length_mi(1,n)=18.9893*0.621371;
feeder_length_ohm(1,n)=17.372;
feeder_volt_peak_head(1,n)=.037;
feeder_volt_min_head(1,n)=0.024;
feeder_conductor(1,n)=87.416; %mi
Load_Center_Resistance(1,n)=0.691; %ohm

load Annual_daytime_load_ROX.mat   %WINDOW.DAYTIME.KW.A
KW_3PH=WINDOW.DAYTIME.KW.A(:,1)+WINDOW.DAYTIME.KW.B(:,1)+WINDOW.DAYTIME.KW.C(:,1);
KW_3PH_MAX=0;
KW_3PH_MIN=100e6;
for i=1:1:length(KW_3PH)
    if KW_3PH(i,1) < KW_3PH_MIN
        KW_3PH_MIN = KW_3PH(i,1);
    end
    if KW_3PH(i,1) > KW_3PH_MAX
        KW_3PH_MAX = KW_3PH(i,1);
    end
end
feeder_ValleyMW(1,n)=KW_3PH_MIN/1e3;
%%
%5 - Hollysprings
n = n + 1;
load Annual_ls_HOLLY.mat
%feeder_PeakMW(1,n)=10.35; %MW
feeder_PeakMW(1,n)=(MAX.YEAR.KW.A+MAX.YEAR.KW.B+MAX.YEAR.KW.C)/1000;
feeder_CAP_Fixed(1,n)=1200*2;
feeder_CAP_Switch(1,n)=0;
feeder_length_mi(1,n)=8.202*0.621371;
feeder_length_ohm(1,n)=8; %4.211
feeder_volt_peak_head(1,n)=0.026;
feeder_volt_min_head(1,n)=0.018;
Load_Center_Resistance(1,n)=0.915; %ohm (this is not correct)

load Annual_daytime_load_HOLLY.mat   %WINDOW.DAYTIME.KW.A
KW_3PH=WINDOW.DAYTIME.KW.A(:,1)+WINDOW.DAYTIME.KW.B(:,1)+WINDOW.DAYTIME.KW.C(:,1);
KW_3PH_MAX=0;
KW_3PH_MIN=100e6;
for i=1:1:length(KW_3PH)
    if KW_3PH(i,1) < KW_3PH_MIN
        KW_3PH_MIN = KW_3PH(i,1);
    end
    if KW_3PH(i,1) > KW_3PH_MAX
        KW_3PH_MAX = KW_3PH(i,1);
    end
end
feeder_ValleyMW(1,n)=KW_3PH_MIN/1e3;


feeder_conductor(1,n)=60.358; %mi
%%
%6 - East Raleigh
n = n + 1;
load Annual_ls_ERALEIGH.mat
feeder_PeakMW(1,n)=(MAX.YEAR.KW.A+MAX.YEAR.KW.B+MAX.YEAR.KW.C)/1000;
feeder_CAP_Fixed(1,n)=200;
feeder_CAP_Switch(1,n)=0;
feeder_length_mi(1,n)=1.753*0.621371;
feeder_length_ohm(1,n)=0.308; %ohms
feeder_volt_peak_head(1,n)=0.022;
feeder_volt_min_head(1,n)=0.015;

Load_Center_Resistance(1,n)=0.1454; %ohms

load Annual_daytime_load_ERALEIGH.mat   %WINDOW.DAYTIME.KW.A
KW_3PH=WINDOW.DAYTIME.KW.A(:,1)+WINDOW.DAYTIME.KW.B(:,1)+WINDOW.DAYTIME.KW.C(:,1);
KW_3PH_MAX=0;
KW_3PH_MIN=100e6;
for i=1:1:length(KW_3PH)
    if KW_3PH(i,1) < KW_3PH_MIN
        KW_3PH_MIN = KW_3PH(i,1);
    end
    if KW_3PH(i,1) > KW_3PH_MAX
        KW_3PH_MAX = KW_3PH(i,1);
    end
end
feeder_ValleyMW(1,n)=KW_3PH_MIN/1e3;
feeder_conductor(1,n)=1.531; %mi

%%
Labels={'Bellhaven','Commonwealth','Flay','Roxboro','Holly Springs','E.Raleigh'};
figure(1);
%-----------------------------
subplot(3,4,1);
ax = gca;
barh(feeder_Volt);
axis([0 40 0 7]);
ax.XTick = [0 10 20 30 40];
ax.YTickLabel = Labels;
set(gca,'FontWeight','bold');
xlabel('Voltage Class (kV)','FontWeight','bold');
ylabel('Feeder','FontSize',16);
%-----------------------------
subplot(3,4,2);
barh(feeder_PeakMW);
axis([0 15 0 7]);
set(gca,'FontWeight','bold');
xlabel('Peak Load (MW)','FontWeight','bold');
%-----------------------------
subplot(3,4,3);
ax = gca;
barh(feeder_ValleyMW);
axis([0 5 0 7]);
set(gca,'FontWeight','bold');
ax.XTick = [0 1 2 3 4 5];
xlabel('Valley Day Load (MW)','FontWeight','bold');
%-----------------------------
subplot(3,4,4);
ax = gca;
barh(feeder_CAP_Fixed);
axis([0 4000 0 7]);
set(gca,'FontWeight','bold');
ax.XTick = [0 1000 2000 3000 4000];
xlabel('Fixed Caps (kVAR)','FontWeight','bold');
%-----------------------------
subplot(3,4,5);
ax = gca;
barh(feeder_LTC_VREG);
axis([0 8 0 7]);
set(gca,'FontWeight','bold');
ax.XTick = [0 2 4 6 8];
ax.YTickLabel = Labels;
xlabel('LTC & Line Regulators','FontWeight','bold');
ylabel('Feeder','FontSize',16);
%-----------------------------
subplot(3,4,6);
ax = gca;
barh(feeder_volt_peak_head);
axis([0 0.125 0 7]);
set(gca,'FontWeight','bold');
ax.XTick = [0 0.025 0.05 0.075 0.100 0.125];
xlabel('Peak Load Headroom (Vpu)','FontWeight','bold');
%-----------------------------
subplot(3,4,7);
ax = gca;
barh(feeder_volt_min_head);
axis([0 0.125 0 7]);
set(gca,'FontWeight','bold');
ax.XTick = [0 0.025 0.05 0.075 0.100 0.125];
xlabel('Valley Load Headroom (Vpu)','FontWeight','bold');
%-----------------------------
subplot(3,4,8);
barh(feeder_CAP_Switch);
axis([0 4000 0 7]);
set(gca,'FontWeight','bold');
xlabel('Swtch Caps (kVAR)','FontWeight','bold');
%-----------------------------
subplot(3,4,9);
ax = gca;
barh(feeder_length_mi);
axis([0 15 0 7]);
set(gca,'FontWeight','bold');
ax.YTickLabel = Labels;
xlabel('End Distance (mi)','FontWeight','bold');
ylabel('Feeder','FontSize',16);
%-----------------------------
subplot(3,4,10);
barh(feeder_length_ohm);
axis([0 20 0 7]);
set(gca,'FontWeight','bold');
xlabel('End Resistance (ohm)','FontWeight','bold');
%-----------------------------
subplot(3,4,11);
barh(feeder_conductor);
axis([0 100 0 7]);
set(gca,'FontWeight','bold');
xlabel('Feeder Conductor (mi)','FontWeight','bold');
%-----------------------------
subplot(3,4,12);
barh(Load_Center_Resistance);
axis([0 3 0 7]);
set(gca,'FontWeight','bold');
xlabel('Load Center Resistance (ohm)','FontWeight','bold');










