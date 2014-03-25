#!/bin/bash
set -e -u -x
(
  cd /warden/warden
  sudo bundle install
  sudo bundle exec rake warden:start[config/test_vm.yml] --trace > /dev/null &
)

echo "waiting for warden to come up"
while [ ! -e /tmp/warden.sock ]
do
  sleep 1
done
echo "warden is ready"
