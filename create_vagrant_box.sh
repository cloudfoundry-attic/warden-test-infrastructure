#!/bin/bash
set -e -x

if [ -z $BUILD_TAG ]; then
  echo 'Missing $BUILD_TAG variable, assuming we are not running in jenkins'
  BUILD_TAG=`date +%s`
  echo "Generated build_tag: #{BUILD_TAG}"
fi

VM_NAME="vm_for_$BUILD_TAG"

mkdir -p ~/boxes

cat <<EOF > Vagrantfile
  Vagrant.configure("2") do |config|
    config.ssh.username = "vagrant"
    config.vm.define "$VM_NAME" # give the VM a unique name
    config.vm.box = "travis-base"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ['travis-cookbooks/ci_environment', 'ci-cookbooks']
      chef.add_recipe 'git'
      chef.add_recipe 'golang'
      chef.add_recipe 'zip'
      chef.add_recipe 'sqlite'
      chef.add_recipe 'libffi'
      chef.add_recipe 'libreadline'
      chef.add_recipe 'rubydependencies'
      chef.add_recipe 'rvm::multi'
      chef.add_recipe 'mysql::server'
      chef.add_recipe 'postgresql::server'
      chef.add_recipe 'warden'
      chef.json = {
        "rvm" => {
          "version" => "latest-1.21",
          "default" => "1.9.3-p448",
          "rubies" => [{"name" => "1.9.3-p448", "arguments" => "--autolibs=2"}]
        },
        "travis_build_environment" => {
          "user" => "vagrant",
          "home" => "/home/vagrant"
        }
      }
    end
  end
EOF
cat Vagrantfile
vagrant up
rm -f ~/boxes/ci_with_warden_prereqs.box
vagrant package $VM_NAME --output ~/boxes/ci_with_warden_prereqs.box

set +e # Rest of the code is cleanup so doesn't matter if it fails

vagrant box remove ci_with_warden_prereqs virtualbox  # this will fail the first time, that's okay
vagrant destroy --force
rm Vagrantfile
rm -rf .vagrant
