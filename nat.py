import json
import os
import sys
import re

def help():
        if 4 != len(sys.argv):
                print "[INFO]This is the name of the script:", sys.argv[0]
                print "[INFO]Number of arguments: ", len(sys.argv)
                print "[INFO]The arguments are: ", str(sys.argv)
                print "----------\n"
                print "Usage: python", sys.argv[0], "[Vlan_Number]" "[Private_IPv4] [User_NAT_Mode <add|del|show>]"
                print "Example: "
                print " python ", sys.argv[0], "124 10.241.62.101 show"
                print " python ", sys.argv[0], "124 10.241.62.101 add"
                print " python ", sys.argv[0], "124 10.241.62.101 del"
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

def check_nat_data(data, vlan):
        for i in range(len(data)):
                if (data[i]['vlan'] == vlan and \
                        data[i]['vlan'] and \
                        data[i]['seg']  and \
                        data[i]['dnat_new']):
                        return True
        return False

def split_10_ip(ipAddr):
        addr=ipAddr.strip().split('.')
        if len(addr) != 4:
                print "[ERROR] Check ip address failed."
                exit(1)
        return addr

def split_163_30_ip(ipAddr, symbol):
        addr=ipAddr.strip().split(symbol)
        return addr

def bash_check_user_nat_list(user_ipv4):
        tmsh_list_cmd_str = "tmsh list ltm nat NAT_" + user_ipv4
        ##### DEMO #####
        #print tmsh_list_cmd_str
        #os.system(tmsh_list_cmd_str)
        tmsh_list_cmd = os.popen(tmsh_list_cmd_str)
        if tmsh_list_cmd.read():
                os.system(tmsh_list_cmd_str)

def bash_delete_user_nat_list(user_ipv4):
        tmsh_list_cmd_str = "tmsh delete ltm nat NAT_" + user_ipv4
        os.system(tmsh_list_cmd_str)
        #tmsh_list_cmd = os.popen(tmsh_list_cmd_str)


def bash_create_user_nat_list(user_ipv4, user_ext_ipv4):
        tmsh_list_cmd_str = "tmsh create ltm nat NAT_" + user_ipv4 + "originating-address " + user_ipv4 + "translation-address " + user_ext_ipv4
        os.system(tmsh_list_cmd_str)
        #tmsh_list_cmd = os.popen(tmsh_list_cmd_str)


def main():
        help()
        user_vlan = sys.argv[1]
        user_ipv4 = sys.argv[2]
        user_nat_mode = sys.argv[3]
        osp_range_pool_start = 101

        #if user_nat_mode != "add" and user_nat_mode != "del" and user_nat_mode != "show"
        #       print "[ERROR] User Mode failed."
        #       exit(1)

        if check_10_ip(user_ipv4) != True:
                print "[ERROR] User IPv4 failed."
                exit(1)

        addr = []
        addr = split_10_ip(user_ipv4)
        addr_and_netmask = str(addr[0]) + "." + str(addr[1]) + "." + str(addr[2]) + ".0"
        if int(addr[3]) < int(osp_range_pool_start):
                print "[ERROR] User IPv4 range pool failed."
                exit(1)
        addr_gap = int(addr[3]) - int(osp_range_pool_start)

        f = open('nat_list.json')
        data = []
        data = json.load(f)
        for i in range(len(data)):
                if (data[i]['vlan'] == user_vlan and \
                    data[i]['seg'] == addr_and_netmask and \
                    data[i]['dnat_new']):
                        range_pool_limit = 0
                        ext_range_start = 0
                        ext_range_end = 0
                        ext_list_addr1 = []
                        ext_list_addr2 = []
                        ext_list_addr1 = split_163_30_ip(str(data[i]['dnat_new']), '-')
                        ext_range_end = int(ext_list_addr1[1])
                        ext_list_addr2 = split_163_30_ip(str(ext_list_addr1[0]), '.')
                        ext_range_start = int(ext_list_addr2[3])
                        range_pool_limit = ext_range_end - ext_range_start
                        print "[INFO] User Vlan: ", data[i]['vlan']
                        print "[INFO] User Private IP: ", data[i]['seg']
                        print "[INFO] User Public IP: ", data[i]['dnat_new']
                        print "[INFO] User DNAT External Range Pool Number: ", range_pool_limit + 1
                        print "[INFO] External ", ext_list_addr2[0], ".", ext_list_addr2[1], ".", ext_list_addr2[2], " Range Pool: ", ext_range_start, " to ", ext_range_end
                        if addr_gap > range_pool_limit:
                                print "[ERROR] user private ip is over range."
                                exit(1)

                        user_ext_8bit_ipv4 = ext_range_start + addr_gap
                        user_ext_ipv4 = ext_list_addr2[0] + "." + ext_list_addr2[1] + "." + ext_list_addr2[2] + "." + str(user_ext_8bit_ipv4)
                        print user_ext_ipv4
                        if user_nat_mode == "show":
                                bash_check_user_nat_list(user_ipv4)
                        #elif user_nat_mode == "show_all":
                        #       bash_check_all_nat_list()
                        elif user_nat_mode == "add":
                                bash_create_user_nat_list(user_ipv4, user_ext_ipv4)
                        elif user_nat_mode == "del":
                                bash_delete_user_nat_list(user_ipv4)
                        else:
                                print "[ERROR] User Mode failed."
                                exit(1)


if __name__ == '__main__':
        main()
