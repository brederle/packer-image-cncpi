#!/bin/bash

###
# Defaults user settings and ssh access
#
# source /tmp/utils.sh

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=C


###
# Auto-CIFS a watch directory if configured
# 
if [[ ! -z "$CIFSPATH" ]] && [[ ! -z "$CIFSUSER" ]] && [[ ! -z "$CIFSPASS" ]]; then
    echo "### Auto-mount /mnt/cncfiles to ${CIFSPATH} ###"
    DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install cifs-utils
    mkdir -p /etc/cncfiles
    echo -n "${CIFSPATH}   /mnt/cncfiles   cifs    vers=3.0,username=${CIFSUSER},password=${CIFSPASS},uid=${USER},gid=${GROUP},rw,iocharset=utf8,sec=ntlmssp 0 0" >> /etc/fstab
else
    echo "### SKIP Auto-mount ###"
fi
