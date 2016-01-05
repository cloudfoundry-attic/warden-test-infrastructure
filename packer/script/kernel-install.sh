#!/bin/bash -eux

export UCF_FORCE_CONFFNEW=YES
export DEBIAN_FRONTEND=noninteractive

apt-get -y --force-yes install linux-generic-lts-vivid

# reboot
echo "Rebooting ..."
reboot
sleep 60
