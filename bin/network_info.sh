#!/bin/bash

# Function to get current IP info
get_ip_info() {
    PRIVATE_IP=$(hostname -I | awk '{print $1}')
    PUBLIC_IP=$(curl -s https://ipinfo.io/ip || echo "Unavailable")
}

# Function to show the menu
show_menu() {
    get_ip_info
    clear
    echo "====================================="
    echo "       Network Information Menu"
    echo "====================================="
    echo -e "Private IP: \033[1;32m$PRIVATE_IP\033[0m"
    echo -e "Public IP : \033[1;35m$PUBLIC_IP\033[0m"
    echo "-------------------------------------"
    echo "1. List available Wi-Fi networks"
    echo "2. Show routing table"
    echo "3. Show device status"
    echo "4. Show detailed network hardware info"
    echo "5. Display system network info (IP, DNS)"
    echo "6. Release and renew IP (via dhclient)"
    echo "7. Show all network interfaces"
    echo "8. Restart NetworkManager service"
    echo "q. Exit"
    echo "====================================="
    echo -n "Please select an option (1-8): "
}

# Function to display and run the selected option
run_command() {
    case $1 in
        1)
            echo -e "\033[1;34mList available Wi-Fi networks (nmcli dev wifi list)\033[0m"
            nmcli dev wifi list
            ;;
        2)
            echo -e "\033[1;34mShow routing table (ip route)\033[0m"
            ip route
            ;;
        3)
            echo -e "\033[1;34mShow device status (nmcli device status)\033[0m"
            nmcli device status
            ;;
        4)
            echo -e "\033[1;34mDetailed network hardware info (sudo lshw -C network)\033[0m"
            sudo lshw -C network
            ;;
        5)
            echo -e "\033[1;34mDisplay system network info\033[0m"
            echo -e "\033[1;32mInternal IP Address:\033[0m $(hostname -I)"
            echo -e "\033[1;32mDNS Servers:\033[0m"
            grep nameserver /etc/resolv.conf
            echo -e "\033[1;32mPublic IP Address:\033[0m $(curl -s https://ipinfo.io/ip)"
            ;;
        6)
            echo -e "\033[1;34mReleasing and renewing IP address using dhclient...\033[0m"
            interface=$(ip -o -4 route show to default | awk '{print $5}')
            echo -e "Detected interface: \033[1;36m$interface\033[0m"
            sudo dhclient -r "$interface"
            sudo dhclient -v "$interface"
            ;;
        7)
            echo -e "\033[1;34mShow all network interfaces (ip a)\033[0m"
            ip a
            ;;
        8)
            echo -e "\033[1;34mRestarting NetworkManager service...\033[0m"
            sudo systemctl restart NetworkManager
            echo -e "\033[1;32mNetworkManager restarted.\033[0m"
            ;;
        q)
            echo "Exiting the program. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option, please select a valid number (1-8)."
            ;;
    esac
}

# Main script loop
while true; do
    show_menu
    read -r choice
    run_command "$choice"
    echo
    echo -n "Press any key to return to the menu..."
    read -n 1 -s
done
