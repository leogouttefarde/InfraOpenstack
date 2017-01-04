#! /bin/bash

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
packstack --allinone
