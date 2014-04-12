#!/bin/bash -eux

# delete stale linux kernels
dpkg --list | awk '{ print $2 }' | grep 'linux-image-3.*-generic' | grep -v `uname -r` | xargs apt-get -y purge

# delete stale linux headers
dpkg --list | awk '{ print $2 }' | grep 'linux-headers-3.*-generic' | grep -v `uname -r` | xargs apt-get -y purge

# delete linux source
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge

# cleanup implicit packages that are no longer needed
apt-get -y autoremove
apt-get -y clean

# cleanup leftover leases
echo "cleaning up dhcp leases"
rm -f /var/lib/dhcp/* /var/lib/dhcp3/*

# cleanup udev rules
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm /lib/udev/rules.d/75-persistent-net-generator.rules
rm -rf /dev/.udev/

# cleanup tmp and /var/cache
echo "cleanup up /tmp and /var/cache"
rm -rf /tmp/*
find /var/cache -type f | xargs rm -f
