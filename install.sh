#!/bin/bash

# Rclone
curl https://rclone.org/install.sh | sudo bash

# Plexdrive
OS_type="`uname -m`"
case $OS_type in
  x86_64|amd64)
    OS_type='amd64'
    ;;
  i?86|x86)
    OS_type='386'
    ;;
  arm*)
    OS_type='arm'
    ;;
  aarch64)
    OS_type='arm64'
    ;;
  *)
    echo 'OS type not supported'
    exit 2
    ;;
esac

curl -LJO https://github.com/plexdrive/plexdrive/releases/download/${PLEXDRIVE_VERSION}/plexdrive-linux-${OS_type}
mv plexdrive-linux-${OS_type} /usr/bin/plexdrive
chmod 755 /usr/bin/plexdrive
