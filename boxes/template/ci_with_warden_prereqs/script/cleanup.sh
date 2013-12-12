# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces

# Clean up apt caches
apt-get -y autoremove
apt-get autoclean
apt-get clean

# Clean up tmp and /var/cache
rm -rf /tmp/*
rm -rf /var/cache/*

# Remove leftover leases
if [ -d "/var/lib/dhcp" ]; then
    echo "cleaning up dhcp leases"
    rm /var/lib/dhcp*/*
fi
