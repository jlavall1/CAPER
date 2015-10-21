function DER_Planning_GUI = DER_Planning_GUI(position)
%Purpose:   This .m file will prompt the user with what kind of simulation
%they would like to run.

    myGUI=[];
    %Create Figure:
    h.f = figure('units','pixels','position',position,...
                 'toolbar','none','menu','none');
    COLUMN_X = 10;
    COLUMN_Y = 800;
    SPACE = 160;
    string = 'What Computer are you on:';
    n = length(string)*20;
    %%
    %Checkbox for what computer they are on:
    h.ls = uicontrol('style','text','unit','pix','position',[COLUMN_X COLUMN_Y n 30],...
                    'min',0,'max',2,'fontsize',17,'string',string,...
                    'ForegroundColor','r');
    %Acutal Textboxes   LEFT,UP,Lenght,Width
    COLUMN_Y = COLUMN_Y - 30;
    %1]
    string = 'JML Home Desktop';
    n = length(string)*12;
    h.c(1) = uicontrol('style','checkbox','units','pixels','position',[COLUMN_X,COLUMN_Y,n,30],'string',string,'fontsize',14);
    COLUMN_X = COLUMN_X + n;    
    %2]
    string = 'Brian''s Computer';
    n = length(string)*12;
    h.c(2) = uicontrol('style','checkbox','units','pixels','position',[COLUMN_X,COLUMN_Y,n,30],'string',string,'fontsize',14);
    COLUMN_X = COLUMN_X + n;
    %3]
    string = 'JML Laptop  ';
    n = length(string)*12;
    h.c(3) = uicontrol('style','checkbox','units','pixels','position',[COLUMN_X,COLUMN_Y,n,30],'string',string,'fontsize',14);
    COLUMN_X = COLUMN_X + n;
    %4]
    string = 'Sean''s Computer';
    n = length(string)*12;
    h.c(4) = uicontrol('style','checkbox','units','pixels','position',[COLUMN_X,COLUMN_Y,n,30],'string',string,'fontsize',14);
    %Default Checkbox:
    set(h.c(1),'Value',1);
    %%
    %Create popup menu
    %%
    % Create OK/Cancel pushbutton   
    h.p = uicontrol('style','pushbutton','units','pixels',...
                    'position',[COLUMN_X,30,100,40],'string','ENTER',...
                    'callback',@p_call,'fontsize',14);
    %{
    h.p = uicontrol('style','pushbutton','units','pixels',...
                    'position',[370,20,100,40],'string','Close',...
                    'callback',@p_call2,'fontsize',14);
    h.p = uicontrol('style','pushbutton','units','pixels',...
                    'position',[40,20,150,40],'string','Plot Mho-Relay',...
                    'callback',@p_call3,'fontsize',14);
    %}
    %OKAY - Pushbutton callback
    %%
    %Ask user what circuit they would like to run?
    COL1 = 10;
    ROW1 = 700;
    ROW2 = ROW1 - 50;
    COL2 = COL1 + 255; % +410
    COL3 = COL2 + 255;
    

    %h.b(1) = uicontrol('style','pushbutton','string','DEC Circuits',...
    %                'position', [COL1,ROW1,200, 50],'callback','cla','BackgroundColor',[0 0 1]);
    
    %~~~~~~~~
    h.ls2 = uicontrol('style','text','unit','pix','position',[COL1 ROW1 200 50],...
                    'min',0,'max',2,'fontsize',16,'string','DEC Circuits',...
                    'BackgroundColor',[0 0 1]);
    h.p(1) = uicontrol('style','popup','units','pixels',...
                'position',[COL1,ROW2,200 50],'fontsize',16,'string',{'Bellhaven 12-04','Commonwealth 12-05','Flay 12-01'},...
                'callback',@setmap);
    h.c(5) = uicontrol('style','checkbox','units','pixels','position',[COL1+255-50,ROW1-25,19,19],'string','');
    %~~~~~~~~
    h.ls3 = uicontrol('style','text','unit','pix','position',[COL2 ROW1 200 50],...
                    'min',0,'max',2,'fontsize',16,'string','DEP Circuits',...
                    'BackgroundColor',[0.2 0.6 1]);
    h.p(2) = uicontrol('style','popup','units','pixels',...
                'position',[COL2,ROW2,200 50],'fontsize',16,'string',{'Roxboro 22.9kV','HollySprings','ERaleigh'},...
                'callback',@setmap);
    h.c(6) = uicontrol('style','checkbox','units','pixels','position',[COL1+255-50,ROW1-25,19,19],'string','');
    %~~~~~~~~
    h.ls4 = uicontrol('style','text','unit','pix','position',[COL3 ROW1 200 50],...
                    'min',0,'max',2,'fontsize',16,'string','EPRI / IEEE',...
                    'BackgroundColor',[0.2 1 1]);
    h.p(3) = uicontrol('style','popup','units','pixels',...
                'position',[COL3,ROW2,200 50],'fontsize',16,'string',{'ckt5','ckt7','ckt24','8,500 Node'},...
                'callback',@setmap);
    h.c(7) = uicontrol('style','checkbox','units','pixels','position',[COL1+255-50,ROW1-25,19,19],'string','');
    h.c(8) = uicontrol('style','checkbox','units','pixels','position',[COL2+255-50,ROW1-25,19,19],'string','');
    h.c(9) = uicontrol('style','checkbox','units','pixels','position',[COL3+255-50,ROW1-25,19,19],'string','');
    %%
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %Plot feeder when pushbutton 'Plot' is selected.
    %COL4 = (COL2+COL3)/2;
    h.ls5 = uicontrol('style','pushbutton','unit','pix','position',[COL3 ROW1-100 200 50],...
                    'fontsize',16,'backgroundcolor',[0 0.8 0.4],'string','Plot Feeder','callback',@p_feeder);
    
    
    
    
    %%
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %Now lets decide what openDSS scenerio you would want to run:
    ROW3 = ROW2 - 100;
    string = 'PV Hosting Capacity Run Scenerios using openDSS:';
    n = 300;
    h.ls5 = uicontrol('style','text','unit','pix','position',[COL1 ROW3 n 50],...
                    'min',0,'max',2,'fontsize',16,'string',string,...
                    'BackgroundColor',[1 0.6 0]);
    ROW = ROW3 - 50;
    string = '  TOP of acceptable Vband';
    n = length(string)*12;
    m = n;
    h.sim(1) = uicontrol('style','checkbox','units','pixels','position',[COL1,ROW,n,30],'string',string,'fontsize',14);
    
    ROW = ROW - 50;
    string = '  BOT of acceptable Vband';
    n = length(string)*12;
    h.sim(2) = uicontrol('style','checkbox','units','pixels','position',[COL1,ROW,m,30],'string',string,'fontsize',14);
    
    ROW = ROW - 50;
    string = '  Steady State, CAP = OFF';
    n = length(string)*12;
    h.sim(3) = uicontrol('style','checkbox','units','pixels','position',[COL1,ROW,m,30],'string',string,'fontsize',14);
    
    ROW = ROW - 50;
    string = '  PV up-ramping case';
    n = length(string)*12;
    h.sim(4) = uicontrol('style','checkbox','units','pixels','position',[COL1,ROW,m,30],'string',string,'fontsize',14);
    
    ROW = ROW - 50;
    string = '  PV down-ramping case';
    n = length(string)*12;
    h.sim(5) = uicontrol('style','checkbox','units','pixels','position',[COL1,ROW,m,30],'string',string,'fontsize',14);
    
    %Set Default checkbox:
    set(h.sim(3),'Value',1);
    
 
    
            
            
            
            
%%
    function setmap(source,callbackdata)
        val = source.Value;
        maps = source.String;
        % For R2014a and earlier: 
        % val = get(source,'Value');
        % maps = get(source,'String'); 

        newmap = maps{val};
        colormap(newmap);
    end
    
    
    
function m=p_call(varargin)
    vals = get(h.c,'Value');
    checked = find([vals{:}]);
    
     if isempty(checked)
        checked = 'none';
        fprintf('You did not select the settings for your test. Please use checkboxes to select your test and click Okay.');
     end
 
    [n m]=size(checked);                                                    %ex: size=[0 0] if empty; ex: size=[1 5]
    if m~=0
       for i=1:1:m
           %Which Computer?
           if checked(i) == 1
               comp_choice = 1;
               assignin('base', 'comp_choice', 1);
           elseif checked(i)==2
               comp_choice = 2;
               assignin('base', 'comp_choice', 2);
           elseif  checked(i)==3
               comp_choice = 3;
               assignin('base', 'comp_choice', 3);
           elseif  checked(i)==4
               comp_choice = 4;
               assignin('base', 'comp_choice', 4);
           end
       end
    end
    close(h.f);
end

function m=p_feeder(varargin)
    vals = get(h.sim,'Value');
    checked = find([vals{:}]);
    if isempty(checked)
        checked = 'none';
        fprintf('You did not select the settings for your test. Please use checkboxes to select your test and click Okay.');
    end
    [n m]=size(checked);                                                    %ex: size=[0 0] if empty; ex: size=[1 5]
    %Now lets see what the user selected:
    if m~=0
       for i=1:1:m
           %Which Computer?
           if checked(i) == 1
               ckt_choice = 1;
               assignin('base', 'ckt_choice', 1);
           elseif checked(i)==2
               ckt_choice = 2;
               assignin('base', 'ckt_choice', 2);
           elseif  checked(i)==3
               ckt_choice = 3;
               assignin('base', 'ckt_choice', 3);
           elseif  checked(i)==4
               ckt_choice = 4;
               assignin('base', 'ckt_choice', 4);
           end
       end
    end
end


end
