DEP_Test_Circuits CYME model based on CYME 5.02 Rev 07


The DEP_Test_Circuits CYME database stores three Duke Energy Progress feeders.
	1. Ridge Road 23 kV Feeder, Roxboro 115 kV Substation (T5240B12)
		- Long rurual feeder.  Typical for solar farm connections.

	2. Wilmington Street 12 kV Feeder, Raleigh East Street 115 kV Substation (T5120B01)
		- Short dense feeder.  Typical for large commercial rooftop solar connections.

	3. Feltonsville 23 kV Feeder, Holly Springs 230 kV Substation (T4795B23) 
		- Largely underground residential/newer subdivision feeder.  Typical for residential rooftop solar connections.


DEP_Test_Circuits CYME model has been loaded with coincident peak feeder loads from July 02, 2014 between 1600-1700.


Feeder/line regulators are set to  forward and reverse BC = 125.0, forward and reverse BW = 1.5, 5% regulation, and bi-directional mode.


Typical Duke Energy Progress CYME Configuration Settings are in the CYME Configuration Settings folder.


Update Network Grouping in CYME Preferences for easier feeder/circuit navigation.
	1. Open CYME
	2. Click File --> Preferences...
	3. Click "Text" at the top of the Preferences Window
	4. Change Network Grouping to the following:
		Group 1:	Substation
		Group 2:	Ops Center
		Group 3:	Feeder

		Sort by:	Ops Center
		Then by:	Substation
		Then by:	Feeder