#!/bin/bash

###
# Node.js platform setup
#
# source /tmp/utils.sh

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

echo "### Register cnc.js in PM2 ###"

CNCJSUSERHOME=$(eval echo "~$CNCJSUSER")

# register cnc.js
/usr/bin/pm2 start ${CNCJSUSERHOME}/.npm/bin/cncjs -- --host 0.0.0.0 -p ${CNCJSPORT} --config ${CNCJSUSERHOME}/.cncrc
/usr/bin/pm2 save --silent