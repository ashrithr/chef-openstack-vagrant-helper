Test openstack deployments on vagrant using chef (rackspace recipes):

##Usage:

Req: Install [Vagrant](http://www.vagrantup.com/)

Download

  ```
  git clone --recursive https://github.com/ashrithr/chef-openstack-vagrant-helper.git
  ```
Install Chef server

  ```
  vagrant up chef
  ```
Deploy using 2 ways:

1. `all-in-one` which deploys openstack controller & openstack compute on the same node

  ```
  vagrant up allinone
  ```
2. seperate openstack controller and openstack compute

  ```
  vagrant up single_controller
  vagrant up single_compute
  ```
