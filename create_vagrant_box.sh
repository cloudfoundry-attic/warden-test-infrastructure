#!/bin/bash
set -e -x

if [ -z $BUILD_TAG ]; then
  echo 'Missing $BUILD_TAG variable, assuming we are not running in jenkins'
  BUILD_TAG=`date +%s`
  echo "Generated build_tag: #{BUILD_TAG}"
fi

VM_NAME="vm_for_$BUILD_TAG"

mkdir -p ~/boxes

bundle install
bundle exec librarian-chef install

cat <<EOF > Vagrantfile
Vagrant.configure("2") do |config|
  config.ssh.username = "vagrant"
  config.vm.define "$VM_NAME" # give the VM a unique name
  config.vm.box     = "opscode_ubuntu-13.04_provisionerless"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-13.10_chef-provisionerless.box"
  config.omnibus.chef_version = :latest
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['cookbooks', 'site-cookbooks']
    chef.add_recipe 'apt'
    chef.add_recipe 'packages'
    chef.add_recipe 'chef_rubies'
    chef.add_recipe 'warden'
    chef.json = {
      "rubies" => {
        "list" => ["1.9.3-p448"],
        "install_bundler" => true,
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
