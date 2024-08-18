packer {  
    required_plugins {
        armflash =  {
            version = ">= 1.1.0"
            source = "github.com/brederle/armflash"
        }
    }
}

source "armflash" "cncpi" {
  file_urls             = ["https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz"]
  file_checksum_url     = "https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz.sha256"
  file_checksum_type    = "sha256"
  file_target_extension = "xz"
  file_unarchive_cmd    = ["xz", "--decompress", "$ARCHIVE_PATH"]
  image_build_method    = "resize"
  image_type            = "dos"
  image_partitions {
    filesystem = "fat"
    # mountpoint has changed for bookworm !
    mountpoint   = "/boot/firmware"
    name         = "boot"
    size         = "256M"
    start_sector = "2048"
    type         = "c"
  }
  image_partitions {
    filesystem   = "ext4"
    mountpoint   = "/"
    name         = "root"
    size         = "0"
    start_sector = "526336"
    type         = "83"
  }
  image_path       = "cncpi-pi-arm64.img"
  image_size       = "4G"
  image_chroot_env = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]

  # for MAC M1 build
  qemu_binary_destination_path = "/usr/bin/qemu-arm-static"
  qemu_binary_source_path      = "/usr/bin/qemu-arm-static"

  # for Intel build
  # qemu_binary_source_path      = "/usr/bin/qemu-aarch64"
  # qemu_binary_destination_path = "/usr/bin/qemu-aarch64-static"
}

build {
  sources = ["source.armflash.cncpi"]

  // General raspberry pi image modifications and hardenings
  provisioner "shell" {
    inline = ["apt-get -yq update"]
  }

  provisioner "shell" {
    env = {
      HOSTNAME = "${var.hostname}"
      TZ       = "${var.timezone}"
      LOCALE   = "${var.locale}"
      ENCODING = "${var.encoding}"
      KEYMAP   = "${var.keymap}"
    }
    script = "raspi/core_setup.sh"
  }

  provisioner "shell" {
    env = {
      WIFI_SSID    = "${var.wifi_ssid}"
      WIFI_PASS    = "${var.wifi_passphrase}"
      WIFI_COUNTRY = "${var.wifi_country}"
    }
    script = "raspi/wifi_setup.sh"
  }

  provisioner "shell" {
    env = {
      LOCALE   = "${var.locale}"
      ENCODING = "${var.encoding}"
      BOOTTIME = "${var.boottime}"
    }
    script = "raspi/auto_updates.sh"
  }

  provisioner "file" {
    source      = "raspi/sshd_config"
    destination = "/etc/ssh/sshd_config"
  }

  # an empty file is copy by default
  # to activate password authentication
  provisioner "file" {
    source      = "${var.authorized_keyfile}"
    destination = "/tmp/authorized_keys"
  }

  provisioner "shell" {
    env = {
      LOCALE   = "${var.locale}"
      ENCODING = "${var.encoding}"
      USER     = "${var.user}"
      PASS     = "${var.password}"
    }
    script = "raspi/user_ssh_setup.sh"
  }

  provisioner "shell" {
    env = {
      LOCALE   = "${var.locale}"
      ENCODING = "${var.encoding}"
    }
    script = "raspi/sdcard_saver.sh"
  }


  // CIFS mount ---------------------
  provisioner "shell" {
    env = {
      LOCALE        = "${var.locale}"
      ENCODING      = "${var.encoding}"
      CNCUSER       = "${var.cncjs_user}"
      MOUNTPATH     = "${var.mount_path}"
      MOUNTUSER     = "${var.mount_user}"
      MOUNTPASS     = "${var.mount_password}"
    }
    script = "cncjs/cncjs_mount.sh"
  }

  // cnc.js installation ---------------------

  // install fqdn warning blocker for sudo
  provisioner "file" {
    source      = "cncjs/020_sudo_no_fqdn"
    destination = "/etc/sudoers.d"
  }

  provisioner "shell" {
    env = {
      LOCALE        = "${var.locale}"
      ENCODING      = "${var.encoding}"
      NODE_VERSION  = "${var.node_version}"
    }
    script = "cncjs/nodejs_install.sh"
  }

  provisioner "shell" {
    env = {
      LOCALE        = "${var.locale}"
      ENCODING      = "${var.encoding}"
      CNCUSER       = "${var.cncjs_user}"
      CNCUID        = "2142"  // some randomly chosen number
    }
    script = "cncjs/cncjs_user.sh"
  }

  // install as CNCUSER, not as root
  provisioner "shell" {
    execute_command = "sudo -u ${var.cncjs_user} sh -c '{{ .Vars }} {{ .Path }}'"
    env = {
      LOCALE        = "${var.locale}"
      ENCODING      = "${var.encoding}"
      CNCJS_VERSION = "${var.cncjs_version}"
      CNCUSER       = "${var.cncjs_user}"
    }
    script = "cncjs/cncjs_install.sh"
  }

  // set up the service

  // cncpi specific setup
  provisioner "file" {
    source      = "cncjs/cncrc.json"
    destination = "/home/${var.cncjs_user}/.cncrc"
  }

  provisioner "shell" {
    env = {
      LOCALE        = "${var.locale}"
      ENCODING      = "${var.encoding}"
      CNCUSER       = "${var.cncjs_user}"
    }
    script = "cncjs/cncjs_config.sh"
  }

  // remove fqdn warning blocker for sudo
  provisioner "shell" {
    inline = ["echo Remove sudo dns resolution blocker",
              "rm -f /etc/sudoers.d/020_sudo_no_fqdn"]
  }

  // cam installation ---------------------

  // set sdcard_device != /dev/null in variables
  // to write an sdcard directly after successful build
  post-processors {
  //  post-processor "flasher" {
  //    device      = "${var.sdcard_device}"
  //    block_size  = 4096
  //    interactive = true
  //  }
  }

}