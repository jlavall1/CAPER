%***********************************%
%       Line Change Study           %
%***********************************%

%This is a script to automatically detect and plot nodes on an OpenDSS
%feeder where there is a wire change. The output information is in the cell
%wireSizeChangeInfo. This script takes several minutes to run. Be patient!


%Set a pointer for the active circuit
DSSCircuit=DSSCircObj.ActiveCircuit;
%Get line info
Lines = getLineInfo(DSSCircObj);
%Get transformer info
Xfmrs = getTransformerInfo(DSSCircObj);
%Get all transformer names
xfmrNames={Xfmrs.name};
%Get all fuse names
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
        %If the line is a dummy line or switch, do not iterate
        DSSText.command = ['? Line.',Lines(i).name,'.switch'];
        if not(Lines(i).length < 1) & strcmp(DSSText.Result, 'False')
            %Get parent object of line
            Parent=Lines(i).parentObject;
            %Trim "Line" from beginning of line name
            [token, Parent]=strtok(Parent,'.');
            %Trim period from beginning of line name
            Parent=Parent(2:end);
            %Initialize a flag to tell if the parent object is a switch
            DSSText.command = ['? Line.',Parent,'.switch'];
            switchFlag = DSSText.Result;

            if not(ismember(Parent, xfmrNames))
                %Check to see if the parent object is a switch. If it is, find the next upstream device. Could be expanded ino a
                %loop to look through multiple objects
            
                if switchFlag
                    %Update the Parent cell to be the parent of the fuse line
                    Parent = getLineInfo(DSSCircObj, {Parent});
                    Parent = Parent.parentObject;
                    %Trim "Line" from beginning of line name
                    [token, Parent]=strtok(Parent,'.');
                    %Trim period from beginning of line name
                    Parent=Parent(2:end);
                end
                %Check to see if the parent object is a fuse. Could be expanded to into
                %a loop to look through multiple objects
                if ismember(Parent,fuseNames{1,1})
                    %Update the Parent cell to be the parent of the fuse line
                    Parent = getLineInfo(DSSCircObj, {Parent});
                    Parent = Parent.parentObject;
                    %Trim "Line" from beginning of line name
                    [token, Parent]=strtok(Parent,'.');
                    %Trim period from beginning of line name
                    Parent=Parent(2:end);
                end
    
                %Get wire configuration data about the parent and child wires
                DSSText.command = ['? Line.', char(Parent) ,'.wires'];
                %Trim off the extra phases out of the DSSText.Result cell
                k = strfind(DSSText.Result, ' ');
                if not(isempty(k))
                    parentWireInfo = DSSText.Result(1:k(1));
                else
                    parentWireProxy = getLineInfo(DSSCircObj, {Parent});
                    parentWireInfo = parentWireProxy.lineCode;
                end

                DSSText.command = ['? Line.',Lines(i).name ,'.wires'];
                %Trim off the extra phases out of the DSSText.Result cell
                k = strfind(DSSText.Result, ' ');
                if not(isempty(k))
                    childWireInfo = DSSText.Result(1:k(1));
                else
                    childWireInfo = Lines(i).lineCode;
                end
            end
    
        %Check to make sure parent object is a line and not a xfmr
        if (ismember(Parent,xfmrNames)~=1);
            %Get information about parent line
            ParentInfo=getLineInfo(DSSCircObj,{Parent});
            %Check the difference betwen parent and child wire configuration
            if not(strcmp(parentWireInfo, childWireInfo))
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
                wireSizeChangeInfo{i}.parentLineCode = parentWireInfo;
                wireSizeChangeInfo{i}.parentCurrentRating = ParentInfo.lineRating;
                wireSizeChangeInfo{i}.parentName = ParentInfo.name;
                wireSizeChangeInfo{i}.parentSpacing = ParentInfo.spacing;
                %Store the name, current rating, geometry, and wire type of the
                %child object
            
                wireSizeChangeInfo{i}.childLineCode = childWireInfo;
                wireSizeChangeInfo{i}.childCurrentRating = Lines(i).lineRating;
                wireSizeChangeInfo{i}.childName = Lines(i).name;
                wireSizeChangeInfo{i}.childSpacing = Lines(i).spacing;

            end
        end
        end
end
    
%Trim the empty cells from the wireSizeChangeInfo array
emptyCells = cellfun(@(x) isempty(x), wireSizeChangeInfo);
wireSizeChangeInfo(emptyCells) = [];


%Plotting violation buses
%figure; Handles = plotCircuitLines(DSSCircObj,'Coloring', 'numPhases');
%Violation buses
%addBuses = [A]; 
%Get information for wire switched
%Buses = getBusInfo(DSSCircObj,addBuses,1);
%Manipulate bus coordinates to be plotted by MATLAB
%BusesCoords = reshape([Buses.coordinates],2,[])';
%Plots specific markers at violation bus locations
%busHandle = plot(repmat(BusesCoords(:,2)',2,1),repmat(BusesCoords(:,1)',2,1), 'ko','MarkerSize',4,'MarkerFaceColor','c','LineStyle','none','DisplayName','Bottleneck');  
%Adds a legend with respective bus names
%legend([Handles.legendHandles,busHandle'],[Handles.legendText, 'Border Buses'] )
