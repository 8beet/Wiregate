#!/bin/bash

chmod u+x /home/app/wgd.sh

chmod u+x /home/app/FIREWALLS/Admins/wg0-dwn.sh
chmod u+x /home/app/FIREWALLS/Admins/wg0-nat.sh

chmod u+x /home/app/FIREWALLS/Members/wg1-dwn.sh
chmod u+x /home/app/FIREWALLS/Members/wg1-nat.sh

chmod u+x /home/app/FIREWALLS/LAN-only-users/wg2-dwn.sh
chmod u+x /home/app/FIREWALLS/LAN-only-users/wg2-nat.sh

chmod u+x /home/app/FIREWALLS/Guest/wg3-dwn.sh
chmod u+x /home/app/FIREWALLS/Guest/wg3-nat.sh


if [ ! -f "/etc/wireguard/wg0.conf" ]; then
    /home/app/wgd.sh newconfig

fi

run_wireguard_up() {
  config_files=$(find /etc/wireguard -type f -name "*.conf")

  
  for file in $config_files; do
    config_name=$(basename "$file" ".conf")
    chmod 600 "/etc/wireguard/$config_name.conf"
    
    wg-quick up "$config_name"  
  done
}




create_wiresentinel_user() {
    # Check if the user already exists
    if id "wiresentinel" &>/dev/null; then
        echo "User wiresentinel already exists."
        return 1
    fi

    password=$(openssl rand -base64 180 | tr -d '\n')
    
    # Create wiresentinel user without a home directory and with /bin/false as the shell
    adduser -D -H -s /bin/false wiresentinel
    # Set password for wiresentinel
    echo "wiresentinel:$password" | chpasswd  > /dev/null 2>&1
    # Set permissions on /home
    chmod 750 /home
    # Set ownership of /home and /etc/wireguard to wiresentinel:gatekeeper
    chown -R wiresentinel:wiresentinel /home
    chown -R wiresentinel:wiresentinel /etc/wireguard
    # Run uWSGI command as wiresentinel without a password prompt

    # Add wiresentinel to the wheel group
    adduser wiresentinel wheel

    # Uncomment the %wheel line in sudoers file
    sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

    
}

logs_title() {
  echo -e "\033[32m"
  echo '
________________________________________________________________________________
|                                                                               |
|       ██╗    ██╗██╗██████╗ ███████╗ ██████╗  █████╗ ████████╗███████╗         |
|       ██║    ██║██║██╔══██╗██╔════╝██╔════╝ ██╔══██╗╚══██╔══╝██╔════╝         |
|       ██║ █╗ ██║██║██████╔╝█████╗  ██║  ███╗███████║   ██║   █████╗           |
|       ██║███╗██║██║██╔══██╗██╔══╝  ██║   ██║██╔══██║   ██║   ██╔══╝           |
|       ╚███╔███╔╝██║██║  ██║███████╗╚██████╔╝██║  ██║   ██║   ███████╗         |
|        ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝         |
|                                    LOGS                                       |
|_______________________________________________________________________________|'                                                               
  echo -e "\033[33m"
  echo ""
}


create_wiresentinel_user
logs_title 
sleep 0.005
run_wireguard_up 



/home/app/wgd.sh start
