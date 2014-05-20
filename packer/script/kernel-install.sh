#!/bin/bash -eux

# get package list
packages=${KERNEL_PACKAGES:-linux-image-generic-lts-saucy linux-headers-generic-lts-saucy}

# Use this script to bring the kernel up to date if desired.
apt-get update
apt-get install -y $packages

# reboot
echo "Rebooting ..."
reboot
sleep 90
