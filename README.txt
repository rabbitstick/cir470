#Team 1
#CIT 470 
#Members: David Geis, Clay Dempsey, Sean Hasenstab
##
##
########automated server setup########
#The server-setup script downloads the a2.tar.bz2 tarball,
#extracts the two scripts detailed below, and runs them
#without user interaction; manual install info is below.
##
#Script:
#    creates directory for script activity, logs
#    downloads and extracts a2.tar.bz2.
#    located as root, use ./server-setup
##
########install LDAP server########
#The install-ldap-server script installs an ldap server
#on the current machine, configures server, and allows 
#for authentication.
##
##
##
#Script: 
#    sets firewall rules to allow access on ports 389, 636.
#    sets diradm to modify files without using vi.
#    located as root, use ./install-ldap-server .
##
#Options:
#    - h 
#
##
##
##
########install-nfs-server########
#The install-nfs-server script installs an nfs server 
#on the current machine; allows clients server conection 
#simultaneously, and access to same files.
##
#Script:
#    sets firewall rules clients connect on ports 2049, 111, 20048.
#    located as root, use ./install-nfs-server .
##
#Options:
#    -h
#
##
##
