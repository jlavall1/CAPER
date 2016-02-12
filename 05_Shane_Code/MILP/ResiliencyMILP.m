% Driving Script for LP solution
clear
clc

tic
disp('Reading in Circuit Data...')
% Read in Circuit Data
%[NODE,SECTION,DER,PARAM] = DSSRead(filename);
[NODE,SECTION,DER,PARAM] = sxstRead; %(fullfilename);

% Add DER
[NODE,SECTION,DER] = addDER(NODE,SECTION,DER,...
    {'258896301' '258908260' '258896628' '264491247'});
LOAD = NODE(logical([NODE.p]));

PARAM.SO = {'264495349'};

toc
disp('Formulating MILP Constraints...')
% Formulate Problem
[f,intcon,Aineq,bineq,Aeq,beq,lb,ub] = ResiliencyMILPForm(NODE,SECTION,LOAD,DER,PARAM);

toc
disp('Solving MILP...')
% Solve Problem
[X,fval,exitflag,output] = intlinprog(f,intcon,Aineq,bineq,Aeq,beq,lb,ub);

if exitflag==1
    toc
    disp('Parcing out Solution Data...')
    % Parse out solution data
    N = length({NODE.ID});    % Number of Nodes
    S = length({SECTION.ID}); % Number of Sections
    D = length({DER.ID});     % Number of DER
    
    % Define starting indicies
    a       = 0;
    b       = N;
    beta    = N+S;
    c       = N+2*S;
    gamma   = (D+1)*N+2*S;
    d       = (2*D+1)*N+2*S;
    
    for i = 1:N
        NODE(i).a = X(a+i);
        for j = 1:D
            NODE(i).(['c_',DER(j).ID]) = X(c+i+(j-1)*N);
            NODE(i).(['gamma_',DER(j).ID]) = X(gamma+i+(j-1)*N);
        end
    end
    
    for i = 1:S
        SECTION(i).b = X(b+i);
        SECTION(i).beta = X(beta+i);
        SECTION(i).d = X(d+i);
    end
end    

toc