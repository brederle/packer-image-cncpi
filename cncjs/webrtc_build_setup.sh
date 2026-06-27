
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

echo "### Build Chrome webrtc library ###"

DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install\ 
 build-essential\
 python\
 git\
 g++\
 libasound2-dev\
 libpulse-dev\
 libudev-dev\
 libexpat1-dev\
 libnss3-dev\
 libgtk2.0-dev

