#! /bin/bash

#Installer nfs
yum install -y nfs-utils
systemctl enable nfs-server.service
systemctl start nfs-server.service

#Desactiver le firewall pour nfs
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --reload

#Créer la config pour exporter
mkdir /storage
echo "/storage         10.11.51.0/24(rw,sync,no_root_squash) " > /etc/exports

#Refresh NFS exports
exportfs -a
