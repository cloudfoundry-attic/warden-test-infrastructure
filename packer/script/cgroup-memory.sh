#!/bin/bash -eux

# Memory and swap accounting require kernel command line parms
sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub

# Update the grub configuration
update-grub

# Reboot the machine
reboot
sleep 90
