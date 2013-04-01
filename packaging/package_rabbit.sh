#!/bin/bash

set -e -x -u

LOCAL_TAR="/tmp/r.tar.gz"
REMOTE_TAR="/tmp/rabbit.tar.gz"
JUMP_HOST=bosh.tabasco.cf-app.com
TARGET_HOST=10.10.4.72
RABBIT_PACKAGES="/var/vcap/packages/{erlang,rabbitmq-*}"

ssh -A vcap@${JUMP_HOST} "ssh ${TARGET_HOST} \"tar czhf ${REMOTE_TAR} ${RABBIT_PACKAGES}\""
rsync -v --rsh "ssh -A vcap@${JUMP_HOST} ssh" ${TARGET_HOST}:${REMOTE_TAR} ${LOCAL_TAR}
