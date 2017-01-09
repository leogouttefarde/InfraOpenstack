#! /bin/bash

# Defining the global parameters of the script.
LANGUAGE_ENVIRONMENT_FILE="/etc/environment"

# Downloading Packstack.
yum install -y centos-release-openstack-mitaka
yum update -y
yum install -y openstack-packstack
