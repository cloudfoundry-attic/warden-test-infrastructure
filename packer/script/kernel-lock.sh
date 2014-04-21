#!/bin/bash -uex

# Lock the current kernel version
echo $(dpkg -l "*$(uname -r)*" | grep image | awk '{print $2}') hold | dpkg --set-selections
