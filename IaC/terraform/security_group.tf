# ------------------------------
#  Var
# ------------------------------

# prefix = myk-zabbix
# server ec2 az = ap-northeast-1a
# proxy  ec2 az = ap-northeast-1a
# agent  ec2 az = ap-northeast-1a



# ------------------------------
#  Zabbix Control side
# ------------------------------

#  Server ----------------------
# sercurity group
resource "aws_security_group" "server" {
  name        = "myk-zabbix-server-sg"
  description = "Allow ssh http zabbix-proxy"
  vpc_id      = aws_vpc.monitor.id
}

# in ssh
resource "aws_security_group_rule" "server_allow_in_ssh" {
  security_group_id = aws_security_group.server.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.my_cidr]
}
# in http
resource "aws_security_group_rule" "server_allow_in_http" {
  security_group_id = aws_security_group.server.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [local.my_cidr]
}
# in proxy
resource "aws_security_group_rule" "server_allow_in_proxy" {
  security_group_id = aws_security_group.server.id
  type              = "ingress"
  from_port         = 10051
  to_port           = 10051
  protocol          = "tcp"
  cidr_blocks       = ["${aws_eip.proxy.public_ip}/32"]
}
# out all
resource "aws_security_group_rule" "server_allow_out_all" {
  security_group_id = aws_security_group.server.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}


#  Database --------------------
# sercurity group
resource "aws_security_group" "db" {
  name        = "myk-zabbix-db-sg"
  description = "Allow only 3306"
  vpc_id      = aws_vpc.monitor.id
}

# in sql
resource "aws_security_group_rule" "db_allow_in_sql" {
  depends_on               = [aws_security_group.server]
  security_group_id        = aws_security_group.db.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.server.id
}
# out all
resource "aws_security_group_rule" "db_allow_out_all" {
  security_group_id = aws_security_group.db.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}



# ------------------------------
#  Zabbix Target side
# ------------------------------

#  Proxy -----------------------
# security group
resource "aws_security_group" "proxy" {
  name        = "myk-zabbix-proxy-sg"
  description = "Allow ssh http zabbix-server zabbix-agent"
  vpc_id      = aws_vpc.target.id
}

# in ssh
resource "aws_security_group_rule" "proxy_allow_in_ssh" {
  security_group_id = aws_security_group.proxy.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.my_cidr]
}
# in http
resource "aws_security_group_rule" "proxy_allow_in_http" {
  security_group_id = aws_security_group.proxy.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [local.my_cidr]
}
# in server
resource "aws_security_group_rule" "proxy_allow_in_server" {
  security_group_id        = aws_security_group.proxy.id
  type                     = "ingress"
  from_port                = 10050
  to_port                  = 10050
  protocol                 = "tcp"
  cidr_blocks              = ["${aws_eip.server.public_ip}/32"]
}
# in agent
resource "aws_security_group_rule" "proxy_allow_in_agent" {
  security_group_id        = aws_security_group.proxy.id
  type                     = "ingress"
  from_port                = 10051
  to_port                  = 10051
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.agent.id
}
# out all
resource "aws_security_group_rule" "proxy_allow_out_all" {
  security_group_id = aws_security_group.proxy.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}


#  Agent -----------------------
# security group
resource "aws_security_group" "agent" {
  name        = "myk-zabbix-agent-sg"
  description = "Allow ssh http zabbix-proxy"
  vpc_id      = aws_vpc.target.id
}

# in ssh
resource "aws_security_group_rule" "agent_allow_in_ssh" {
  security_group_id = aws_security_group.agent.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [local.my_cidr]
}
# in http
resource "aws_security_group_rule" "agent_allow_in_http" {
  security_group_id = aws_security_group.agent.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [local.my_cidr]
}
# in proxy
resource "aws_security_group_rule" "agent_allow_in_proxy" {
  security_group_id        = aws_security_group.agent.id
  type                     = "ingress"
  from_port                = 10050
  to_port                  = 10050
  protocol                 = "tcp"
  cidr_blocks              = [local.proxy_ec2_cidr]
}
# out all
resource "aws_security_group_rule" "agent_allow_out_all" {
  security_group_id = aws_security_group.agent.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
