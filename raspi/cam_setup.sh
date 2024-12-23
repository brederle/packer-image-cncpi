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
        gstreamer1.0-tools\
        libgstrtspserver-1.0\
        cmake

    cd /tmp
    git clone https://github.com/sfalexrog/gst-rtsp-launch
    mkdir -p /tmp/gst-rtsp-launch/build
    cd /tmp/gst-rtsp-launch/build
    cmake ..
    make install
    rm -rf /tmp/gst-rtsp-launch

    # see `v4l2-ctl --list-formats-ext` for available input formats
    # use `gst-inspect-1.0 v4l2convert` for supported plugin parameters
    cat > /etc/systemd/system/livecam@.service <<SERVICE_EOF
[Unit]
Description=Real-time streaming cam service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/gst-rtsp-launch --port=9000 "( v4l2src device=/dev/video0 ! image/jpeg, width=1280, height=720, framerate=30/1 ! queue ! rtpjpegpay name=pay0 pt=96 )"
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
User=%i
Restart=on-abort
RestartPreventExitStatus=255
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE_EOF
fi

# Enable cncjs service
systemctl --quiet enable livecam@${CNCUSER}.service
