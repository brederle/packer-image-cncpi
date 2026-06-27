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

echo "### Network setup ###"

WIFI_HASH=$(openssl kdf -keylen 32 -kdfopt digest:SHA1 \-kdfopt pass:"${WIFI_PASS}" -kdfopt salt:"${WIFI_SSID}" -kdfopt iter:4096 PBKDF2 | tr -d ':')
WIFI_UUID=$(cat /proc/sys/kernel/random/uuid)

echo ${HOSTNAME} >/etc/hostname

# Ethernet is by default enables in /etc/netplan/10-dhcp-all-interfaces.yaml
# so no extra configuration
if [[ ! -z "$WIFI_SSID" ]] && [[ ! -z "$WIFI_PASS" ]]; then
    cat <<EOS >/etc/NetworkManager/system-connections/"${WIFI_SSID}".nmconnection
[connection]
id=${WIFI_SSID}
uuid=${WIFI_UUID}
type=wifi
interface-name=wlan0
autoconnect=true

[wifi]
mode=infrastructure
ssid=${WIFI_SSID}
country=${WIFI_COUNTRY}
# 2 = Disable powersave, 3 = Enable powersave
powersave=2

[wifi-security]
key-mgmt=wpa-psk
psk=${WIFI_HASH}

[ipv4]
method=auto

[ipv6]
method=auto
EOS

  chmod 600 /etc/NetworkManager/system-connections/"${WIFI_SSID}".nmconnection

  # to set COUNTRY reliable on raspberry with NetworkManager
  echo -n "REGDOMAIN=${WIFI_COUNTRY}
" >/etc/default/crda

  # to the "very early" workaround as ultimate fix 
  sed -i "/cfg80211.ieee80211_regdom/!s/$/ cfg80211.ieee80211_regdom=${WIFI_COUNTRY}/" ${BOOTDIR}/cmdline.txt
  
  # for strange reasons, system requires rfkill unblock wifi on first boot
  cat <<EOS >/etc/systemd/system/unblock-wifi.service
[Unit]
Description=Unblock WiFi on boot (mandatory for first setup and preventive later)
After=NetworkManager.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/unblock-wifi
# to only run on first boot after install, uncomment these lines:
# ExecStart=/bin/bash -c "systemctl disable unblock-wifi"
# ExecStart=/bin/bash -c "systemctl mask unblock-wifi"

[Install]
WantedBy=multi-user.target
EOS

  chown root:root /usr/local/sbin/unblock-wifi
  chmod 755 /usr/local/sbin/unblock-wifi
  systemctl --quiet enable unblock-wifi
fi
