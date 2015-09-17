%Get line info
Lines = getLineInfo(DSSCircObj);
%Get transformer info
Xfmrs = getTransformerInfo(DSSCircObj);
%Get all transformer names
xfmrNames={Xfmrs.name};
%Empty cell which will be populated with bus names at violation locations
A={};
%Iniate to use as index for the cell structure above in the for loop below
count=1;

%Begin looking through circuit
for i=1:length(Lines)-1
    %Get parent object of line
    Parent=Lines(i).parentObject;
    %Trim "Line" from beginning of line name
    [token, Parent]=strtok(Parent,'.');
    %Trim period from beginning of line name
    Parent=Parent(2:end);
    %Check to make sure parent object is a line and not a xfmr
    if ismember(Parent,xfmrNames)~=1;
        %Get information about parent line
        ParentInfo=getLineInfo(DSSCircObj,{Parent});
        %Check if difference betwen parent and child line ratings is large
        %and if the parent object is part of the 3 phase backbone
        if ParentInfo.lineRating - Lines(i).lineRating > 400 && ParentInfo.numPhases==3
            %Get bus name for parent object
            bus=ParentInfo.bus2;
            %Trim phase numbers off end of bus name
            bus=strtok(bus,'.');
            %Add bus name to cell array
            A{count}=bus;
            %Increment count index
            count=count+1;
        end
    end
end
    
%Plotting violation buses
figure; Handles = plotCircuitLines(DSSCircObj,'Coloring','numPhases');
%Violation buses
addBuses = [A]; 
%Get information for violation buses
Buses = getBusInfo(DSSCircObj,addBuses,1);
%Manipulate bus coordinates to be plotted by MATLAB
BusesCoords = reshape([Buses.coordinates],2,[])';  
%Plots specific markers at violation bus locations
busHandle = plot(repmat(BusesCoords(:,2)',2,1),repmat(BusesCoords(:,1)',2,1), 'ko','MarkerSize',10,'MarkerFaceColor','c','LineStyle','none','DisplayName','Bottleneck');  
%Adds a legend with respective bus names
legend([Handles.legendHandles,busHandle'],[Handles.legendText,addBuses] )