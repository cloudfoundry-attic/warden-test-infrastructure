#!/bin/bash -eux

# Use this script to bring the kernel up to date if desired.
apt-get update
apt-get install -y linux-image-server linux-headers-server

# reboot
echo "Rebooting ..."
reboot
sleep 90
