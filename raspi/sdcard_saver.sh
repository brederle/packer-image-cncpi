#!/bin/bash

###
# Disable swap, /tmp in ramdisk
# to protect SDCARD a little better

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

# disable swap
dphys-swapfile swapoff && dphys-swapfile uninstall 
update-rc.d dphys-swapfile remove 
apt-get purge dphys-swapfile -yq
apt-get autoremove -yq

# move /tmp from sdcard to ramdisk
# for better sdcard live
cp /usr/share/systemd/tmp.mount /etc/systemd/system/tmp.mount
systemctl -q enable tmp.mount