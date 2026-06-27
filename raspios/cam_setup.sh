#!/bin/bash

source /tmp/utils.sh

###
# Raspi improved camera setup with libcamera for RPi3/4
# for simple realtime streaming

echo "### Kernel settings for cam ###"
SETKEY gpu_mem ${GPU_MEM} ${BOOTDIR}/config.txt
SETKEY force_turbo 1 ${BOOTDIR}/config.txt
SETKEY camera_auto_detect 1 ${BOOTDIR}/config.txt

# enable usb soundcard
# SETKEY "dtparam=audio" on ${BOOTDIR}/config.txt
# sed -i 's/^\s*\(defaults\.ctl\.card\)\s\+[0-9\-]\+/\1 '"${SOUNDCARDID}"'/' /usr/share/alsa/alsa.conf
# sed -i 's/^\s*\(defaults\.pcm\.card\)\s\+[0-9\-]\+/\1 '"${SOUNDCARDID}"'/' /usr/share/alsa/alsa.conf

# no screen on boot
#setConfig hdmi_ignore_cec_init 1 ${BOOTDIR}/config.txt

# disable hardware UART completely to disable peephole
# SETKEY enable_uart 0 ${BOOTDIR}/config.txt

# disable bluetooth
# echo "dtoverlay=disable-bt" >> ${BOOTDIR}/config.txt
# echo "blacklist bluetooth" >> /etc/modprobe.d/raspi-blacklist.conf

# enable SPI
# SETKEY "dtparam=spi" on ${BOOTDIR}/config.txt