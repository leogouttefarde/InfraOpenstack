#! /bin/bash

# Handling the arguments of the script.
USE_SCREEN=0
while getopts ":hS" arg; do
    case "$arg" in
        h)
            echo "
./ovs.sh

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
            echo "Try ./ovs.sh -h."
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

# Updating software and installing dependencies.
echo -e "\n### Installation of OpenVSwitch ###\n"
echo -e "Updating software and installing required dependencies ...\n"
yum -y update
yum -y install \
    make \
    gcc \
    openssl-devel \
    autoconf \
    automake \
    rpm-build \
    redhat-rpm-config \
    python-devel \
    openssl-devel \
    kernel-devel \
    kernel-debug-devel \
    libtool \
    wget

# Building OpenVSwitch from its RPM.
# Creating, if necessary, the RPM build directory.
mkdir -p ~/rpmbuild/SOURCES && cd ~/rpmbuild/SOURCES

# Downloading and untaring the RPM.
echo -e "Downloading the OpenVSwitch RPM ...\n"
wget http://openvswitch.org/releases/openvswitch-2.5.1.tar.gz
tar xfz openvswitch-2.5.1.tar.gz

# Disabling the "kmod" (kernel mode) of OpenVSwitch.
# The resulting configuration is saved to a new file.
sed 's/openvswitch-kmod, //g' openvswitch-2.5.1/rhel/openvswitch.spec \
    > openvswitch-2.5.1/rhel/openvswitch_no_kmod.spec

# Compiling the RPM.
echo -e "Compiling the OpenVSwitch RPM ...\n"
rpmbuild -bb --nocheck openvswitch-2.5.1/rhel/openvswitch_no_kmod.spec

# Installing the RPM.
echo -e "Installing the OpenVSwitch RPM ...\n"
yum -y localinstall ~/rpmbuild/RPMS/x86_64/openvswitch-2.5.1-1.x86_64.rpm

# Starting the OpenVSwitch service and enabling it for the next boot.
systemctl start openvswitch.service
chkconfig openvswitch on
