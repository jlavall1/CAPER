% Driving Script for Battery MILP
clear
clc
close all

global NODE SECTION LOAD DER PARAM

tic
disp('Reading in Historical Data...')
%% Read in Historical Data

% Load Data
load('FlayLoad.mat');
% Data Characteristics
start = DATA(1).Date; % Date at which data starts
[nstp,~] = size(DATA(1).kW); % Number of Data points per row in struct
step = 24*60*60*(datenum(DATA(2).Date)-datenum(start))/nstp; % [s] - Resolution of data

% Average by Month
figure;
cmap = colormap(hsv);
for i = 1:11
    DOY = (datenum(sprintf('%d/1/2014',i)):datenum(sprintf('%d/30/2014',i+1))-1) - datenum(start) + 1;
    AVG = sum([DATA(DOY).kW],2)/length(DOY);
    plot(AVG,'Color',cmap(round(64*(i-1)/12)+1,:))
    hold on
end
% December
AVG = 3*mean([DATA(datenum('12/1/2014')-datenum(start)+1:end).kW],2);
plot(AVG,'Color',cmap(60,:))
colormap hsv
legend('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec')
hold off

% Summer Average (May-Aug)
SumDOY = (datenum('5/1/2014'):datenum('8/31/2014')) - datenum(start) + 1;
s = length(SumDOY);
SumAVG = sum([DATA(SumDOY).kW],2)/s;
SumAVG = mean(reshape(SumAVG,30,[]),1)'; % 15 min average

% Winter Average (Jan-Mar & Oct-Dec)
remove = (datenum('4/1/2014'):datenum('9/30/2014')) - datenum(start) + 1;
WinDOY = unique([remove,1:364],'stable');
WinDOY = WinDOY(length(remove)+1:end);
WinAVG = sum([DATA(WinDOY).kW],2)/length(WinDOY);
WinAVG = mean(reshape(WinAVG,30,[]),1)'; % 15 min average

% Plot Loadshapes
figure;
plot(SumAVG)
hold on
plot(WinAVG)
legend('Summer','Winter')

clear DATA

% PV Data
load('FlayPV.mat')

% PV Specifications
PV(1).Bus1 = '260007367';
PV(1).kW = 3000;
PV(1).pf = 1;

PV(2).Bus1 = '258406388';
PV(2).kW = 500;
PV(2).pf = 1;



toc
disp('Reading in Circuit Data...')
%% Read in Circuit Data
fid = fopen('pathdef.m');
rootlocation = textscan(fid,'%c')';
rootlocation = regexp(rootlocation{1}','C:[^.]*?CAPER\\','match','once');
fclose(fid);
fullfilename = [rootlocation,'07_CYME\Flay_ret_16271201.sxst'];

[NODE,SECTION,LOAD,DER,PARAM,~] = sxstRead(fullfilename);
% Removed Unnecessary Fields
NODE = rmfield(NODE,{'DSS','Capacitors','CapCtrl'});
SECTION = rmfield(SECTION,{'Recloser','Switch','Fuse','FuseCode',...
    'LineCode','DSS','Spacing','Wires','ReclCode','SwitchCode'});
% Remove Open points
SECTION = SECTION([SECTION.NormalStatus]);
% Remove End of feeder Nodes
[~,~,ic] = unique([{'264487210','264487418'},{NODE.ID}],'stable');
NODE(ic(3:end)<=2) = [];

SubBus = 'FLAY_RET_16271201';

toc
disp('Pre-Processing Data...')
%% Pre-Process Circuit Data
BatteryPreProcessing();

% Plot Reduced Graph
N = length(NODE);
S = length(SECTION);
MaxLoad = max([NODE.kW]);

figure;
% Substation
index = ismember({NODE.ID},SubBus);
plot(NODE(index).XCoord,NODE(index).YCoord,'kh','MarkerSize',15,...
    'MarkerFaceColor',[0,0.5,1],'LineStyle','none');
hold on

for i = 1:S
    index = [find(ismember({NODE.ID},SECTION(i).FROM)),find(ismember({NODE.ID},SECTION(i).TO))];
    plot([NODE(index).XCoord],[NODE(index).YCoord],'-k')
    hold on
end

for i = 1:N
    if NODE(i).kW>0
        plot(NODE(i).XCoord,NODE(i).YCoord,'ko','MarkerSize',5*10^(NODE(i).kW/MaxLoad),...
            'MarkerFaceColor','w','LineStyle','none');
    end
end










toc
disp('Formulating Problem...')
%% Formulate Problem
[f,A,rl,ru,lb,ub,xint] = BatteryMILPForm();

toc
disp('Solving LP...')
%% Solve Problem

[X,fval,exitflag,info] = opti_cplex([],f,A,rl,ru,lb,ub,xint);
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
    
    toc
    disp('Check for Violations...')
    % Check for Violations
%     for i = 1:D
%         % Find Source in Micro-grid
%         index = {logical([NODE.(['a_',MG{i}])]),logical([SECTION.(['b_',MG{i}])]),logical([LOAD.(['alpha_',MG{i}])])};
%         if length(find(index{1}))>1 % Must Contain more than 1 node for simulation
%             [DSSCircuit, DSSCircObj, DSSText, gridpvPath] = DSSDeclare(NODE(index{1}),SECTION(index{2}),LOAD(index{3}),DER([DER.MGNumber]==i),DSS);
%             
%             % Collect Data
%             %Lines = getLineInfo(DSSCircObj);
%             %Bus = getBusInfo(DSSCircObj);
%             %Load = getLoadInfo(DSSCircObj);
%             %figure; plotKWProfile(DSSCircObj);
%             %figure; plotVoltageProfile(DSSCircObj);
%             handles = plotCircuitLines(DSSCircObj,'Coloring','voltage120',...
%                 'ContourScale',[112 120],'CapacitorMarker','off','SubstationMarker','off','LoadMarker','on');
%             set(gca,'YTick',[])
%             set(gca,'XTick',[])
%             hold on
%             [~,~,ic] = unique([{NODE.ID},{DER([DER.MGNumber]==i).ID}],'stable');
%             hs = plot([NODE(ic(N+1:end)).XCoord],[NODE(ic(N+1:end)).YCoord],'kh','MarkerSize',15,'MarkerFaceColor',[0,0.5,1],'LineStyle','none');
% 
%         end
%     end
%     legend([hs,handles.legendHandles],'Source','Load')
end    

toc