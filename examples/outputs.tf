output "network_id" {
  value = module.vpc.id
}

output "subnets" {
  value = module.vpc.subnets
}

output "instance" {
  value = {
    (module.compute_instance.instance.id) : {
      (module.compute_instance.instance.name) : (module.compute_instance.instance.network_interface[0].nat_ip_address)
    }
  }
}
