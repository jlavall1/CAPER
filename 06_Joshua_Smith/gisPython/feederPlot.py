#   filename    : feederPlot.py
#   description : plot feeder in arcGIS
#   author      : Joshua M B Smith
#   date        : 10/28/2016
#   needs work  :

# preprocessors
import csv
import re

#   function    : parseCoordinatesCSV()
#   description : parse coordinates CSV into a dictionary whose keys are the node IDs
#                 each dictionary entry holds the CYME X/Y and geographic lat/long corresponding to that key
#   parameters  :
#   return      :
#   needs work  :
def parseCoordinatesCSV():
    nodes = {}

    fileLoc  = 'circuitCoordinates.csv'
    f = open(fileLoc, 'rb')
    reader = csv.reader(f)  # csv object

    next(reader, None)  # skip header
    for row in reader:
        nodes[row[0]] = {}
        nodes[row[0]]['cymeX'] = row[1]
        nodes[row[0]]['cymeY'] = row[2]
        nodes[row[0]]['lat'] = row[3]
        nodes[row[0]]['long'] = row[4]

    f.close()

    return nodes

#   function    : parseLines
#   description :
#   parameters  :
#   return      :
#   needs work  :
def parseLines():
    lines = {}
    fileLoc = ['Mocksville_Main_Circuit_Opendss/MOCKS_01/Elements/Lines.dss',
               'Mocksville_Main_Circuit_Opendss/MOCKS_02/Elements/Lines.dss',
               'Mocksville_Main_Circuit_Opendss/MOCKS_03/Elements/Lines.dss',
               'Mocksville_Main_Circuit_Opendss/MOCKS_04/Elements/Lines.dss']
    for path in fileLoc:
        f = open(path, 'rb')

        reader = csv.reader(f)  # csv object

        # compile improves efficiency of loop
        newLine = re.compile(r'New Line\.(\d+)', re.I|re.M)
        b1 = re.compile(r'Bus1\=(\d+)', re.I|re.M)
        b2 = re.compile(r'Bus2\=(\d+)', re.I|re.M)


        for index, row in enumerate(reader):
            lineID = re.search(newLine, row[0], flags=0)
            bus1 = re.search(b1, row[0], flags=0)
            bus2 = re.search(b2, row[0], flags=0)
            if (lineID.group(1) and bus1.group(1) and bus2.group(1)):
                lines[lineID.group(1)] = {}
                lines[lineID.group(1)]['bus1'] = bus1.group(1)
                lines[lineID.group(1)]['bus2'] = bus2.group(1)
            else:
                print('\n\n*****\nCheck around line %i for an entry error\n*****\n', index)

        f.close()
        print path

    return 0

parseLines()