#!/bin/bash
set -e -x

if [ -z $BUILD_TAG ]; then
  echo 'Missing $BUILD_TAG variable, assuming we are not running in jenkins'
  BUILD_TAG=`date +%s`
  echo "Generated build_tag: #{BUILD_TAG}"
fi

VM_NAME="vm_for_$BUILD_TAG"

bundle install
bundle exec librarian-chef install

cat <<EOF > Vagrantfile
Vagrant.configure("2") do |config|
  config.ssh.username = "vagrant"
  config.vm.define "$VM_NAME" # give the VM a unique name
  config.vm.box     = "precise64"
  config.omnibus.chef_version = :latest
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['cookbooks', 'site-cookbooks']
    chef.add_recipe 'apt'
    chef.add_recipe 'packages'
    chef.add_recipe 'golang'
    chef.add_recipe 'chef_rubies'
    chef.add_recipe 'warden'
    chef.json = {
      "go" => {
        "version" => "1.2.1"
      },
      "rubies" => {
        "list" => ["ruby 1.9.3-p484"]
      },
      "warden" => {
        "user" => "vagrant",
      }
    }
  end
end
EOF

cat Vagrantfile
vagrant up

box_name=warden-compatible

vagrant halt
rm -f ${box_name}.box
vagrant package $VM_NAME --output ${box_name}.box
vagrant box add ${box_name} ${box_name}.box --force

vagrant destroy --force
rm Vagrantfile
rm -rf .vagrant
