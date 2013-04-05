#!/bin/bash
set -e -u -x
(
  cd /warden/warden
  rvmsudo bundle exec rake warden:start[config/test_vm.yml] --trace >/dev/null 2>&1 &
)

# Wait for warden to come up
while [ ! -e /tmp/warden.sock ]
do
  sleep 1
done

echo "/tmp/warden.sock exists, let's run the specs"
