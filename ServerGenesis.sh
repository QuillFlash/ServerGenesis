#! /bin/bash

# ServerGenesis - Spin up containerised company servers in under 5 minutes!
# Pre-Alpha Version 0.5 -- EXPECT BUGS AND ISSUES!!!

echo "SERVER GENESIS -- Fire up a platform-agnostic server in minutes!"
echo "Pre-Alpha Version 0.55 -- EXPECT BUGS AND ISSUES!!!"
sleep 2

initcheck=$(ps -p 1 | tail -1 | cut -f17 -d " ")

# If the docker package is not present, install it on the popular distros
# (Debian/Ubuntu, Fedora, RHEL, Arch Linux, Gentoo, Alpine)
if [ ! -e /usr/bin/docker ]
then
    echo "Docker is not installed! Installing dependency of shell script..."
    sleep 2
    if [ -e /etc/debian_version ]
    then
        sudo apt-get -y install docker.io
    elif [ -e /etc/fedora-release ]
    then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif [ -e /etc/redhat-release ]
    then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
        sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif [ -d /etc/pacman.d ]
    then
        sudo pacman -Syu --noconfirm docker docker-buildx
        sudo systemctl enable --now docker.service
    elif [ -d /etc/portage ]
    then
        sudo emerge -qv docker docker-buildx
        # Gentoo uses two init systems, accommodating for the systemd users
        case $initcheck in
            *openrc*)
                sudo rc-update add docker default
                sudo rc-service docker start
                ;;
            systemd)
                sudo systemctl enable --now docker.service
                ;;
            *)
                echo "Unsupported Gentoo configuration!"
                exit 1
                ;;
        esac
    elif [ -d /etc/apk ]
    then
        sudo apk add docker
        sudo rc-update add docker default
        sudo service docker start
    else
        echo "Unfortunately, this script doesn't support your distribution."
        exit 1 # ChatGPT segítsége
    fi
fi
# Mac install
if [ -d /Applications ]
then
    echo "You are running macOS!"
    echo "Homebrew is not installed, installing Mac-specific dependency..."
    sleep 2
    xcode-select --install
    NONINTERACTIVE=1 sudo /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Installing Docker for Mac..."
    brew install docker --force
    open -a /Applications/Docker.app
    sleep 2
fi

# Source: https://stackoverflow.com/questions/18431285/check-if-a-user-is-in-a-group-in-bash, ChatGPT
if [ "$(id -nG "$USER" | tr ' ' '\n' | grep -w 'docker')" != "docker" ] \
&& [ ! -d /Applications ]
then
    echo "$USER is not part of group 'docker', adding user to necessary group..."
    sudo usermod -aG docker "$USER"
fi

# Source code for choosing functionality of the Debian container
echo
echo "Choose the functionality of your containerised Debian server:"
echo
echo "1.) Would you like to grant SSH access to the server? (Y/N) ";\
read -r isSSHAccess # https://ryanstutorials.net/bash-scripting-tutorial/bash-input.php
echo
echo "Which port would you like SSH to listen on?"
read -r sshPortNumber
echo
if [[ "$isSSHAccess" =~ [yY] ]]
then
    echo "2.) Would you like to install a file server? (Y/N) ";\
    read -r isFileServer
fi
echo

echo "3.) Would you like to install a web server? (Y/N) ";\
read -r isWebServer

if [[ "$isWebServer" =~ [yY] ]]
then
    echo
    echo "Choose your web server: [A]pache/[N]ginx/[O]penResty ";\
    read -r webServerType
    echo
    echo "Which port would you like the web server to listen on?"
    read -r webserverPortNumber
    echo
    echo "Would you like to import an existing website? (Y/N) ";\
    read -r restoreWebsiteState
    if [[ $restoreWebsiteState =~ [yY] ]]
    then
        echo "Please type in the path to your website's files:";\
        read -r websiteFiles
    fi
fi
echo

if [[ "$isWebServer" =~ [yY] ]]
then
    echo "4.) Would you like to install a database server? (Y/N) ";\
    read -r isDbServer
    if [[ "$isDbServer" =~ [yY] ]]
    then
        echo
        echo "Choose your database management system (DBMS): [Mo]ngoDB/[My]SQL/[O]racle SQL (PL/SQL)/[P]ostgreSQL ";\
        read -r dbType
        echo
        echo "Would you like to import an existing database? (Y/N) ";\
        read -r restoreDbState
        echo
        if [[ $restoreDbState =~ [yY] ]]
        then
            echo "Please type in the path to your website's files:";\
            read -r databaseFiles
            if [[ "$dbType" =~ [oO] ]]
            then
                echo "Enter your database's SID: "
                read -r sid
                export ORACLE_SID="$sid"
                echo
                echo "Enter the path to your log file: "
                read -r logfile_path
                echo
                echo "Enter your username: "
                read -r username
                echo
                echo "Enter your password: "
                read -r password
                echo
                echo "Enter the data pump's directory:"
                read -r datapump_dir
            fi
        fi
    fi
fi
echo
echo "5.) And finally: would you like to install an e-mail server? (Y/N) "
read -r isMailServer
echo

sudo docker build -t dockerian .
# Inspired by a ChatGPT response
sudo docker run -d --restart always --name dockerian -p "$sshPortNumber":22 -p "$webserverPortNumber":80 -it dockerian /bin/bash

# Installing chosen dependencies
echo "Installing chosen dependencies..."
echo

case $isSSHAccess in
    y|Y)
        sudo docker exec -it dockerian apt-get -y install openssh-server
        # Debian in a container doesn't use systemd, so it manages processes
        # the exact same way as Devuan: with the classic sysvinit init system.
        sudo docker exec -it dockerian update-rc.d ssh defaults
        sudo docker exec -it dockerian service ssh start
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
        sudo docker exec -it dockerian bash -c \
        "printf 'Match Group sftpuser\n\
        ForceCommand internal-sftp\n\
        ChrootDirectory ~\n\
        PermitTunnel no\n\
        AllowAgentForwarding no\n\
        AllowTcpForwarding no\n\
        X11Forwarding no' >> /etc/ssh/sshd_config"
        sudo docker exec -it dockerian service ssh restart
        ;;
    n|N|"")
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
            sudo docker exec -it dockerian apt-get -y install apache2
            case $restoreWebsiteState in
                y|Y)
                    sudo docker exec -it dockerian cp -r "$websiteFiles"/* /var/www/html
                    ;;
                n|N|"")
                    ;;
                *)
                    echo "ERROR: Invalid input."
                    exit 1
                    ;;
            esac
            ;;
        n|N)
            sudo docker exec -it dockerian apt-get -y install nginx
            case $restoreWebsiteState in
                y|Y)
                    sudo docker exec -it dockerian cp -r "$websiteFiles"/* /usr/share/nginx/html/
                    ;;
                n|N)
                    ;;
                *)
                    echo "ERROR: Invalid input."
                    exit 1
                    ;;
            esac
            ;;
        o|O)
            sudo docker exec -it dockerian apt-get -y install \
            --no-install-recommends wget gnupg ca-certificates
            sudo docker exec -it dockerian bash -c "wget -O - \
            https://openresty.org/package/pubkey.gpg | gpg --dearmor -o \
            /etc/apt/trusted.gpg.d/openresty.gpg"
            sudo docker exec -it dockerian bash -c "echo 'deb \
            https://openresty.org/package/debian bookworm openresty' \
            | tee /etc/apt/sources.list.d/openresty.list"
            sudo docker exec -it dockerian bash -c "apt-get update && apt-get -y install openresty"
            case $restoreWebsiteState in
                y|Y)
                    sudo docker exec -it dockerian cp -r "$websiteFiles"/* /usr/local/openresty/nginx/html/
                    ;;
                n|N)
                    ;;
                *)
                    echo "ERROR: Invalid input."
                    exit 1
                    ;;
            esac
            ;;
        "")
            ;;
        *)
            echo "ERROR: Invalid input."
            exit 1
            ;;
        esac
        ;;
    n|N|"")
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
                sudo docker exec -it dockerian apt-get -y install gnupg curl
                sudo docker exec -it dockerian bash -c "curl -fsSL \
                https://pgp.mongodb.com/server-8.0.asc | gpg -o \
                /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor"
                sudo docker exec -it dockerian bash -c "echo 'deb \
                [ signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] \
                https://repo.mongodb.com/apt/debian \
                bookworm/mongodb-enterprise/8.0 main' | \
                tee /etc/apt/sources.list.d/mongodb-enterprise.list"
                sudo docker exec -it dockerian bash -c "apt-get update && apt-get -y install mongodb-enterprise"
                case $restoreDbState in
                y|Y)
                    sudo docker exec -it dockerian cp -r "$databaseFiles" /
                    sudo docker exec -it dockerian mongorestore --drop --dir "$databaseFiles" # Help by ChatGPT
                    ;;
                n|N|"")
                    ;;
                *)
                    echo "ERROR: Invalid input."
                    exit 1
                    ;;
                esac
                ;;
            my|My|MY)
                sudo docker exec -it dockerian curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash
                sudo docker exec -it dockerian bash -c "apt-get update && apt-get -y install \
                mariadb-server mariadb-client mariadb-backup"
                case $restoreDbState in
                y|Y)
                    sudo docker exec -it dockerian cp -r "$databaseFiles" /
                    sudo docker exec -it dockerian bash -c "mysql -u root < $databaseFiles" # Help by ChatGPT
                    ;;
                n|N|"")
                    ;;
                *)
                    echo "ERROR: Invalid input."
                    exit 1
                    ;;
                esac
                ;;
            o|O)
                sudo docker exec -it dockerian apt-get -y install wget alien libaio1 unixodbc
                sudo docker exec -it dockerian wget https://download.oracle.com/otn/linux/oracle21c/oracle-database-ee-21c-1.0-1.ol8.x86_64.rpm
                sudo docker exec -it dockerian alien -cdi oracle-database-ee-*.rpm
                sudo docker exec -it dockerian dpkg -i oracle-database-ee-*.deb
                case $restoreDbState in
                y|Y)
                    # Source: https://stackoverflow.com/questions/6463614/how-to-import-an-oracle-database-from-dmp-file-and-log-file, ChatGPT
                    sudo docker exec -it dockerian cp -r "$databaseFiles" /
                    sudo docker exec -it dockerian cp -r "$logfile_path" /
                    sudo docker exec -it dockerian cp -r "$datapump_dir" /
                    sudo docker exec -it dockerian bash -c "sqlplus -s ${username}/${password} <<EOF
                    WHENEVER SQLERROR EXIT SQL.SQLCODE
                    BEGIN
                        EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY DATA_PUMP_DIR AS ''${datapump_dir}''';
                        EXECUTE IMMEDIATE 'GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO ${username}';
                    END;
                    /
                    EXIT
EOF"

                    previousCommand=$?
                    if [ $previousCommand -ne 0 ]
                    then
                        echo "FATAL ERROR: Setting the data pump directory or database permissions failed."
                        exit 2
                    fi

                    impdp "${username}"/"${password}" \
                    directory="$datapump_dir" \
                    dumpfile="$(basename "$databaseFiles")" \
                    logfile="$(basename "$logfile_path")" \
                    full=y

                    if [ $previousCommand -ne 0 ]
                    then
                        echo "FATAL ERROR: Database import failed."
                        exit 2
                    fi
                    ;;
                n|N|"")
                    ;;
                *)
                    echo "ERROR: Invalid input."
                    exit 1
                    ;;
                esac
                ;;
            p|P)
                sudo docker exec -it dockerian apt-get -y install postgresql
                sudo docker exec -it dockerian cp -r "$databaseFiles" /
                sudo docker exec -it dockerian bash -c "su - postgres -c 'psql < $databaseFiles'" # Help by ChatGPT
                ;;
            "")
                ;;
            *)
                echo "ERROR: Invalid input."
                exit 1
                ;;
        esac
        ;;
    n|N|"")
        ;;
    *)
        echo "ERROR: Invalid input."
        exit 1
        ;;
esac

if [[ "$isMailServer" =~ [yY] ]]
then
    sudo docker exec -it dockerian apt-get -y install postfix
    sudo docker exec -it dockerian postconf -e smtpd_tls_security_level=may
    sudo docker exec -it dockerian postconf -e smtpd_use_tls
    sudo docker exec -it dockerian postconf -e smtpd_enforce_tls
fi

echo "Congratulations! You've successfully configured a ready-to-use (and portable) Debian server for your needs."
echo "Isn't it nice that I spent a lot of my time so that you'd have less headaches? :)"