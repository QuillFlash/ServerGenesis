#! /bin/bash

# Source code for choosing functionality of the Debian container
echo
echo "Choose the functionality of your containerised Debian server:"
echo
echo "1.) Would you like to grant SSH access to the server? (Y/N) "
read -r isSSHAccess # https://ryanstutorials.net/bash-scripting-tutorial/bash-input.php
echo

if [[ "$isSSHAccess" =~ [yY] ]]
then
    echo "2.) Would you like to install a file server? (Y/N) "
    read -r isFileServer
fi
echo

echo "3.) Would you like to install a web server? (Y/N) "
read -r isWebServer

if [[ "$isWebServer" =~ [yY] ]]
then
    echo
    echo "Choose your web server: [A]pache/[N]ginx/[O]penResty "
    read -r webServerType
fi
echo

if [[ "$isWebServer" =~ [yY] ]]
then
    echo "4.) Would you like to install a database server? (Y/N) "
    read -r isDbServer
    if [[ "$isDbServer" =~ [yY] ]]
    then
        echo
        echo "Choose your database management system (DBMS): [Mo]ngoDB/[My]SQL/[O]racle SQL (PL/SQL)/[P]ostgreSQL "
        read -r dbType
    fi
fi
echo
echo "5.) And finally: Would you like to install an e-mail server? (Y/N) "
read -r isMailServer
echo

# Installing chosen dependencies
echo "Installing chosen dependencies..."

case $isSSHAccess in
    y|Y)
        apt-get -y install openssh-server
        ;;
    n|N)
        ;;
    *)
        echo "ERROR: Not a valid input."
        exit 1
        ;;
esac

# Arch Wiki: https://wiki.archlinux.org/title/SCP_and_SFTP
case $isFileServer in
    y|Y)
        sed -i '$a\Match Group sftpuser\
        ForceCommand internal-sftp\
        ChrootDirectory ~\
        PermitTunnel no\
        AllowAgentForwarding no\
        AllowTcpForwarding no\
        X11Forwarding no' /etc/ssh/sshd_config
        ;;
    n|N)
        ;;
    "")
        ;;
    *)
        echo "ERROR: Not a valid input."
        exit 1
        ;;
esac

case $isWebServer in
    y|Y)
        case $webServerType in
        a|A)
            apt-get -y install apache2
            ;;
        n|N)
            apt-get -y install nginx
            ;;
        o|O)
            apt-get -y install --no-install-recommends wget gnupg ca-certificates
            wget -O - https://openresty.org/package/pubkey.gpg | \
            gpg --dearmor -o /etc/apt/trusted.gpg.d/openresty.gpg
            codename=$(grep -Po 'VERSION="[0-9]+ \(\K[^)]+' /etc/os-release)
            echo "deb https://openresty.org/package/debian $codename openresty" \
            | tee /etc/apt/sources.list.d/openresty.list
            apt-get update && apt-get -y install openresty
            ;;
        *)
            echo "ERROR: Invalid input."
            exit 1
            ;;
        esac
        ;;
    n|N)
        ;;
    *)
        echo "ERROR: Invalid input."
        exit 1
        ;;
esac

case $isDbServer in
    y|Y)
        case $dbType in
            mo|Mo|MO)
                apt-get -y install gnupg curl
                curl -fsSL https://pgp.mongodb.com/server-8.0.asc \
                | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
                echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] \
                https://repo.mongodb.com/apt/debian bookworm/mongodb-enterprise/8.0 main" | \
                tee /etc/apt/sources.list.d/mongodb-enterprise.list
                apt-get update && apt-get -y install mongodb-enterprise
                ;;
            my|My|MY)
                curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash
                apt-get update && apt-get -y install mariadb-server mariadb-client mariadb-backup
                ;;
            o|O)
                apt-get -y install wget alien libaio1 unixodbc
                wget https://download.oracle.com/otn/linux/oracle21c/oracle-database-ee-21c-1.0-1.ol8.x86_64.rpm
                alien -cdi oracle-database-ee-*.rpm
                ;;
            p|P)
                apt-get -y install postgresql
                ;;
            *)
                echo "ERROR: Invalid input."
                exit 1
                ;;
        esac
        ;;
    n|N)
        ;;
    *)
        echo "ERROR: Invalid input."
        exit 1
        ;;
esac

if [[ "$isMailServer" =~ [yY] ]]
then
    apt-get -y install postfix
fi
