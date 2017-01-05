#! /bin/bash

# This script fails if any command does.
set -eo pipefail

# Defining global parameters.
MANAGEMENT_DIR=$(cd $(dirname $0) && pwd)
NETWORK_CONFIG_DIR="/etc/sysconfig/network-scripts"
ENO_1_CONFIG="${NETWORK_CONFIG_DIR}/ifcfg-eno1"
BR_EX_CONFIG="${NETWORK_CONFIG_DIR}/ifcfg-br-ex"
BASE_IP=10.11.51
BASE_HOST=160
NETMASK=255.255.255.192
GATEWAY=10.11.51.129
DNS1=10.3.156.23
DNS2=10.3.156.12

# Handling the arguments.
TARGET=0
while getopts ":hn:" arg; do
    case "$arg" in
        h)
            echo "
./set_brex.sh

List of options:
-h      => prints the associated help;
-n id   => specifies the ID of the targeted server.

Creates the OpenVSwitch interface required by OpenStack on the
targeted server.

As a consequence, it is within the range 1 <= ID <= 14 (\"1\" 
corresponding to \"c31\" and \"14\" to \"c44\").
"
            exit 0
            ;;
        n)
            if [[ "$OPTARG" -le 0 || "$OPTARG" -ge 15 ]]; then
                echo "The ID must be within [[1 ; 14]]."
                echo "Try ./connect.sh -h."
                exit 1
            fi
            TARGET="$OPTARG"
            ;;
        :)
            echo "The option \"${arg}\" needs an argument."
            echo "Try ./connect.sh -h."
            exit 1
            ;;
        \?)
            echo "Unknown option: \"${OPTARG}\"."
            echo "Try ./connect.sh -h."
            exit 1
            ;;
    esac
done

# Verifying that the ID of the targeted server has been set.
if [[ "$TARGET" -eq 0 ]]; then
    echo "The ID of the targeted server must be set."
    echo "Try \"./set_brex.sh -h\"."
    exit 1
fi
# Computing the IP address of the remote server (useful for the
# configuration files of the network interfaces.
let "ip_addr = BASE_HOST + TARGET"
ip_addr="${BASE_IP}.${ip_addr}"

# Sending the associated commands over SSH.
echo "
Creating and configuring the OpenVSwitch required by OpenStack.

Since it requires to restart the network interfaces, you shall
be disconnected from the remote host at the end of the execution
of this script.

Thus, if a message related to such a disconnection occurs, please
ignore it.
"

cd "${MANAGEMENT_DIR}/../connection"

echo -e "\nCreating the network configuration associated with \
the use of a OpenVSwitch ...\n"

# The following command is UGLY AS F**K (sending all the commands
# to execute in one giant string). 
# However, since we are tuning network configuration over a SSH 
# connection, it is one of the simpliest and lightest to do so.
./connect.sh -n "$TARGET" -c \
"ovs-vsctl add-br br-ex && \
ovs-vsctl add-port br-ex eno1 && \
echo \"DEVICE=br-ex
DEVICETYPE=ovs
TYPE=OVSBridge
BOOTPROTO=static
IPADDR=${ip_addr}
NETMASK=${NETMASK}
GATEWAY=${GATEWAY}
DNS1=${DNS1}
DNS2=${DNS2}
ONBOOT=yes\" > ${BR_EX_CONFIG} && \
echo \"DEVICE=eno1
TYPE=OVSPort
DEVICETYPE=ovs
OVS_BRIDGE=br-ex
ONBOOT=yes\" > ${ENO_1_CONFIG} && \
systemctl restart network"
