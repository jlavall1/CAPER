%Start of Chapter 4 Plotting Function:
clear
clc
close all
UIControl_FontSize_bak = get(0, 'DefaultUIControlFontSize');
set(0, 'DefaultUIControlFontSize', 18);
fig = 0;
base_dir = 'C:\Users\jlavall\Documents\GitHub\CAPER\01_Sept_Code\04_QSTS_Solar_Coeff\03_FLAY\Three_Month_Runs';
section=menu('What Section of Chapter 4 would you like to initiate?','Section 1 (Vreg control schemes)','Section 2 (Centralized Approach)','Section 3 (Intro of DER-PV)');
while section<1
    section=menu('What Section of Chapter 4 would you like to initiate?','Section 1 (Vreg control schemes)','Section 2 (Centralized Approach)','Section 3 (Intro of DER-PV)');
end
if section == 1
    run=menu('What run on FLAY?','1 YEAR','1 DAY');
    while run<1
        run=menu('What run on FLAY?','1 YEAR','1 DAY');
    end
    if run == 1
        Show_Annual_VREG %(2 Figures)
    elseif run == 2
        Show_VREG_DAY
    end
        
elseif section == 2
    %DSDR on ROX(FDR_04):
    fig = 0;
    run=menu('What run on ROX?','1 DAY','1 WEEK');
    while run<1
        run=menu('What run on ROX?','1 DAY','1 WEEK');
    end
    if run == 1
        DSDR_ON_ROX_1DAY
    elseif run == 2
        DSDR_ON_ROX
    end   
end
    
    
