provider "yandex" {
  folder_id = var.folder_id
}

data "yandex_compute_image" "main" {
  family = "almalinux-8"
}

module "vpc" {
  source                 = "git::https://github.com/agmtr/terraform-yandex-vpc.git?ref=v1.0.1"
  create_default_subnets = true
}

module "sg" {
  source               = "git::https://github.com/agmtr/terraform-yandex-sg.git?ref=v1.0.1"
  network_id           = module.vpc.id
  enable_default_rules = {
    egress_any = true
    ssh        = true
  }
  rules = {
    https = {
      direction      = "ingress"
      protocol       = "TCP"
      port           = 443
      v4_cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "compute_instance" {
  source = "git::https://github.com/agmtr/terraform-yandex-compute.git?ref=v1.0.1"
  name   = "compute-instance"
  image  = data.yandex_compute_image.main.id
  network = {
    subnet_id = module.vpc.subnets["default-a"].id
    security_group_ids = [module.sg.id]
  }
  resources = {
    cores  = 2
    memory = 2
    preemptible = true
  }
  zone = module.vpc.subnets["default-a"].zone
}
