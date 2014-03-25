#!/bin/bash
set -e -x -u

BUILD_TO_RUN_PATH=$1
TEST_INFRA_PATH=$2
TMP_FOLDER_PATH=`pwd`
VM_NAME=default
WARDENIZED_SERVICE=${WARDENIZED_SERVICE:-}
REQUIRE_PACKAGE=${REQUIRE_PACKAGE:-}

echo "at the beginning"
echo date

# best effort to command in critical section
function lock {
  LOCKFILE=/run/shm/vagrantup.lock
  FLOCKTIMEOUT=600
  if which flock ; then
    flock -w $FLOCKTIMEOUT --close -x $LOCKFILE -c "$*"
  else
    $*
  fi
}

if [[ ! -f ~/boxes/warden-compatible.box ]]; then
  echo "NO vagrant box found in ~/boxes, you probably need to run create_vagrant_box.sh first!"
  exit 1
fi

cat <<EOF >Vagrantfile
  Vagrant.configure("2") do |config|
    config.ssh.username = "vagrant"
    config.vm.define "$VM_NAME"
    config.vm.box = "warden-compatible"
    config.vm.box_url = "~/boxes/warden-compatible.box"
  end
EOF

echo "before vagrant up:"
date

lock vagrant up

echo "after vagrant up:"
date

vagrant ssh-config > ssh_config
rsync -arq --rsh="ssh -F ssh_config" $BUILD_TO_RUN_PATH/ $VM_NAME:workspace
rsync -arq --rsh="ssh -F ssh_config" $TEST_INFRA_PATH/start_warden.sh $VM_NAME:workspace/

echo "after rsync stuff"
date

echo "Your vagrant box is now provisioned in folder $TMP_FOLDER_PATH! Don't forget to vagrant destroy it eventually."
echo "To connect: vagrant ssh $VM_NAME"
echo "To destroy: vagrant destroy $VM_NAME"

echo "about to ssh to run tests"
date

if [ -z ${NOTEST:=} ]; then
  vagrant ssh $VM_NAME -c "cd ~/workspace &&     \
    env WARDENIZED_SERVICE=$WARDENIZED_SERVICE   \
    REQUIRE_PACKAGE=$REQUIRE_PACKAGE             \
    FOLDER_NAME=$FOLDER_NAME                     \
    ./.travis.run"
fi
