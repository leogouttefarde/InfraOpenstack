#! /bin/bash

# Handling the arguments of the script.
USE_SCREEN=0
while getopts ":hS" arg; do
    case "$arg" in
        h)
            echo "
./packstack-all_in_one.sh

List of options:
-h => prints the associated help;
-S => activate the in-a-screen-session provisioning option.

Provisions the designated host with OpenVSwitch.
"
            exit 0
            ;;
        S)
            USE_SCREEN=1
            ;;
        \?)
            echo "Unknown option: \"${OPTARG}\"."
            echo "Try ./packstack-all_in_one.sh -h."
            exit 1
            ;;
    esac
done

# Executing this script in a screen session, in order to prevent
# a network crash from crashing the update/install process.
if [[ $USE_SCREEN -eq 1 ]]; then
    if [ -z "$STY" ]; then 
        exec screen -dm -S provision /bin/bash "$0"; 
    fi
fi

# Defining the global parameters of the script.
LANGUAGE_ENVIRONMENT_FILE="/etc/environment"

# Appending the language environment settings.
echo "
# START OF PAIO CONFIG
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
# END OF PAIO CONFIG" >> "$LANGUAGE_ENVIRONMENT_FILE"

# Setting up network so as to allow connection from the outside.
systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network

# Downloading Packstack.
yum install -y centos-release-openstack-mitaka
yum update -y
yum install -y openstack-packstack
packstack --allinone --provision-demo=n --os-neutron-ovs-bridge-mappings=extnet:br-ex \
    --os-neutron-ml2-type-drivers=vlan,vxlan,flat --os-heat-install=y
