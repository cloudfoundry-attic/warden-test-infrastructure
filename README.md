warden-test-insfrastructure
===========================

Packer templates to create vagrant boxes to run DEA and Warden tests in.

## Virtualbox based Vagrant box

### Pre-requisites

- Packer 0.5.2 or later
- Virtualbox

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
