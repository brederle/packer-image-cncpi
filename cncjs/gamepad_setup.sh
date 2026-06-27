#!/bin/bash

###
# Defaults user settings and ssh access
#
source /tmp/utils.sh

echo "### (Bluetooth) gamepad support ###" 

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=C

COMMENT "enable_uart=1" ${BOOTDIR}/config.txt
COMMENT "dtoverlay=disable-bt" ${BOOTDIR}/config.txt

DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install bluetooth\
 bluez\
 bluez-firmware\
 bluez-tools\
 evtest

###
# To detect and pair your gamepad, you need to 
# execute the following commands with your power user
# via ssh on the device:
#
# Shell command: `bluetoothctl`
# Within bluetoothctl:
# ```
# power on
# agent on
# default-agent
# scan on
# ````
#
# As soon as your controller is detected,
# copy the detected MAC `XX:XX:XX:XX:XX:XX` 
# you can disable scan and connect your gaming
# device:
# ```
# scan off
# pair XX:XX:XX:XX:XX:XX
# trust XX:XX:XX:XX:XX:XX
# connect XX:XX:XX:XX:XX:XX
# ```