#!/bin/bash
set -e -x

if [ -z $BUILD_TAG ]; then
  echo 'Missing $BUILD_TAG variable, assuming we are not running in jenkins'
  BUILD_TAG=`date +%s`
  echo "Generated build_tag: #{BUILD_TAG}"
fi

VM_NAME="vm_for_$BUILD_TAG"

mkdir -p ~/boxes
if [[ ! -d travis-cookbooks ]]; then
  git clone https://github.com/travis-ci/travis-cookbooks.git
fi
(
  cd travis-cookbooks
  git fetch https://github.com/travis-ci/travis-cookbooks.git
  git checkout 77605d7405dd97e1b418965d3d8fa481030d6117
)

cat <<EOF > Vagrantfile
  Vagrant.configure("2") do |config|
    config.ssh.username = "travis"
    config.vm.define "$VM_NAME" # give the VM a unique name
    config.vm.box = "travis-base"
    config.vm.box_url = "http://files.travis-ci.org/boxes/bases/precise64_base_v2.box"
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ['travis-cookbooks/ci_environment', 'ci-cookbooks']
      chef.add_recipe 'git'
      chef.add_recipe 'unzip'
      chef.add_recipe 'rvm::multi'
      chef.add_recipe 'sqlite'
      chef.add_recipe 'mysql::server'
      chef.add_recipe 'postgresql::server'
      chef.add_recipe 'redis'
      chef.add_recipe 'warden'
      chef.json = {
        "rvm" => {
          "version" => "latest-1.18",
          "default" => "1.9.3",
          "rubies" => [{"name" => "1.9.3"}]
        }
      }
    end
  end
EOF
cat Vagrantfile
vagrant up
rm -f ~/boxes/ci_with_warden_prereqs.box
vagrant package $VM_NAME --output ~/boxes/ci_with_warden_prereqs.box
vagrant box remove ci_with_warden_prereqs virtualbox  # this will fail the first time, that's okay
vagrant destroy --force
rm Vagrantfile
rm -rf .vagrant
