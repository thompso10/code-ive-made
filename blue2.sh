#!/bin/bash

# Define the new password
NEW_PASSWORD="3blue_3team"

# Loop through all users in /etc/passwd
for USER in $(cut -d: -f1 /etc/passwd); do
    # Skip system users (UID < 1000 are typically system users)
    if [ "$(id -u $USER)" -ge 1000 ]; then
        # Change the password for each user
        echo "$USER:$NEW_PASSWORD" | sudo chpasswd
        echo "Password changed for $USER"
    fi
done
