#!/usr/bin/env bash

function label {
    echo -e "\n\033[0;34m=> ${1}\033[0m\n"
}

label "Update System"
sudo apt-get update
sudo apt-get upgrade -y

label "Install Apache"
sudo apt-get install -y apache2
sudo echo "ServerName localhost" >> /etc/apache2/apache2.conf
rm -rf /var/www/html/*

label "Install PHP 7.1"
sudo apt-add-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php7.1

label "Installing PHP 7 modules"
sudo apt-get install -y php7.1-cli php7.1-curl php7.1-gd php7.1-intl php7.1-json php7.1-mbstring php7.1-mcrypt
sudo apt-get install -y php7.1-mysql php7.1-opcache php7.1-readline php7.1-xml php7.1-xsl php7.1-zip php7.1-bz2
sudo apt-get install -y libapache2-mod-php7.1
a2enconf php7.1-fpm
sudo service apache2 reload

label "Removing MySQL"
sudo service mysql stop
sudo apt-get remove --purge mysql-server-5.6 mysql-client-5.6 mysql-common-5.6
sudo apt-get autoremove
sudo apt-get autoclean
sudo rm -rf /var/lib/mysql/
sudo rm -rf /etc/mysql/

label "Installing MariaDB-Server"
sudo debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password vagrant'
sudo debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password vagrant'
sudo apt-get install -y mariadb-server

label "Configure MariaDB-Server"
# Set MariaDB root user password and persmissions
mysql -u root -pvagrant -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION; FLUSH PRIVILEGES;"

#Open MariaDB to be used with external clients
sudo sed -i 's|127.0.0.1|0.0.0.0|g' /etc/mysql/my.cnf

# drop the demo database
mysql -u root -pvagrant -e "DROP DATABASE test;"

sudo service mysql restart

#label "Install tools"
sudo apt-get install -y zip unzip vim git

