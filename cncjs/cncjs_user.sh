#!/bin/bash

###
# Install cnc.js as extra cncjs CNCUSER
# 
#
echo "Running cncjs as system user" ${CNCUSER} - ${CNCUID}
useradd --uid ${CNCUID} --comment "CNCjs system user" --create-home ${CNCUSER}
usermod -a -G plugdev,input,netdev,dialout ${CNCUSER}