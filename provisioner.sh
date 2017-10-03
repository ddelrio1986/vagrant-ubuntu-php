#!/usr/bin/env bash

timedatectl set-timezone America/New_York

apt-get -y update

# Apache HTTP Server
apt-get install -y apache2
a2dissite 000-default
a2enmod rewrite

# MySQL (MariaDB)
apt-get install -y software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.jmu.edu/pub/mariadb/repo/10.1/ubuntu xenial main'
apt-get -y update
debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'
apt-get install -y mariadb-server

# PHP
apt-get install -y python-software-properties
add-apt-repository -y ppa:ondrej/php
apt-get update -y
apt-get install -y php7.1 libapache2-mod-php7.1 php7.1-xml php7.1-xsl php7.1-mbstring php7.1-zip php7.1-mysql php7.1-sqlite3 php7.1-opcache php7.1-pspell php7.1-json php7.1-xmlrpc php7.1-curl php7.1-ldap php7.1-bz2 php7.1-imap php7.1-cli php7.1-intl php7.1-soap php7.1-mcrypt php7.1-gd

# Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

# Application
touch /etc/apache2/sites-available/app.conf
echo '<VirtualHost *:80>' >> /etc/apache2/sites-available/app.conf
echo '    ServerName localhost' >> /etc/apache2/sites-available/app.conf
echo '    ServerAdmin ddelrio1986@gmail.com' >> /etc/apache2/sites-available/app.conf
echo '    DocumentRoot "/vagrant"' >> /etc/apache2/sites-available/app.conf
echo '    ErrorLog ${APACHE_LOG_DIR}/app-error.log' >> /etc/apache2/sites-available/app.conf
echo '    CustomLog ${APACHE_LOG_DIR}/app-access.log combined' >> /etc/apache2/sites-available/app.conf
echo '    <Directory "/vagrant">' >> /etc/apache2/sites-available/app.conf
echo '        DirectoryIndex index.php' >> /etc/apache2/sites-available/app.conf
echo '        AllowOverride All' >> /etc/apache2/sites-available/app.conf
echo '        Require all granted' >> /etc/apache2/sites-available/app.conf
echo '    </Directory>' >> /etc/apache2/sites-available/app.conf
echo '</VirtualHost>' >> /etc/apache2/sites-available/app.conf
a2ensite app
usermod -a -G www-data ubuntu
mysql -u root -ppassword < /vagrant/app.sql

service apache2 restart
service mysql restart
