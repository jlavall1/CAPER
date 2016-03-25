function [ ToS1,PAR_CB ] = ToS1_EST(BncI,CSI,DoD_max)
    %Find TOS1_min
    ToS1_min=(1-DoD_max)*1.05;
    PAR_B=max(BncI)/mean(BncI);
    PAR_C=max(CSI)/mean(CSI);
    PAR_CB=PAR_C/PAR_B;
    
    min_PAR_CB=1.26;
    
    ToS1=ToS1_min+(PAR_CB-min_PAR_CB)*min_PAR_CB;
end

