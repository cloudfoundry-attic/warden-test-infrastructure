#!/bin/bash

set -e -x -u

SERVICE_NAME="rabbitmq"
TARGET_HOST=10.10.4.72  # ip of mysql node on tabasco
TAR_UP_STORE="rabbitmq_common"
TAR_UP_PACKAGES="{erlang,rabbitmq-*}"
source ./package.sh
