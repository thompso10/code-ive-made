#/bin/bash

#change passwords
while IFS= read -r user; do
  echo "$user:3blue3team" | sudo chpasswd
done < /tmp/users

echo "Setting up a firewall to block all traffic..."

# Flush existing iptables rules
sudo iptables -F
sudo iptables -X

# Set default policies to DROP all incoming, outgoing, and forwarded packets
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP

# Allow incoming traffic on loopback interface (for local system communication)
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow incoming connections on ports 21115-21117
sudo iptables -A INPUT -p tcp --dport 21115:21117 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 21115:21117 -j ACCEPT

# Allow outgoing connections on ports 21115-21117
sudo iptables -A OUTPUT -p tcp --sport 21115:21117 -j ACCEPT
sudo iptables -A OUTPUT -p udp --sport 21115:21117 -j ACCEPT

# Log dropped packets (optional, can help with debugging)
sudo iptables -A INPUT -j LOG --log-prefix "iptables-blocked: "
sudo iptables -A OUTPUT -j LOG --log-prefix "iptables-blocked: "

echo "Firewall rules have been applied: blocking all except ports 21115-21117."

#Clear out crontab
echo clearing out crontab
crontab -r

#Clear out /.ssh
SSH_DIR="$HOME/.ssh"

if [ -d "$SSH_DIR" ]; then
  echo "Deleting all contents of $SSH_DIR..."
  
  rm -rf "$SSH_DIR"/*
  
  echo "All contents of $SSH_DIR have been deleted."
else
  echo "No .ssh directory found at $SSH_DIR."
fi

#delete python because fuck you

# Uninstall Python 3
#sudo apt remove --purge python3

# Uninstall Python 2 (if applicable)
#sudo apt remove --purge python2

# Clean up any residual packages
sudo apt autoremove -y
sudo apt autoclean

# Stop the SSH service
sudo systemctl stop ssh

# Disable SSH to prevent it from starting on boot
sudo systemctl disable ssh

# Stop and disable the SSH daemon
sudo systemctl stop sshd
sudo systemctl disable sshd

# Stop the FTP service (replace with your FTP service name)
sudo systemctl stop vsftpd
sudo systemctl disable vsftpd

sudo systemctl stop proftpd
sudo systemctl disable proftpd

sudo systemctl status ssh
sudo systemctl status vsftpd  # or proftpd, depending on your setup

#!/bin/bash

# List of services to check, stop, and disable
services=("ssh" "cron" "sudo" "apache2" "mysql" "smbd" "rpcbind" "cups" "postfix" "vsftpd")

for service in "${services[@]}"; do
    # Check if the service is installed
    if systemctl list-units --type=service | grep -q "$service.service"; then
        echo "Service '$service' is installed."

        # Stop the service
        echo "Stopping $service..."
        sudo systemctl stop "$service.service"

        # Disable the service
        echo "Disabling $service..."
        sudo systemctl disable "$service.service"
        echo "$service has been stopped and disabled."
    else
        echo "Service '$service' is not installed."
    fi
done
