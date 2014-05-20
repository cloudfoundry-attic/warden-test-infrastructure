#!/bin/bash -eux

# Memory and swap accounting require kernel command line parms
# for newer Ubuntu kernels

# The grub2 configuration is in /etc/default/grub
if [ -f /etc/default/grub ]; then
    sed -i -e 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
fi

# The 'legacy' grub used by ec2 needs special massaging
grub_menu=/boot/grub/menu.lst
if [ -f $grub_menu ]; then
    grep -q '^# kopt=.*cgroup_enable=memory' $grub_menu || sed -i 's@^# kopt=\(.*\)@# kopt=\1 cgroup_enable=memory@g' $grub_menu
    grep -q '^# kopt=.*swapaccount=1' $grub_menu || sed -i 's@^# kopt=\(.*\)@# kopt=\1 swapaccount=1@g' $grub_menu
fi

# Update the grub configuration
[ -x /usr/sbin/update-grub ] && /usr/sbin/update-grub
[ -x /usr/sbin/update-grub-legacy-ec2 ] && /usr/sbin/update-grub-legacy-ec2

# Reboot the machine
reboot
sleep 90
