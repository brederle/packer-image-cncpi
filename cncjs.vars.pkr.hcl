###
# cncjs settings
variable "node_version" {
  description = "Node version for cncjs (LTS versions preferred)"
  type        = string
  default     = "24"
  sensitive   = false
}

variable "cncjs_version" {
  description = "Cncjs github version"
  type        = string
  default     = "1.11.1"
  sensitive   = false
}

variable "marlin_version" {
  description = "Marlin firmware version (build)"
  type        = string
  default     = "lts-2.1.2"
  sensitive   = false
}

variable "cncjs_uid" {
  description = "Extra system user running cncjs"
  type        = number
  default     = 1779
  sensitive   = false
}

variable "cncjs_user" {
  description = "Extra system user id running cncjs"
  type        = string
  default     = "cncjs"
  sensitive   = false
}

variable "cncjs_port" {
  description = "Port where cnc.js is exposed for use"
  type        = number
  default     = 8000
  sensitive   = false
}

###
# Automount remote directory
variable "cifs_path" {
  description = "Remote path to mount at /mnt/cncfiles (CIFS)"
  type        = string
  default     = ""
  sensitive   = false
}

variable "cifs_user" {
  description = "User for CIFS mount"
  type        = string
  default     = ""
  sensitive   = false
}

variable "cifs_password" {
  description = "Password for CIFS mount"
  type        = string
  default     = ""
  sensitive   = true
}
