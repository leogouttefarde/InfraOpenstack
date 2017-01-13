#!/bin/bash
# Flavors configuration


# Delete flavor m1.small first to customize it (id = 2)
openstack flavor delete 2

# Update flavor m1.small
openstack flavor create --public m1.small --id 2 --ram 1024 --disk 20 --vcpus 1 --rxtx-factor 1

# Create flavor m1.custom
openstack flavor create --public m1.custom --id 7 --ram 512 --disk 20 --vcpus 1 --rxtx-factor 1

