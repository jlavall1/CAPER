originBus = [101,102,103]
destinationBus = [201,202,203]
loadTransfer = [75, 45, 10]

buses = originBus[:]
for i in destinationBus:
    if i not in buses:
        buses.append(i)

loads = {}

for bus in buses:
    loads[str(bus)] = {}
    loads[str(bus)]['transfer'] = 100.0
    loads[str(bus)]['original'] = {
        'P': 100, #psspy.busdt2(buses[bus],'MVA','NOM')[1].real,
        'Q': 200,  #psspy.busdt2(buses[bus],'MVA','NOM')[1].imag,
        'IP': 300,  #psspy.busdt2(buses[bus],'IL','NOM')[1].real,
        'IQ': 400,  #psspy.busdt2(buses[bus],'IL','NOM')[1].imag,
        'YP': 500,  #psspy.busdt2(buses[bus],'YL','NOM')[1].real,
        'YQ': 600  #psspy.busdt2(buses[bus],'YL','NOM')[1].imag
    }
    loads[str(bus)]['updated'] = {
        'P': 100,  #psspy.busdt2(buses[bus], 'MVA', 'NOM')[1].real,
        'Q': 200,  #psspy.busdt2(buses[bus], 'MVA', 'NOM')[1].imag,
        'IP': 300,  #psspy.busdt2(buses[bus], 'IL', 'NOM')[1].real,
        'IQ': 400,  #psspy.busdt2(buses[bus], 'IL', 'NOM')[1].imag,
        'YP': 500,  #psspy.busdt2(buses[bus], 'YL', 'NOM')[1].real,
        'YQ': 600  #psspy.busdt2(buses[bus], 'YL', 'NOM')[1].imag
    }

    #psspy.purgloads(bus)

flag = True

if len(originBus)  == len(destinationBus)  == len(loadTransfer):
    index = 0
    while index < len(originBus):
        for key,val in loads[str(destinationBus[index])]['updated'].items():
            loads[str(destinationBus[index])]['updated'][key] = val + (float(loadTransfer[index])/100)*loads[str(originBus[index])]['original'][key]
        for key,val in loads[str(originBus[index])]['updated'].items():
            loads[str(originBus[index])]['updated'][key] = val - (float(loadTransfer[index])/100)*loads[str(originBus[index])]['original'][key]
        loads[str(originBus[index])]['transfer'] -= float(loadTransfer[index])
        index += 1
else:
    print("\n\n\n\t\t***Error 1: vector lengths do not match***\n\n")
    flag = False

index = 0
while index < len(originBus):
    if loads[str(originBus[index])]['transfer'] < 0:
        print("\n\n\n\t\t***Error 2: more than 100% load swap***\n\n")
        flag = False
    index += 1

if flag:
    print("\n\n\n\n\n\n\t\tSuccess: load swaps completed\n\n\n\n\n")


index = 0
#or bus in loads:
 #   with loads[bus]['updated'] as chg:
  #      psspy.load_data_4(bus, r"""JS""", [_i, _i, _i, _i, _i, _i],[chg['P'], chg['Q'], chg['IP'], chg['IQ'], chg['YP'], chg['YQ']])
print("finished")