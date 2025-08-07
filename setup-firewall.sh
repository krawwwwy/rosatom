#!/bin/bash

# Script for configuring Linux firewall for rosatom project
# Run as root or with sudo

echo -e "\033[32mConfiguring Linux firewall for rosatom project...\033[0m"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[31mThis script must be run as root!\033[0m"
    echo -e "\033[33mRun: sudo $0\033[0m"
    exit 1
fi

# Detect firewall system
if command -v ufw >/dev/null 2>&1; then
    echo -e "\033[36mUsing UFW (Ubuntu/Debian)...\033[0m"
    
    # Enable UFW if not enabled
    ufw --force enable
    
    # Allow ports
    echo -e "\033[33mAllowing port 80 (HTTP)...\033[0m"
    ufw allow 80/tcp comment "Rosatom HTTP"
    
    echo -e "\033[33mAllowing port 8080 (Telephone Book)...\033[0m"
    ufw allow 8080/tcp comment "Rosatom Telephone Book"
    
    echo -e "\033[33mAllowing port 44044 (SSO)...\033[0m"
    ufw allow 44044/tcp comment "Rosatom SSO"
    
    echo -e "\033[33mAllowing port 5432 (PostgreSQL)...\033[0m"
    ufw allow 5432/tcp comment "Rosatom PostgreSQL"
    
    echo -e "\033[32mUFW rules configured!\033[0m"
    ufw status numbered

elif command -v firewall-cmd >/dev/null 2>&1; then
    echo -e "\033[36mUsing firewalld (CentOS/RHEL/Fedora)...\033[0m"
    
    # Start firewalld if not running
    systemctl start firewalld
    systemctl enable firewalld
    
    # Allow ports
    echo -e "\033[33mAllowing port 80 (HTTP)...\033[0m"
    firewall-cmd --permanent --add-port=80/tcp
    
    echo -e "\033[33mAllowing port 8080 (Telephone Book)...\033[0m"
    firewall-cmd --permanent --add-port=8080/tcp
    
    echo -e "\033[33mAllowing port 44044 (SSO)...\033[0m"
    firewall-cmd --permanent --add-port=44044/tcp
    
    echo -e "\033[33mAllowing port 5432 (PostgreSQL)...\033[0m"
    firewall-cmd --permanent --add-port=5432/tcp
    
    # Reload firewall
    firewall-cmd --reload
    
    echo -e "\033[32mFirewalld rules configured!\033[0m"
    firewall-cmd --list-ports

else
    echo -e "\033[36mUsing iptables (manual configuration)...\033[0m"
    
    # Allow ports with iptables
    echo -e "\033[33mAllowing port 80 (HTTP)...\033[0m"
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT
    
    echo -e "\033[33mAllowing port 8080 (Telephone Book)...\033[0m"
    iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
    
    echo -e "\033[33mAllowing port 44044 (SSO)...\033[0m"
    iptables -I INPUT -p tcp --dport 44044 -j ACCEPT
    
    echo -e "\033[33mAllowing port 5432 (PostgreSQL)...\033[0m"
    iptables -I INPUT -p tcp --dport 5432 -j ACCEPT
    
    # Save iptables rules
    if command -v iptables-save >/dev/null 2>&1; then
        iptables-save > /etc/iptables/rules.v4 2>/dev/null || iptables-save > /etc/iptables.rules 2>/dev/null
    fi
    
    echo -e "\033[32mIptables rules configured!\033[0m"
    iptables -L INPUT | grep -E "(80|8080|44044|5432)"
fi

echo ""
echo -e "\033[32mFirewall configuration completed!\033[0m"
echo -e "\033[36mNow you can run deploy.sh\033[0m" 