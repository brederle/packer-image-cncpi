#!/bin/bash

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

export USERDIR=/home/${CNCUSER}

# adapt rights of copied settingss
chown ${CNCUSER}:${CNCUSER} /home/${CNCUSER}/.cncrc

###
# Install cnc.js as extra cncjs CNCUSER
#
echo "Installing cncjs packages for user " ${CNCUSER}
mkdir -p ${USERDIR}/.npm
npm config set prefix ${USERDIR}/.npm
npm_config_loglevel=silent npm install -g cncjs@${CNCJS_VERSION} --unsafe-perm
# allow fqdn resolution in final image again

###
# cncjs service
echo "Installing cncjs@.service"
cat > /etc/systemd/system/cncjs@.service <<SERVICE_EOF
[Unit]
Description=CNC JS server
After=network.target

[Service]
Type=simple
Environment=PATH=/home/%i/.npm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
WorkingDirectory=/home/%i
ExecStart=/home/%i/.npm/bin/cncjs --host 0.0.0.0 -p 8000 --config /home/%i/.cncrc
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
USER=%i
Restart=on-failure
RestartPreventExitStatus=255

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Enable cncjs service
systemctl --quiet enable cncjs@${CNCUSER}.service