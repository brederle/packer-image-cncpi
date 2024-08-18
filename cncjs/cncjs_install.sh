#!/bin/bash

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}


###
# Install cnc.js as extra cncjs CNCUSER
#
npm config set prefix ~/.npm
echo "Installing cncjs packages for user " $(whoami)
npm_config_loglevel=silent npm install -g cncjs@${CNCJS_VERSION} --unsafe-perm
# allow fqdn resolution in final image again


###
# Install auto leveler
#
echo "Installing autoscaler for user" $(whoami)
git clone -q https://github.com/kreso-t/cncjs-kt-ext.git ~/cncjs-kt-ext
cd ~/cncjs-kt-ext
npm_config_loglevel=silent npm install
rm -rf ~/cncjs-kt-ext

###
# Install patched grblsim
#
echo "Installing grblsim for user" $(whoami)
mkdir -p ~/grbl
git clone -q https://github.com/gnea/grbl ~/grbl
git clone -q https://github.com/grbl/grbl-sim ~/grbl/grbl/grbl-sim
cd ~/grbl/grbl/grbl-sim
# atm, some patching on rpi is needed
curl -L https://github.com/grbl/grbl-sim/pull/29.patch | git apply
# TODO: deliver real patch to project
sed -ri 's/util\/floatunsisf.o//g' Makefile
make new
mv -i gvalidate.exe /usr/local/bin/gvalidate
mv -i grbl_sim.exe /usr/local/bin/grblsim
rm -rf ~/grbl