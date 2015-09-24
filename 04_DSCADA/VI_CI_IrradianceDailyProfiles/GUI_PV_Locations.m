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
        Algo_num=menu('What stage do you want to run?','ALL','1)Data import','2)Solar Constants Calc','PV Ramping Analysis');
        while Algo_num<1
            Algo_num=menu('What stage do you want to run?','ALL','1)Data import','2)Solar Constants Calc','PV Ramping Analysis');
        end
        if Algo_num == 1 || Algo_num == 3
            plot_type=menu('Now what plots?','VI vs. CI','VI=1:1:20 Sampled Days','1&2','Irradiances','NONE','Correlation between daily VI & DARR','Irradiance Changes vs. VI','6 & 7');
            while plot_type<1
                plot_type=menu('Now what plots?','VI vs. CI','VI=1:1:20 Sampled Days','1&2','Irradiances','NONE','Correlation between daily VI & DARR','Irradiance Changes vs. VI','6 & 7');
            end
        end
        %1  :ALL
        %2  :Data Import
        %3  :Solar Constants Calc
        
    elseif sim_type == 2
        PV_Site=menu('Choose Site:','5.0MW - Mocksville Farm','3.5MW - Ararat Rock 3.5MW','1.5MW - Old Dominion','1.0MW - Mayberry Farm');
        while sim_type<1
            PV_Site=menu('Choose Site:','5.0MW - Mocksville Farm','3.5MW - Ararat Rock 3.5MW','1.5MW - Old Dominion','1.0MW - Mayberry Farm');
        end
    end
    
    STRING_0(1,1) = sim_type;
    STRING_0(1,2) = PV_Site;
    STRING_0(1,3) = plot_type;
    STRING_0(1,4) = Algo_num;
end
    
