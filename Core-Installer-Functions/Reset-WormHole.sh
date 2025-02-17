fresh_install() {
    local masterkey_file="./Global-Configs/Master-Key/master.conf"
    local database_folder="./Global-Configs/Wiregate-Database"
    local yml_file="docker-compose.yml"
    
    clear
    echo -e "\033[33m\n"    
    echo '
        ██╗    ██╗ █████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗ 
        ██║    ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║██╔════╝ 
        ██║ █╗ ██║███████║██████╔╝██╔██╗ ██║██║██╔██╗ ██║██║  ███╗
        ██║███╗██║██╔══██║██╔══██╗██║╚██╗██║██║██║╚██╗██║██║   ██║
        ╚███╔███╔╝██║  ██║██║  ██║██║ ╚████║██║██║ ╚████║╚██████╔╝
         ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝                                                   
    '
    echo "#######################################################################"
    echo ""
    echo "                  Resetting WireGuard will Delete            "
    echo "        Your Client, Server, Master Key Configs, & All Database        "
    echo ""
    echo "#######################################################################"
    echo -e "\n\033[0m"

    read -p "Continue Resetting Wireguard? $(tput setaf 1)(y/n)$(tput sgr0) " answer 
    echo ""
    echo ""

    if [[ $answer == [Yy] || -z $answer ]]; then
        port_mappings="770-777:770-777/udp"
        export WG_DASH_PORT_MAPPINGS="$port_mappings"
        docker compose down --volumes --remove-orphans

        if [ -f "$masterkey_file" ]; then
            echo "Removing existing '$masterkey_file'..."
            sudo rm "$masterkey_file"
            echo "Existing '$masterkey_file' removed."
        fi

        if [ -d "$database_folder" ]; then
            echo "Removing existing '$database_folder'..."
            sudo rm -r "$database_folder"
            echo "Existing '$database_folder' removed."
        fi


        echo "Removing existing Compose File"
        sudo rm "$yml_file"
        echo "Existing Compose File removed."

        echo "Pulling from Default Compose File..."
        cat Global-Configs/Docker-Compose/pihole-docker-compose.yml > "$yml_file"
        echo "File successfully pulled from Default Compose File."
        
        clear
        menu
    else
        clear
        menu
    fi
}
pihole_preset_compose_swap() {
    local yml_file="docker-compose.yml"
    sudo rm "$yml_file"
    echo "Pulling from Preset Compose File..."
    cat Global-Configs/Docker-Compose/pihole-custom-docker-compose.yml > "$yml_file"
    echo "File successfully pulled from Preset Compose File."

}
adguard_preset_compose_swap() {
    local yml_file="docker-compose.yml"
    sudo rm "$yml_file"
    echo "Pulling from Preset Compose File..."
    cat Global-Configs/Docker-Compose/adguard-custom-docker-compose.yml > "$yml_file"
    echo "File successfully pulled from Preset Compose File."

}
adguard_compose_swap() {
    local yml_file="docker-compose.yml"
    sudo rm "$yml_file"
    echo "Pulling from Preset Compose File..."
    cat Global-Configs/Docker-Compose/adguard-docker-compose.yml > "$yml_file"
    echo "File successfully pulled from Preset Compose File."
}
pihole_compose_swap() {
    local yml_file="docker-compose.yml"
    sudo rm "$yml_file"
    cat Global-Configs/Docker-Compose/pihole-docker-compose.yml > "$yml_file"
    
}
unbound_config_swap() {
    local yml_file="Global-Configs/Unbound/custom-unbound.conf"
    cat "$yml_file" > Global-Configs/Unbound/cloud-deploy/cloud-unbound.conf
    sudo rm "$yml_file"
    cat Global-Configs/Unbound/local-deploy/local-unbound.conf > "$yml_file"
    clear
    echo "Successfully swapped to Local Deployment."
    menu
    
}


unbound_config_swapback() {
    local yml_file="Global-Configs/Unbound/custom-unbound.conf"
    sudo rm "$yml_file"
    cat Global-Configs/Unbound/cloud-deploy/cloud-unbound.conf > "$yml_file"
    clear
    echo "Successfully swapped to Cloud Deployment."
    menu
    
}