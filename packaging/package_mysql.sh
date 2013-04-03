#!/bin/bash

set -e -x -u

SERVICE_NAME="mysql"
TARGET_HOST=10.10.4.31  # ip of mysql node on tabasco
TAR_UP_STORE="mysql_common"
TAR_UP_PACKAGES="{mysql55,mysqlclient}"
source ./package.sh
