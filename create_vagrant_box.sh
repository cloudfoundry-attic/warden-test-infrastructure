#!/bin/bash
set -e -x

(

bundle install
bundle exec librarian-chef install

cd packer

box_name=warden-compatible
provider=${1:-virtualbox}

rm -f ${provider}/${box_name}.box
make ${provider}/${box_name}.box
vagrant box add ${box_name} ${provider}/${box_name}.box --force # Optimization to avoid downloading the box on CI
                                                                # and to ensure the latest box is always used to run
                                                                # dea and warden specs
)
