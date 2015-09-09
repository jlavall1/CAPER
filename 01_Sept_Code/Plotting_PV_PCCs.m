clear
clc
%This function will generate plots depending on what user desires:
%Focuses on interp simulation data:
plot_choice=menu('How would you like to see the PV_PCCs?','By Distance','By Iteration #');
while plot_choice<1
    plot_choice=menu('How would you like to see the PV_PCCs?','By Distance','By Iteration #');
end
user_def = zeros(1,2); %LOWER_BOUND | UPPPER_BOUND
if plot_choice==1
    cat_choice=menu('What Range?','0.00km  -  1.00km','1.01km  -  1.75km','1.76km  -  2.5km','2.51km  -  3.00km','3.01km  -  3.50km','3.51 <');
    while cat_choice<1
        cat_choice=menu('What Range?','0.00km  -  1.00km','1.01km  -  1.75km','1.76km  -  2.5km','2.51km  -  3.00km','3.01km  -  3.50km','3.51 <');
    end
    if cat_choice == 1
        user_def(1,1) = 0;
        user_def(1,2) = 1;
    elseif cat_choice == 2
        user_def(1,1) = 1.01;
        user_def(1,2) = 1.75;
    elseif cat_choice == 3
        user_def(1,1) = 1.76;
        user_def(1,2) = 2.50;
    elseif cat_choice == 4
        user_def(1,1) = 2.51;
        user_def(1,2) = 3.00;
    elseif cat_choice == 5
        user_def(1,1) = 3.01;
        user_def(1,2) = 3.50;
    elseif cat_choice == 6
        user_def(1,1) = 3.51;
        user_def(1,2) = 4.5;
    end       
elseif plot_choice==2
    prompt = 'Please Enter lower bound of Position Iteration # (0 -> 200)';
    lb = input(prompt);
    if lb < 0 || lb > 200
        prompt = 'Please RE-ENTER lower bound:';
        lb = input(prompt);
    end
    prompt = 'Now ENTER upper bound (0:200)';
    ub = input(prompt);
    %update matrix:
    user_def(1,1) = lb;
    user_def(1,2) = ub;
end
%%
%After Simulation, Lets show where all the locations were w/ distance from
%substation.

%Add this part of script if you don't want to run sim"
%
%Setup the COM server:
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
%Find directory of Circuit:
mainFile = GUI_openDSS_Locations();
%Declare name of basecase .dss file:
master = 'Master_ckt7.dss';
basecaseFile = strcat(mainFile,master);
DSSText.command = ['Compile "',basecaseFile];
DSSText.command = 'Set mode=snapshot';
DSSText.command = 'Set controlmode = static';
DSSText.command = 'solve';

%"PLOT BASE CASE (to see that I am wrong ha.ha."
figure(1);
%plotKWProfile(DSSCircObj,'Only3Phase','on');
%plotVoltageProfile(DSSCircObj,'SecondarySystem','off');
plotAmpProfile(DSSCircObj,'157345');
Buses =getBusInfo(DSSCircObj);
%Import desired Buses:
load config_LEGALBUSES.mat
load config_LEGALDISTANCE.mat %legal_distances
j = 1;
for i=1:1:length(legal_buses);
    if plot_choice == 1
        if legal_distances(i,1) >= user_def(1,1) && legal_distances(i,1) <= user_def(1,2)
            addBuses{j,1} = legal_buses{i,1};
            j = j + 1;
        end
    elseif plot_choice == 2
        if i >= user_def(1,1) && i <= user_def(1,2)
            addBuses{j,1} = legal_buses{i,1};
            j = j + 1;
        end
    end
end

%addBuses = [legal_buses];
%{

if plot_choice == 1
    titlestring=sprintf('PV-PCC''s DISTANCE range from SUB: %1.2f to %1.2f km ',user_def(1,1),user_def(1,2));
elseif plot_choice == 2
    %title(fprintf('PV-PCC''s shown are %s -> %s Interation of simulation',num2str(user_def(1,1)),num2str(user_def(1,2))));
end

%This is to print the feeder
figure(1);

%plotCircuitLines(DSSCircObj,'Coloring','lineLoading','PVMarker','on','MappingBackground','none');
gcf=plotCircuitLines(DSSCircObj,'Coloring','numPhases','MappingBackground','none');
title(titlestring);

%PV_PCC buses

Bus2add =getBusInfo(DSSCircObj,addBuses,1);
BusesCoords = reshape([Bus2add.coordinates],2,[])';
%now lets add onto plot:
%   B = repmat(A,r1,r2): specs a list of scalars (rN) that describes how
%   copies of A are arranged in each dimension
busHandle = plot(repmat(BusesCoords(:,2)',2,1),repmat(BusesCoords(:,1)',2,1),'ko','MarkerSize',10,'MarkerFaceColor','c','LineStyle','none','DisplayName','Bottleneck');
legend([gcf.legendHandles,busHandle'],[gcf.legendText,'PV_{PCC} Locations'] )
%set(gcf.name,'CKT 7');
 %}       
    
    
    


