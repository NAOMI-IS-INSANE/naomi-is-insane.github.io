#!/bin/bash

mkdir /var/myLogs/

# Set locale variables
export LANGUAGE=en_AU.UTF-8
export LC_ALL=en_AU.UTF-8
export LC_TIME=en_AU.UTF-8
export LANG=en_AU.UTF-8

# Update locale to English (Australia)
echo "en_AU.UTF-8 UTF-8" > /etc/locale.gen
locale-gen > /var/myLogs/1-locale 2>&1
update-locale LANG=en_AU.UTF-8

# Set timezone to Adelaide
timedatectl set-timezone Australia/Adelaide

# Verify changes
echo "Locale has been set to English (Australia) and timezone to Adelaide."
echo "Current Locale Settings:"
locale
echo "Current Timezone:"
timedatectl

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
apt update > /var/myLogs/2-apt-update 2>&1
check_status "apt update"

# Install necessary packages
apt install -y ufw apache2 python3-certbot-apache > /var/myLogs/3-apt-install 2>&1
check_status "apt install"

# Enable firewall
echo "yes" | ufw enable > /var/myLogs/4-ufw 2>&1
check_status "ufw enable"

# Allow SSH, HTTP, and HTTPS
ufw allow 22
ufw allow 80
ufw allow 443

# Remove default Apache config files
a2dissite 000-default > /var/myLogs/5-2dissite 2>&1
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
a2ensite naomis-world > /var/myLogs/6-a2ensite 2>&1

# Obtain SSL certificate
certbot --apache
check_status "certbot --apache"

# Reload Apache
systemctl reload apache2
check_status "systemctl reload apache2"

echo "Server setup completed successfully"
