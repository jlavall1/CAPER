#   filename    : feederPlot.py
#   description : plot feeder in arcGIS
#   author      : Joshua M B Smith
#   date        : 10/28/2016
#   needs work  :

# preprocessors
import csv
import re
import arcpy

#   function    : parseCoordinatesCSV()
#   description : parse coordinates CSV into a dictionary whose keys are the node IDs
#                 each dictionary entry holds the CYME X/Y and geographic lat/long corresponding to that key
#   parameters  :
#   return      :
#   needs work  :
def parseCoordinatesCSV():
    nodes = {}

    fileLoc = 'bellhaven.csv'
    f = open(fileLoc, 'rb')
    reader = csv.reader(f)  # csv object

    next(reader, None)  # skip header
    for index, row in enumerate(reader):
        nodes[row[0]] = {}
        nodes[row[0]]['cymeX'] = row[1]
        nodes[row[0]]['cymeY'] = row[2]
        nodes[row[0]]['lat'] = row[3]
        nodes[row[0]]['long'] = row[4]
        print index

    f.close()

    return nodes

#   function    : parseLines
#   description :
#   parameters  :
#   return      :
#   needs work  :
def parseLines():
    lines = {}
    path = 'bellhaven.dss'
    #    fileLoc = ['Mocksville_Main_Circuit_Opendss/MOCKS_01/Elements/Lines.dss',
    #               'Mocksville_Main_Circuit_Opendss/MOCKS_02/Elements/Lines.dss',
    #               'Mocksville_Main_Circuit_Opendss/MOCKS_03/Elements/Lines.dss',
    #               'Mocksville_Main_Circuit_Opendss/MOCKS_04/Elements/Lines.dss']
    #  for path in fileLoc:
    f = open(path, 'rb')
    print path

    reader = csv.reader(f)  # csv object

    # compile improves efficiency of loop
    newLine = re.compile(r'New Line\.(\d+)', re.I|re.M)
    b1 = re.compile(r'Bus1\=(\d+)', re.I|re.M)
    b2 = re.compile(r'Bus2\=(\d+)', re.I|re.M)

    for index, row in enumerate(reader):
        lineID = re.search(newLine, row[0], flags=0)
        bus1 = re.search(b1, row[0], flags=0)
        bus2 = re.search(b2, row[0], flags=0)
        if (newLine is not None and bus1 is not None and bus2 is not None):
            lineID = lineID.group(1)
            lines[lineID] = {}
            lines[lineID]['bus1'] = bus1.group(1)
            lines[lineID]['bus2'] = bus2.group(1)
        else:
            print '*****Check around line %d for an entry error*****' % index
    print
    f.close()

    return lines

#   function    :
#   description :
#   parameters  :
#   return      :
#   needs work  :
def createLineFeatureClass(coords, lines):
    point = arcpy.Point()
    array = arcpy.Array()

    featureList = []
    #  arcpy.CreateFeatureclass_management(r"C:\Users\jms6\Documents\GitHub\CAPER\06_Joshua_Smith\gisPython\GIS", 'bellhavenLines.shp', 'POLYLINE')
    cursor = arcpy.InsertCursor(r"C:\Users\jms6\Documents\GitHub\CAPER\06_Joshua_Smith\gisPython\GIS\bellhavenLines.shp")

    feat = cursor.newRow()

    for newLine in lines:
        # set x and y for start and end points
        point.X = coords[lines[newLine]['bus1']]['long']
        point.Y = coords[lines[newLine]['bus1']]['lat']
        array.add(point)
        point.X = coords[lines[newLine]['bus2']]['long']
        point.Y = coords[lines[newLine]['bus2']]['lat']
        array.add(point)
        # create a polyline object based on the array of points
        polyline = arcpy.Polyline(array)
        # clear the array fro future use
        array.removeAll()
        # append to the list of Polyline objects
        featureList.append(polyline)
        # insert the feature
        feat.shape = polyline
        cursor.insertRow(feat)
    del feat
    del cursor
    return

coords = parseCoordinatesCSV()
lines = parseLines()
createLineFeatureClass(coords, lines)

print 'successful build'
