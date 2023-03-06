# Usage

```
provider "yandex" {
  folder_id = var.folder_id
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket     = "tfstates-bucket"
    key        = "production/vpc.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

data "yandex_compute_image" "main" {
  family = "almalinux-8"
}

module "vm" {
  source = "git::https://github.com/agmtr/terraform-yandex-compute.git?ref=v1.0.0"
  name   = "vm"
  image  = data.yandex_compute_image.main.id
  network = {
    subnet_id = data.terraform_remote_state.vpc.outputs.subnets["subnet-a"].id
  }
  resources = {
    cores  = 2
    memory = 2
  }
  zone = data.terraform_remote_state.vpc.outputs.subnets["subnet-a"].zone
}
