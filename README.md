# ubuntu_zabbix_agent
Script to install and config zabbix agent in Ubuntu servers with UFW or LFD firewalls:

1. Create the following file in your desired location:

```
touch ubuntu_zabbix_agent.sh
```
2. Open it with your favorite text editor (vi, vi, nano, etc) and paste the script code:

```
vi ubuntu_zabbix_agent.sh
```
Script:

```bash
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

# Restart Zabbix Agent
sudo service zabbix-agent restart
```

3.  Make it executable, and run it with superuser privileges:

```
chmod +x ubuntu_zabbix_agent.sh
sudo ./ubuntu_zabbix_agent.sh
```

4. Enter the IP address of your Zabbix server. It can be more than one server IP, separated by a comma.
