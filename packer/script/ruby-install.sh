#!/bin/bash -eux

# install Ruby 2.2.4
git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
cd /tmp/ruby-build && \
PREFIX=/usr/local ./install.sh && \
/usr/local/bin/ruby-build 2.2.4 /usr && \
cd && \
rm -rf /tmp/ruby-build && \
gem install bundler --no-ri --no-doc
