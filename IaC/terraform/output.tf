output "server_eip" {
  value = aws_eip.server.public_ip
}
output "proxy_eip" {
  value = aws_eip.proxy.public_ip
}
output "agent_eip" {
  value = aws_eip.agent.public_ip
}


output "rds_end_point" {
  value = aws_db_instance.rds.endpoint
}
output "rds_database_name" {
  value = aws_db_instance.rds.name
}
output "rds_database_user" {
  value = aws_db_instance.rds.username
}
output "rds_database_password" {
  value = aws_db_instance.rds.password
}

# Unnecessary
# output "server_ec2_public_ip" {
#   value = aws_instance.server.public_ip
# }
# output "proxy_ec2_public_ip" {
#   value = aws_instance.proxy.public_ip
# }
# output "agent_ec2_public_ip" {
#   value = aws_instance.agent.public_ip
# }