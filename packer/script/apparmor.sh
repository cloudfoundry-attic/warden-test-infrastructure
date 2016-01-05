#!/bin/bash -eux

/etc/init.d/apparmor stop
update-rc.d -f apparmor remove
apt-get remove apparmor apparmor-utils -y
rm /etc/init.d/apparmor
