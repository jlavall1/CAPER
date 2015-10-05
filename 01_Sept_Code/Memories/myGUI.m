function myGUI = myGUI(position)

myGUI=[];  

% Create figure
h.f = figure('units','pixels','position',position,...
             'toolbar','none','menu','none');         
         
% Create checkboxes:
%Type of Fault
h.ls = uicontrol('style','text','unit','pix','position',[5 410 150 29],...
                'min',0,'max',2,'fontsize',17,'string','Type of Fault:',...
                'ForegroundColor','r');
            
h.c(1) = uicontrol('style','checkbox','units','pixels',...
                'position',[10,378,100,25],'string','SLGF','fontsize',14);
h.c(2) = uicontrol('style','checkbox','units','pixels',...
                'position',[130,378,100,25],'string','LLGF','fontsize',14);
h.c(3) = uicontrol('style','checkbox','units','pixels',...
                'position',[250,378,100,25],'string','3phGF','fontsize',14);            
               
%Fault Location            
h.ls = uicontrol('style','text','unit','pix','position',[5 325 150 28],...
                'min',0,'max',2,'fontsize',17,'string','Fault Location:',...
                'ForegroundColor','r');            
             
h.c(4) = uicontrol('style','checkbox','units','pixels',...
                'position',[10,290,100,25],'string','300km','fontsize',14);
h.c(5) = uicontrol('style','checkbox','units','pixels',...
                'position',[130,290,100,25],'string','590km','fontsize',14);
h.c(6) = uicontrol('style','checkbox','units','pixels',...
                'position',[250,290,100,25],'string','600km','fontsize',14);            
         
%Wind Variation            
h.ls = uicontrol('style','text','unit','pix','position',[5 232 170 28],...
                'min',0,'max',2,'fontsize',17,'string','Wind Variation:',...
                'ForegroundColor','r');      
             
h.c(7) = uicontrol('style','checkbox','units','pixels',...
                'position',[10,195,120,25],'string','Average','fontsize',14);
h.c(8) = uicontrol('style','checkbox','units','pixels',...
                'position',[145,195,80,25],'string','MAX','fontsize',14);             
h.c(9) = uicontrol('style','checkbox','units','pixels',...
                'position',[240,195,80,25],'string','MIN','fontsize',14);
h.c(10) = uicontrol('style','checkbox','units','pixels',...
                'position',[330,195,90,25],'string','test','fontsize',14);             
             
            
%Capacitor Bypassed            
h.ls = uicontrol('style','text','unit','pix','position',[5 137 220 28],...
                'min',0,'max',2,'fontsize',17,'string','Capacitor Bypassed:',...
                'ForegroundColor','r');  

h.c(11) = uicontrol('style','checkbox','units','pixels',...
                'position',[10,102,100,25],'string','Yes','fontsize',14);
h.c(12) = uicontrol('style','checkbox','units','pixels',...
                'position',[120,102,100,25],'string','NO','fontsize',14);             
            
             
% Create OK/Cancel pushbutton   
h.p = uicontrol('style','pushbutton','units','pixels',...
                'position',[250,20,100,40],'string','OK',...
                'callback',@p_call,'fontsize',14);
h.p = uicontrol('style','pushbutton','units','pixels',...
                'position',[370,20,100,40],'string','Close',...
                'callback',@p_call2,'fontsize',14);
h.p = uicontrol('style','pushbutton','units','pixels',...
                'position',[40,20,150,40],'string','Plot Mho-Relay',...
                'callback',@p_call3,'fontsize',14);
            
h.p = uicontrol('style','pushbutton','units','pixels',...
                'position',[485,378,205,40],'string','Addaptive Mho Relay',...
                'callback',@p_call4,'fontsize',14);
            
%Addaptive Mho Relay            
h.ls = uicontrol('style','text','unit','pix','position',[485 340 100 22],...
                'min',0,'max',2,'fontsize',13,'string','Final Value',...
                'ForegroundColor','k');
h.ls = uicontrol('style','text','unit','pix','position',[520 310 65 22],...
                'min',0,'max',2,'fontsize',12,'string','Phase A:',...
                'ForegroundColor','k');
h.ls = uicontrol('style','text','unit','pix','position',[520 280 65 22],...
                'min',0,'max',2,'fontsize',12,'string','Phase B:',...
                'ForegroundColor','k');
h.ls = uicontrol('style','text','unit','pix','position',[520 250 65 22],...
                'min',0,'max',2,'fontsize',12,'string','Phase C:',...
                'ForegroundColor','k');            
    %Phase A:
    try
        Rcap=evalin('base','Rcap_phA');
        Vexists=1;
    catch
        Vexists=0;
    end
    if Vexists==1
        %Phase A
        Rcap=evalin('base','Rcap_phA');
        RcapMOVa=round(Rcap(end)*1000)/1000;
        Xcap=evalin('base','Xcap_phA');
        XcapMOVa=round(Xcap(end)*1000)/1000;
        ZcapMOVa=num2str(RcapMOVa+XcapMOVa*1i);
        
        %Phase B
        Rcap=evalin('base','Rcap_phB');
        RcapMOVb=round(Rcap(end)*1000)/1000;
        Xcap=evalin('base','Xcap_phB');
        XcapMOVb=round(Xcap(end)*1000)/1000;
        ZcapMOVb=num2str(RcapMOVb+XcapMOVb*1i);
        
        %Phase C
        Rcap=evalin('base','Rcap_phC');
        RcapMOVc=round(Rcap(end)*1000)/1000;
        Xcap=evalin('base','Xcap_phC');
        XcapMOVc=round(Xcap(end)*1000)/1000;
        ZcapMOVc=num2str(RcapMOVc+XcapMOVc*1i);        
    else
        ZcapMOVa=num2str(0.00+0.00*1i);
        ZcapMOVb=num2str(0.00+0.00*1i);
        ZcapMOVc=num2str(0.00+0.00*1i);
    end
    h.ed = uicontrol('style','edit','unit','pix','position',[590 310 170 24],...
                     'fontsize',13,'string',ZcapMOVa);    
    h.ed = uicontrol('style','edit','unit','pix','position',[590 280 170 24],...
                     'fontsize',13,'string',ZcapMOVb);
    h.ed = uicontrol('style','edit','unit','pix','position',[590 250 170 24],...
                     'fontsize',13,'string',ZcapMOVc);
                 
%Apparent Impedance
h.ls = uicontrol('style','text','unit','pix','position',[485 180 160 22],...
                'min',0,'max',2,'fontsize',13,'string','Apparent Impedance:',...
                'ForegroundColor','k');
            
h.ls = uicontrol('style','text','unit','pix','position',[530 150 55 22],...
                'min',0,'max',2,'fontsize',12,'string','Zapp:',...
                'ForegroundColor','k');   
    try
        R5=evalin('base','R5');
        Zexists=1;
    catch
        Zexists=0;
    end
    try
        Fault_Under300km=evalin('base','Fault_Under300km');
    catch
        Fault_Under300km=0;
    end
    if Zexists==1
        if Fault_Under300km==1
            R5=evalin('base','R5');
            Rapp5=round(R5(end)*1000)/1000;
            X5=evalin('base','X5');
            Xapp5=round(X5(end)*1000)/1000;
            Zapp=num2str(Rapp5+Xapp5*1i);
            disp(Fault_Under300km)
        else
            R6=evalin('base','R6');
            Rapp6=round(R6(end)*1000)/1000;
            X6=evalin('base','X6');
            Xapp6=round(X6(end)*1000)/1000;
            Zapp=num2str(Rapp6+Xapp6*1i);
            disp(Fault_Under300km)
        end
    else
        Zapp=num2str(0+0*1i);
    end
h.ed = uicontrol('style','edit','unit','pix','position',[590 150 170 24],...
                 'fontsize',13,'string',Zapp);
       
            
%OKAY - Pushbutton callback
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
           %Checking for Type of Fault
           if checked(i) == 1
               assignin('base', 'FaultType', 1);
           elseif checked(i)==2
               assignin('base', 'FaultType', 2);
           elseif  checked(i)==3
               assignin('base', 'FaultType', 3);
           
           %Checking for Fault Location
           elseif checked(i) == 4
               assignin('base', 'FaultLocation', 4);
           elseif checked(i)==5
               assignin('base', 'FaultLocation', 5);
           elseif  checked(i)==6
               assignin('base', 'FaultLocation', 6);        

           %Checking for WindVariation
           elseif checked(i) == 7
               assignin('base', 'WindVariation', 7);
           elseif checked(i)==8
               assignin('base', 'WindVariation', 8);
           elseif  checked(i)==9
               assignin('base', 'WindVariation', 9);
           elseif  checked(i)==10
               assignin('base', 'WindVariation', 10);
           
           %Checking for Capacitor Bypassed    
           elseif  checked(i)==11
               assignin('base', 'CapacitorBypass', 11);
           elseif  checked(i)==12
               assignin('base', 'CapacitorBypass', 12);
           end    
       end
    end
    close(h.f);
end


%CANCEL - Pushbutton callback
function p_call2(varargin)
    assignin('base', 'Cancelbutton', 1);
    close(h.f);
end


%Plot Mho-Relay - Pushbutton callback
function p_call3(varargin)
    %Re-select Mho-settings
    vals = get(h.c,'Value');
    checked = find([vals{:}]);
    
    [n m]=size(checked);         %ex: size=[0 0] if empty; ex: size=[1 5]
    if m~=0
       for i=1:1:m
           if checked(i) == 11                                              %Capcitor Bypassed "Yes checkbox"
               assignin('base', 'Capacitor_bypass', 0);
           elseif checked(i)==12                                            %Capacitor Bypassed "No checkbox"
               assignin('base', 'Capacitor_bypass', 1);
           end
           if checked(i)==4
               assignin('base', 'Fault_Under300km', 1);
           elseif checked(i)==5 || checked(i) ==6
               assignin('base', 'Fault_Under300km', 0);
           end
       end
    end
    R5=evalin('base','R5');
    X5=evalin('base','X5');
    R6=evalin('base','R6');
    X6=evalin('base','X6');
    Capacitor_bypass=evalin('base','Capacitor_bypass');
    Fault_Under300km=evalin('base','Fault_Under300km');
    %Call Function to plot
    Plot_ApparentImpedance(Capacitor_bypass,R5,X5,R6,X6,Fault_Under300km);
end

%Plot Zcap/MOV Impedance - Pushbutton callback
function p_call4(varargin)
    vals = get(h.c,'Value');
    checked = find([vals{:}]);
    [n m]=size(checked);         %ex: size=[0 0] if empty; ex: size=[1 5]
    if m~=0
       for i=1:1:m
           if checked(i)==4
               assignin('base', 'Fault_Under300km', 1);
           elseif checked(i)==5 || checked(i) ==6
               assignin('base', 'Fault_Under300km', 0);
           end
       end
    end    
    
    R5=evalin('base','R5');
    X5=evalin('base','X5');
    R6=evalin('base','R6');
    X6=evalin('base','X6');
    Fault_Under300km=evalin('base','Fault_Under300km');
    Plot_AddaptiveImpedance(R5,X5,R6,X6,Rcap,Xcap,Fault_Under300km);
end

uiwait(h.f);    
end
