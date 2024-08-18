#!/bin/bash

###
# Add wifi settings (if configured)
#
BOOTDIR=$(/usr/lib/raspberrypi-sys-mods/get_fw_loc)

if [[ ! -z "$WIFI_SSID" ]] && [[ ! -z "$WIFI_PASS" ]]; then
    ENCRYPTED_PASSPHRASE=$(wpa_passphrase "${WIFI_SSID}" "${WIFI_PASS}" | sed -n '/psk=/s/^[[:space:]]*psk=//p')
    echo -n $WIFI_PASS=$ENCRYPTED_PASSPHRASE
    cat << SECTION >> ${BOOTDIR}/custom.toml  
 
[wlan]
country = "${WIFI_COUNTRY}"
ssid = "${WIFI_SSID}"
password = "${ENCRYPTED_PASSPHRASE}"
password_encrypted = true
hidden = false
SECTION
fi