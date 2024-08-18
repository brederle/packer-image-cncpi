###
# cncjs settings
variable "node_version" {
  description = "Node version for cncjs"
  type        = string
  default     = ""
  sensitive   = false
}

variable "cncjs_version" {
  description = "Cncjs github version"
  type        = string
  default     = "latest"
  sensitive   = false
}

variable "cncjs_user" {
  description = "Extra system user running cncjs"
  type        = string
  default     = "cncjs"
  sensitive   = false
}

###
# Automount remote directory
variable "mount_path" {
  description = "Remote path to mount for /mnt/cncfiles (CIFS)"
  type        = string
  default     = ""
  sensitive   = false
}

variable "mount_user" {
  description = "User for CIFS mount"
  type        = string
  default     = ""
  sensitive   = false
}

variable "mount_password" {
  description = "Password for CIFS mount"
  type        = string
  default     = ""
  sensitive   = false
}

###
# CAM settings
variable "gpumem" {
  description = "Size of GPU memory for the RasPi cam"
  type        = number
  default     = 64
  sensitive   = false
}

