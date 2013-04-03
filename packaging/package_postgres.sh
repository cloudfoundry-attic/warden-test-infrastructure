#!/bin/bash

set -e -x -u

SERVICE_NAME="postgresql"
TARGET_HOST=10.10.4.42  # ip of mysql node on tabasco
TAR_UP_STORE="postgresql_common"
TAR_UP_PACKAGES="postgresql92"
source ./package.sh
