import json
import sys
import re

def help_nat():
        if 3 != len(sys.argv):
                print "[INFO]This is the name of the script:", sys.argv[0]
                print "[INFO]Number of arguments: ", len(sys.argv)
                print "[INFO]The arguments are: ", str(sys.argv)
                print "----------\n"
                print "Usage: python", sys.argv[0], "[Vlan_Number]" "[Private_IPv4]"
                print "Example: "
                print " python", sys.argv[0], "124" "10.241.62.101"
                print
                print "[ERROR] Wrong number of arguments."
                print
                exit(1)
        return sys.argv[1]

def check_10_ip(ipAddr):
        compile_ip=re.compile("^(10)\.(24[0-1])\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)$")
        if compile_ip.match(ipAddr):
                return True
        else:
                return False



help_nat()
vlan = sys.argv[1]
ipv4 = sys.argv[2]
if check_10_ip(ipv4) != True:
        print "[ERROR] IPv4 is not private IP."
        exit(1)

f = open('nat_list.json')
data = []
data = json.load(f)
for i in range(len(data)):
        if (data[i]['vlan'] == vlan and \
                data[i]['vlan'] and \
                data[i]['seg'] and \
                data[i]['dnat_new']):
                print data[i]['vlan']
                print data[i]['seg']
                print data[i]['dnat_new']
