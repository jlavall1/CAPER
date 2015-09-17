%***********************************%
%       Line Change Study           %
%***********************************%

%This is a script to automatically detect and plot nodes on an OpenDSS
%feeder where there is a wire change. The output information is in the cell
%wireSizeChangeInfo. This script takes several minutes to run. Be patient!

%1) Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;
%2) Compile the Circuit:
DSSText.command = 'compile R:\00_CAPER_SYSTEM\05_OpenDSS_Circuits\Roxboro_Circuit_Opendss\Run_Master_Allocate.DSS';
DSSText.command = 'solve';
%3) Setup a pointer of the active circuit:
DSSCircuit = DSSCircObj.ActiveCircuit;
%4) Obtain component info:
Lines = getLineInfo(DSSCircObj);
Xfmrs = getTransformerInfo(DSSCircObj);
%5) Obtain component structs:
xfmrNames={Xfmrs.name};
fuseNames = {DSSCircuit.Fuses.All};


%Empty cell which will be populated with bus names at violation locations
A={};
%Iniate to use as index for the cell structure above in the for loop below
count=1;
%Initiate cells to hold information about the buses at which the line size
%changes, information about the parent and child objects.
wireSizeChangeInfo=cell(length(Lines), 1);

%Begin looking through circuit
for i=1:length(Lines)-1
    %Get parent object of line
    Parent=Lines(i).parentObject;
    %Trim "Line" from beginning of line name
    [token, Parent]=strtok(Parent,'.');
    %Trim period from beginning of line name
    Parent=Parent(2:end);
    
    %Get wire configuration data about the parent and child wires
    DSSText.command = ['? Line.', ParentInfo.name  ,'.wires'];
    parentWireInfo = DSSText.Result;
    DSSText.command = ['? Line.',Lines(i).name ,'.wires'];
    childWireInfo = DSSText.Result;
    
    %Check to make sure parent object is a line and not a xfmr or fuse
    if ismember(Parent,xfmrNames)~=1;
        %Get information about parent line
        ParentInfo=getLineInfo(DSSCircObj,{Parent});
        %Check the difference betwen parent and child line rating
        if (ParentInfo.lineRating - Lines(i).lineRating) > 0
            %Get bus name for parent object
            bus=ParentInfo.bus2;
            %Trim phase numbers off end of bus name
            bus=strtok(bus,'.');
            %Add bus name to cell array
            A{count}=bus;
            %Increment count index
            count=count+1;
            %Store the name of the bus junction where the wire size changes
            wireSizeChangeInfo{i}.busName = bus;
            %Store the name, current rating, geometry, and wire type of the parent
            %object
            DSSText.command = ['? Line.', ParentInfo.name  ,'.wires'];
            wireSizeChangeInfo{i}.parentLineCode = DSSText.result;
            wireSizeChangeInfo{i}.parentCurrentRating = ParentInfo.lineRating;
            wireSizeChangeInfo{i}.parentName = ParentInfo.name;
            wireSizeChangeInfo{i}.parentSpacing = ParentInfo.spacing;
            %Store the name, current rating, geometry, and wire type of the
            %child object
            DSSText.command = ['? Line.', Lines(i).name ,'.wires'];
            wireSizeChangeInfo{i}.childLineCode = DSSText.result;
            wireSizeChangeInfo{i}.childCurrentRating = Lines(i).lineRating;
            wireSizeChangeInfo{i}.childName = Lines(i).name;
            wireSizeChangeInfo{i}.childSpacing = Lines(i).spacing;

        end
    end
end
    
%Trim the empty cells from the wireSizeChangeInfo array
emptyCells = cellfun(@(x) isempty(x), wireSizeChangeInfo);
wireSizeChangeInfo(emptyCells) = [];


%Plotting violation buses
figure; Handles = plotCircuitLines(DSSCircObj,'Coloring', 'numPhases');
%Violation buses
addBuses = [A]; 
%Get information for wire switched
Buses = getBusInfo(DSSCircObj,addBuses,1);
%Manipulate bus coordinates to be plotted by MATLAB
BusesCoords = reshape([Buses.coordinates],2,[])';
%Plots specific markers at violation bus locations
busHandle = plot(repmat(BusesCoords(:,2)',2,1),repmat(BusesCoords(:,1)',2,1), 'ko','MarkerSize',4,'MarkerFaceColor','c','LineStyle','none','DisplayName','Bottleneck');  
%Adds a legend with respective bus names
legend([Handles.legendHandles,busHandle'],[Handles.legendText, 'Border Buses'] )
