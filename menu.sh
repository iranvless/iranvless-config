#!/bin/bash

source common/utils.sh

#PACKAGE_MODE=$(get_package_mode)
#LATEST_CONFIG_VERSION=$(get_release_version iranvless-config)
#LATEST_PANEL_VERSION=$(get_release_version iranvlesspanel)

CURRENT_CONFIG_VERSION=$(get_installed_config_version)
CURRENT_PANEL_VERSION=$(get_installed_panel_version)

# if [[ "$PACKAGE_MODE" == "develop" ]] || [[ "$CURRENT_CONFIG_VERSION" == "$LATEST_CONFIG_VERSION" && "$CURRENT_PANEL_VERSION" == "$LATEST_PANEL_VERSION" ]]; then
#     UPDATE_NEED=""
# else
#     UPDATE_NEED="*UPDATE AVAILABLE* Config=v$LATEST_CONFIG_VERSION Panel=v$LATEST_PANEL_VERSION"
# fi

cd "$(dirname -- "$0")"
cd /opt/iranvless-config/

function menu() {

    HEIGHT=20
    WIDTH=70
    CHOICE_HEIGHT=12
    BACKTITLE="iranvless Panel (Config=v$CURRENT_CONFIG_VERSION Panel=v$CURRENT_PANEL_VERSION)   $UPDATE_NEED  "
    TITLE="iranvless Panel $PACKAGE_MODE"
    MENU="Choose one of the following options:"

    OPTIONS=(status "View status of system"
        admin "Show admin link"
        log "view system logs"
        restart "Restart Services without changing the configs"
        apply_configs "Apply the changed configs"
        update "Update $UPDATE_NEED"
        install "Reinstall"
        advanced "Uninstall, Remote Assistant, Downgrade,..."
        Exit ""
    )

    CHOICE=$(whiptail --clear \
        --backtitle "$BACKTITLE" \
        --title "$TITLE" \
        --menu "$MENU" \
        $HEIGHT $WIDTH $CHOICE_HEIGHT \
        "${OPTIONS[@]}" \
        3>&1 1>&2 2>&3)

    if [[ $? != 0 ]]; then
        clear
        exit 1
    fi
    clear
    echo "iranvless: Command $CHOICE"
    echo "=========================================="
    NEED_KEY=1
    case $CHOICE in
    "") exit 1 ;;
    "Exit") exit 1 ;;
    'log')
        W=()
        while read -r line; do
            size=$(ls -lah log/system/"$line" | awk -F " " '{print $5}')
            W+=("$line" "$size")
        done < <(ls -1 log/system)
        LOG=$(whiptail --clear \
            --backtitle "$BACKTITLE" \
            --title "$TITLE" \
            --menu "$MENU" \
            $HEIGHT $WIDTH $CHOICE_HEIGHT \
            "${W[@]}" \
            3>&1 1>&2 2>&3)
        clear
        echo -e "\033[0m"
        if [[ $LOG != "" ]]; then
            less -r -P"Press q to exit" +G "log/system/$LOG"
        fi
        NEED_KEY=0
        ;;
    "advanced")
        OPTIONS=(
            warp "Check Warp Status"
            add_remote "Add remote assistant access to this server"
            remove_remote "Remove remote assistant access to this server"
            downgrade "Downgrade to Version 7"
            enable "show this menu on start up"
            disable "disable this menu"
            uninstall "Uninstall iranvless :("
            purge "Uninstall completely and remove database :("
        )
        CHOICE=$(whiptail --clear --backtitle "$BACKTITLE" --title "$TITLE" --menu "$MENU" $HEIGHT $WIDTH $CHOICE_HEIGHT "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
        case $CHOICE in
        "enable")
            echo "/opt/iranvless-config/menu.sh" >>~/.bashrc
            echo "cd /opt/iranvless-config/" >>~/.bashrc
            NEED_KEY=0
            ;;
        "disable")
            sed -i "s|/opt/iranvless-config/menu.sh||g" ~/.bashrc
            sed -i "s|cd /opt/iranvless-config/||g" ~/.bashrc
            NEED_KEY=0
            ;;
        "uninstall")
            bash uninstall.sh
            ;;
        "purge")
            bash uninstall.sh purge
            ;;
        "downgrade")
            bash common/downgrade.sh
            ;;
        "add_remote")
            bash common/add_remote_assistant.sh
            ;;
        "remove_remote")
            bash common/remove_remote_assistant.sh
            ;;
        "warp")
            (
                cd other/warp/
                bash status.sh | less -r -P"Press q to exit" +G
            )
            NEED_KEY=0
            ;;
        *) NEED_KEY=0 ;;
        esac
        ;;

    "update")
        OPTIONS=(default "Based on the configuration in panel"
            release "(suggested) $UPDATE_NEED"
            develop "Develop (may have some bugs)"
        )
        CHOICE=$(whiptail --clear --backtitle "$BACKTITLE" --title "$TITLE" --menu "$MENU" $HEIGHT $WIDTH $CHOICE_HEIGHT "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
        case $CHOICE in
        "default")
            bash update.sh
            ;;
        "release")
            bash update.sh release
            ;;
        "develop")
            bash update.sh develop
            ;;
        *) NEED_KEY=0 ;;
        esac
        ;;
    "admin")
        (
            cd iranvless-panel
            python3 -m iranvlesspanel admin-links
        )
        ;;
    "status")
        bash status.sh | less -r -P"Press q to exit" +G
        NEED_KEY=0
        ;;
    *)
        bash "$CHOICE.sh"
        ;;
    esac

    if [[ $NEED_KEY == 1 ]]; then
        read -p "Press any key to return to menu" -n 1 key
    fi

    menu
}
menu
