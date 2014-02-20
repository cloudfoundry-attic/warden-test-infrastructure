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
    config.vm.box = "precise64"
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
      chef.add_recipe 'redis::ppa'
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

NEW_BOX=./new_ci_with_warden_prereqs.box

rm -f $NEW_BOX
vagrant halt
vagrant package $VM_NAME --output $NEW_BOX
mv $NEW_BOX ~/boxes/ci_with_warden_prereqs.box

set +e # Rest of the code is cleanup so doesn't matter if it fails

vagrant box remove ci_with_warden_prereqs virtualbox || echo "This will fail the first time, that's okay"
vagrant destroy --force
rm Vagrantfile
rm -rf .vagrant
