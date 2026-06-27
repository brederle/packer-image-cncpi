#!/bin/bash

###
# DHCP assigned LAN and wifi settings if configured
# See https://docs.armbian.com/User-Guide_Networking/ to extend it for static IP
#
source /tmp/utils.sh

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=C

echo "### Shell motd decoration ###"

# clean up some default decorations
rm -f /etc/update-motd.d/10-uname
rm -f /etc/motd

# preserve configured cnc user for display
SETKEY "CNCJSUSER" "${CNCJSUSER}" /etc/update-motd.d/30-boilerplate-info
SETKEY "USER" "${USER}" /etc/update-motd.d/30-boilerplate-info

# make uploaded files executable
chmod 755 /etc/update-motd.d/30-boilerplate-info


# enable motd for ssh login
SETKEY "PrintMotd" " " "yes" /etc/ssh/sshd_config
