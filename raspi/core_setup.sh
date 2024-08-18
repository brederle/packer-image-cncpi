#!/bin/bash

###
# Core settings of the modified image
#
BOOTDIR=$(/usr/lib/raspberrypi-sys-mods/get_fw_loc)

# disable 3d overlay for smooth work with vscode


# replace hostname
cat << SECTION > ${BOOTDIR}/custom.toml 
# Raspberry PI OS config.toml
# This file is used for the initial setup of the system on the first boot, if
# it's s present in the boot partition of the installation.
#
# This file is loaded by firstboot, parsed by init_config and ends up
# as several calls to imager_custom.
#
# References:
# - https://github.com/RPi-Distro/raspberrypi-sys-mods/blob/master/usr/lib/raspberrypi-sys-mods/firstboot
# - https://github.com/RPi-Distro/raspberrypi-sys-mods/blob/master/usr/lib/raspberrypi-sys-mods/init_config
# - https://github.com/RPi-Distro/raspberrypi-sys-mods/blob/master/usr/lib/raspberrypi-sys-mods/imager_custom

# Required:
config_version = 1

[system]
hostname = "${HOSTNAME}"
SECTION

# set locale, timezone
cat << SECTION >> ${BOOTDIR}/custom.toml

[locale]
keymap = "${KEYMAP}"
timezone = "${TZ}"
SECTION


# default server language settings
sed -i "/${LOCALE}.*[[:space:]]${ENCODING}[[:space:]]*$/s/^[#[:space:]]*#//g" /etc/locale.gen
DEBIAN_FRONTEND=noninteractive locale-gen
update-locale LANG=${LOCALE}.${ENCODING} >& /dev/null

# assure hardware random is used
#if grep -R "^[:space:]*.*/dev/hwrnd.*" /etc/XXX  > /dev/null;  then
#fi
