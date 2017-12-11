#!/usr/bin/env bash

#
# Author: Daniel Pellarini
# GitHub profile: dp87 - https://github.com/dp87/
# Date: 11/12/2017
#
# Provisioning script to install Monica Personal Relationship Manager on a Ubuntu 16.04 box
#

echo "########################"
echo "Installing prerequisites"
echo "########################"
echo "Installing apache"
#apt-get update >/dev/null 2>&1
apt-get update
apt-get install -y apache2
echo "ServerName vagrant" >> /etc/apache2/apache2.conf # suppress apache warning
systemctl restart apache2
echo "Installing MySQL with default root password"
debconf-set-selections <<< 'mysql-server mysql-server/root_password password changeme'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password changeme'
apt-get install -y mysql-server mysql-client
#echo "Installing PHP"
#apt-get install -y php libapache2-mod-php php-mcrypt php-mysql >/dev/null 2>&1
echo "Installing PHP 7.1"
add-apt-repository -y ppa:ondrej/php
apt-get update >/dev/null
apt-get install -y php7.1 >/dev/null
echo "Installing git"
apt-get install -y git >/dev/null
echo "Installing composer"
apt-get install -y curl php7.1-cli git
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
echo "Installing packages for Monica"
apt-get install -y php7.1-intl php7.1-simplexml php7.1-gd php7.1-mbstring php7.1-curl php7.1-zip php7.1-mysql
echo "Getting database ready"
mysql -uroot -pchangeme -e "CREATE DATABASE monica;"
mysql -uroot -pchangeme -e "CREATE USER 'monica'@'localhost' IDENTIFIED BY 'changeme';"
mysql -uroot -pchangeme -e "GRANT ALL ON monica.* TO 'monica'@'localhost';"
mysql -uroot -pchangeme -e "FLUSH PRIVILEGES;"
echo "Installing Monica"
cd /var/www/html
git clone https://github.com/monicahq/monica.git
cd monica/
chown -R www-data:www-data /var/www/html/monica
sudo -u www-data composer install
echo "Configuring Monica"
sudo -u www-data cp .env.example .env
sudo -u www-data sed -i 's/DB_USERNAME=homestead/DB_USERNAME=monica/g' .env
sudo -u www-data sed -i 's/DB_PASSWORD=secret/DB_PASSWORD=changeme/g' .env
sudo -u www-data sed -i 's/APP_DISABLE_SIGNUP=true/APP_DISABLE_SIGNUP=false/g' .env
sudo -u www-data php artisan key:generate
sudo -u www-data php artisan migrate
sudo -u www-data php artisan storage:link
sudo -u www-data php artisan db:seed --class ActivityTypesTableSeeder
sudo -u www-data php artisan db:seed --class CountriesSeederTable
sudo -u www-data php artisan passport:install
echo "Configuring cron script"
{ crontab -l -u www-data; echo '* * * * * sudo -u www-data /usr/bin/php /var/www/html/artisan schedule:run'; } | crontab -u www-data -
echo "Configuring apache"
a2enmod rewrite
sed -i 's/\/var\/www\/html/\/var\/www\/html\/monica\/public/g' /etc/apache2/sites-enabled/000-default.conf
sed -i 's/\/var\/www/\/var\/www\/html\/monica/g' /etc/apache2/apache2.conf
sed -i '/<Directory \/var\/www\/html\/monica\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
echo "Restarting apache"
service apache2 restart
echo "Done! You can access Monica by visiting http://localhost:8080 from your host machine"
