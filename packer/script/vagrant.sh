#!/bin/bash

# create the vagrant user if it doesn't already exist
grep -q '^vagrant' /etc/passwd || useradd -U -m -s /bin/bash --groups sudo -p vagrant vagrant

mkdir /home/vagrant/.ssh
wget --no-check-certificate \
    'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# Add tty chack around `mesg n` so Chef doesn't report `stdin: not a tty`
sed -i '$d' /root/.profile
cat << 'EOH' >> /root/.profile
if `tty -s`; then
      mesg n
  fi
EOH
