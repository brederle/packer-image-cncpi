#!/bin/bash

###
# Node.js platform setup
#
# source /tmp/utils.sh

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

USERHOME=$(eval echo "~$USER")

echo "### Marlin build environemnt ($USER) ###"

python3 -m venv $USERHOME/platformio/.venv
$USERHOME/platformio/.venv/bin/pip3 install --upgrade pip
$USERHOME/platformio/.venv/bin/pip3 install platformio

mkdir -p $USERHOME/marlin
git clone https://github.com/marlinfirmware/marlin --branch lts-2.1.2 --depth 1 $USERHOME/marlin 2>&1

