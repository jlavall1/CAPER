main_sub = zeros(4,8);
main_sub(1:4,1) = [1;2;3;4];
main_sub(1:4,2) = [1;2;3;7];
SUB_NUM = [31,111,219,430];
%hit = 1;
for hit = 1:1:4
    for i = 1:length(res_conn)
        if res_conn(i).SUBSTATION == SUB_NUM(hit)
            main_sub(hit,3) = main_sub(hit,3) + res_conn(i).KW; 
        end
    end
    for i = 1:length(comm_conn)
        if comm_conn(i).SUBSTATION == SUB_NUM(hit)
            main_sub(hit,4) = main_sub(hit,4) + comm_conn(i).KW; 
        end
    end
    for i = 1:length(utility_conn)
        if utility_conn(i).SUBSTATION == SUB_NUM(hit)
            main_sub(hit,5) = main_sub(hit,5) + utility_conn(i).KW; 
        end
    end
    for i = 1:length(res_pend)
        if res_pend(i).SUBSTATION == SUB_NUM(hit)
            main_sub(hit,6) = main_sub(hit,6) + res_pend(i).KW; 
        end
    end
    for i = 1:length(comm_pend)
        if comm_pend(i).SUBSTATION == SUB_NUM(hit)
            main_sub(hit,7) = main_sub(hit,7) + comm_pend(i).KW; 
        end
    end
    for i = 1:length(utility_pend)
        if utility_pend(i).SUBSTATION == SUB_NUM(hit)
            main_sub(hit,8) = main_sub(hit,8) + utility_pend(i).KW; 
        end
    end
end
