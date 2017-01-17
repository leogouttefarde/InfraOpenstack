#!/bin/bash


openstack network delete external_network

neutron net-create external-network --provider:network_type vlan \
        --provider:physical_network extnet \
        --router:external --provider:segmentation_id 3207 

neutron subnet-create external-network 10.11.51.192/26 \
        --name external-subnet \
        --enable_dhcp=False \
        --gateway 10.11.51.193 \
        --allocation-pool start=10.11.51.195,end=10.11.51.250

