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
# Install PHP7.1

label "Starting: Install PHP..."

label "Install PHP 7.1"
sudo apt-add-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php7.1

label "Completing: Install PHP..."

#################################################################
# Install additional PHP modules

label "Starting: Installing PHP 7 modules..."

sudo apt-get install -y php7.1-cli php7.1-curl php7.1-gd php7.1-intl php7.1-json php7.1-mbstring php7.1-mcrypt
sudo apt-get install -y php7.1-mysql php7.1-opcache php7.1-readline php7.1-xml php7.1-xsl php7.1-zip php7.1-bz2

label "Completing:Installing PHP 7 modules..."

#################################################################
# Remove old MySQL installation if exists

label "Starting: Removing MySQL..."

sudo service mysql stop
sudo apt-get remove --purge mysql-server-5.6 mysql-client-5.6 mysql-common-5.6 mysql-common
sudo apt-get autoremove
sudo apt-get autoclean
sudo rm -rf /var/lib/mysql/
sudo rm -rf /etc/mysql/

label "Completing: Removing MySQL..."

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

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL \& \~E_DEPRECATED/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 1024M/" /etc/php/7.1/apache2/php.ini
sudo sed -i "s/;date.timezone = */date.timezone = \"Europe\/Berlin\"/" /etc/php/7.1/apache2/php.ini

label "Completing: Change PHP settings..."

#################################################################
# Clean up

label "Starting: Clean up..."

sudo apt-get clean

label "Completing: Clean up..."