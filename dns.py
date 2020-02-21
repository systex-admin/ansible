import json
import os
import sys
import re

def help():
        if 2 != len(sys.argv):
                print "Usage: python", sys.argv[0], " [User_Private_IPv4]"
                print
                print "[ERROR] Wrong number of arguments."
                print
                exit(1)
        return sys.argv[1]

def bash_catch_user_ext_ip(user_ipv4):
        tmsh_list_cmd_str = "tmsh list ltm nat NAT_" + user_ipv4 + " translation-address " + "| grep " + " translation-address " + "| cut -d\' \' -f 6"
        tmsh_log = os.popen(tmsh_list_cmd_str)
        user_ext_ipv4 = tmsh_log.read()
        if not "163.30" in user_ext_ipv4:
                print "[ERROR] Get User internat IP is failed"
                exit(1)
        return user_ext_ipv4

def write_file(user_ipv4, user_ext_ipv4):
        file_name = "dns_" + str(user_ipv4) + ".log"
        if os.path.isfile(file_name):
                print "[ERROR] File", file_name, "is exist"
                exit(1)
        else:
                f = open( file_name, 'w')
                f.write( user_ext_ipv4 )
                f.close()

def main():
        help()
        user_ipv4 = sys.argv[1]
        user_ext_ipv4 = bash_catch_user_ext_ip(user_ipv4).strip()
        write_file(user_ipv4, user_ext_ipv4)

if __name__ == '__main__':
        main()
        
        
