#!/bin/bash

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

chown ${CNCUSER}:${CNCUSER} /home/${CNCUSER}/.cncrc

###
# cncjs service
echo "Installing cncjs@.service"
echo > /etc/systemd/system/cncjs@.service <<SERVICE_EOF
[Unit]
Description=CNC JS server
After=network.target

[Service]
Type=simple
Environment=PATH=/home/%i/.npm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
WorkingDirectory=/home/%i
ExecStart=cncjs --host 0.0.0.0 -p 8000 --config /home/%i/.cncrc
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

###
# auto leveler service
echo "Installing autolevel@.service"
echo > /etc/systemd/system/autolevel@.service <<SERVICE_EOF
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

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Enable autolevel service
systemctl --quiet enable autolevel@${CNCUSER}.service

###
# grblsim service
echo "Installing grblsim@.service"
echo > /etc/systemd/system/grblsim@.service <<SERVICE_EOF
[Unit]
Description=GRBL sim for cncjs via /dev/ttyGSIM
After=network.target

[Service]
User=%i
Type=simple
ExecStart=/usr/bin/socat PTY,raw,link=/dev/ttyGSIM,echo=0 "EXEC:'/usr/local/bin/grblsim -n -s /mnt/cncfiles/step.out -b /mnt/cncfiles/block.out',pty,raw,echo=0"
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Enable autolevel service
systemctl --quiet enable grblsim@${CNCUSER}.service