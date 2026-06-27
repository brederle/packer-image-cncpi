#!/bin/bash

###
# Automatic installation of security updates
# with controlled reboot at configured BOOTTIME
# Use BOOTTIME='now' to reboot directly after installation
# (which is potentially 2 times a day!)
#

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

apt-get -yq install unattended-upgrades
# modify the default configuration entries
sed -ri "s/^[\/\s]*Unattended-Upgrade::Automatic-Reboot\s.*;/Unattended-Upgrade::Automatic-Reboot \"true\";/"\
    /etc/apt/apt.conf.d/50unattended-upgrades
sed -ri "s/^[\/\s]*Unattended-Upgrade::Automatic-Reboot-Time\s.*;/Unattended-Upgrade::Automatic-Reboot-Time '${BOOTTIME}';/"\
    /etc/apt/apt.conf.d/50unattended-upgrades
dpkg-reconfigure -plow -f noninteractive unattended-upgrades
apt-get -yq autoremove
