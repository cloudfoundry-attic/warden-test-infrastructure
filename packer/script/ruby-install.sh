#!/bin/bash -eux

# install Ruby 2.2.4
git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
cd /tmp/ruby-build && \
PREFIX=/usr/local ./install.sh && \
/usr/local/bin/ruby-build 2.3.1 /usr && \
cd && \
rm -rf /tmp/ruby-build && \
gem install bundler -v '1.11.2' --no-ri --no-doc
