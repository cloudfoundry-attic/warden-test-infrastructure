#!/bin/bash -eux

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
