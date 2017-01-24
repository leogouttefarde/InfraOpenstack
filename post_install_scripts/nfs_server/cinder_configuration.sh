#!/bin/bash

# Replacing nfs_mount_point_base value by the one of Nova config
sed -i "s/^nfs_mount_point_base=.*/nfs_mount_point_base=\/var\/lib\/cinder\/nfs/" /etc/cinder/cinder.conf

sed -i "s/^nfs_mount_point_base=.*/nfs_mount_point_base=\/var\/lib\/cinder\/nfs/" /etc/nova/nova.conf

# Restart Cinder service
sudo service openstack-cinder-volume restart

# Restart Nova service
sudo service openstack-nova-compute restart
