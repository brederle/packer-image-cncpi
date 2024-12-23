#!/bin/bash

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

export USERDIR=/home/${CNCUSER}

###
# auto leveler service
echo "Installing autolevel@.service"
cat > /etc/systemd/system/autolevel@.service <<SERVICE_EOF
[Unit]
Description=Auto level functionality for cncjs
After=network.target

[Service]
User=%i
Type=simple
ExecStart=/usr/bin/node /home/%i/.npm/cncjs-kt-ext --port /dev/ttyUSB0
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Enable autolevel service
### systemctl --quiet enable autolevel@${CNCUSER}.service
