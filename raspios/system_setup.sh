#!/bin/bash

###
# Core settings of the modified image
#
source /tmp/utils.sh

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=C

echo "### System defaults setup ###"

# Set the desired keymap config
SETKEY XKBLAYOUT \"${KEYMAP}\" /etc/default/keyboard


# default server language settings
UNCOMMENTWS "en_US.${ENCODING}" /etc/locale.gen
UNCOMMENTWS "en_GB.${ENCODING}" /etc/locale.gen
UNCOMMENTWS "${LOCALE}.${ENCODING}" /etc/locale.gen
dpkg-reconfigure -f noninteractive locales 2>&1   # avoid red info outputs
update-locale LANG=${LANG} LANGUAGE=${LANG} LC_MESSAGES=${LANG}

# set timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/${TZ} /etc/localtime
dpkg-reconfigure -f noninteractive tzdata 2>&1   # avoid red info outputs

# disable unnecessary services for heeadless/lite setup
systemctl disable keyboard-setup.service 2>&1
systemctl disable console-setup.service 2>&1

# for boot debugging
echo "\$BOOTDIR=" $BOOTDIR
