#!/bin/bash
#Team 1
#CIT 470 
#Members: David Geis, Clay Dempsey, Sean Hasenstab

#Make a directory for scripts, logs, etc. and change to directory
mkdir server-setup
cd server-setup

#Download tarball and extract
wget https://github.com/rabbitstick/cir470/blob/master/a2.tar.bz2
tar xvf a2.tar.bz2

#Change permissions of scripts and run
chmod 744 install-nfs-server.bash install-ldap-server.bash
bash install-nfs-server.bash
bash install-ldap-server.bash
