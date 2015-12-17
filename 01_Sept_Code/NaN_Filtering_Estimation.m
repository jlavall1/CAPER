%4]With KVAR, check to see if there are any NaN:
    for ij=1:1:2
        j = 1;
        error_len= zeros(1,3);
        error_srt = 0;
        for ph=1:1:3
            for i=1:1:str2num(sim_num)
                if isnan(KVAR_ACTUAL.data(i,ph)) == 1
                    save(j,ph) = i;
                    if j ~= 1
                        if save(j-1,ph) == i-1
                            error_len(1,ph) = error_len(1,ph) + 1;
                            if error_srt == 0
                                error_srt = i-1;
                            end
                        end
                    end
                    j = j + 1;
                end
            end
            j = 1;
        end
        %fprintf('KVAR Error started: %d\n',error_srt);
        %   Linearize data gaps:
        if error_srt ~= 0
            for ph=1:1:3
                y1 = KVAR_ACTUAL.data(error_srt-1,ph);
                y2 = KVAR_ACTUAL.data(error_srt+error_len(1,ph)+1,ph);
                m = (y2-y1)/(error_len(1,ph)+1);
                for i=0:1:error_len(1,ph)
                    KVAR_ACTUAL.data(error_srt+i,ph) = KVAR_ACTUAL.data(error_srt+i-1,ph)+m;
                end
            end
        end
    end
    
%5]With KW, check to see if there are any NaN:
    for ij=1:1:2
        %Check twice for errors --
        j = 1;
        error_len= zeros(1,3);
        error_srt = 0;
        for ph=1:1:3
            for i=1:1:str2num(sim_num)
                if isnan(LOAD_ACTUAL(i,ph)) == 1
                    save(j,ph) = i;
                    if j ~= 1
                        if save(j-1,ph) == i-1
                            error_len(1,ph) = error_len(1,ph) + 1;
                            if error_srt == 0
                                error_srt = i-1;
                            end
                        end
                    end
                    j = j + 1;
                end
            end
            j = 1;
        end
        %disp(error_len)
        %fprintf('KW Error started: %d\n',error_srt);
        %   Linearize data gaps:
        if error_srt ~= 0
            for ph=1:1:3
                y1 = LOAD_ACTUAL(error_srt-1,ph);
                y2 = LOAD_ACTUAL(error_srt+error_len(1,ph)+1,ph);
                m = (y2-y1)/(error_len(1,ph)+1);
                for i=0:1:error_len(1,ph)
                    LOAD_ACTUAL(error_srt+i,ph) = LOAD_ACTUAL(error_srt+i-1,ph)+m;
                end
            end
        end
    end