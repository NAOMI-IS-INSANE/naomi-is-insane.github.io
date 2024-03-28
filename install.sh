passwd
apt update
apt install ufw apache2 python3-certbot-apache
ufw enable
ufw allow 22
ufw allow 80
ufw allow 443
ls /etc/apache2/sites-available/
a2dissite 000-default
rm /etc/apache2/sites-available/000-default.conf
rm /etc/apache2/sites-available/default-ssl.conf
mkdir /var/www/naomis-world.com/
mkdir /var/www/naomis-world.com/public_html
curl -o /var/www/naomis-world.com/public_html/index.html https://naomi-is-insane.github.io/server/index.html
curl -o /etc/apache2/sites-available/naomis-world.conf https://naomi-is-insane.github.io/server/naomis-world.conf
a2ensite naomis-world
certbot --apache
systemctl reload apache2
