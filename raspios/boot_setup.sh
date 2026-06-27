#!/bin/bash

###
# Core settings of the modified image
#
source /tmp/utils.sh

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=C

echo "### Boot defaults setup ###"

# disable raspi-config on first start
systemctl disable userconfig.service 2>&1 || true
# avoid re-enabling from other services
systemctl mask userconfig.service 2>&1 || true

# enable ssh before first start
touch ${BOOTDIR}/ssh
