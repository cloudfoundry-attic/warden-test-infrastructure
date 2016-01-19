#!/bin/bash -eux

# install Go 1.5
wget -qO- https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz | tar -C /usr/local -xzf -
echo "export PATH=/usr/local/go/bin:$PATH" > /etc/profile.d/golang.sh
