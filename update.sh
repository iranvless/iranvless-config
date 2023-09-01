#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cd $(dirname -- "$0")

function cleanup() {
    error "Script interrupted. Exiting..."
    rm log/update.lock
    pkill -9 dialog
    echo "1" >log/error.lock
    exit 1
}

# Trap the Ctrl+C signal and call the cleanup function
trap cleanup SIGINT

source common/utils.sh

function main() {
    CURRENT_CONFIG_VERSION=$(get_installed_config_version)
    CURRENT_PANEL_VERSION=$(get_installed_panel_version)

    rm -rf sniproxy
    rm -rf caddy
    echo "Creating a backup ..."
    ./iranvless-panel/backup.sh
    UPDATE=0
    PANEL_UPDATE=0
    if [[ "$1" == "" ]]; then
        PACKAGE_MODE=$(get_package_mode)
        FORCE=false
    else
        PACKAGE_MODE=$1
        FORCE=true
    fi

    if [[ "$PACKAGE_MODE" == "develop" ]]; then
        echo "you are in develop mode"
        #LATEST=$(get_commit_version iranvlessPanel)
        #INSTALL_DIR=$(pip show iranvlesspanel |grep Location |awk -F": " '{ print $2 }')
        #CURRENT=$(cat $INSTALL_DIR/iranvlesspanel/VERSION)
        #echo "DEVLEOP: iranvless panel version current=$CURRENT latest=$LATEST"
        #if [[ FORCE == "true" || "$LATEST" != "$CURRENT" ]];then
        #    pip3 uninstall -y iranvlesspanel
        #    pip3 install -U git+https://github.com/iranvless/iranvlessPanel
        #    echo $LATEST>$INSTALL_DIR/iranvlesspanel/VERSION
        #    echo "__version__='$LATEST'">$INSTALL_DIR/iranvlesspanel/VERSION.py
        #    UPDATE=1
        #fi
        pip install -U iranvlesspanel --pre
        PANEL_UPDATE=1
    else
        #iranvless=`cd iranvless-panel;python3 -m iranvlesspanel downgrade`

        CURRENT=$CURRENT_PANEL_VERSION
        #LATEST=`lastversion iranvlesspanel --at pip`
        LATEST=$(get_release_version iranvlesspanel)
        echo "iranvless panel version current=$CURRENT latest=$LATEST"
        if [[ $FORCE == "true" || "$CURRENT" != "$LATEST" ]]; then
            echo "panel is outdated! updating...."
            pip3 install -U iranvlesspanel==$LATEST
            PANEL_UPDATE=1
        fi
    fi

    if [[ "$PACKAGE_MODE" == "develop" ]]; then
        LATEST_CONFIG_VERSION=$(get_commit_version iranvless-config)
        echo "DEVELOP: Current Config Version=$CURRENT_CONFIG_VERSION -- Latest=$LATEST_CONFIG_VERSION"
        if [[ $FORCE == "true" || "$CURRENT_CONFIG_VERSION" != "$LATEST_CONFIG_VERSION" ]]; then
            curl -L -o main.tar.gz https://github.com/hiddify/iranvless-config/archive/refs/heads/main.tar.gz
            # rm  -rf nginx/ xray/
            tar xvzf main.tar.gz --strip-components=1 && echo $LAST_CONFIG_VERSION >VERSION

            rm main.tar.gz
            rm -rf other/netdata
            bash install.sh
            UPDATE=1
        fi
    else
        LATEST_CONFIG_VERSION=$(get_release_version iranvless-config)
        echo "Current Config Version=$CURRENT_CONFIG_VERSION -- Latest=$LATEST_CONFIG_VERSION"
        if [[ $FORCE == "true" || "$CURRENT_CONFIG_VERSION" != "$LATEST_CONFIG_VERSION" ]]; then
            echo "Config is outdated! updating..."

            curl -L -o iranvless-config.zip https://github.com/iranvless/iranvless-config/releases/latest/download/iranvless-config.zip && rm xray/configs/*
            # rm  -rf nginx/ xray/

            apt install -y unzip
            unzip -o iranvless-config.zip
            rm iranvless-config.zip
            bash install.sh
            UPDATE=1

        fi
    fi
    if [[ $UPDATE == 0 ]]; then
        echo "---------------------Finished!------------------------"
    fi
    if [[ "$PANEL_UPDATE" == 1 ]]; then
        systemctl restart iranvless-panel
    fi

    if [[ "$PANEL_UPDATE" == 1 && $UPDATE == 0 ]]; then
        bash apply_configs.sh
    fi
    rm log/update.lock
}

mkdir -p log/system/

if [[ -f log/update.lock && $(($(date +%s) - $(cat log/update.lock))) -lt 120 ]]; then
    echo "Another installation is running.... Please wait until it finishes or wait 5 minutes or execute 'rm -f log/update.lock'"
    exit 1
fi

echo "$(date +%s)" >log/update.lock

main $@ |& tee log/system/update.log
