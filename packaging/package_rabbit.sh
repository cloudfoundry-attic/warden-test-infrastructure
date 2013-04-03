#!/bin/bash

set -e -x -u

LOCAL_TAR="rabbitmq.tar.gz"
REMOTE_TAR="/tmp/rabbit.tar.gz"
JUMP_HOST=bosh.tabasco.cf-app.com
TARGET_HOST=10.10.4.72
RABBIT_PACKAGES="/var/vcap/packages/{erlang,rabbitmq-*} /var/vcap/data/packages/{erlang,rabbitmq-*} /var/vcap/store/rabbitmq_common"

ssh -A vcap@${JUMP_HOST} "ssh ${TARGET_HOST} \"tar czf ${REMOTE_TAR} ${RABBIT_PACKAGES}\""
rsync -v --rsh "ssh -A vcap@${JUMP_HOST} ssh" ${TARGET_HOST}:${REMOTE_TAR} ${LOCAL_TAR}
# zsyncmake -eZ -u http://vcap-services-binaries.s3.amazonaws.com/rabbitmq.tar.gz $LOCAL_TAR
