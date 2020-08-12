# ------------------------------
#  Var
# ------------------------------

# prefix = myk-zabbix

# server ec2 az = ap-northeast-1a
# proxy  ec2 az = ap-northeast-1a
# agent  ec2 az = ap-northeast-1a

# ami           = amazon linux 2



# ------------------------------
#  Zabbix Control side
# ------------------------------

# EC2
resource "aws_instance" "server" {
  key_name          = local.pem_key
  ami               = "ami-0af1df87db7b650f4"
  instance_type     = "t2.micro"
  availability_zone = "ap-northeast-1a"
  subnet_id         = aws_subnet.server.id
  security_groups   = [aws_security_group.server.id]
  private_ip        = local.server_ec2_ip
  ebs_optimized     = false
  monitoring        = false
  source_dest_check = false
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
  tags = { "Name" = "myk-zabbix-server-ec2" }
}

# ElasticIP
resource "aws_eip" "server" {
  instance = aws_instance.server.id
  vpc      = true
  tags     = { "Name" = "myk-zabbix-server-eip" }
}



# ------------------------------
#  Zabbix Target side
# ------------------------------

# Proxy -----------------------
# EC2
resource "aws_instance" "proxy" {
  key_name          = local.pem_key
  ami               = "ami-0af1df87db7b650f4"
  instance_type     = "t2.micro"
  availability_zone = "ap-northeast-1a"
  subnet_id         = aws_subnet.proxy.id
  security_groups   = [aws_security_group.proxy.id]
  private_ip        = local.proxy_ec2_ip
  ebs_optimized     = false
  monitoring        = false
  source_dest_check = false
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
  tags = { "Name" = "myk-zabbix-proxy-ec2" }
}

# ElasticIP
resource "aws_eip" "proxy" {
  instance = aws_instance.proxy.id
  vpc      = true
  tags     = { "Name" = "myk-zabbix-proxy-eip" }
}


# Agent -----------------------
# EC2
resource "aws_instance" "agent" {
  key_name          = local.pem_key
  ami               = "ami-0af1df87db7b650f4"
  instance_type     = "t2.micro"
  availability_zone = "ap-northeast-1a"
  subnet_id         = aws_subnet.agent.id
  security_groups   = [aws_security_group.agent.id]
  private_ip        = local.agent_ec2_ip
  ebs_optimized     = false
  monitoring        = false
  source_dest_check = false
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
  tags = { "Name" = "myk-zabbix-agent-ec2" }
}

# ElasticIP
resource "aws_eip" "agent" {
  instance = aws_instance.agent.id
  vpc      = true
  tags     = { "Name" = "myk-zabbix-agent-eip" }
}


# resource "aws_volume_attachment" “some-attachment” {
#   device_name = "/dev/sdb"
#   volume_id   = "${aws_ebs_volume.some-ebs.id}"
#   instance_id = "${aws_instance.some-instance.id}"
# }
#  resource "aws_ebs_volume" “some-ebs" {
#   availability_zone = "ap-northeast-1a"
#   size              = 100
#    tags {
#     Name = “some-ebs"
#   }
# }