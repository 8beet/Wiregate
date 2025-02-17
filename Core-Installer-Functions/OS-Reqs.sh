#!/bin/bash


#OS


run_os_update() {
    echo -e "\033[33m\n" 
    echo "#######################################################################"
    echo ""
    echo "                     Getting OS Updates and Upgrades"
    echo "                        This may take some time ..."
    echo ""
    echo "#######################################################################"
    echo -e "\n\033[0m"
    
    sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qy update 
    sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qy upgrade 
    clear
}
install_prerequisites() {
    echo -e "\033[33m\n" 
    echo "#######################################################################"
    echo ""
    echo "                        Installing prerequisites"
    echo ""
    echo "#######################################################################"
    echo -e "\n\033[0m"
    # List of prerequisites
    PREREQUISITES=(
        curl
        qrencode
        ca-certificates
        gnupg
        openssl
        apache2-utils
    )
    # Define ANSI color codes
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RESET=$(tput sgr0)
   
    # Check if each prerequisite is already installed
    for prerequisite in "${PREREQUISITES[@]}"
    do
        if ! dpkg -s "$prerequisite" > /dev/null 2>&1; then
            echo "${GREEN}$prerequisite is not installed.${RESET} ${YELLOW}Installing...${RESET}"
            sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qy install "$prerequisite" > /dev/null 2>&1
        else
            echo "${GREEN}$prerequisite is already installed.${RESET} ${YELLOW}Skipping...${RESET}"
        fi
    done

        
    
}
install_docker() {
    # Color codes for terminal output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RESET='\033[0m'

    if [ -f /etc/apt/keyrings/docker.gpg ]; then
        sudo rm /etc/apt/keyrings/docker.gpg
    fi

    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt-get remove -y $pkg > /dev/null 2>&1 || true
    done

    sudo install -m 0755 -d /etc/apt/keyrings
    sleep 0.25s

    # Get Linux distribution information
    source /etc/os-release
    distro=$ID
    codename=$VERSION_CODENAME

    case $distro in
    "ubuntu")
        repo_url="https://download.docker.com/linux/ubuntu"
        ;;
    "debian")
        repo_url="https://download.docker.com/linux/debian"
        ;;
    *)
        printf "${RED}Unsupported Linux distribution: $distro${RESET}\n"
        exit 1
        ;;
    esac

    sudo curl -fsSL "$repo_url/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sleep 0.25s
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    sleep 0.25s

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] $repo_url $codename stable" |
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    sleep 0.25s

    # Function to update APT and install Docker
    sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qy update > /dev/null 2>&1
    sleep 0.25s

    DOCREQS=(
        docker-ce
        docker-ce-cli
        containerd.io
        docker-buildx-plugin
        docker-compose-plugin
        docker-compose
    )

    for docreqs in "${DOCREQS[@]}"; do
        if ! dpkg -s "$docreqs" > /dev/null 2>&1; then
            printf "${GREEN}Docker is not installed. Installing...${RESET}\n"
            sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qy install "$docreqs"
        else
            printf "${GREEN}$docreqs is already installed.${RESET} ${YELLOW}Skipping...${RESET}\n"
        fi
    done
}

install_requirements() {
    run_os_update &&
    install_prerequisites &&
    install_docker &&
    cat <<EOF >"preqsinstalled.txt"
    !!!!!!
EOF
}