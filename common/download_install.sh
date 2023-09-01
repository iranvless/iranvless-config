#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root' >&2
        exit 1
fi
export DEBIAN_FRONTEND=noninteractive
if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root' >&2
        exit 1
fi

echo "we are going to download needed files:)"
GITHUB_REPOSITORY=iranvless-config
GITHUB_USER=iranvless
GITHUB_BRANCH_OR_TAG=main

# if [ ! -d "/opt/$GITHUB_REPOSITORY" ];then
        apt update
        apt upgrade -y
        apt install -y curl unzip
        # pip3 install lastversion "requests<=2.29.0"
        # pip install lastversion "requests<=2.29.0"
        mkdir -p /opt/$GITHUB_REPOSITORY
        cd /opt/$GITHUB_REPOSITORY
        curl -L -o iranvless-config.zip https://github.com/iranvless/iranvless-config/releases/latest/download/iranvless-config.zip
        unzip -o iranvless-config.zip
        rm iranvless-config.zip
        
        bash install.sh
        # exit 0
# fi 


echo "/opt/iranvless-config/menu.sh">>~/.bashrc
echo "cd /opt/iranvless-config/">>~/.bashrc

read -p "Press any key to go  to menu" -n 1 key
cd /opt/$GITHUB_REPOSITORY
bash menu.sh
