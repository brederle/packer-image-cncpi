#!/bin/bash

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

export USERDIR=/home/${CNCUSER}

# adapt rights of copied settingss
chown ${CNCUSER}:${CNCUSER} /home/${CNCUSER}/.cncrc

###
# cncjs service
echo "Installing cncjs@.service"
cat > /etc/systemd/system/cncjs@.service <<SERVICE_EOF
[Unit]
Description=CNC JS server
After=network.target

[Service]
User=%i
Type=simple
Environment=PATH=/home/%i/.npm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
WorkingDirectory=/home/%i
ExecStart=/home/%i/.npm/bin/cncjs --host 0.0.0.0 -p 8000 --config /home/%i/.cncrc
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartPreventExitStatus=255
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Enable cncjs service
systemctl --quiet enable cncjs@${CNCUSER}.service