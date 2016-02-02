%Post_Process_Sraps

%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
%Sort in ascending order in respect to BUS VOLT:
VS_RESULTS = zeros(length(RESULTS(102:20001,1)),9);
[VS_RESULTS(:,2),I]=sort(RESULTS(102:20001,2),1,'descend');
for i=1:1:length(VS_RESULTS)
    for j=102:1:20001%length(RESULTS)
        if j==I(i,1) %if the index matches:
            VS_RESULTS(i,1)=RESULTS(j,1); %PV_KW
            VS_RESULTS(i,3)=RESULTS(j,2); %max_BusV
            VS_RESULTS(i,6)=RESULTS(j,6); %max_%thermal
            VS_RESULTS(i,9)=RESULTS(j,9); %
        end
    end
end
%}
%{
%This will sort by "tallest bus Vmax set"
maxsetV=zeros(200,2); %Vmax | Bus
j=1;
HOLD=1;
for i=1:1:length(VS_RESULTS)-1000
    %RESULTS(i,9)=HOLD;
    if j ~= 100 
        if RESULTS(i,2) > maxsetV(HOLD,1)
            maxsetV(HOLD,1)=RESULTS(i,2);
        end
        RESULTS(i,10)=HOLD;
        j = j + 1;
    elseif j == 100
        maxsetV(HOLD,2)=HOLD; %Hold bus index position;
        RESULTS(i,10)=HOLD;
        j = 1; %Go onto next BUS set
        HOLD=HOLD+1; %Go onto next maxV position
    end
    
end
%Now sort max(maxBUSVOLTAGES):
[maxset_sort(:,1),I]=sort(maxsetV(:,1),1,'descend');
k = 1; %counter for a set:
i = 1;
while i < length(VS_RESULTS)-1000 %end result:
    %Search through and obtain all hits of HOLD#
    for j=1:1:length(RESULTS)
        
        if RESULTS(j,10)==I(k,1) %if the index matches:
            VS_RESULTS(i,1)=RESULTS(j,1);
            VS_RESULTS(i,2)=RESULTS(j,2);
            VS_RESULTS(i,3)=RESULTS(j,3);
            VS_RESULTS(i,6)=RESULTS(j,6);
            VS_RESULTS(i,9)=RESULTS(j,9);
            VS_RESULTS(i,10)=RESULTS(j,10);
            i = i + 1; %should only hit 100 times
        end
    end
    k = k + 1; %move onto next I(k,1)
end
%}
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~