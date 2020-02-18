import json
import sys

def help():

        if 2 != len(sys.argv):
                print "[INFO]This is the name of the script:", sys.argv[0]
                print "[INFO]Number of arguments: ", len(sys.argv)
                print "[INFO]The arguments are: ", str(sys.argv)
                print "----------\n"
                print "Usage: python", sys.argv[0], "[vlan_number]"
                print "Example: "
                print " python", sys.argv[0], "124"
                print
                print "[ERROR] Wrong number of arguments."
                print
                exit(0)
        return sys.argv[1]


data = []
vlan = 0

vlan = help()

f = open('nat_list.json')

data = json.load(f)

for i in range(len(data)):
        if (data[i]['vlan'] == vlan and \
                data[i]['vlan'] and \
                data[i]['seg'] and \
                data[i]['dnat_new']):
                print data[i]['vlan']
                print data[i]['seg']
                print data[i]['dnat_new']
