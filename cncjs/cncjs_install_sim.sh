#!/bin/bash

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=${LOCALE}.${ENCODING}

export USERDIR=/home/${CNCUSER}

###
# Install patched grblsim
#
echo "Installing grblsim for user" $(whoami)
mkdir -p /tmp/grbl
git clone -q https://github.com/gnea/grbl /tmp/grbl
git clone -q https://github.com/grbl/grbl-sim /tmp/grbl/grbl/grbl-sim
cd /tmp/grbl/grbl/grbl-sim
# atm, some patching on rpi is needed
curl -sL https://github.com/grbl/grbl-sim/pull/29.patch | git apply
# TODO: deliver real patch to project
sed -ri 's/util\/floatunsisf.o//g' Makefile
make new
mv -i gvalidate.exe /usr/local/bin/gvalidate
mv -i grbl_sim.exe /usr/local/bin/grblsim
rm -rf /tmp/grbl

###
# grblsim service
mkdir -p /home/${CNCUSER}/grblsim

echo "Installing grblsim@.service"
cat > /etc/systemd/system/grblsim@.service <<SERVICE_EOF
[Unit]
Description=GRBL sim for cncjs via /dev/ttyGSIM
After=network.target

[Service]
User=%i
Type=simple
ExecStart=/usr/bin/socat PTY,raw,link=/dev/ttyGSIM,echo=0 "EXEC:'/usr/local/bin/grblsim -n -s /home/%i/grblsim/step.out -b /home/%i/grblsim/block.out',pty,raw,echo=0"
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Enable autolevel service
systemctl --quiet enable grblsim@${CNCUSER}.service