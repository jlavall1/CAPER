%Load Historical DSCADA
load CAP_Mult_60s_ROX.mat
load P_Mult_60s_ROX.mat
load Q_Mult_60s_ROX.mat
load LoadTotals.mat

%Component Names:
Caps.Name{1}='CAP1';
Caps.Name{2}='CAP2';
Caps.Name{3}='CAP3';
Caps.Swtch(1)=1200/3; 
Caps.Swtch(2)=1200/3; 
Caps.Swtch(3)=1200/3;
trans_name='T5240B12';
sub_line='A1';

timeseries_span = 2;