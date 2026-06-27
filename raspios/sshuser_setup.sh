#!/bin/bash

###
# Default power user settings and ssh access
#
# source /tmp/utils.sh

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=C

echo "### Default user \`${USER}\` setup ###"

# create a device admin group controlling extended sudo and ssh
# rights for the device main user
POWERUSER_GROUP="devctrl"
groupadd ${POWERUSER_GROUP}

useradd --uid ${UID}\
 --comment "${DESCRIPTION}"\
 --groups ${POWERUSER_GROUP},pi,adm,users,tty,sudo,plugdev,dialout,input,netdev,gpio,spi\
 --user-group\
 --shell /bin/bash\
 --create-home ${USER}

# remove the pi default user, but not the group
userdel --force --remove pi 2>&1 || true

###
# Make the device admins user special sudoer
echo -n "# ${POWERUSER_GROUP}'s group members sudo without passwd
%${POWERUSER_GROUP} ALL=(ALL:ALL) NOPASSWD: ALL
" > /etc/sudoers.d/010_${POWERUSER_GROUP}_nopasswd

# and diabale the privileges for pi group
rm -f /etc/sudoers.d/010_pi_nopasswd

###
# Enable ssh
rm -f /etc/ssh/sshd_not_to_be_run
systemctl enable ssh 2>&1

USERHOME=$(eval echo "~$USER")
mkdir -p $USERHOME/.ssh
chmod 700 $USERHOME/.ssh

###
# Completely disable root login
# ssh is diabled in sshd_config on hardening
sed -ir "s/^root:x:0:0:root:\/root:.*/root:x:0:0:root:\/root:\/sbin\/nologin/g" /etc/passwd

