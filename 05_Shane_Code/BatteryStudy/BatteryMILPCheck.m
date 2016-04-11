
% Let x = [a;c;d;E;P;Pbar;r]

n = length(NODE);
s = length(SECTION);
pv = length(PV);
t = length(PARAM.beta);

% Define starting indicies
a       = 0;
c       = a+n;
d       = c+n*t;
E       = d+n*t;
P       = E+n*(t+2);
Pbar    = P+(s+1)*t;
r       = Pbar+s*t;
xlen = r+s*t;

for i = 1:n
    x{a+i} = ['a_',NODE(i).ID];
    for j = 1:t/2
        x{c+t*(i-1)+j} = ['c_',NODE(i).ID,'(sum',num2str(j),')'];
        x{c+(t/2)+t*(i-1)+j} = ['c_',NODE(i).ID,'(win',num2str(j),')'];
        
        x{d+t*(i-1)+j} = ['d_',NODE(i).ID,'(sum',num2str(j),')'];
        x{d+(t/2)+t*(i-1)+j} = ['d_',NODE(i).ID,'(win',num2str(j),')'];
        
        x{E+(t+2)*(i-1)+j} = ['E_',NODE(i).ID,'(sum',num2str(j),')'];
        x{E+(t/2+1)+(t+2)*(i-1)+j} = ['E_',NODE(i).ID,'(sum',num2str(j),')'];
    end
    x{E+t*(i-1)+t/2+1} = ['E_',NODE(i).ID,'(sumEND)'];
    x{E+t*(i-1)+t+2} = ['E_',NODE(i).ID,'(winEND)'];
end

for i = 1:s
    for j = 1:t/2
        x{P+t*(i-1)+j} = ['P_',SECTION(i).FROM,'_',SECTION(i).TO,'(sum',num2str(j),')'];
        x{P+t/2+t*(i-1)+j} = ['P_',SECTION(i).FROM,'_',SECTION(i).TO,'(win',num2str(j),')'];
        
        x{Pbar+t*(i-1)+j} = ['Pbar_',SECTION(i).FROM,'_',SECTION(i).TO,'(sum',num2str(j),')'];
        x{Pbar+t/2+t*(i-1)+j} = ['Pbar_',SECTION(i).FROM,'_',SECTION(i).TO,'(win',num2str(j),')'];
        
        x{r+t*(i-1)+j} = ['r_',SECTION(i).FROM,'_',SECTION(i).TO,'(sum',num2str(j),')'];
        x{r+t/2+t*(i-1)+j} = ['r_',SECTION(i).FROM,'_',SECTION(i).TO,'(win',num2str(j),')'];
    end
end

for i = 1:t/2
    x{P+s*t+i} = ['P_g(sum',num2str(i),')'];
    x{P+s*t+t/2+i} = ['P_g(win',num2str(i),')'];
end

save('xvars.mat','x')
%{
load('xvars.mat');
clear var
[n,~] = size(A);
for i = 1:n
    var(i) = {x(logical(A(i,:)))};
end
%}