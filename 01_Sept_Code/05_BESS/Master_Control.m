%Beginning of Master Controller:
if t==6*3600/ss
    MSTR_STATE(t+1).F_CAP_OP = 1;
    MSTR_STATE(t+1).SC_OP_EN = 1;
else
    MSTR_STATE(t+1).F_CAP_OP = 0;
    MSTR_STATE(t+1).F_CAP_CL = 0;
    MSTR_STATE(t+1).SC_OP_EN = 0;
    MSTR_STATE(t+1).SC_CL_EN = 0;
end