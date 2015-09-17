%Setup the COM server
[DSSCircObj, DSSText, gridpvPath] = DSSStartup;

%Compile the circuit
DSSText.command = 'compile C:\Users\dotso_000\Documents\OpenDSS\HollySprings_Circuit_Opendss\Run_Master_Allocate.DSS';

%Setup a pointer fo the active circuit
DSSCircuit = DSSCircObj.ActiveCircuit;

%Bus Information
Buses = getBusInfo(DSSCircObj);

%Prepare all input curves for PV
DSSText.command = 'New XYCurve.MyPvsT npts=4 xarray=[0 25 75 100] yarray=[1.2 1.0 0.8 0.6]';
DSSText.command = 'New XYCurve.MyEff npts=4 xarray=[.1 .2 .4 1.0] yarray=[.86 .9 .93 .97]';
DSSText.command = 'New Loadshape.MyIrrad npts=24 interval=1 mult=[0 0 0 0 0 0 .1 .2 .3 .5 .8 .9 1.0 1.0 .99 .9 .7 .4 .1 0 0 0 0 0]';
DSSText.command = 'New Tshape.MyTemp npts=24 interval=1 temp=[25, 25, 25, 25, 25, 25, 25, 25, 35, 40, 45, 50 60 60 55 40 35 30 25 25 25 25 25 25]';

%Place PV on the bus*************************************************

%Selecting the bus
Active_Bus = Buses(48);

%Sizing the panel
Active_Bus_kw = 1;

%Prepare the DSS Command string
%DSS_Command = sprintf('new generator.%s_PV bus1=%s phases=%s kv=%s kw=%s pf=1 enabled=true',Active_Bus.name,Active_Bus.name,num2str(Active_Bus.numPhases),num2str(Active_Bus.kVBase),num2str(Active_Bus_kw));
DSS_Command = sprintf('New PVSystem.%s_PV phases=%s bus1=%s kV=%s kVA=500 irrad=0.8 Pmpp=500 temperature=25 PF=1 effcurve=MyEff P-TCurve=MyPvsT Daily=MyIrrad TDaily=MyTemp',Active_Bus.name,num2str(Active_Bus.numPhases),Active_Bus.name, num2str(Active_Bus.kVBase));


%Execute the command
DSSText.command = DSS_Command;

%Resolve the circuit
%DSSText.command = 'solve';