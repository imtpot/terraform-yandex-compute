variable "name" {
  type    = string
  default = null
}

variable "desc" {
  type    = string
  default = null
}

variable "resources" {
  type = object({
    platform_id   = optional(string, "standard-v3")
    cores         = optional(number, 2)
    memory        = optional(number, 2)
    core_fraction = optional(number, 100)
    preemptible   = optional(bool, false)
  })
  default = {}
}

variable "boot_disk" {
  type = object({
    image_id = string
    type     = optional(string, "network-hdd")
    size     = optional(number, 20)
  })
  default = {
    image_id = ""
    type     = "network-hdd"
    size     = 20
  }
}

variable "network" {
  type = object({
    subnet_id          = string
    public_ip          = optional(bool, true)
    security_group_ids = optional(list(string))
  })
}

variable "cloud_config" {
  type = object({
    template_file = optional(string, "./templates/cloud-init.tftpl")
    user          = optional(string, "cloud-user")
    pub_key_file  = optional(string, "~/.ssh/id_rsa.pub")
    extra_config  = optional(object({
      content_type = optional(string),
      filename     = optional(string),
      content      = optional(string)
    }))
  })
  default = {}
}

variable "zone" {
  type = string
}

#variable "provisioner" {
#  type = object({
#    inline = list(string)
#  })
#  default = {
#    inline = null
#  }
#}

variable "labels" {
  type    = map(string)
  default = {}
}
