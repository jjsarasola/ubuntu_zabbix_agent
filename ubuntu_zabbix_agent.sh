#!/bin/bash

# Prompt user for the Zabbix server IP address
read -p "Enter the Zabbix server IP address: " ZABBIX_SERVER_IP

# Detect the system hostname - Uncomment the following line if you want to automatically set the Zabbix hostname parameter to the value of the server hostname.
# HOSTNAME=$(hostname)

# Update the package list and install the Zabbix agent
sudo apt update
sudo apt install zabbix-agent -y

# Update the Zabbix agent configuration file
sudo sed -i "s/Server=127.0.0.1/Server=$ZABBIX_SERVER_IP/g" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/ServerActive=127.0.0.1/ServerActive=$ZABBIX_SERVER_IP/g" /etc/zabbix/zabbix_agentd.conf

# Uncomment the following line if you want to automatically set the Zabbix hostname parameter to the value of the server hostname.
# sudo sed -i "s/# Hostname=/Hostname=$HOSTNAME/g" /etc/zabbix/zabbix_agentd.conf

# Start and enable the Zabbix agent service
sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent

# Detect the active firewall and allow Zabbix agent through it
if command -v csf &>/dev/null; then
    # If ConfigServer Firewall (lfd) is installed
    sudo csf -a $ZABBIX_SERVER_IP
    echo "Zabbix agent has been installed, configured, and firewall rule added to lfd."
elif command -v ufw &>/dev/null; then
    # If UFW is installed
    sudo ufw allow from $ZABBIX_SERVER_IP to any port 10050
    echo "Zabbix agent has been installed, configured, and firewall rule added to UFW."
else
    echo "Firewall detection failed. No supported firewall found."
fi
