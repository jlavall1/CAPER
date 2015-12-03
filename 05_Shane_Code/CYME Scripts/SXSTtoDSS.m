% Snap to grid function for CYME file
clear
clc

filename = 0;

%filename = 'Flay 12-01 - 2-3-15 loads (original).sxst';

%filename = 'Commonwealth 12-05-  9-14 loads (original).sxst';
%filelocation = 'C:\Users\SJKIMBL\Documents\MATLAB\CAPER\05_Shane_Code\CYME Scripts\';
while ~filename
    [filename,filelocation] = uigetfile({'*.*','All Files'},'Select .sxst file to convert');
end
savelocation = [filelocation,filename,'_DSS\'];
if ~exist(savelocation,'dir')
    mkdir(savelocation)
end

% Read File
FILE = fileread([filelocation,filename]);

% Print specs
n = length(strfind(FILE,'<Node>'));
s = length(strfind(FILE,'<Section>'));
l = length(strfind(FILE,'<SpotLoad>'));
lp = length(strfind(FILE,'<CustomerLoadValue>'));
fprintf('%d Nodes; %d Sections; %d Loads (%d by phase)\n',n,s,l,lp)

% Extract Node Information
%  Output - Busses.dss (text file containing BusID, X, and Y Coords)
nodeinfo = regexp(FILE,'<Node>(.*?)</Node>','match');
fID_Buses = fopen([savelocation,'Busses.dss'],'wt');
for i = 1:length(nodeinfo)
    % MILP
    NODE(i).ID = regexp(nodeinfo{i},'(?<=<NodeID>)(.*?)(?=</NodeID>)','match');
    
    % DSS
    Buses(i).ID = regexp(nodeinfo{i},'(?<=<NodeID>)(.*?)(?=</NodeID>)','match');
    Buses(i).XCoord = str2double(regexp(nodeinfo{i},'(?<=<X>)(.*?)(?=</X>)','match'));
    Buses(i).YCoord = str2double(regexp(nodeinfo{i},'(?<=<Y>)(.*?)(?=</Y>)','match'));
    
    fprintf(fID_Buses,'%-30s %-15.2f %-15.2f\n',Buses(i).ID{1},Buses(i).XCoord,Buses(i).YCoord);
end
fclose(fID_Buses);

% Extract Section Information
%  Output - Lines.dss, Loads.dss
sectinfo = regexp(FILE,'<Section>(.*?)</Section>','match');
k = 1;
fID_Lines = fopen([savelocation,'Lines.dss'],'wt');
fID_Monitors = fopen([savelocation,'Monitors.dss'],'wt'); % Only 3ph
for i = 1:length(sectinfo)
    % MILP
    SECTION(i).FROMNODE = regexp(sectinfo{i},'(?<=<FromNodeID>)(.*?)(?=</FromNodeID>)','match');
    SECTION(i).TONODE = regexp(sectinfo{i},'(?<=<ToNodeID>)(.*?)(?=</ToNodeID>)','match');
    SECTION(i).PHASE = regexp(sectinfo{i},'(?<=<Phase>)(.*?)(?=</Phase>)','match','once');

    % DSS
    Lines(i).ID = regexp(sectinfo{i},'(?<=<SectionID>)(.*?)(?=</SectionID>)','match');
    Lines(i).Phase = regexp(sectinfo{i},'(?<=<Phase>)(.*?)(?=</Phase>)','match','once');
    % String to be appended to bus info
    append = '';
    if ~isempty(strfind(Lines(i).Phase,'A'))
        append = [append,'.1'];
    end
    if ~isempty(strfind(Lines(i).Phase,'B'))
        append = [append,'.2'];
    end
    if ~isempty(strfind(Lines(i).Phase,'C'))
        append = [append,'.3'];
    end
    
    Lines(i).Phase = length(Lines(i).Phase);
    % Monitor all 3ph lines
    if Lines(i).Phase == 3
        fprintf(fID_Monitors,'New Monitor.%s_Mon_VI element=Line.%s term=1 mode=32\n',...
            Lines(i).ID{1},Lines(i).ID{1});
        fprintf(fID_Monitors,'New Monitor.%s_Mon_PQ element=Line.%s term=1 mode=1 PPolar=No\n',...
            Lines(i).ID{1},Lines(i).ID{1});
    end
    
    bus1 = regexp(sectinfo{i},'(?<=<FromNodeID>)(.*?)(?=</FromNodeID>)','match');
    bus2 = regexp(sectinfo{i},'(?<=<ToNodeID>)(.*?)(?=</ToNodeID>)','match');
    Lines(i).Bus1 = [bus1{1},append];
    Lines(i).Bus2 = [bus2{1},append];
            
    % Extract Device Info
    %  Overhead By Phase
    overheadinfo = regexp(sectinfo{i},'<OverheadByPhase>(.*?)</OverheadByPhase>','match');
    if ~isempty(overheadinfo)
        % DSS
        Lines(i).Length = str2double(regexp(overheadinfo{1},'(?<=<Length>)(.*?)(?=</Length>)','match'));
        Lines(i).Spacing = strrep(regexp(overheadinfo{1},'(?<=<ConductorSpacingID>)(.*?)(?=</ConductorSpacingID>)','match'),'&apos;','''');
        wires = regexp(overheadinfo{1},'(?<=<PhaseConductorID[ABC]>)(.*?)(?=</PhaseConductorID[ABC]>)','match');
        wires = [wires(~strcmp(wires,'NONE')),regexp(overheadinfo{1},'(?<=<NeutralConductorID>)(.*?)(?=</NeutralConductorID>)','match')];
        Lines(i).Wires = ['[''',strjoin(wires,''' '''),''']'];
        
        fprintf(fID_Lines,['New Line.%s Phases= %d Bus1=%-15s Bus2=%-15s ',...
            'Length=%-6.2f units=m  Spacing=%s wires=%s\n'],...
            Lines(i).ID{1},Lines(i).Phase,Lines(i).Bus1,Lines(i).Bus2,...
            Lines(i).Length,Lines(i).Spacing{1},Lines(i).Wires);
    end
    
    %  Underground
    undergroundinfo = regexp(sectinfo{i},'<Underground>(.*?)</Underground>','match');
    if ~isempty(undergroundinfo)
        % DSS
        Lines(i).Length = str2double(regexp(undergroundinfo{1},'(?<=<Length>)(.*?)(?=</Length>)','match'));
        Lines(i).LineCode = regexp(undergroundinfo{1},'(?<=<CableID>)(.*?)(?=</CableID>)','match');
        
        fprintf(fID_Lines,['New Line.%s Bus1=%-15s Bus2=%-15s LineCode=%s ',...
            'Phases= %d Length=%-6.2f units=m\n'],Lines(i).ID{1},Lines(i).Bus1,...
            Lines(i).Bus2,Lines(i).LineCode{1},Lines(i).Phase,Lines(i).Length);
    end
    
    %  Spot Loads
    loadinfo = regexp(sectinfo{i},'<SpotLoad>(.*?)</SpotLoad>','match');
    spotloadinfo = regexp(sectinfo{i},'<CustomerLoadValue>(.*?)</CustomerLoadValue>','match');
    for j = 1:length(spotloadinfo)
        % MILP
        %<NormalPriority>0</NormalPriority>
        %<EmergencyPriority>0</EmergencyPriority>
        
        % DSS
        phase = regexp(spotloadinfo{j},'(?<=<Phase>)(.*?)(?=</Phase>)','match');
        % String to be appended to load info
        append = '';
        if ~isempty(strfind(phase{1},'A'))
            append = [append,'_1'];
        end
        if ~isempty(strfind(phase{1},'B'))
            append = [append,'_2'];
        end
        if ~isempty(strfind(phase{1},'C'))
            append = [append,'_3'];
        end
        
        Location = regexp(loadinfo{1},'(?<=<Location>)(.*?)(?=</Location>)','match');
        switch Location{1}
            case 'From'
                Loads(k).ID = [bus1{1},append];
            case 'To'
                Loads(k).ID = [bus2{1},append];
        end
        
        Loads(k).Phase = phase{1};
        Loads(k).numPhase = length(phase);
        Loads(k).Bus1 = strrep(Loads(k).ID,'_','.');
        Loads(k).kV = 7.2; % kV
        Loads(k).XFKVA = str2double(regexp(spotloadinfo{j},'(?<=<ConnectedKVA>)(.*?)(?=</ConnectedKVA>)','match'));
        
        LoadType = regexp(spotloadinfo{j},'(?<=<LoadValue Type="LoadValue)(.*?)(?=">)','match');
        
        switch LoadType{1}
            case 'KW_KVAR'
                Loads(k).kW = str2double(regexp(spotloadinfo{j},'(?<=<KW>)(.*?)(?=</KW>)','match'));
                Loads(k).kVAR = str2double(regexp(spotloadinfo{j},'(?<=<KVAR>)(.*?)(?=</KVAR>)','match'));
                Loads(k).kVA = sqrt(Loads(k).kW^2 + Loads(k).kVAR^2);
                Loads(k).pf  = cos(atan(Loads(k).kVAR/Loads(k).kW));
            case 'KVA_PF'
                Loads(k).kVA = str2double(regexp(spotloadinfo{j},'(?<=<KVA>)(.*?)(?=</KVA>)','match'));
                Loads(k).pf  = str2double(regexp(spotloadinfo{j},'(?<=<PF>)(.*?)(?=</PF>)','match'))/100;
                Loads(k).kW   = Loads(k).kVA*Loads(k).pf;
                Loads(k).kVAR = Loads(k).kVA*sqrt(1-Loads(k).pf^2);
            case 'KW_PF'
                Loads(k).kW = str2double(regexp(spotloadinfo{j},'(?<=<KW>)(.*?)(?=</KW>)','match'));
                Loads(k).pf  = str2double(regexp(spotloadinfo{j},'(?<=<PF>)(.*?)(?=</PF>)','match'))/100;
                Loads(k).kVA = Loads(k).kW/loads(k).pf;
                Loads(k).kVAR = Loads(k).kVA*sqrt(1-Loads(k).pf^2);
            otherwise
                error('Unknown Load Type')
        end
        
        Loads(k).kWh = str2double(regexp(spotloadinfo{j},'(?<=<KWH>)(.*?)(?=</KWH>)','match'));
        Loads(k).NumCust = str2double(regexp(spotloadinfo{j},'(?<=<NumberOfCustomer>)(.*?)(?=</NumberOfCustomer>)','match'));
        
        k = k+1;
    end
end
fclose(fID_Lines);
fclose(fID_Monitors);

% Generate Loads.dss
fID_Loads = fopen([savelocation,'Loads.dss'],'wt');
fID_LoadsFault = fopen([savelocation,'Loads_Fault.dss'],'wt');

% Find per phase demand totals
kWtotA = sum([Loads(regexp([Loads.Phase],'A')).kW]);
kWtotB = sum([Loads(regexp([Loads.Phase],'B')).kW]);
kWtotC = sum([Loads(regexp([Loads.Phase],'C')).kW]);
kVARtotA = sum([Loads(regexp([Loads.Phase],'A')).kVAR]);
kVARtotB = sum([Loads(regexp([Loads.Phase],'B')).kVAR]);
kVARtotC = sum([Loads(regexp([Loads.Phase],'C')).kVAR]);

for k = 1:lp
    switch Loads(k).Phase
        case 'A'
            kWtot = kWtotA;
            kVARtot = kVARtotA;
        case 'B'
            kWtot = kWtotB;
            kVARtot = kVARtotB;
        case 'C'
            kWtot = kWtotC;
            kVARtot = kVARtotC;
    end
    
    % Print Timeseries Loads
    fprintf(fID_Loads,['New Load.%s Phases=%d Bus1=%-10s kV=%.4f ',...
        'kW=%.8f kVAR=%.8f status=variable Vminpu=0.7 ',...
        'yearly=LS_Phase%c daily=LS_Phase%c duty=LS_Phase%c\n'],...
        Loads(k).ID,Loads(k).numPhase,Loads(k).Bus1,Loads(k).kV,...
        Loads(k).kW/kWtot,Loads(k).kVAR/kVARtot,...
        Loads(k).Phase,Loads(k).Phase,Loads(k).Phase);
    
    % Print Fault Loads
    fprintf(fID_LoadsFault,['New Load.%s Phases=%d Bus1=%-10s kV=%.4f ',...
        'XFKVA=%3.1f PF=%.4f Vminpu=0.7\n'],...
        Loads(k).ID,Loads(k).numPhase,Loads(k).Bus1,Loads(k).kV,...
        Loads(k).XFKVA,Loads(k).pf);
end
fclose(fID_Loads);
fclose(fID_LoadsFault);