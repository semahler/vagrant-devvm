#!/usr/bin/env bash

function label {
    echo -e "\n\033[0;34m=> ${1}\033[0m\n"
}

label "Update System"
sudo apt-get update
sudo apt-get upgrade -y

label "Install Apache"
sudo apt-get install -y apache2
#sudo echo "ServerName localhost" >> /etc/apache2/apache2.conf
rm -rf *

label "Install PHP 7.1"
sudo apt-add-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php7.1

label "Installing MariaDB-Server"
sudo apt-get install -y mariadb-server

label "Configure MariaDB-Server"
sudo /etc/init.d/mysql restart

# set root password
sudo /usr/bin/mysqladmin -u root password 'vagrant'

# allow remote access (required to access from our private network host. Note that this is completely insecure if used in any other way)
mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# drop the anonymous users
mysql -u root -ppassword -e "DROP USER ''@'localhost';"
mysql -u root -ppassword -e "DROP USER ''@'$(hostname)';"

# drop the demo database
mysql -u root -ppassword -e "DROP DATABASE test;"

# restart
sudo /etc/init.d/mysql restart

#label "Install tools"
sudo apt-get install -y zip unzip vim git

