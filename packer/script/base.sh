#!/bin/bash -eux

apt-get -y update
apt-get -y dist-upgrade

apt-get -y autoremove
apt-get clean
