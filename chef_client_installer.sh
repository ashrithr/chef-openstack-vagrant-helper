#!/bin/bash

if [ ! -f /home/vagrant/.chef/knife.db ]; then
  echo "Preparing to install chef client..."
  echo '33.33.33.50 chefserver.local' >> /etc/hosts
  apt-get -y install curl git links
  curl --silent -L http://www.opscode.com/chef/install.sh | bash
  sudo mkdir -p /etc/chef
  sudo cp /vagrant/.chef/chef-validator.pem /etc/chef/validation.pem
  mkdir -p /home/vagrant/.chef
  sudo cp /vagrant/.chef/*.pem /home/vagrant/.chef/

cat<<CHEF > /etc/chef/client.rb
    log_level        :info
    log_location     STDOUT
    chef_server_url  'https://33.33.33.50/'
    validation_client_name 'chef-validator'
CHEF


cat<<KNIFE > /home/vagrant/.chef/knife.rb
log_level                :info
log_location             STDOUT
node_name                'admin'
client_key               '/home/vagrant/.chef/admin.pem'
validation_client_name   'chef-validator'
validation_key           '.chef/chef-validator.pem'
chef_server_url          'https://chefserver.local'
cache_type               'BasicFile'
cache_options( :path => '/home/vagrant/.chef/checksums' )
KNIFE

  sudo chown vagrant. /vagrant/.chef/*
  sudo chown vagrant. /home/vagrant/.chef/*

# multiple runs just to be sure, had some weird issues on first run.
# seems to help clear up some weirdness where it tries to launch instances
# using KVM rather than the Qemu as set in the environment JSON file.
# run once
chef-client
# run twice
chef-client
# run thrice
chef-client

echo "restart all the services for shits n giggles..."
cd /etc/init.d/; for i in $(ls nova-*); do sudo service $i restart; done

echo "check if all services are running..."
sudo nova-manage service list

echo "##################################"
echo "#     Openstack Installed        #"
echo "#   visit https://33.33.33.60    #"
echo "#   default username: admin      #"
echo "#   default password: secrete    #"
echo "##################################"

else
  echo "chef Client already installed!, kicking a chef-client"
  chef-client
fi