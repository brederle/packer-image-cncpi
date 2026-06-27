packer {  
    required_plugins {
        armflash =  {
            version = ">= 1.1.0"
            source = "github.com/brederle/armflash"
        }
    }
}

source "armflash" "rpi-cncjs" {
  file_urls             = ["https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2026-06-19/2026-06-18-raspios-trixie-arm64-lite.img.xz"]
  file_checksum_url     = "https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2026-06-19/2026-06-18-raspios-trixie-arm64-lite.img.xz.sha256"
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
  image_path       ="cncjs-raspi-arm64.img"
  image_size       = "5G"
  image_chroot_env = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]

  # for Apple Silicon build
  qemu_binary_destination_path = "/usr/bin/qemu-arm-static"
  qemu_binary_source_path      = "/usr/bin/qemu-arm-static"

  # for Intel build
  # qemu_binary_source_path      = "/usr/bin/qemu-aarch64"
  # qemu_binary_destination_path = "/usr/bin/qemu-aarch64-static"
}

build {
  sources = ["source.armflash.rpi-cncjs"]

  // deposit the helper functions for use in
  // the following scripts
  provisioner "file" {
    source      = "raspios/utils.sh"
    destination = "/tmp/utils.sh"
  }

  # start with network configuration  
  // the workaround for spurious wifi blocks on boot
  // (esp. on first run after setup)
  provisioner "file" {
    source      = "raspios/unblock-wifi"
    destination = "/usr/local/sbin/unblock-wifi"
  }

  // start with network configuration  
  provisioner "shell" {
    env = {
      HOSTNAME     = "${var.hostname}"
      WIFI_SSID    = "${var.wifi_ssid}"
      WIFI_PASS    = "${var.wifi_passphrase}"
      WIFI_COUNTRY = "${var.wifi_country}"
    }
    script = "raspios/net_setup.sh"
  }

  # general system setting
  provisioner "shell" {
    env = {
      TZ       = "${var.timezone}"
      LOCALE   = "${var.locale}"
      ENCODING = "${var.encoding}"
      KEYMAP   = "${var.keymap}"
    }
    script = "raspios/system_setup.sh"
  }

  # boot setup headless and preferred overlays
  provisioner "shell" {
    env = {
      TZ       = "${var.timezone}"
      LOCALE   = "${var.locale}"
      ENCODING = "${var.encoding}"
      KEYMAP   = "${var.keymap}"
    }
    script = "raspios/boot_setup.sh"
  }

  # refresh package lists for package installations
  provisioner "shell" {
    inline = ["echo '### Update apt packages ###'",
              "DEBIAN_FRONTEND=noninteractive apt-get -yq update",
              "DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install curl wget vim nano ca-certificates build-essential figlet git dfu-util python3-venv python3-pip"]
  }

  ###
  # RAM optimization with ZRAM and more
  provisioner "shell" {
    env = {
      LOCALE      = "${var.locale}"
      ENCODING    = "${var.encoding}"
    }
    script = "raspios/ram_optimize.sh"
  }

  ###
  # automatic security updates
  provisioner "shell" {
    env = {
      LOCALE   = "${var.locale}"
      ENCODING = "${var.encoding}"
      BOOTTIME = "${var.boottime}"
    }
    script = "raspios/auto_updates.sh"
  }

  ###
  # SSH hardening setup
  #
  # ATTENTION: This setup does only support elliptic keys
  # RSA is NOT supported!
  # TIP: Use `ssh-keygen -t ecdsa` to create an elliptic ssh key
  provisioner "file" {
    source      = "raspios/sshd_config"
    destination = "/etc/ssh/sshd_config"
  }

  provisioner "shell" {
    env = {
      LOCALE      = "${var.locale}"
      ENCODING    = "${var.encoding}"
      USER        = "${var.user}"
      UID         = "${var.uid}"
      DESCRIPTION = "${var.user_description}"
    }
    script = "raspios/sshuser_setup.sh"
  }

  provisioner "file" {
    source      = "${var.authorized_keyfile}"
    destination = "/home/${var.user}/.ssh/authorized_keys"
  }

  provisioner "shell" {
    inline = ["chown -R ${var.user}:${var.user} /home/${var.user}/.ssh"]
  }

  /**************************************************************
   * Manta M5P firmare specifics, cnc.js installation
   */

  # mount to NAS  
  provisioner "shell" {
    env = {
      LOCALE      = "${var.locale}"
      ENCODING    = "${var.encoding}"
      USER        = "${var.user}"
      GROUP       = "${var.user}"
      CIFSPATH    = "${var.cifs_path}"
      CIFSUSER    = "${var.cifs_user}"
      CIFSPASS    = "${var.cifs_password}"
    }
    script = "raspios/nas_mount.sh"
  }

  /**
   * own motd decoration
   */
  provisioner "file" {
    source      = "cncjs/update-motd.d"
    destination = "/etc"
  }
  
  provisioner "shell" {
    env = {
      LOCALE     = "${var.locale}"
      ENCODING   = "${var.encoding}"
      USER       = "${var.user}"
      CNCJSUSER  = "${var.cncjs_user}"
    }
    script = "cncjs/decoration.sh"
  }

  // install fqdn warning blocker for sudo
  provisioner "file" {
    source      = "cncjs/22_sudo_no_fqdn"
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
      CNCUSERS      = "${var.user}"
      CNCJSUSER     = "${var.cncjs_user}"
      CNCJSUID      = "${var.cncjs_uid}"
    }
    script = "cncjs/cncjsuser_setup.sh"
  }

  // install cncjs as CNCUSER, not as root
  provisioner "shell" {
    execute_command = "sudo -u ${var.cncjs_user} sh -c '{{ .Vars }} {{ .Path }}'"
    env = {
      LOCALE       = "${var.locale}"
      ENCODING     = "${var.encoding}"
      CNCJSUSER    = "${var.cncjs_user}"
      CNCJSVERSION = "${var.cncjs_version}"
    }
    script = "cncjs/cncjs_install.sh"
  }

  // lowrider default settings
  provisioner "file" {
    source      = "cncjs/cncrc.json"
    destination = "/home/${var.cncjs_user}/.cncrc"
  }

  provisioner "shell" {
    inline = ["chown ${var.cncjs_user}:users /home/${var.cncjs_user}/.cncrc",
              "chmod 644 /home/${var.cncjs_user}/.cncrc"]
  }

  provisioner "shell" {
    execute_command = "sudo -u ${var.cncjs_user} sh -c '{{ .Vars }} {{ .Path }}'"
    env = {
      LOCALE        = "${var.locale}"
      ENCODING      = "${var.encoding}"
      CNCJSUSER     = "${var.cncjs_user}"
      CNCJSPORT     = "${var.cncjs_port}"
    }
    script = "cncjs/cncjspm2_setup.sh"
  }
  
  provisioner "shell" {
    env = {
      LOCALE        = "${var.locale}"
      ENCODING      = "${var.encoding}"
      CNCJSUSER     = "${var.cncjs_user}"
      CNCJSPORT     = "${var.cncjs_port}"
    }
    script = "cncjs/gamepad_setup.sh"
  }

  provisioner "shell" {
    execute_command = "sudo -u ${var.user} sh -c '{{ .Vars }} {{ .Path }}'"
    env = {
      LOCALE        = "${var.locale}"
      ENCODING      = "${var.encoding}"
      USER          = "${var.user}"
      MARLINVERSION = "${var.marlin_version}"
    }
    script = "marlin/build_marlin_setup.sh"
  }
 
  provisioner "file" {
    source      = "marlin/platformio.ini"
    destination = "/home/${var.user}/marlin/platformio.ini"
  }

  provisioner "file" {
    source      = "marlin/Marlin/"
    destination = "/home/${var.user}/marlin/Marlin"
  }

  provisioner "shell" {
    inline = ["chown ${var.user}:users /home/${var.user}/marlin/platformio.ini",
              "chown ${var.user}:users /home/${var.user}/marlin/Marlin/Configuration.h",
              "chown ${var.user}:users /home/${var.user}/marlin/Marlin/Configuration_adv.h",
              "chmod 644 /home/${var.user}/marlin/platformio.ini",
              "chmod 644 /home/${var.user}/marlin/Marlin/Configuration.h",
              "chmod 644 /home/${var.user}/marlin/Marlin/Configuration_adv.h"]
  }

  /***
   * Clean up workfiles:
   * - the temporary resolv.conf is removed in favor of an update
   *   via DHCP after boot
   * - the fqdn warning blocker for sudo
   */
  provisioner "shell" {
    inline = ["echo ### Cleanup workfiles ###",
              "rm -f /etc/sudoers.d/22_sudo_no_fqdn"]
  }

  /**************************************************************
   * rename the resulting image to support multiple setup for
   * one script (workaround)
   */
  provisioner "shell-local" {
    inline = [
      "mv cncjs-raspi-arm64.img ${var.hostname}-cncjs-raspi-arm64.img"
    ]
  }

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