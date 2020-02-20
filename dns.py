import json
import os
import sys
import re

def help():
        if 2 != len(sys.argv):
                print "[INFO]This is the name of the script:", sys.argv[0]
                print "[INFO]Number of arguments: ", len(sys.argv)
                print "[INFO]The arguments are: ", str(sys.argv)
                print "----------\n"
                print "Usage: python", sys.argv[0], " [Private_IPv4]"
                print "Example: "
                print " python ", sys.argv[0], "10.241.62.101"
                print
                print "[ERROR] Wrong number of arguments."
                print
                exit(1)
        return sys.argv[1]

def bash_catch_user_ext_ip(user_ipv4):
        tmsh_list_cmd_str = "tmsh list ltm nat NAT_" + user_ipv4 + " translation-address " + "| grep " + " translation-address " + "| cut -d\' \' -f 6"
        tmsh_log = os.popen(tmsh_list_cmd_str)
        user_ext_ip = tmsh_log.read()
        if not "163.30" in user_ext_ip:
                print "[ERROR] Get User internat IP is failed"
                exit(1)
        return user_ext_ip

def write_file(user_ipv4, user_ext_ipv4):
        f = open( "dns.log", 'w' )
        f.write( user_ipv4 + "-" + user_ext_ipv4 )
        f.close()

def main():
        help()
        user_ipv4 = sys.argv[1]
        user_ext_ipv4 = bash_catch_user_ext_ip(user_ipv4)
        write_file(user_ipv4, user_ext_ipv4)

if __name__ == '__main__':
        main()
