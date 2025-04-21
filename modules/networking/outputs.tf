output "vpc_name" {
  description = "Name of the VPC"
  value       = aws_vpc.main.tags["Name"]
}

output "subnet_names" {
  description = "Names of all subnets"
  value = [
    aws_subnet.public_web_az1.tags["Name"],
    aws_subnet.private_app_az1.tags["Name"],
    aws_subnet.private_db_az1.tags["Name"],
    aws_subnet.public_web_az2.tags["Name"],
    aws_subnet.private_app_az2.tags["Name"],
    aws_subnet.private_db_az2.tags["Name"]
  ]
}

output "internal_lb_sg_name" {
  description = "Security group name for internal load balancer"
  value       = aws_security_group.internal_lb_sg.tags["Name"]
}

output "external_lb_sg_name" {
  description = "Security group name for external (public) load balancer"
  value       = aws_security_group.public_lb_sg.tags["Name"]
}

output "web_instance_sg_name" {
  description = "Security group name for public web instances"
  value       = aws_security_group.public_web_sg.tags["Name"]
}

output "app_instance_sg_name" {
  description = "Security group name for private app instances"
  value       = aws_security_group.private_app_sg.tags["Name"]
}

output "db_instance_sg_name" {
  description = "Security group name for private DB instances"
  value       = aws_security_group.private_db_sg.tags["Name"]
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}

output "aws_security_group" {
  value = aws_security_group.private_db_sg.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_app_subnet_ids" {
  value = [aws_subnet.private_app_az1.id, aws_subnet.private_app_az2.id]
}

output "public_web_subnet_ids" {
  value = [aws_subnet.public_web_az1.id, aws_subnet.public_web_az2.id]
}

output "private_app_sg_id" {
  value = aws_security_group.private_app_sg.id
}

output "public_web_sg_id" {
  value = aws_security_group.public_web_sg.id
}

output "internal_lb_sg_id" {
  value = aws_security_group.internal_lb_sg.id
}

output "public_lb_sg_id" {
  value = aws_security_group.public_lb_sg.id
}
