import json
import os
import sys
import re

def help():
        if 5 != len(sys.argv):
                print "[INFO]This is the name of the script:", sys.argv[0]
                print "[INFO]Number of arguments: ", len(sys.argv)
                print "[INFO]The arguments are: ", str(sys.argv)
                print "----------\n"
                print "Usage: python", sys.argv[0], "[Vlan_Number]" "[Private_IPv4] [User_NAT_Mode <add|del|show>] [NAT_JSON_File_Name]"
                print "Example: "
                print " python ", sys.argv[0], "124 10.241.62.101 show nat_list.json"
                print " python ", sys.argv[0], "124 10.241.62.101 add nat_list.json"
                print " python ", sys.argv[0], "124 10.241.62.101 del nat_list.json"
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

def split_10_ip(ipAddr):
        addr=ipAddr.strip().split('.')
        if len(addr) != 4:
                print "[ERROR] Check ip address failed."
                exit(1)
        return addr

def split_163_30_ip(ipAddr, symbol):
        addr=ipAddr.strip().split(symbol)
        return addr

def bash_check_user_nat_list(header_name, private_ip):
        tmsh_list_cmd_str = "tmsh list ltm nat " + header_name + private_ip + " 2>&1"
        tmsh_list_cmd = os.popen(tmsh_list_cmd_str)
        tmsh_log = tmsh_list_cmd.read()
        print tmsh_log
        if "was not found" in tmsh_log:
                exit(1)

def bash_delete_user_nat_list(header_name, private_ip):
        tmsh_list_cmd_str = "tmsh delete ltm nat " + header_name + private_ip + " 2>&1"
        tmsh_list_cmd = os.popen(tmsh_list_cmd_str)
        tmsh_log = tmsh_list_cmd.read()
        print tmsh_log
        if "was not found" in tmsh_log:
                exit(1)

def bash_create_user_nat_list(header_name, private_ip, user_ext_ipv4):
        tmsh_list_cmd_str = "tmsh create ltm nat " + header_name + private_ip + " originating-address " + private_ip + " translation-address " + user_ext_ipv4 + " 2>&1"
        tmsh_list_cmd = os.popen(tmsh_list_cmd_str)
        tmsh_log = tmsh_list_cmd.read()
        print tmsh_log
        if "already exists in partition Common" in tmsh_log:
                exit(1)


def main():
        help()
        vlan = sys.argv[1]
        private_ip = sys.argv[2]
        op_mode = sys.argv[3]
        json_file = sys.argv[4]
        header_private_ip = 101
        header_name = "nat_"

        if check_10_ip(private_ip) != True:
                print "[ERROR] User IPv4 failed."
                exit(1)

        private_ip_array = []
        private_ip_array = split_10_ip(private_ip)
        private_seg = str(private_ip_array[0]) + "." + str(private_ip_array[1]) + "." + str(private_ip_array[2]) + ".0"
        if int(private_ip_array[3]) < int(header_private_ip):
                print "[ERROR] private ip failed."
                exit(1)

        addr_gap = int(private_ip_array[3]) - int(header_private_ip)

        f = open(json_file)
        data = []
        data = json.load(f)

        ext_range_pool = 0
        ext_range_start = 0
        ext_range_end = 0
        ext_split1 = []
        ext_split2 = []
        for i in range(len(data)):
                if (data[i]['vlan'] == vlan and \
                    data[i]['seg'] == private_seg and \
                    data[i]['dnat_new']):
                        ext_split1 = split_163_30_ip(str(data[i]['dnat_new']), '-')
                        ext_split2 = split_163_30_ip(str(ext_split1[0]), '.')
                        ext_range_start = int(ext_split2[3])
                        ext_range_end = int(ext_split1[1])
                        ext_range_pool = ext_range_end - ext_range_start

                        ext_and_netmask= str(ext_split2[0]) + "." + str(ext_split2[1]) + "." + str(ext_split2[2])
                        if addr_gap > ext_range_pool:
                                print "[ERROR] Floating IP out of range."
                                exit(1)

                        user_ext_8bit_ipv4 = ext_range_start + addr_gap
                        user_ext_ipv4 = str(ext_and_netmask) + "." + str(user_ext_8bit_ipv4)
                        print "[INFO] User Vlan: ", data[i]['vlan']
                        print "[INFO] User Private IP: ", private_ip
                        print "[INFO] User Public IP: ", user_ext_ipv4
                        print "[INFO] User DNAT External Range Pool: ", ext_range_pool + 1
                        print "[INFO] External ", ext_and_netmask, " Range Pool: ", ext_range_start, " to ", ext_range_end

                        if op_mode == "show":
                                bash_check_user_nat_list(header_name, private_ip)
                        elif op_mode == "add":
                                bash_create_user_nat_list(header_name, private_ip, user_ext_ipv4)
                        elif op_mode == "del":
                                bash_delete_user_nat_list(header_name, private_ip)
                        else:
                                print "[ERROR] User Mode failed."
                                exit(1)


if __name__ == '__main__':
        main()

