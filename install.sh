#!/bin/bash

mkdir /var/myLogs/

# Function to check the exit status of commands
check_status() {
    if [ $? -ne 0 ]; then
        echo "Failed to execute: $1"
        exit 1
    fi
}

# Change the password
passwd
check_status "passwd"

# Update package list
apt update
check_status "apt update" > /var/myLogs/aptUpdate 2>&1

# Install necessary packages
apt install -y ufw apache2 python3-certbot-apache > /var/myLogs/aptInstall 2>&1
check_status "apt install"

# Enable firewall
echo "yes" | ufw enable > /var/myLogs/ufwSetup 2>&1
check_status "ufw enable"

# Allow SSH, HTTP, and HTTPS
ufw allow 22
ufw allow 80
ufw allow 443
check_status "ufw allow"

# Remove default Apache config files
ls /etc/apache2/sites-available/
a2dissite 000-default
rm /etc/apache2/sites-available/000-default.conf
rm /etc/apache2/sites-available/default-ssl.conf

# Create directories and download index.html
mkdir -p /var/www/naomis-world.com/public_html
curl -o /var/www/naomis-world.com/public_html/index.html https://naomi-is-insane.github.io/server/index.html
if [ $? -ne 0 ]; then
    echo "Unable to download index.html"
    exit 1
fi

# Download and enable custom Apache config
curl -o /etc/apache2/sites-available/naomis-world.conf https://naomi-is-insane.github.io/server/naomis-world.conf
if [ $? -ne 0 ]; then
    echo "Unable to download naomis-world.conf"
    exit 1
fi
a2ensite naomis-world

# Obtain SSL certificate
certbot --apache
check_status "certbot --apache"

# Reload Apache
systemctl reload apache2
check_status "systemctl reload apache2"

echo "Server setup completed successfully"
