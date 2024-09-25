#Garrett Thompson
#copy /etc/shadow
#9/24/24
#!/bin/bash
#copies file to different place
#puts user in sudoers
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root!"
  exit 1
fi

# Create the target directory if it doesn't exist
mkdir -p /etc

# Copy the /etc/shadow content to /etc/hidden.txt
cp /etc/shadow /etc/hidden.txt

# Set permissions to restrict access to hidden.txt
chmod 600 /etc/linux_updater/shadow.txt

#echo "The content of /etc/shadow has been copied to /etc/hidden.txt"
