function STRING_0 = GUI_PV_Locations()
    %Make font bigger!
    UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
    set(0, 'DefaultUIControlFontSize', 18);
    
    sim_type=menu('Import data from which source?','PV_kw with VI/CI','DEC NUG Solar Farms');
    while sim_type<1
        sim_type=menu('Import data from which source?','PV_kw with VI/CI','DEC NUG Solar Farms');
    end

    if sim_type == 1
        PV_Site=menu('Choose Site:','Shelby,NC (King''s Mtn','Murphy,NC (western tip)');
        while sim_type<1
            PV_Site=menu('Choose Site:','Shelby,NC (King''s Mtn','Murphy,NC (western tip)');
        end
        
        plot_type=menu('Now what plots?','VI vs. CI','VI=1:1:20 Sampled Days','1&2','Irradiances','NONE');
        while plot_type<1
            plot_type=menu('Now what plots?','VI vs. CI','VI=1:1:20 Sampled Days','1&2','Irradiances','NONE');
        end
        
    elseif sim_type == 2
        PV_Site=menu('Choose Site:','5.0MW - Mocksville Farm','3.5MW - Ararat Rock 3.5MW','1.5MW - Old Dominion','1.0MW - Mayberry Farm');
        while sim_type<1
            PV_Site=menu('Choose Site:','5.0MW - Mocksville Farm','3.5MW - Ararat Rock 3.5MW','1.5MW - Old Dominion','1.0MW - Mayberry Farm');
        end
    end
    
    STRING_0(1,1) = sim_type;
    STRING_0(1,2) = PV_Site;
    STRING_0(1,3) = plot_type;
end
    
