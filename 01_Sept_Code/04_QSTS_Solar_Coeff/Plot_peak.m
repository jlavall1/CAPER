close all
figure(1)
plot([BESS(1:8665).PCC])
hold on 
plot([BESS(1:8665).PCC]+[BESS(1:8665).kW])
hold on
plot(ones(8665,1)*3400*1.01,'r--')
hold on
plot(ones(8665,1)*3400*0.99,'r--')

figure(2)
plot([BESS(1:8665).SOC])
hold on
plot(100-[BESS(1:8665).SOC])
legend('SOC','DoD');

