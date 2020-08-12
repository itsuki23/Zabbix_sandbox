# ------------------------------
#  Var
# ------------------------------

# prefix = myk-zabbix
# RDS az = ap-northeast-1a


# ------------------------------
#  RDS
# ------------------------------

resource "aws_db_instance" "rds" {
  identifier           = "myk-zabbix-rds"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.25"
  instance_class       = "db.t2.micro"
  name                 = "myk_zabbix"
  username             = "myk"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  # auto_minor_version_upgrade = true
  availability_zone = "ap-northeast-1a"
  # backup_retention_period    = 7
  # backup_window              = "17:21-17:51"
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name
  # deletion_protection   = false
  skip_final_snapshot   = true
  copy_tags_to_snapshot = true
}

#  DB_SubnetGroup
resource "aws_db_subnet_group" "db" {
  name        = "myk_zabbix_db_subnet_group"
  description = "subnet_group_for_db"
  subnet_ids = [
    "${aws_subnet.db_1a.id}",
    "${aws_subnet.db_1c.id}"
  ]
}