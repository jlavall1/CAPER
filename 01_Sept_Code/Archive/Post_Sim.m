load RESULTS_9_3_2015
%PV_Size | PV_meas | max_PU | max_thermal

figure(1);
plot(RESULTS(:,1),RESULTS(:,4),'r*')
xlabel('Central PV size (kW)');
ylabel('max %Theral Rating');

%Voltage Contour:
figure(2);
plot(RESULTS(2:10000,1),RESULTS(2:10000,3),'b*')
xlabel('Central PV size (kW)');
ylabel('max phase voltage P.U.');
