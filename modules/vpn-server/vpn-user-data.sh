#!/bin/bash 
 
 
sudo mv /fortify.license /root/.fortify/fortify.license 
master_dns_ip=$1 
slave_dns_ip=$2
vpc_cidr=$3
 
# ########################################## 
# Do some configuration stuff for VPN
# ########################################## 
 
# The variables below are filled in via Terraform interpolation 
 
sed -i -e 's/local_IP/'$master_dns_ip'/g' /tmp/aws.server.conf
sed -i -e 's/master_DNS_IP/'$master_dns_ip'/g' /tmp/aws.server.conf
sed -i -e 's/slave_DNS_IP/'$slave_dns_ip'/g' /tmp/aws.server.conf

  for i in $(echo $vpc_cidr | sed "s/,/ /g"
    do
      VPC_UPDATE+='push_"route_'$i'_255.255.255.0"\n'
    done
  sed -i '/vpc_cidr/c '$VPC_UPDATE'' /tmp/aws.server.conf
  sed -i -e 's/_/ /g' /tmp/aws.server.conf

 sudo cp /tmp/aws.server.conf /etc/openvpn/server/aws.server.conf
 
# ######################################### 
# Start OpenVPN
# ######################################### 

sudo systemctl start openvpn
 
