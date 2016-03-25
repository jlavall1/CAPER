Run_code = menu('user choice','construct','show PV and substations','CAPER substations','show bell service area');
while Run_code < 1
    Run_code = menu('user choice','construct','show PV and substations','CAPER substations','show bell service area');
end

if Run_code == 1
    lat_long_load_substations
    lat_long_load_substation_matches
elseif Run_code == 2
    %plotGoogleMaps example to show substation & PV
    %figure(1) & figure(2)
    ploting
elseif Run_code == 3
    assigned_substations
elseif Run_code == 4
    bellhaven_only
end