#!/bin/bash

###
# SSH hardening setup
#
# ATTENTION: This setup does only support elliptic keys
# RSA is NOT supported!
#
# TIP: Use `ssh-keygen -t ecdsa` to create an elliptic ssh key
# 
# if no authorized_keys file is configured
# username/password is used for ssh authentication
#
BOOTDIR=$(/usr/lib/raspberrypi-sys-mods/get_fw_loc)

if [ -s /tmp/authorized_keys ]; then
    # login only via ssh
    AUTH_KEYLIST=$(sed 's/.*/"&"/' /tmp/authorized_keys | paste -s -d ',')
    cat << SECTION >> ${BOOTDIR}/custom.toml  

[user]
name = "${USER}"
# no password, console login is locked

[ssh]
enabled = true
password_authentication = false
authorized_keys = [ ${AUTH_KEYLIST} ]
SECTION

else
    # empty authorized_keys file activates password authentication
    ENCRYPTED_PASSWORD=$(openssl passwd -5 ${PASSWORD})
    cat << SECTION >> ${BOOTDIR}/custom.toml  

[user]
name = "${USER}"
password = "${ENCRYPTED_PASSWORD}"
password_encrypted = true

[ssh]
enabled = true
password_authentication = true
SECTION
fi

# no console login, make sure old pi user is really killed
# userdel -r pi >& /dev/null

