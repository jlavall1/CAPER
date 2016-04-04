%SVR_Tap_Pos_DSDR
SVR(1).ph{1,1}='VR1A';
SVR(1).ph{1,2}='VR1B';
SVR(1).ph{1,3}='VR1C';

SVR(2).ph{1,1}='VR2A';
SVR(2).ph{1,2}='VR2B';
SVR(2).ph{1,3}='VR2C';

SVR(3).ph{1,1}='VR3A';
SVR(3).ph{1,2}='0';
SVR(3).ph{1,3}='0';

SVR(4).ph{1,1}='0';
SVR(4).ph{1,2}='VR4B';
SVR(4).ph{1,3}='0';

for SVR_C=1:1:4
    for ph=1:1:3
        if strcmp(SVR(SVR_C).ph{1,ph},'0') ~= 1
            DSSText.command = sprintf('? Transformer.%s.Tap',SVR(SVR_C).ph{1,ph});
            SVR(SVR_C).TAP(t,ph) = str2double(DSSText.Result);
        end
    end
end
