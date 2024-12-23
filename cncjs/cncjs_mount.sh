#!/bin/bash

###
# Auto-mount a watch directory if configured
# 
mkdir -p /mnt/cncfiles
if [[ ! -z "$MOUNTPATH" ]] && [[ ! -z "$MOUNTUSER" ]] && [[ ! -z "$MOUNTPASS" ]]; then
    echo "Auto-mounting" $MOUNTPATH
    cat >> /etc/fstab  << FSTAB
${MOUNTPATH}   /mnt/cncfiles   cifs    username=${MOUNTUSER},password=${MOUNTPASS},uid=${CNCUSER},gid=${CNCUSER},iocharset=utf8,sec=ntlmssp 0 0 
FSTAB
else
    echo "Skip auto-mounting"
fi

