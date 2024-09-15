#!/bin/bash

source /tmp/utils.sh

###
# Raspi improved camera setup with libcamera for RPi3/4
# for simple realtime streaming

echo "Improve kernel settings for cam"
SETKEY gpu_mem ${GPU_MEM} ${BOOTDIR}/config.txt
SETKEY force_turbo 1 ${BOOTDIR}/config.txt
SETKEY camera_auto_detect 1 ${BOOTDIR}/config.txt

if [ -z "$USBCAM_DEV" ]; then
    # set up pi camera
    SETKEY disable_camera_led 1 ${BOOTDIR}/config.txt        

    echo "Install picam live service" 
    cat > /etc/systemd/system/livecam@.service <<SERVICE_EOF
[Unit]
Description=Real-time streaming cam service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/libcamera-vid --camera ${PICAM_NR} --level 4.2 --denoise cdn_off --tuning-file /usr/share/libcamera/ipa/raspberrypi/ov5647_noir.json -v 1 -t 0 --width 1296 --height 972 --nopreview --inline --listen -o tcp://0.0.0.0:9000
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
User=%i
Restart=on-abort
RestartPreventExitStatus=255

[Install]
WantedBy=multi-user.target
SERVICE_EOF

else
    # set up usb camera
    echo "Install usb cam live service" 
    apt-get install -y --no-install-recommends libgstreamer1.0-dev\
        libgstreamer-plugins-base1.0-dev\
        libgstreamer-plugins-bad1.0-dev\
        gstreamer1.0-plugins-base\
        gstreamer1.0-plugins-good\
        gstreamer1.0-plugins-bad\
        gstreamer1.0-plugins-ugly\
        gstreamer1.0-libav\
        gstreamer1.0-tools


    cat > /etc/systemd/system/livecam@.service <<SERVICE_EOF
[Unit]
Description=Real-time streaming cam service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/gst-launch-1.0 -vv -e v4l2src device="${USBCAM_DEV}" ! "video/x-raw,width=1280,height=720" ! queue ! omxh264enc  ! h264parse ! rtph264pay ! tcpsink host=0.0.0.0 port=9000
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
User=%i
Restart=on-abort
RestartPreventExitStatus=255

[Install]
WantedBy=multi-user.target
SERVICE_EOF
fi

# Enable cncjs service
systemctl --quiet enable livecam@${CNCUSER}.service
