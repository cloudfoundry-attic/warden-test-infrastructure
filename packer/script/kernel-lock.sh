#!/bin/bash -uex

# Lock the current kernel version
for kernel_package in $(dpkg -l "*$(uname -r)*" | grep image | awk '{print $2}'); do
    echo $kernel_package hold | dpkg --set-selections
done
