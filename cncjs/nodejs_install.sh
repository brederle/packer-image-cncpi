#!/bin/bash
###
# Node.js platform setup
#
# source /tmp/utils.sh

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}
export 

echo "### Install node.js ${NODE_VERSION} ###"

###
# Install node.js from debian package repo
#
curl -sSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | DEBIAN_FRONTEND=noninteractive bash - 2>&1
DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends libusb-1.0-0-dev libudev-dev nodejs
npm_config_loglevel=silent npm install -g npm@latest

###
# Install pm2 process manager
#
npm_config_loglevel=silent npm install -g pm2
