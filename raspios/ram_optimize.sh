#!/bin/bash

###
# Ootimize for 512M memory
# to protect SDCARD a little better
# source /tmp/utils.sh

# to avoid perl warnings in apt, use the raspi default
export LANGUAGE=${LOCALE}.${ENCODING}
export LANG=${LOCALE}.${ENCODING}
export LC_ALL=C


############################
# log to memory, not sdcard
echo "### RAM optimisation: Log to ram ###"

echo "none                  /var/run       tmpfs   size=5M,noatime    0       0" >>/etc/fstab
echo "none                  /var/log       tmpfs   size=5M,noatime    0       0" >>/etc/fstab

############################
# primary swap ZRAM 64M
echo "### RAM optimisation: ZRAM as primary swap ###"

DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install -y zram-tools

cat <<EOC >/etc/default/zramswap
ENABLED=true

# Compression algorithm selection
# speed: lz4 > zstd > lzo
# compression: zstd > lzo > lz4
# This is not inclusive of all that is available in latest kernels
# See /sys/block/zram0/comp_algorithm (when zram module is loaded) to see
# what is currently set and available for your kernel[1]
# [1]  https://github.com/torvalds/linux/blob/master/Documentation/blockdev/zram.txt#L86
ALGO=lz4

# Specifies the amount of RAM that should be used for zram
# based on a percentage the total amount of available memory
# This takes precedence and overrides SIZE below
PERCENT=10

# Specifies a static amount of RAM that should be used for
# the ZRAM devices, this is in MiB  /etc/default/zramswap
#SIZE=256

# Specifies the priority for the swap devices, see swapon(2)
# for more details. Higher number = higher priority
# This should probably be higher than hdd/ssd swaps.
PRIORITY=100
EOC

systemctl --quiet enable zramswap

############################
# secondary emergency swap 128M, not intended to be used
# zramfs has usually priority 5, so the pri in fstab is lower=less prio
echo "### RAM optimisation: Swapfile as secondary emergency swap ###"

fallocate -l 128M /var/emergency_swap
chmod 600 /var/emergency_swap
mkswap /var/emergency_swap
echo "/var/emergency_swap   none           swap    sw,pri=10          0       0" >>/etc/fstab


############################
# optimize swap behaior
echo "### RAM optimisation: Reduced swapiness ###"

  cat <<EOS >> /etc/sysctl.conf
###################################################################
# reduce swappiness for raspberry pi with zram
vm.vfs_cache_pressure=500
vm.swappiness=10
vm.dirty_background_ratio=1
vm.dirty_ratio=50
EOS
