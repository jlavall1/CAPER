function F = solve_SCR_h2(x,T,C,h_1,ToS1,ToS2)
%numerical Solve to find SCR & h2
    %T=6; %hrs
    
    %x(1)=h2
    %x(2)=SCR
    %ToS1=0.85;
    %ToS2=0.9;
    F=[(x(1)^2)+(2*h_1-T*x(2))*x(1)+h_1^2;
        (h_1+x(1))*(T-(2*h_1/x(2))-(2*x(1)/x(2)))-(ToS2-ToS1)*C];
end

