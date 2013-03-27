#!/bin/bash
set -e -x

if [[ -z ${WORKSPACE-} ]]; then
  exit 1
fi

VM_NAME="vm_for_$BUILD_TAG"
BUILD_TO_RUN_PATH=$1
TEST_INFRA_PATH=$2

if [[ ! -f ~/boxes/ci_with_warden_prereqs.box ]]; then
  if [[ ! -d travis-cookbooks ]]; then
    git clone https://github.com/travis-ci/travis-cookbooks.git
  fi
  (
    cd travis-cookbooks
    git fetch https://github.com/travis-ci/travis-cookbooks.git
    git checkout 77605d7405dd97e1b418965d3d8fa481030d6117
  )

  cp -r $WORKSPACE/ci-cookbooks .
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
        chef.add_recipe 'warden'
        chef.json = {
          "rvm" => {
            "default" => "1.9.3",
            "rubies" => [{"name" => "1.9.3"}]
          }
        }
      end
    end
EOF
  cat Vagrantfile
  vagrant up
  vagrant package $VM_NAME --output ~/boxes/ci_with_warden_prereqs.box
  vagrant box remove ci_with_warden_prereqs virtualbox  # this will fail the first time, that's okay
  vagrant destroy --force
fi

cat <<EOF >Vagrantfile
  Vagrant.configure("2") do |config|
    config.ssh.username = "travis"
    config.vm.define "$VM_NAME" # give the VM a unique name
    config.vm.box = "ci_with_warden_prereqs"
    config.vm.box_url = "~/boxes/ci_with_warden_prereqs.box"
  end
EOF
cat Vagrantfile
vagrant up

vagrant ssh-config > ssh_config
ssh -F ssh_config $VM_NAME 'mkdir -p ~/workspace'
rsync -rq --rsh="ssh -F ssh_config" $BUILD_TO_RUN_PATH/.git/ $VM_NAME:workspace/.git
rsync -rq --rsh="ssh -F ssh_config" $TEST_INFRA_PATH/start_warden.sh $VM_NAME:workspace/
ssh -F ssh_config $VM_NAME 'cd ~/workspace && git checkout .'

vagrant ssh $VM_NAME -c "cd ~/workspace &&         \
  env WARDENIZED_SERVICE=$WARDENIZED_SERVICE       \
      REQUIRE_PACKAGE=$REQUIRE_PACKAGE             \
      FOLDER_NAME=$FOLDER_NAME                     \
    ./.travis.run"
