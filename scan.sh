#!/bin/bash

# Paths to relevant files
usernames_path="/home/kali/Desktop/SecLists/Usernames/cirt-default-usernames.txt"
rockyou_path="/home/kali/Desktop/SHORTER_ROCKYOU.TXT"  # Changed to the shorter rockyou list
current_directory=$(pwd)
services=("ssh" "rdp" "ftp" "telnet")

# 1.1 Get the network range from the user
while true; do
    read -p $'\033[1mEnter network range (e.g., 192.168.1.0/24): \033[0m' network_range
    if [[ "$network_range" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/([0-9]|[1-2][0-9]|3[0-2]))?$ ]]; then
        echo -e "\033[1mValid network range. Continuing...\033[0m"
        break
    else
        echo -e "\033[1mInvalid input. Try again.\033[0m"
    fi
done

# 1.2 Get the output directory name from the user
while true; do
    read -p $'\033[1mEnter output directory name: \033[0m' output_directory
    if [[ "$output_directory" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        if [ -d "$current_directory/$output_directory" ]; then
            echo -e "\033[1mDirectory exists. Choose another name.\033[0m"
        else
            mkdir "$current_directory/$output_directory"
            echo -e "\033[1mDirectory created: $current_directory/$output_directory\033[0m"
            break
        fi
    else
        echo -e "\033[1mInvalid name. Use letters, numbers, underscores, or hyphens.\033[0m"
    fi
done

# 1.3 Network scanning
scan_network() {
    echo -e "\033[1mScanning TCP ports...\033[0m"
    tcp_output="$current_directory/$output_directory/tcp_scan_results.txt"
    nmap -sS -sV --top-ports 1000 -T4 "$network_range" > "$tcp_output"
    echo -e "\033[1mTCP scan results saved to $tcp_output\033[0m"
    
    echo -e "\033[1mScanning UDP ports...\033[0m"
    udp_output="$current_directory/$output_directory/udp_scan_results.txt"
    nmap -sU -sV --top-ports 100 -T4 "$network_range" > "$udp_output"
    echo -e "\033[1mUDP scan results saved to $udp_output\033[0m"
}

# 2. Weak credential scanning
scan_weak_credentials() {
    while true; do
        read -p $'\033[1mUse default password list or provide your own? (default/own): \033[0m' user_password_choice
        case "$user_password_choice" in
            default)
                echo -e "\033[1mUsing default password list.\033[0m"
                break;;
            own)
                read -p $'\033[1mEnter path to your password list: \033[0m' user_password_list
                [[ -f "$user_password_list" ]] && break || echo -e "\033[1mInvalid file. Try again.\033[0m"
                ;;
            *) 
                echo -e "\033[1mInvalid choice. Enter 'default' or 'own'.\033[0m" ;;
        esac
    done

    for service in "${services[@]}"; do
        echo -e "\033[1mScanning $service for Weak Credentials...\033[0m"
        password_list=${user_password_choice/own/$user_password_list}
        password_list=${password_list/default/$rockyou_path}  # Using the new shorter rockyou file
        
        hydra -l "$usernames_path" -P "$password_list" -t 4 "$network_range" $service 2>/dev/null | grep -i '\[.*\] host:.* login:'
    done
}

# 3. Mapping vulnerabilities
Mapping_Vulnerabilities() {
    echo -e "\033[1mStarting vulnerability mapping...\033[0m"
    output_file="$current_directory/$output_directory/vulnerability_scan_results.txt"

    available_services=$(nmap -sV --script vuln --top-ports 1000 -T4 "$network_range" | \
        awk '$2=="open" { for(i=4;i<=NF;i++) printf "%s ", $i; print "" }')

    echo "$available_services" > "$output_file"

    echo -e "\033[1mDetected services and versions:\033[0m"
    echo "$available_services"

    while true; do
        read -p "Enter service to search in searchsploit (or 'exit' to quit): " service_choice
        [[ "$service_choice" == "exit" ]] && break
        searchsploit "$service_choice"
    done
}

# 1.4 Selecting scan type
while true; do
    read -p "Choose scan type: Basic or Full: " user_scan_choice
    [[ "$user_scan_choice" =~ ^(Basic|Full)$ ]] && break || echo -e "\033[1mInvalid input. Enter 'Basic' or 'Full'.\033[0m"
done

# Executing the scan based on user selection
scan_network
scan_weak_credentials
[[ "$user_scan_choice" == "Full" ]] && Mapping_Vulnerabilities

# Compressing results
cd "$current_directory/$output_directory" && zip -r "results.zip" ./*
echo -e "\033[1mResults saved in results.zip\033[0m"
