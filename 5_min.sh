#/bin/bash
sudo adduser realredteam --shell=/bin/false --no-create-home --disabled-password

USER_LIST=$(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd)
EXCLUDED_USERS=("greyteam" "grayteam" "blackteam")
# Loop through each user and set a new password
for USER in $USER_LIST; do
    # Change the user's password
    if [[ " ${EXCLUDED_USERS[@]} " =~ " $USER " ]]; then
        echo "Skipping user: $USER"
        continue
    fi
    
    echo "$USER:3blue3team" | sudo chpasswd
    
    if [[ $? -eq 0 ]]; then
        echo "Password successfully changed for user: $USER"
    else
        echo "Failed to change password for user: $USER"
    fi
done

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

# Allow incoming connections on port 443
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 80 -j ACCEPT

# Allow outgoing connections on port 443
sudo iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
sudo iptables -A OUTPUT -p udp --sport 80 -j ACCEPT

# Allow incoming connections on port 443
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 443 -j ACCEPT

# Allow outgoing connections on port 443
sudo iptables -A OUTPUT -p tcp --sport 443 -j ACCEPT
sudo iptables -A OUTPUT -p udp --sport 443 -j ACCEPT

# Log dropped packets (optional, can help with debugging)
sudo iptables -A INPUT -j LOG --log-prefix "iptables-blocked: "
sudo iptables -A OUTPUT -j LOG --log-prefix "iptables-blocked: "

echo "Firewall rules have been applied: blocking all except ports 80, 443, and 21115-21117."

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

# Stop the FTP service (replace with your FTP service name)
sudo systemctl stop vsftpd
sudo systemctl disable vsftpd

sudo systemctl stop proftpd
sudo systemctl disable proftpd

#defaultservices=("anacron.service" "apparmor.service" "avahi-daemon.service" "cloud-config.service" "cloud-final.service" "cloud-init-local.service" "cloud-init.service" "colord.service" "console-setup.service" "cron.service" "cups-browsed.service" "cups.service" "dbus.service" "getty@tty1.service" "ifupdown-pre.service" "keyboard-setup.service" "kmod-static-nodes.service" "lightdm.service" "lm-sensors.service" "ModemManager.service" "networking.service" "NetworkManager-wait-online.service" "NetworkManager.service" "plymouth-quit-wait.service" "plymouth-read-write.service" "plymouth-start.service" "polkit.service" "rtkit-daemon.service" "ssh.service" "systemd-binfmt.service" "systemd-journal-flush.service" "systemd-journald.service" "systemd-logind.service" "systemd-modules-load.service" "systemd-random-seed.service" "systemd-remount-fs.service" "systemd-sysctl.service" "systemd-sysusers.service" "systemd-timesyncd.service" "systemd-tmpfiles-setup-dev.service" "systemd-tmpfiles-setup.service" "systemd-udev-trigger.service" "systemd-udevd.service" "systemd-update-utmp.service" "systemd-user-sessions.service" "udisks2.service" "upower.service" "user-runtime-dir@1000.service" "user@1000.service" "wpa_supplicant.service")

# File containing the list of services to compare
SERVICE_FILE="servicelist"

# Check if the service file exists
if [[ ! -f $SERVICE_FILE ]]; then
    echo "Error: Service file '$SERVICE_FILE' not found."
    exit 1
fi

# Get the list of active services using systemctl
ACTIVE_SERVICES=$(systemctl list-units --type=service --state=running | awk '{print $1}' | grep -E "\.service$")

# Read the input file containing expected services
EXPECTED_SERVICES=$(cat "$SERVICE_FILE")

echo "Services currently running but not listed in $SERVICE_FILE:"
comm -13 <(echo "$EXPECTED_SERVICES" | sort) <(echo "$ACTIVE_SERVICES" | sort)
