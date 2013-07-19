#!/bin/bash

if [ ! -f /home/vagrant/.chef/knife.db ]; then
  echo "Preparing to install chef server..."
  mkdir -p /vagrant/packages
  cd /vagrant/packages
  echo "downloading chef-server debian package.  this may take some time..."
  wget -nc https://opscode-omnitruck-release.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.0.6-1.ubuntu.12.04_amd64.deb
  echo "installing chef-server package"
  sudo dpkg -i chef-server*.deb
  echo "configuring chef-server (installs dependencies and configures them)"
  sudo chef-server-ctl reconfigure

  mkdir -p /home/vagrant/.chef
  sudo cp /etc/chef-server/admin.pem /home/vagrant/.chef/
  sudo cp /etc/chef-server/chef-validator.pem /home/vagrant/.chef/
  mkdir -p /vagrant/.chef
  sudo cp /home/vagrant/.chef/* /vagrant/.chef/

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

  echo "Chef server installed!!\nNow let us configure up the cookbooks."
  if [ ! -d /vagrant/chef-cookbooks ]; then
    echo "I need those chef cookbooks try doing this from vagrant home"
    echo "git submodule add git@github.com:rcbops/chef-cookbooks.git"
    echo "git submodule update --init --recursive"
    exit 2
  fi
  cd /vagrant/chef-cookbooks
  echo "uploading cookbooks to the chef-server"
  knife cookbook upload -o cookbooks --all
  echo "updating roles to chef-server"
  knife role from file roles/*.rb
  knife environment from file /vagrant/env_vagrant.json
  knife node from file /vagrant/allinone_node.json
  knife node from file /vagrant/single_controller_node.json
  knife node from file /vagrant/single_compute_node.json

  echo "Completed installing & configuring chef-server along with cookbooks, roles, nodes, environments upload"
else
  echo "chef server already installed!"
fi