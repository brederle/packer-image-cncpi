variable "hostname" {
  description = "The hostname identifier of your armbian."
  type        = string
  default     = "cncjs"
  sensitive   = false
}

###
# wifi configuration (no wifi by default)
#
variable "wifi_ssid" {
  description = "The identifier of your wifi. No wifi support if empty."
  type        = string
  default     = ""
  sensitive   = true
}

variable "wifi_passphrase" {
  description = "The unencrypted passphrase of your wifi"
  type        = string
  default     = ""
  sensitive   = true
}

variable "wifi_country" {
  description = "The countrycode your wifi runs in"
  type        = string
  default     = "DE"
  sensitive   = false
}

###
# General system settings
#
variable "timezone" {
  description = "Timezone to run the armbian in"
  type        = string
  default     = "UTC"
  sensitive   = false
}

variable "locale" {
  description = "Language/locale setting the armbian uses"
  type        = string
  default     = "en_GB"
  sensitive   = false
}

variable "encoding" {
  description = "Global character encoding for server. Rarely requires change"
  type        = string
  default     = "UTF-8"
  sensitive   = false
}

variable "keymap" {
  description = "Keyboard keymap setup"
  type        = string
  default     = "gb"
  sensitive   = false
}


variable "boottime" {
  description = "Time for an automatic reboot after auto security update. Use 'now' to boot directly after download"
  type        = string
  default     = "03:00"
  sensitive   = false
}

###
# Service provider user 
#
variable "user" {
  description = "Non-root service account name the armbian runs on"
  type        = string
  default     = "armour"
  sensitive   = false
}

variable "uid" {
  description = "Non-root service account name the Armbian runs on"
  type        = number
  default     = 1778
  sensitive   = false
}

variable "user_description" {
  description = "Non-root service account user description"
  type        = string
  default     = "Armbian main user"
  sensitive   = false
}

variable "authorized_keyfile" {
  description = "Path to the `authorized_keys` file if keys sould be used."
  type        = string
  default     = ".private/ssh/authorized_keys"
  sensitive   = false
}

variable "sdcard_device" {
  description = "If set to a /dev/sdX where sdcard is mounted, try to flash directly"
  type        = string
  default     = "/dev/null"
  sensitive   = false
}