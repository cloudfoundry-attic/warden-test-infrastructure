#!/bin/bash
set -e -x

if [ -z $BUILD_TAG ]; then
  echo 'Missing $BUILD_TAG variable, assuming we are not running in jenkins'
  BUILD_TAG=`date +%s`
  echo "Generated build_tag: #{BUILD_TAG}"
fi

VM_NAME="vm_for_$BUILD_TAG"

mkdir -p ~/boxes

gem install bundler --no-ri --no-rdoc
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
