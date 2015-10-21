load Solar_Constants.mat
MTH_LN(1,1:12) = [31,28,31,30,31,30,31,31,30,31,30,31];
BIN = zeros(1,12);
i = 1;
j = 1;
k = 1;
SUM = 0;
figure(1);
hist(Solar_Constants(:,4));
xlabel('Variability Index (VI)','FontSize',12,'FontWeight','bold');
ylabel('Number of days','FontSize',12,'FontWeight','bold');
%title('Feeder Power Flows','FontSize',12,'FontWeight','bold');
axis([0 30 0 150]);

while i < 13
    if j < MTH_LN(1,i)+1
        SUM = SUM + Solar_Constants(k,4);
        j = j + 1;
        k = k + 1;
    elseif j > MTH_LN(1,i)
        %New month:
        BIN(1,i) = SUM/MTH_LN(1,i);
        j = 1;
        i = i + 1;
        SUM = 0;
    end
end
    
figure(2);
bar(BIN);
xlabel('Month','FontSize',12,'FontWeight','bold');
ylabel('Mean Daily VI','FontSize',12,'FontWeight','bold');
%title('Feeder Power Flows','FontSize',12,'FontWeight','bold');
axis([0 15 0 15]);

    
