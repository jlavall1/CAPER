%load M_MOCKS.mat
%M_PVSITE = M_MOCKS;
clear
clc
close all
ALT = 379.781; %[m] Taylorsville,NC
addpath('C:\Users\jlavall\Documents\GitHub\CAPER\04_DSCADA\VI_CI_IrradianceDailyProfiles\03_Taylorsville_NC');
load M_TAYLOR.mat
M_PVSITE = M_TAYLOR;
%Static Constants:
I_sc = 1367; %W/m^2
T_L = 3; %(original Linke Constant)
a_1 = (5.09 * 10 ^ (-5)) * ALT + 0.868;
a_2 = (3.92 * 10 ^ (-5)) * ALT + 0.0387;
f_h1 = exp(-1 * ALT / 8000);    %could be -1 as well.
f_h2 = exp(-1 * ALT / 1250);
b = 0.664 + 0.163/f_h1;

MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
%-----------
%Start Date: 1/1/2014 (FIND V.I.)
MNTH = 1;
DAY = 1;
%-----------
%Calculations:
min = 0;
hr = 0;
i = 1;
n = 1;
while MNTH < 2%13
    while DAY < MTH_LN(1,MNTH)+1
        while hr < 24
            while min < 60
                h = M_PVSITE(MNTH).DAY(time2int(DAY,hr,min),4);
                %-------------Method not used
                %AM_1(i,n) = 1160 + 75*sin(deg2rad((360/365)*(n-275)));
                AM_1(i,n) = 1160 + 75*sin((360/365)*(n-275));
                k_1(i,n) = 0.174+0.035*sin(deg2rad((360/365)*(n-100)));
                m_1(i,n) = (((708*sin(deg2rad(h))^2)+1417)^(1/2)-708*sin(deg2rad(h)));
                B_ncI_1(i,n) = AM_1(i,n)*exp(-1*k_1(i,n)*m_1(i,n));
                
                %-------------Method used
                %extraterrestrial irradiance on a plane perp. to Sun's:
                %n = M_PVSITE(MNTH).DAY(time2int(DAY,hr,min),6);   
                I_o(i,n) = I_sc *(1 + 0.034 * cos(deg2rad(2*pi * (n / 265.25))));
                
                %Beam clear sky (normal irradiance)
            %Old Method:
                %optical Air Mass:
                AM(i,n) = 1/cos(deg2rad(h));
                if h > 0
                    B_ncI(i,n) = b * I_o(i,n) * exp(-0.09*AM(i,n)*(T_L-1));
                else
                    B_ncI(i,n) = 0;
                end
                DNI(i,n) = I_o(i,n)*(1-0.014*ALT)*0.7^(AM(i,n)^0.678)+0.14*ALT;
                T_LI(i,n) = (11.1*log((b*I_o(i,n))/B_ncI(i,n))/AM(i,n))+1;
                if B_ncI(i,n) > I_sc
                    B_ncI(i,n) = 0; %Make to show no irrad. avail. w/out sun present.
                end
                
                %Global Sky Radiation reaching the ground on a horizontal surface.
                G_hcI(i,n) = a_1 *I_o(i,n)*sin(deg2rad(h))*exp(-1*a_2*AM(i,n)*(f_h1+f_h2*(T_LI(i,n)-1)));
                if G_hcI(i,n) < 0
                    G_hcI(i,n) = 0; %No Irradiance available to generate.
                end

                
                
                
                min = min + 1;
                i = i + 1;
            end
            min = 0;
            hr = hr + 1;
        end
        hr = 0;
        min = 0;
        DAY = DAY + 1
        n = n + 1;
        i = 1;
    end
    DAY = 1;
    MNTH = MNTH + 1;
end
%{
for n=1:1:365
    AM(n) = 1160 + 75*sin(deg2rad((360/365)*(n-275)));
    k(n) = 0.174+0.035*sin(deg2rad((360/365)*(n-100)));
    m(n) = (((708*sin(deg2rad(h))^2)+1417)^(1/2)-708*sin(deg2rad(h)));
    B_ncI(n) = AM(n)*exp(-1*k(n)*m(n));
end
%}
%%
figure(1)
plot(G_hcI(:,1))
hold on
plot(B_ncI(:,1))
legend('Global Horiz. CSI','Direct Beam Irradiance');