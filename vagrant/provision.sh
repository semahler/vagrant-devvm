#!/usr/bin/env bash

# Output function bold/blue
function label {
    echo -e "\n\033[0;34m==> ${1}\033[0m\n"
}

#################################################################
# Updating the OS
label "Starting: Updating System..."

sudo apt-get update
sudo apt-get upgrade -y

label "Completing: Updating System..."

#################################################################
# Remove old MySQL/Apache2 installation if exists

label "Starting: Removing MySQL and Apache2..."

label "- Stopping services"
sudo service mysql stop
sudo service apache2 stop

label "- Removing packages/cleanup"
sudo apt-get remove --purge mysql-server-5.6 mysql-client-5.6 mysql-common-5.6 mysql-common apache2*
sudo apt-get autoremove
sudo apt-get autoclean
sudo rm -rf /var/lib/mysql/
sudo rm -rf /etc/mysql/

label "Completing: Removing MySQL and Apache2..."

#################################################################
# Installing/Starting nginx

label "Starting: Install nginx..."
sudo apt-get -y install nginx

sudo service nginx start

label "Completing: Install nginx..."

#################################################################
# Set up nginx

label "- Delete old config-files"
sudo rm /etc/nginx/sites-available/*
sudo rm /etc/nginx/sites-enabled/*

label "- Copy configuration and set permissions"
sudo cp /vagrant/vagrant/nginx/default /etc/nginx/sites-available/default
sudo chmod 644 /etc/nginx/sites-available/default
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

label "- Restarting nginx"
sudo service nginx restart

#################################################################
# Install PHP7.1

label "Starting: Install PHP..."

label "Install PHP 7.1"
sudo apt-add-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php7.1-fpm
sudo apt-get install -y php7.1

label "Completing: Install PHP..."

#################################################################
# Install additional PHP modules

label "Starting: Installing PHP 7 modules..."

sudo apt-get install -y php7.1-curl php7.1-gd php7.1-intl php7.1-json php7.1-mbstring php7.1-mcrypt
sudo apt-get install -y php7.1-mysql php7.1-opcache php7.1-readline php7.1-xml php7.1-xsl php7.1-zip php7.1-bz2

label "Completing:Installing PHP 7 modules..."

#################################################################
# Install MariaDB-Server

label "Starting: Installing MariaDB-Server..."

sudo debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password vagrant'
sudo debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password vagrant'
sudo apt-get install -y mariadb-server

label "Completing: Installing MariaDB-Server..."

#################################################################
# Configure and setup MariaDB-Server

label "Starting: Configure MariaDB-Server..."

label "- Set MariaDB root user password and persmissions"
mysql -u root -pvagrant -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION; FLUSH PRIVILEGES;"

label "- Open MariaDB to be used with external clients"
sudo sed -i 's|127.0.0.1|0.0.0.0|g' /etc/mysql/my.cnf

label "- Drop the demo database"
mysql -u root -pvagrant -e "DROP DATABASE IF EXISTS test;"

label "- Restart MariaDB-Server"
sudo service mysql restart

label "Completing: Configure MariaDB-Server..."

#################################################################
# Install some useful tools

label "Starting: Install tools..."

sudo apt-get install -y zip unzip vim git

label "Completing: Install tools..."

#################################################################
# Install Composer globally

label "Starting: Install composer..."

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

label "Completing: Install composer..."

#################################################################
# Modifiy some PHP settings

label "Starting: Change PHP settings..."

sudo cp /vagrant/vagrant/nginx/php.ini /etc/php/7.1/fpm/php.ini

label "Completing: Change PHP settings..."

#################################################################
# Clean up

label "Starting: Clean up..."

sudo apt-get clean

label "Completing: Clean up..."

#################################################################
# Restarting nginx

label "Starting: Restarting nginx..."

sudo service nginx restart
sudo service php7.1-fpm restart

label "Completing: Restarting nginx..."