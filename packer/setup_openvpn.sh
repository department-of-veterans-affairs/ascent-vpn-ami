#!/bin/bash -ex

#install bind

sudo yum -y install bind bind-utils
sudo yum -y install wget

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget http://dl.fedoraproject.org/pub/archive/epel/5/i386//easy-rsa-2.2.2-1.el5.noarch.rpm

sudo yum -y install epel-release-latest-7.noarch.rpm 
sudo yum -y install openvpn
sudo yum -y install easy-rsa-2.2.2-1.el5.noarch.rpm
cd /usr/share/easy-rsa/2.0
sudo cp /tmp/vars /usr/share/easy-rsa/2.0/
sudo cp /tmp/clean-all /usr/share/easy-rsa/2.0/
sudo cp /tmp/build-dh /usr/share/easy-rsa/2.0/
sudo cp /tmp/pkitool /usr/share/easy-rsa/2.0/
sudo chmod +x vars
sudo ./clean-all
sudo ./pkitool --initca
sudo ./pkitool --server server
sudo ./build-dh
