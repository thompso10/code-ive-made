#!/bin/bash

# Flush existing nftables rules
nft flush ruleset

# Define the nftables rules
nft add table inet filter

# Set default policies to drop incoming and forwarding traffic, allow outgoing
nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }
nft add chain inet filter forward { type filter hook forward priority 0 \; policy drop \; }
nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }

# Allow loopback interface traffic (for internal processes)
nft add rule inet filter input iif "lo" accept

# Allow established and related connections
nft add rule inet filter input ct state established,related accept

# Allow incoming connections on the specified port range (21114-21149) for both TCP and UDP
nft add rule inet filter input tcp dport 21114-21149 accept
nft add rule inet filter input udp dport 21114-21149 accept

# Save the nftables rules
nft list ruleset > /etc/nftables.conf

echo "Firewall rules have been applied and saved."
