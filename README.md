warden-test-insfrastructure
===========================

Packer templates to create vagrant boxes to run DEA and Warden tests in.

## Virtualbox based Vagrant box

### Pre-requisites

- Packer 0.5.2 or later
- Virtualbox
   - 4.3.8 works
   - 4.3.10 does NOT work correctly, when bringing up the box you will see this error:
   ```
   Bringing machine 'default' up with 'virtualbox' provider...
   ==> default: Importing base box 'warden-compatible'...
   ==> default: Matching MAC address for NAT networking...
   ==> default: Setting the name of the VM: d20140417-94164-1dssqlt_default_1397770794229_45288
   ==> default: Clearing any previously set network interfaces...
   ==> default: Preparing network interfaces based on configuration...
       default: Adapter 1: nat
   ==> default: Forwarding ports...
       default: 22 => 2222 (adapter 1)
   ==> default: Booting VM...
   ==> default: Waiting for machine to boot. This may take a few minutes...
       default: SSH address: 127.0.0.1:2222
       default: SSH username: vagrant
       default: SSH auth method: private key
       default: Warning: Connection timeout. Retrying...
   ==> default: Machine booted and ready!
   ==> default: Checking for guest additions in VM...
   ==> default: Mounting shared folders...
       default: /vagrant => /private/var/folders/4n/qs1rjbmd1c5gfb78m3_06j6r0000gn/T/d20140417-94164-1dssqlt
   Failed to mount folders in Linux guest. This is usually because
   the "vboxsf" file system is not available. Please verify that
   the guest additions are properly installed in the guest and
   can work properly. The command attempted was:

   mount -t vboxsf -o uid=`id -u vagrant`,gid=`getent group vagrant | cut -d: -f3` /vagrant /vagrant
   mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` /vagrant /vagrant
   ```
-

### Create and add `warden-compatible.box`

```
./create_vagrant_box.sh virtualbox
```

## VMware Fusion based Vagrant box

### Pre-requisites

- Packer 0.5.2 or later
- VMWare Fusion 6.0.3 or later
- VMWare Fusion Tools for linux:
    - manually create an Ubuntu VM with VMware Fusion
    - choose the option to download & install VMWare Fusion Tools for linux while doing this
    - discard this VM

### Create and add `warden-compatible.box`

```
./create_vagrant_box.sh vmware
```
