#!/bin/bash

###
# Node.js platform setup
#
# source /tmp/utils.sh

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

echo "### Create non-root cnc.js user ${CNCJSUSER} - ${CNCJSID} ###"

###
# Install cnc.js as extra cncjs CNCUSER
# 
#
useradd --uid ${CNCJSUID}\
 --comment "cnc.js technical system user"\
 --groups ${CNCUSERS},plugdev,input,netdev,dialout\
 --no-user-group\
 --shell /bin/bash\
 --create-home ${CNCJSUSER}

CNCJSUSERHOME=$(eval echo "~$CNCJSUSER")

###
#
# configure PM2 to run as cnc.js user
/usr/bin/pm2 startup systemd -u ${CNCJSUSER} --hp ${CNCJSUSERHOME} --silent --no-color 2>&1

# to make is run on boot
/usr/bin/pm2 update --silent --no-color