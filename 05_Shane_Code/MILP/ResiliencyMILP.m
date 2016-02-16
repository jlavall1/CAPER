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
    {'258896301' '258896343' '258896628' '264491247'});
LOAD = NODE(logical([NODE.p]));

PARAM.SO =  {'264495349'};

toc
disp('Formulating MILP Constraints...')
% Formulate Problem
[f,intcon,Aineq,bineq,Aeq,beq,lb,ub] = ResiliencyMILPForm(NODE,SECTION,LOAD,DER,PARAM);

toc
disp('Solving LP...')
% Solve Problem
%[X,fval,exitflag,output] = intlinprog(f,intcon,Aineq,bineq,Aeq,beq,lb,ub);
Opt = opti('f',f,'ineq',Aineq,full(bineq),'eq',Aeq,full(beq),'bounds',lb,ub,'xtype',intcon);
[X,fval,exitflag,info] = solve(Opt);
disp(info)
disp(fval)

if exitflag==1
    toc
    disp('Parcing out Solution Data...')
    % Parse out solution data
    N = length(NODE);       % Number of Nodes
    S = length(SECTION);    % Number of Sections
    D = length(DER);        % Number of DER
    L = length(LOAD);       % Number of Loads
    
    
    % Let x = [a;alpha;b1;b2;bbar;c;gamma], then
    % a     = x[           1           :           N           ]
    % alpha = x[          N+1          :        (D+1)*N        ]
    % b1    = x[       (D+1)*N+1       :       (D+1)*N+S       ]
    % b2    = x[      (D+1)*N+S+1      :      (D+1)*N+2*S      ]
    % bbar  = x[     (D+1)*N+2*S+1     :      (D+1)*N+3*S      ]
    % beta  = x[     (D+1)*N+3*S+1     :    (D+1)*N+(3+D)*S    ]
    % c     = x[   (D+1)*N+(3+D)*s+1   :   (D+1)*N+(3+D)*S+L   ]
    % gamma = x[  (D+1)*N+(3+D)*S+L+1  :  (D+1)*N+(3+D)*S+L+D  ]
    
    % Define starting indicies
    a       = 0;
    alpha   = a+N;
    B1      = alpha+D*N;
    B2      = B1+S;
    bbar    = B2+S;
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
        SECTION(i).b1 = X(B1+i);
        SECTION(i).b2 = X(B2+i);
        SECTION(i).b = SECTION(i).b1+SECTION(i).b2;
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
    
    toc
    disp('Plotting Results...')
    PlotResults
end    

toc