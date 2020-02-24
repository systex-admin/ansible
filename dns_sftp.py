import os
import sys
import paramiko

def __help__():
        if 6 != len(sys.argv):
                print "Usage: python " + sys.argv[0] + " [host] [user] [password] [remote_path] [user_ext_ipv4]"
                print ""
                print "[ERROR] Wrong number of arguments."
                print ""
                exit(1)

def sftp_exec_command(host, user, password, command):
        try:
                ssh_client = paramiko.SSHClient()
                ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                ssh_client.connect(host, 22, user, password)
                std_in, std_out, std_err = ssh_client.exec_command(command)
                output = std_out.read().strip()
                ssh_client.close()
        except Exception, e:
                print e
        return output

def main():
        __help__()
        host = sys.argv[1]
        user = sys.argv[2]
        password = str(sys.argv[3])
        remote_path = sys.argv[4]
        user_ext_ipv4 = str(sys.argv[5])
        file_name = "dns_" + user_ext_ipv4 + ".log"
        remote_file = remote_path + file_name
        USER_INTERNAT_IP = sftp_exec_command(host, user, password, "cat " + remote_path + file_name)
        print USER_INTERNAT_IP

if __name__ == '__main__':
        main()

        
