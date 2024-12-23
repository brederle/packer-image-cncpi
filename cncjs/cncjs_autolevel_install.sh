#!/bin/bash

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

export USERDIR=/home/${CNCUSER}

###
# Install auto leveler
#
echo "Installing autoleveler for user" ${CNCUSER}
mkdir -p ${USERDIR}/.npm
npm config set prefix ${USERDIR}/.npm
git clone -q https://github.com/kreso-t/cncjs-kt-ext.git ${USERDIR}/cncjs-kt-ext
cd ${USERDIR}/cncjs-kt-ext
npm_config_loglevel=silent npm install
rm -rf ${USERDIR}/cncjs-kt-ext

