#!/bin/bash
#Team 1
#CIT 470 
#Members: David Geis, Clay Dempsey, Sean Hasenstab

#initiate help command
if [ "$1" == "-h" ]; then echo "Usage: `basename $0` [Install NFS Server. Script is invoked using the following command: ./install-nfs-server]" ; exit 0 ; fi

#move /home contents to /tmp/oldhome
mkdir /tmp/oldhome
mv /home/* /tmp/oldhome

#create /home partition
echo -e "n\np\n4\n\n+5G\nw" | fdisk /dev/sda
partprobe /dev/sda >> nfs-install.log
mkfs.xfs /dev/sda4 >> nfs-install.log
xfs_repair /dev/sda4 >> nfs-install.log

#add partition to fstab and mount it
echo "/dev/sda4	/home	xfs	defaults	0 0" >> /etc/fstab
mount /dev/sda4 >> nfs-install.log

#move /tmp/oldhome contents back to /home
mv /tmp/oldhome/* /home

#edit /etc/exports
echo "/home *.*.*.*(rw)" >> /etc/exports

#install nfs-utils
yum -y install nfs-utils >> nfs-install.log
exportfs -a >> nfs-install.log

#start services
systemctl start nfs >> nfs-install.log

#configure the firewall
firewall-cmd --zone=public --add-port=2049/tcp --permanent >> nfs-install.log
firewall-cmd --zone=public --add-port=111/tcp --permanent >> nfs-install.log
firewall-cmd --zone=public --add-port=20048/tcp --permanent >> nfs-install.log
firewall-cmd --zone=public --add-port=2049/udp --permanent >> nfs-install.log
firewall-cmd --zone=public --add-port=111/udp --permanent >> nfs-install.log
firewall-cmd --zone=public --add-port=20048/udp --permanent >> nfs-install.log
firewall-cmd --reload >> nfs-install.log
