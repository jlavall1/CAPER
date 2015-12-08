function [ LOAD_ACTUAL,KVAR_ACTUAL ] = Pull_DSCADA(DOY,FEEDER,t_int,sim_num)
    %1] Select data for 24hour period --
    LOAD_ACTUAL_1(:,1) = FEEDER.kW.A(time2int(DOY,0,0):time2int(DOY,23,59),1);
    LOAD_ACTUAL_1(:,2) = FEEDER.kW.B(time2int(DOY,0,0):time2int(DOY,23,59),1);
    LOAD_ACTUAL_1(:,3) = FEEDER.kW.C(time2int(DOY,0,0):time2int(DOY,23,59),1);
    KVAR_ACTUAL_1(:,1) = FEEDER.kVAR.A(time2int(DOY,0,0):time2int(DOY,23,59),1);
    KVAR_ACTUAL_1(:,2) = FEEDER.kVAR.B(time2int(DOY,0,0):time2int(DOY,23,59),1);
    KVAR_ACTUAL_1(:,3) = FEEDER.kVAR.C(time2int(DOY,0,0):time2int(DOY,23,59),1);
    %3]Re-size original 1min data accordingly:
    if t_int ~= 0
        LOAD_ACTUAL(:,1) = interp(LOAD_ACTUAL_1(:,1),t_int);
        LOAD_ACTUAL(:,2) = interp(LOAD_ACTUAL_1(:,2),t_int);
        LOAD_ACTUAL(:,3) = interp(LOAD_ACTUAL_1(:,3),t_int);
        KVAR_ACTUAL.data(:,1) = interp(KVAR_ACTUAL_1(:,1),t_int);
        KVAR_ACTUAL.data(:,2) = interp(KVAR_ACTUAL_1(:,2),t_int);
        KVAR_ACTUAL.data(:,3) = interp(KVAR_ACTUAL_1(:,3),t_int);
    else
        jj=1;
        for ii=1:60:length(LOAD_ACTUAL_1)
            LOAD_ACTUAL(jj,1) = LOAD_ACTUAL_1(ii,1);
            LOAD_ACTUAL(jj,2) = LOAD_ACTUAL_1(ii,2);
            LOAD_ACTUAL(jj,3) = LOAD_ACTUAL_1(ii,3);
            KVAR_ACTUAL.data(jj,1) = KVAR_ACTUAL_1(ii,1);
            KVAR_ACTUAL.data(jj,2) = KVAR_ACTUAL_1(ii,2);
            KVAR_ACTUAL.data(jj,3) = KVAR_ACTUAL_1(ii,3);
            jj = jj + 1;
        end
    end
    %4]Check to see if there are any NaN:
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
    %disp(error_len)
    fprintf('Error started: %d\n',error_srt);
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
    %Check to see if the polarity is correct:
    for i=1:1:str2num(sim_num)
        avg_LL(1,1)=(KVAR_ACTUAL.data(i,1)-KVAR_ACTUAL.data(i,2))/2; %AB
        avg_LL(1,2)=(KVAR_ACTUAL.data(i,2)-KVAR_ACTUAL.data(i,3))/2; %BC
        avg_LL(1,3)=(KVAR_ACTUAL.data(i,3)-KVAR_ACTUAL.data(i,1))/2; %CA
    end
    
end

