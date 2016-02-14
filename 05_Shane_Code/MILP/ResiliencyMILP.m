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
    N = length(NODE);       % Number of Nodes
    S = length(SECTION);    % Number of Sections
    D = length(DER);        % Number of DER
    L = length(LOAD);       % Number of Loads
    
    
    % a     = x[       1      :       n      ]
    % alpha = x[      n+1     :    (d+1)*n   ]
    % b     = x[   (d+1)*n+1  :   (d+1)*n+s  ]
    % bbar  = x[    (d+1)*n+s+1 :   (d+1)*n+2s ]
    % beta  = x[   (d+1)*n+2s+1 : (d+1)*n+(2+d)s  ]
    % c     = x[ (d+1)*n+(2+d)s+1  :  (d+1)n+2s ]
    % gamma = x[  (d+1)n+2s+1 : (2d+1)n+2s ]
    
    % Define starting indicies
    a       = 0;
    alpha   = a+N;
    b       = alpha+D*N;
    bbar    = b+S;
    beta    = bbar+S;
    c       = beta+D*S;
    gamma   = c+L*D;
    fprintf('Active Micro-grids: %s\n',sprintf(' %d ',find(X(gamma+1:gamma+D)>.5)))
        
    for i = 1:N
        NODE(i).a = X(a+i);
        for j = 1:D
            NODE(i).(sprintf('alpha_MG%d',j)) = X(alpha+i+(j-1)*N);
        end
    end
    
    for i = 1:S
        SECTION(i).b = X(b+i);
        SECTION(i).bbar = X(bbar+i);
        for j = 1:D
            SECTION(i).(sprintf('beta_MG%d',j)) = X(beta+i+(j-1)*S);
        end
    end
    
    LOAD = NODE(logical([NODE.p]));
    for i = 1:L
        for j = 1:D
            LOAD(i).(sprintf('c_MG%d',j)) = X(c+i+(j-1)*L);
        end
    end
    
    temp = DER;
    [~,~,ic] = unique([{NODE.ID},{DER.ID}],'stable');
    DER = NODE(ic(end-D+1:end));
    DER = rmfield(DER,{'w','p','q'});
    [DER.CAPACITY] = deal(temp.CAPACITY);
    clear temp

end    

toc