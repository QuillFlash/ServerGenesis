#! /bin/sh

# ServerGenesis - Spin up containerised company servers in under 5 minutes!
# Pre-Alpha Version 0.5 -- EXPECT BUGS AND ISSUES!!!

echo "SERVER GENESIS -- Fire up a platform-agnostic server in minutes!"
echo "Pre-Alpha Version 0.5 -- EXPECT BUGS AND ISSUES!!!"
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
if [ "$(id -nG "$(whoami)" | tr ' ' '\n' | grep -w 'docker')" != "docker" ] \
&& [ ! -d /Applications ]
then
    echo "$(whoami) is not part of group 'docker', adding user to necessary group..."
    sudo usermod -aG docker "$USER"
fi

# Here's the fun part: this creates the container based on the Dockerfile and the assist script
sudo docker build -t runeverywhere_debian_server .
sudo docker run --restart always --name debian_corpo_server -it runeverywhere_debian_server /bin/bash

echo "Congratulations! You've successfully configured a ready-to-use (and portable) Debian server for your needs."
echo "Isn't it nice that I spent a lot of my time so that you'd have less headaches? :)"