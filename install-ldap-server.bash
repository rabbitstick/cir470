#!/bin/bash
#Team 1
#CIT 470 
#Members: David Geis, Clay Dempsey, Sean Hasenstab

#Initiate help command option for ./install-ldap-server
if [ "$1" == "-h" ]; then echo "Usage: `basename $0` [Install LDAP Server. Script is invoked using the following command: ./install-ldap-server]" ; exit 0 ; fi
#Yum installs required
yum -y install openldap-servers openldap-clients >> ldap-server.log
#Wget needed database files for ldap from a hosted apache server.
wget -O /etc/openldap/db.ldif 10.2.7.10/db.ldif >> ldap-server.log
wget -O /etc/openldap/base.ldif 10.2.7.10/base.ldif >> ldap-server.log
#Set hashed password for Root
hash=$(slappasswd -s CIT470 -n) >> ldap-server.log
sed -i "s/olcRootPW:/olcRootPW: $hash/g" /etc/openldap/db.ldif >> ldap-server.log
#Enable slapd and start it
systemctl enable slapd.service && systemctl start slapd >> ldap-server.log
#Set firewall rules
firewall-cmd --zone=public --add-port=389/tcp --permanent >> ldap-server.log
firewall-cmd --zone=public --add-port=636/tcp --permanent >> ldap-server.log
firewall-cmd --reload >> ldap-server.log
#Add required LDAP Schemas
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/core.ldif >> ldap-server.log
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif >> ldap-server.log
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif >> ldap-server.log
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif >> ldap-server.log
#Import the domains information to olcDatabase{2} using ldapmodify for no CRC errors
ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /etc/openldap/db.ldif >> ldap-server.log
ldapadd -x -w CIT470 -D cn=Manager,dc=cit470,dc=nku,dc=edu -H ldap:/// -f /etc/openldap/base.ldif >> ldap-server.log
#Restart slapd.service to enfore the changes
systemctl restart slapd >> ldap-server.log
#Get diradm
wget --directory-prefix=/usr/local/ http://www.hits.at/diradm/diradm-1.3.tar.gz >> ldap-server.log
#Unzip diradm directory
tar zxvf /usr/local/diradm-1.3.tar.gz -C /usr/local/ >> ldap-server.log
#Create the diradm.conf file using printf
printf "# Begin /etc/diradm.conf\n# LDAP specific options\n# ---------------------\nLDAPURI="ldap://10.2.7.10:389/"\nBINDDN="cn=Manager,dc=cit470,dc=nku,dc=edu"\n# Be extremely careful with read rights\n# of this file if you set this value!!!\n# BINDPASS="secret"\nUSERBASE="ou=People,dc=cit470,dc=nku,dc=edu"\nGROUPBASE="ou=Group,dc=cit470,dc=nku,dc=edu"\n# Options for user accounts\n# ---------------------------------\nUIDNUMBERMIN="1000"\nUIDNUMBERMAX="60000"\nUSERGROUPS="yes"\nHOMEBASE="/home"\nHOMEPERM="0750"/nSKEL="/etc/skel"\nDEFAULT_GIDNUMBER="100"\nDEFAULT_LOGINSHELL="/bin/bash"\nDEFAULT_SHADOWINACTIVE="7"\nDEFAULT_SHADOWEXPIRE="-1"\nSHADOWMIN="0"\nSHADOWMAX="99999"\nSHADOWWARNING="7"\nSHADOWFLAG="0"\n# Options for group accounts\n# ----------------------------------\nGIDNUMBERMIN="1000"\nGIDNUMBERMAX="60000"\n# End /etc/diradm.conf" >> diradm.conf
#Move and overwrite  diradm.conf with the one created
mv -f diradm.conf /usr/local/diradm-1.3/ >> ldap-server.log
