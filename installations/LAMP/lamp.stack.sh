#!/usr/bin/env bash
########################################################################
###                   LAMP STACK Environment preparation
###
###   Author: Israel Olvera
###   Version: 1.0
###
########################################################################

YELLOW='\033[1;33m';
GREEN='\033[0;32m';
RED='\033[0;31m';

echo -e "${GREEN} Apache, MariaDB and PHP Installation..." &&

# Apache2 Installation
echo -e "${YELLOW} Installing Apache2..." && sudo apt install apache2 -y && sudo systemctl enable apache2;

# MariaDB Installation
echo -e "${YELLOW} Installing MariaDB..." &&
sudo apt-key adv --recv-keys --keyserver hkp: //keyserver.ubuntu.com: 80 0xF1656F24C74CD1D8 &&
sudo add-apt-repository 'deb [arch = amd64, arm64, ppc64el] http://sgp1.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main' &&
sudo apt update && sudo apt mariadb-server -y && sudo systemctl enable mysql;

# PHP 7.3 Installation
echo -e "${YELLOW} PHP v7.3 Installing..." &&
sudo apt install software-properties-common &&
sudo add-apt-repository ppa:ondrej/php && sudo apt update &&
sudo apt install php7.3 php7.3-common php7.3-mysql php7.3-xml php7.3-xmlrpc php7.3-curl php7.3-gd php7.3-imagick php7.3-cli php7.3-dev php7.3-imap php7.3-mbstring php7.3-opcache php7.3-soap php7.3-zip php7.3-intl -y &&
sudo touch "/var/www/html/info.php" && "<?php phpinfo(); ?>" > /var/www/html/info.php &&
echo -e "${GREEN} See https://localhost and https://localhost/info.php to verify that all well fine";