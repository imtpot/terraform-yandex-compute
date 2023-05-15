locals {
  name           = var.name != null ? "${var.name}-${random_id.main.hex}" : "instance-${random_id.main.hex}"
  default_labels = {
    terraform        = "true"
    terraform_module = basename(abspath(path.root))
  }
}

resource "random_id" "main" {
  byte_length = 4
}

data "cloudinit_config" "main" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = templatefile(
      "${path.module}/${var.cloud_config.template_file}",
      {
        user    = var.cloud_config.user,
        pub_key = file(var.cloud_config.pub_key_file)
      }
    )
  }
}

resource "yandex_compute_instance" "main" {
  name        = local.name
  description = var.desc

  hostname = local.name
  boot_disk {
    initialize_params {
      image_id = var.boot_disk.image_id
      type     = var.boot_disk.type
      size     = var.boot_disk.size
    }
  }
  network_interface {
    subnet_id          = var.network.subnet_id
    security_group_ids = var.network.security_group_ids
    nat                = var.network.public_ip
  }
  platform_id = var.resources.platform_id
  resources {
    cores         = var.resources.cores
    core_fraction = var.resources.core_fraction
    memory        = var.resources.memory
  }
  scheduling_policy {
    preemptible = var.resources.preemptible
  }
  metadata = {
    user-data = data.cloudinit_config.main.rendered
  }
  zone                      = var.zone
  allow_stopping_for_update = true

  labels = merge(local.default_labels, var.labels)

  connection {
    user = var.cloud_config.user
    host = self.network_interface[0].nat_ip_address
  }

  #  provisioner "remote-exec" {
  #    count = length(var.provisioner.inline)
  #    inline = var.provisioner.inline
  #  }
}
