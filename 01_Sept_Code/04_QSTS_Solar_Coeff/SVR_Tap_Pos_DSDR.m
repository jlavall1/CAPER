%SVR_Tap_Pos_DSDR
SVR(1).ph{1,1}='152J55__103161240A';
SVR(1).ph{1,2}='152J55__103161240B';
SVR(1).ph{1,3}='152J55__103161240C';

SVR(2).ph{1,1}='17FK87__104175233A';
SVR(2).ph{1,2}='0';%'17FK87__104175233B';
SVR(2).ph{1,3}='0';%'17FK87__104175233C';

SVR(3).ph{1,1}='18GJ19__105595290A';
SVR(3).ph{1,2}='0';
SVR(3).ph{1,3}='0';

SVR(4).ph{1,1}='0';
SVR(4).ph{1,2}='152B04__104329420B';
SVR(4).ph{1,3}='0';

SVR(5).ph{1,1}='E0X71__104175287A';
SVR(5).ph{1,2}='0';
SVR(5).ph{1,3}='0';

for SVR_C=1:1:5
    for ph=1:1:3
        if strcmp(SVR(SVR_C).ph{1,ph},'0') ~= 1
            DSSText.command = sprintf('? Transformer.%s.Tap',SVR(SVR_C).ph{1,ph});
            SVR(SVR_C).TAP(t,ph) = str2double(DSSText.Result);
        end
    end
end
