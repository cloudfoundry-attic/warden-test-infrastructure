# Set up sudo - base careful to set the file attribue before copying to
# sudoers.d
( cat <<'EOP'
%packer ALL=NOPASSWD:ALL
EOP
) > /tmp/packer
chmod 0440 /tmp/packer
mv /tmp/packer /etc/sudoers.d/

apt-get -y update
apt-get clean

# Add conditionals around `mesg n` so that Chef doesn't throw
# `stdin: not a tty`
sed -i '$d' /root/.profile
cat << 'EOH' >> /root/.profile
if `tty -s`; then
      mesg n
  fi
EOH
