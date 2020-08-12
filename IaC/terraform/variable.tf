# 自分以外の通信を許可する場合はこちらを指定
variable "allowed_cidr" {
  default = null
}
locals {
  pem_key = "miyake-key"
  
  # My cider getting from API
  current-ip = chomp(data.http.ifconfig.body)
  my_cidr    = (var.allowed_cidr == null) ? "${local.current-ip}/32" : var.allowed_cidr

  # Monitor side
  monitor_vpc_cidr          = "10.10.0.0/16"

  server_public_subnet_cidr = "10.10.10.0/24"
  server_ec2_ip             = "10.10.10.10"
  server_ec2_cidr           = "10.10.10.10/32"

  db_private_subnet_1a_cidr = "10.10.20.0/24"
  db_private_subnet_1c_cidr = "10.10.21.0/24"

  # Target side
  target_vpc_cidr           = "10.20.0.0/16"

  proxy_public_subnet_cidr  = "10.20.10.0/24"
  proxy_ec2_ip              = "10.20.10.10"
  proxy_ec2_cidr            = "10.20.10.10/32"

  agent_private_subnet_cidr = "10.20.20.0/24"
  agent_ec2_ip              = "10.20.20.10"
  agent_ec2_cidr            = "10.20.20.10/32"
}
