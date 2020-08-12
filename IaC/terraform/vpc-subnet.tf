# ------------------------------
#  Var
# ------------------------------

# prefix = myk-zabbix

# server side prefix = server
# agent  side prefix = agent

# server az = ap-northeast-1a
# agent  az = ap-northeast-1a



# ------------------------------
#  Zabbix Monitor side
# ------------------------------

# Monitor ----------------------
# VPC
resource "aws_vpc" "monitor" {
  cidr_block           = local.monitor_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "myk-zabbix-monitor-vpc"
  }
}

# InternetGateway
resource "aws_internet_gateway" "monitor" {
  vpc_id = aws_vpc.monitor.id
  tags   = { "Name" = "myk-zabbix-monitor-igw" }
}

# RouteTable (rt , rt+igw , rt+vpc)
resource "aws_route_table" "monitor" {
  vpc_id = aws_vpc.monitor.id
  tags   = { "Name" = "myk-zabbix-monitor-rt" }
}
resource "aws_route" "monitor" {
  route_table_id         = aws_route_table.monitor.id
  gateway_id             = aws_internet_gateway.monitor.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_main_route_table_association" "monitor" {
  vpc_id         = aws_vpc.monitor.id
  route_table_id = aws_route_table.monitor.id
}


# Server -----------------------
# Subnet
resource "aws_subnet" "server" {
  vpc_id                  = aws_vpc.monitor.id
  cidr_block              = local.server_public_subnet_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags                    = { "Name" = "myk-zabbix-server-sub" }
}

#  Association (sub + rt)
resource "aws_route_table_association" "server" {
  subnet_id      = aws_subnet.server.id
  route_table_id = aws_route_table.monitor.id
}


# Database ----------------------
# DB RouteTable
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.monitor.id
  tags   = { "Name" = "myk-zabbix-db-rt" }
}

# DB sub
resource "aws_subnet" "db_1a" {
  vpc_id                  = aws_vpc.monitor.id
  cidr_block              = local.db_private_subnet_1a_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags                    = { "Name" = "myk-zabbix-db-sub-1a" }
}
resource "aws_subnet" "db_1c" {
  vpc_id                  = aws_vpc.monitor.id
  cidr_block              = local.db_private_subnet_1c_cidr
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags                    = { "Name" = "myk-zabbix-db-sub-1c" }
}
# pri-sub + pri-rt
resource "aws_route_table_association" "db_1a" {
  subnet_id      = aws_subnet.db_1a.id
  route_table_id = aws_route_table.db.id
}
resource "aws_route_table_association" "db_1c" {
  subnet_id      = aws_subnet.db_1c.id
  route_table_id = aws_route_table.db.id
}



# ------------------------------
#  Zabbix Target side
# ------------------------------

# Target -----------------------
# VPC
resource "aws_vpc" "target" {
  cidr_block           = local.target_vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "myk-zabbix-target-vpc"
  }
}

# InternetGateway
resource "aws_internet_gateway" "target" {
  vpc_id = aws_vpc.target.id
  tags   = { "Name" = "myk-zabbix-target-igw" }
}

# RouteTable (rt , rt+igw , rt+vpc)
resource "aws_route_table" "target" {
  vpc_id = aws_vpc.target.id
  tags   = { "Name" = "myk-zabbix-target-rt" }
}
resource "aws_route" "target" {
  route_table_id         = aws_route_table.target.id
  gateway_id             = aws_internet_gateway.target.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_main_route_table_association" "target" {
  vpc_id         = aws_vpc.target.id
  route_table_id = aws_route_table.target.id
}


# Prosy ------------------------
# Subnet
resource "aws_subnet" "proxy" {
  vpc_id                  = aws_vpc.target.id
  cidr_block              = local.proxy_public_subnet_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags                    = { "Name" = "myk-zabbix-proxy-sub" }
}

# Association (sub + rt)
resource "aws_route_table_association" "proxy" {
  subnet_id      = aws_subnet.proxy.id
  route_table_id = aws_route_table.target.id
}



# Agent ------------------------
# Subnet
resource "aws_subnet" "agent" {
  vpc_id                  = aws_vpc.target.id
  cidr_block              = local.agent_private_subnet_cidr
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags                    = { "Name" = "myk-zabbix-agent-sub" }
}

# Association (sub + rt)
resource "aws_route_table_association" "agent" {
  subnet_id      = aws_subnet.agent.id
  route_table_id = aws_route_table.target.id
}

# # RouteTable
# resource "aws_route_table" "agent" {
#   vpc_id = aws_vpc.target.id
#   tags   = { "Name" = "myk-zabbix-agent-rt" }
# }

# # pri-sub + pri-rt
# resource "aws_route_table_association" "agent" {
#   subnet_id      = aws_subnet.agent.id
#   route_table_id = aws_route_table.agent.id
# }