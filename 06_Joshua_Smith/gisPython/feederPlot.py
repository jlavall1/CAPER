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
#   needs work  : https://www.youtube.com/watch?v=UtPKjYOv2mg
def createLineFeatureClass():
    outworkspace = arcpy.en.workspace # geodb container
    arcpy.CreateFeatureclass_management(outworkspace, "TestLines","POLYLINE")
    arcpy.AddField_management("TestLines","LineID","SHORT")
    arcpy.AddField_management("TestLines","Name","TEXT","","", 16)
    list_coords =
    array = arcpy.Array()
    point_obj = arcpy.Point()
    for coords in list)coords:
        point_obj.X = coords[0]
        point_obj.Y = coords[1]
        array.add(point_obj)
    line_obj = arcpy.Polyline(array)
    line_obj.length
    edit_lines = arcpy.da.InsertCursor("TestLines",['Shape@','LineID','Name'])
    edit_lines.fields