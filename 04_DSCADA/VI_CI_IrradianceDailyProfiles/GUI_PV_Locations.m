function STRING_0 = GUI_PV_Locations()
    %Make font bigger!
    UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
    set(0, 'DefaultUIControlFontSize', 18);
    
    sim_type=menu('Import data from which source?','PV_kw with VI/CI','DEC NUG Solar Farms');
    while sim_type<1
        sim_type=menu('Import data from which source?','PV_kw with VI/CI','DEC NUG Solar Farms');
    end

    if sim_type == 1
        PV_Site=menu('Choose Site:','Shelby,NC (King''s Mtn','Murphy,NC (western tip)','Taylorsville,NC (middle of DEC)');
        while sim_type<1
            PV_Site=menu('Choose Site:','Shelby,NC (King''s Mtn','Murphy,NC (western tip)','Taylorsville,NC (middle of DEC)');
        end
        
        
        %Plot #:
        %1  :VI vs CI
        %2  :VI=1:1:20 Sampled Days
        %3  :1 & 2
        %4  :Irradiances
        %5  :NONE
        %6  :Correlation between daily VI & DARR
        %7  :Irradiance Changes vs. VI
        %8  :6 & 7
        
        %Opt out of beginning algorithms:
        Algo_num=menu('What stage do you want to run?','ALL','1)Data import','2)Solar Constants Calc','3)PV Ramping Analysis','4)CDF plots');
        while Algo_num<1
            Algo_num=menu('What stage do you want to run?','ALL','1)Data import','2)Solar Constants Calc','3)PV Ramping Analysis','4)CDF plots');
        end
        %Import only----
        if Algo_num == 2
            plot_type = 0;
        end
        
        %Solar Constants ----
        if Algo_num == 1 || Algo_num == 3
            plot_type=menu('Now what plots?','VI vs. CI','VI=1:1:20 Sampled Days','1&2','Irradiances','NONE','Correlation between daily VI & DARR','Irradiance Changes vs. VI','6 & 7');
            while plot_type<1
                plot_type=menu('Now what plots?','VI vs. CI','VI=1:1:20 Sampled Days','1&2','Irradiances','NONE','Correlation between daily VI & DARR','Irradiance Changes vs. VI','6 & 7');
            end
        end
        
        %PV Ramping ----
        if Algo_num == 1 || Algo_num == 4
            plot_type=menu('Now what plots?','Correlation between daily VI & DARR','Irradiance Changes vs. VI','1 & 2','  NONE  ');
            while plot_type<1
                plot_type=menu('Now what plots?','Correlation between daily VI & DARR','Irradiance Changes vs. VI','1 & 2','  NONE  ');
            end
        end
        
        %CDF generation ----
        if Algo_num == 5
            plot_type=menu('Now what plots?','NONE','1)Annual 1 site','BOTH 1 & 2','2)DARR Category comparison','(open)');
            while plot_type<1
                plot_type=menu('Now what plots?','NONE','Annual 1 site','Annual all sites','DARR Category comparison','(open)');
            end
        end
        %Conclusion:
        %1  :ALL
        %2  :Data Import
        %3  :Solar Constants Calc
        
    elseif sim_type == 2
        %Make them choose what Dataset they want:
        PV_Site=menu('Choose Site:','5.0MW - Mocksville Farm','3.5MW - Ararat Rock 3.5MW','1.5MW - Old Dominion','1.0MW - Mayberry Farm');
        while sim_type<1
            PV_Site=menu('Choose Site:','5.0MW - Mocksville Farm','3.5MW - Ararat Rock 3.5MW','1.5MW - Old Dominion','1.0MW - Mayberry Farm');
        end
        
        %Ask them what algorithm that they want to run??
        %Opt out of beginning algorithms:
        Algo_num=menu('What stage do you want to run?','ALL','1)Data import','2)Solar Constants Calc','3)PV Ramping Analysis','4)CDF plots');
        while Algo_num<1
            Algo_num=menu('What stage do you want to run?','ALL','1)Data import','2)Solar Constants Calc','3)PV Ramping Analysis','4)CDF plots');
        end
        
        %Import only----
        if Algo_num == 2 || Algo_num == 3
            plot_type = 0;
        end
        %PV Ramping ----
        if Algo_num == 1 || Algo_num == 4
            plot_type=menu('Now what plots?','Correlation between daily VI & DARR','Irradiance Changes vs. VI','1 & 2','   NONE   ');
            while plot_type<1
                plot_type=menu('Now what plots?','Correlation between daily VI & DARR','Irradiance Changes vs. VI','1 & 2','   NONE   ');
            end
        end
        %CDF generation ----
        if Algo_num == 5
            plot_type=menu('Now what plots?','NONE','1)Annual 1 site','BOTH 1 & 2','2)DARR Category comparison','(open)');
            while plot_type<1
                plot_type=menu('Now what plots?','NONE','Annual 1 site','Annual all sites','DARR Category comparison','(open)');
            end
        end
        
    end
    
    STRING_0(1,1) = sim_type;
    STRING_0(1,2) = PV_Site;
    STRING_0(1,3) = plot_type;
    STRING_0(1,4) = Algo_num;
end
    
