#!/bin/bash -eux

# Get build essentials
apt-get install -y build-essential make perl

# Install kernel headers if they're missing
dpkg --status linux-headers-$(uname -r) 2>&1 >/dev/null
if [ $? -ne 0 ]; then
    apt-get install -y linux-headers-$(uname -r)
    installed_headers=1
fi

# Install the tools
if [ -f linux.iso ]; then
    echo "Installing VMware Tools"
    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop /home/packer/linux.iso /mnt/cdrom
    tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/

    /tmp/vmware-tools-distrib/vmware-install.pl -d
    rm /home/packer/linux.iso
    umount /mnt/cdrom
    rmdir /mnt/cdrom
elif [ -f .vbox_version ] ; then
    echo "Installing VirtualBox guest additions"
    apt-get install -y dkms

    VBOX_VERSION=$(cat /home/packer/.vbox_version)
    mount -o loop /home/packer/VBoxGuestAdditions.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run
    umount /mnt
    rm /home/packer/VBoxGuestAdditions.iso
fi

# Remove the headers if we installed them
if [ -n "$installed_headers" ]; then
    apt-get -y remove linux-headers-$(uname -r)
fi
