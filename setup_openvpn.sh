#!/bin/bash -ex

#install bind

sudo yum -y install bind bind-utils
sudo yum -y install wget

wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget http://dl.fedoraproject.org/pub/archive/epel/5/i386//easy-rsa-2.2.2-1.el5.noarch.rpm

sudo cp /tmp/openvpn.service /usr/lib/systemd/system/openvpn.service

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

  INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
  AWS_REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region'`

  echo $INSTANCE_ID

#pull private dns name to use in update
  PRIVATEDNSIP=`aws ec2 describe-instances --instance-id $INSTANCE_ID --region $AWS_REGION | jq .Reservations[].Instances[].PrivateIpAddress |sed 's/\"//g'`

  echo $PRIVATEDNSIP
  sed -i -e 's/local_IP/'$PRIVATEDNSIP'/g' /tmp/aws.server.conf

  MASTER_INSTANCE_ID=`aws --output text --region $AWS_REGION ec2 describe-tags --filters 'Name=tag:Type,Values=dns_master' | awk '{print $3}'`
  MASTER_SERVER_IP=`aws ec2 describe-instances --instance-id $MASTER_INSTANCE_ID --region $AWS_REGION | jq .Reservations[].Instances[].PublicIpAddress |sed 's/\"//g'`

  sed -i -e 's/master_DNS_IP/'$MASTER_SERVER_IP'/g' /tmp/aws.server.conf

  SLAVE_INSTANCE_ID=`aws --output text --region $AWS_REGION ec2 describe-tags --filters 'Name=tag:Type,Values=dns_slave' | awk '{print $3}'`
  SLAVE_SERVER_IP=`aws ec2 describe-instances --instance-id $SLAVE_INSTANCE_ID --region $AWS_REGION | jq .Reservations[].Instances[].PublicIpAddress |sed 's/\"//g'`

  sed -i -e 's/slave_DNS_IP/'$SLAVE_SERVER_IP'/g' /tmp/aws.server.conf
  VPC_CIDRS=`aws ec2 describe-vpcs  --region $AWS_REGION --vpc-id $VPC_ID |  jq .Vpcs[].CidrBlockAssociationSet[].CidrBlock |sed 's/\"//g' | awk -F/ '{print $1}'`
  echo VPC_CIDRS $VPC_CIDRS
  for VPC_CIDR in $VPC_CIDRS
    do
      VPC_UPDATE+='push_"route_'$VPC_CIDR'_255.255.255.0"\n'
    done
  sed -i '/vpc_cidr/c '$VPC_UPDATE'' /tmp/aws.server.conf
  sed -i -e 's/_/ /g' /tmp/aws.server.conf

  sudo cp /tmp/aws.server.conf /etc/openvpn/server/aws.server.conf

sudo systemctl enable openvpn
sudo systemctl start openvpn
