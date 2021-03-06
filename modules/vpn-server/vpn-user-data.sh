#!/bin/bash

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

INSTANCE_IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
MASTER_DNS=${master_dns_ip}
SLAVE_DNS=${slave_dns_ip}
VPC_CIDR=${vpc_cidr}
VPN_CLIENT_SUBNET=${vpn_client_subnet}
 
# ########################################## 
# Do some configuration stuff for VPN
# ########################################## 
 
# The variables below are filled in via Terraform interpolation 
 
sed -i -e 's/local_IP/'$INSTANCE_IP'/g' /tmp/aws.server.conf
sed -i -e 's/master_DNS_IP/'$MASTER_DNS'/g' /tmp/aws.server.conf
sed -i -e 's/slave_DNS_IP/'$SLAVE_DNS'/g' /tmp/aws.server.conf
sed -i -e 's/VPN_CLIENT_SUBNET/'$VPN_CLIENT_SUBNET'/g' /tmp/aws.server.conf

  for i in $(echo $VPC_CIDR | sed "s/,/ /g")
    do
      VPC_UPDATE+='push_"route_'$i'_255.255.255.0"\n'
    done
  sed -i '/vpc_cidr/c '$VPC_UPDATE'' /tmp/aws.server.conf
  sed -i -e 's/_/ /g' /tmp/aws.server.conf

 sudo cp /tmp/aws.server.conf /etc/openvpn/server/aws.conf
 
# ######################################### 
# Start OpenVPN
# ######################################### 

sudo systemctl start openvpn-server@aws.service

# ######################################### 
# Configure IP tables
# ######################################### 
 
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
sudo sysctl -w net.ipv4.ip_forward=1