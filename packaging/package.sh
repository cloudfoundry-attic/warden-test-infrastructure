#!/bin/bash

set -e -x -u

LOCAL_TAR="$SERVICE_NAME.tar.gz"
JUMP_HOST=bosh.tabasco.cf-app.com
THINGS_TO_TAR="/var/vcap/packages/$TAR_UP_PACKAGES /var/vcap/data/packages/$TAR_UP_PACKAGES /var/vcap/store/$TAR_UP_STORE"

ssh -A vcap@${JUMP_HOST} "ssh ${TARGET_HOST} \"tar c ${THINGS_TO_TAR} | gzip -f\"" > ${LOCAL_TAR}
# zsyncmake -eZ -u http://vcap-services-binaries.s3.amazonaws.com/rabbitmq.tar.gz $LOCAL_TAR


if [ -z `which s3cmd` ]; then
  echo "Could not upload $LOCAL_TAR to S3, please install s3cmd (available with brew)"
  echo "Created local file $LOCAL_TAR, consider uploading to S3 manually"
  exit 1
fi

s3cmd --config=$HOME/workspace/deployments-aws/lobot_backend/s3cmd.config --acl-public put ${LOCAL_TAR} s3://vcap-services-binaries/${LOCAL_TAR}

