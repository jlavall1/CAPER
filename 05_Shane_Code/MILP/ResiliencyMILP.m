% Driving Script for LP solution
clear
clc

tic
disp('Reading in Circuit Data...')
%% Read in Circuit Data
%[NODE,SECTION,DER,PARAM] = DSSRead(filename);
%[NODE,SECTION,DER,PARAM] = sxstRead_old2; %(fullfilename);
global NODE SECTION LOAD DER PARAM DSS
[NODE,SECTION,LOAD,DER,PARAM,DSS] = sxstRead;

toc
disp('Pre-Processing Data...')
%% Pre-Process Circuit Data
MILPPreProcessing();

PARAM.SO =  {'264495349'};

toc
disp('Formulating Problem...')
%% Formulate Problem
[f,A,rl,ru,lb,ub,xint] = ResiliencyMILPForm();



toc
disp('Solving LP...')
%% Solve Problem
%[X,fval,exitflag,output] = intlinprog(f,intcon,Aineq,bineq,Aeq,beq,lb,ub);
%Opt = opti('f',f,'ineq',Aineq,full(bineq),'eq',Aeq,full(beq),'bounds',lb,ub,'xtype',intcon);
%[X,fval,exitflag,info] = solve(Opt);
[X,fval,exitflag,info] = opti_cplex([],f,A,rl,ru,lb,ub,xint);
%[X,fval.exitflag,info] = opti-cplex([],f,A,rl,ru,lb,ub,xint);
%load('BILP.mat');
disp(info)
disp(fval)

%% Parse out solution data
if exitflag==1
    toc
    disp('Parcing out Solution Data...')
    
    N = length(NODE);       % Number of Nodes
    S = length(SECTION);    % Number of Sections
    D = length(DER);        % Number of DER
    LD = length(LOAD);       % Number of Loads
    LP = length(PARAM.Loop); % Number of Loops
    
    % Let x = [a;alpha;b;bbar;beta1;beta2;c], then
    % a     = x[    D*N    ]
    % alpha = x[  D*(L+D)  ]
    % b     = x[    D*S    ]
    % bbar  = x[     S     ]
    % beta1 = x[    D*S    ]
    % beta2 = x[    D*S    ]
    % c     = x[    D*LP   ]
    % d     = x[     D     ]
    
    
    % Define starting indicies
    a       = 0;
    alpha   = a+D*N;
    b       = alpha+D*(LD+D);
    bbar    = b+D*S;
    beta1   = bbar+S;
    beta2   = beta1+D*S;
    c       = beta2+D*S;
    d       = c+D*LP;
    
    
    fprintf('Active Micro-grids: %s\n',sprintf(' %d ',find(X(d+1:d+D)>.5)))
    
    MG = cell(D,1);
    for i = 1:D
        MG{i} = sprintf('MG%d',i);
    end
    
    for i = 1:D
        mg = find(X(alpha+LD+i+(LD+D)*(0:D-1)));
        DER(i).MGNumber = mg;
        for j = 1:D
            DER(i).(['alpha_',MG{j}]) = X(alpha+LD+i+(j-1)*(LD+D));
        end
    end
    
    for i = 1:N
        mg = find(X(a+i+N*(0:D-1)));
        NODE(i).MGNumber = mg;
        for j = 1:D
            NODE(i).(['a_',MG{j}]) = X(a+i+(j-1)*N);
        end
    end
    
    for i = 1:S
        SECTION(i).bbar = X(bbar+i);
        mg = find(X(b+i+S*(0:D-1)));
        SECTION(i).MGNumber = mg;
        for j = 1:D
            SECTION(i).(['b_',MG{j}]) = X(b+i+(j-1)*S);
            SECTION(i).(['beta1_',MG{j}]) = X(beta1+i+(j-1)*S);
            SECTION(i).(['beta2_',MG{j}]) = X(beta2+i+(j-1)*S);
        end
    end
    
    %LOAD = NODE(logical([NODE.p]));
    for i = 1:LD
        mg = find(X(alpha+i+(LD+D)*(0:D-1)));
        LOAD(i).MGNumber = mg;
        for j = 1:D
            LOAD(i).(['alpha_',MG{j}]) = X(alpha+i+(j-1)*(LD+D));
        end
    end
    
    [~,~,ic] = unique([{NODE.ID},{DER.ID}],'stable');
    
%     temp = DER;
%     [~,~,ic] = unique([{NODE.ID},{DER.ID}],'stable');
%     DER = NODE(ic(end-D+1:end));
%     DER = rmfield(DER,{'w','p','q'});
%     [DER.CAPACITY] = deal(temp.CAPACITY);
%     clear temp
    
    toc
    disp('Plotting Results...')
    % Plot Results
    PlotResults
%     
%     toc
%     disp('Check for Violations...')
%     % Check for Violations
%     for i = 1:D
%         % Find Source in Micro-grid
%         index = {logical([NODE.(['alpha_',MG{i}])]),logical([SECTION.(['beta_',MG{i}])]),logical([LOAD.(['c_',MG{i}])])};
%         if length(find(index{1}))>1 % Must Contain more than 1 node for simulation
%             [DSSCircuit, DSSCircObj, DSSText, gridpvPath] = DSSDeclare(NODE(index{1}),SECTION(index{2}),LOAD(index{3}),DER([DER.MGNumber]==i),DSS);
%             
%             % Collect Data
%             %Lines = getLineInfo(DSSCircObj);
%             %Bus = getBusInfo(DSSCircObj);
%             %Load = getLoadInfo(DSSCircObj);
%             figure; plotKWProfile(DSSCircObj);
%             figure; plotVoltageProfile(DSSCircObj);
%             figure; plotCircuitLines(DSSCircObj,'Coloring','voltage120')
%         end
%     end
    
end    

toc