#!/bin/bash
#Team 1
#CIT 470 
#Members: David Geis, Clay Dempsey, Sean Hasenstab

#Initiate help command option for ./install-ldap-server
if [ "$1" == "-h" ]; then echo "Usage: `basename $0` [Install LDAP Server. Script is invoked using the following command: ./install-ldap-server]" ; exit 0 ; fi
#Yum installs required
yum -y install openldap-servers openldap-clients >> ldap-server.log
# Backing up the config file
cp /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif.backup >> ldap-server.log
#Configuring LDAP server
sed -i '/olcSuffix: dc=my-domain,dc=com/c\olcSuffix: dc=cit470,dc=nku,dc=edu' /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif >> ldap-server.log
sed -i '/olcRootDN: cn=Manager,dc=my-domain,dc=com/c\olcRootDN: cn=Manager,dc=cit470,dc=nku,dc=edu' /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif >> ldap-server.log
#Configuring the root password for LDAP
echo "olcRootPW: Lemontree2020" >> /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif
#Enable slapd and start it
systemctl enable slapd.service && systemctl start slapd >> ldap-server.log
systemctl enable slapd
#Set firewall rules
systemctl start firewalld.service
firewall-cmd --zone=public --add-port=389/tcp --permanent
firewall-cmd --zone=public --add-port=389/udp --permanent
firewall-cmd --zone=public --add-service=ldap --permanent
firewall-cmd --zone=public --add-port=636/tcp --permanent
firewall-cmd --zone=public --add-port=636/udp --permanent
firewall-cmd --reload
#Deleting The Old LDAP Database
	#rm -R /var/lib/ldap/*
	#Creating DB_CONFIG file
		cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
	chown -R ldap:ldap /var/lib/ldap
	yum install nss_ldap -y >> logfile
	#Installing the  migration tools
		yum install migrationtools -y >> logfile
		#Taking the backup of migration file
		cp /usr/share/migrationtools/migrate_common.ph /usr/share/migrationtools/migrate_common.ph.backup
		#Editing migrate_common.ph file
	sed -i '/$DEFAULT_MAIL_DOMAIN = "padl.com";/c\$DEFAULT_MAIL_DOMAIN = "$HOSTNAME.hh.nku.edu";' /usr/share/migrationtools/migrate_common.ph >> logfile
	sed -i '/$DEFAULT_BASE = "dc=padl,dc=com";/c\$DEFAULT_BASE = "dc=cit470,dc=nku,dc=edu";' /usr/share/migrationtools/migrate_common.ph >> logfile
	#Create base.ldif file
	wget https://github.com/rabbitstick/cir470/raw/master/base.ldif
	cp base.ldif /etc/httpd
	wget -P /usr/share/migrationtools http://localhost/base.ldif >> logfile
	systemctl start slapd.service
	systemctl restart slapd.service
		
		
#Add required LDAP Schemas
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/core.ldif
	ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
	ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
	ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
#Restart slapd.service to enfore the changes
systemctl stop slapd.service
	chown -R ldap:ldap /var/lib/ldap
	#Migrate data
	slapadd -v -l /usr/share/migrationtools/base.ldif 
	cd /usr/share/migrationtools/
	./migrate_passwd.pl /etc/passwd > passwd.ldif
	slapadd -v -l passwd.ldif
	./migrate_group.pl /etc/group > group.ldif
	slapadd -v -l group.ldif
	chown -R ldap.ldap /var/lib/ldap
	systemctl start slapd
	#UP UNTIL THIS POINT I WAS ABLE TO START EVERYTHING FINE, AND THE USERS APPEAR TO BE ADDED CORRECTLY
	cd /usr/local/sbin
	wget http://www.hits.at/diradm/diradm-1.3.tar.gz
	tar zxvf diradm-1.3.tar.gz
	sed -i '/BINDDN="cn=Admin,o=System"/c\BINDDN="cn=Manager,dc=cit470,dc=nku,dc=edu"' /usr/local/sbin/diradm-1.3/diradm.conf >> logfile
	sed -i '/USERBASE="ou=Users,ou=Accounts,o=System"/c\USERBASE="ou=People,dc=cit470,dc=nku,dc=edu"' /usr/local/sbin/diradm-1.3/diradm.conf >> logfile
	sed -i '/GROUPBASE="ou=Groups,ou=Accounts,o=System"/c\GROUPBASE="ou=Group,dc=cit470,dc=nku,dc=edu"' /usr/local/sbin/diradm-1.3/diradm.conf >> logfile
	cp /usr/local/sbin/diradm-1.3/diradm.conf /etc/
	#I might not need this line sed -i 'LDAPURI="ldap://localhost:389/"/c\LDAPURI="ldap://10.2.7.2:389/"' /usr/local/diradm-1.3/diradm.conf >> logfile
	systemctl start slapd.service
	#COnfigure ACL
	echo "olcAccess: {0}to attrs=userPassword, by self write by anonymous auth by * none" >> /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif
	echo "olcAccess: {1} to * by self write by * read" >> /etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif
	systemctl restart slapd.service
	reboot




