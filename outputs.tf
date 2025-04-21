output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "iam_role_name" {
  description = "name of the IAM role"
  value       = module.iam.iam_role_name
}

#networking output

output "vpc_name" {
  description = "Name of the VPC"
  value       = module.networking.vpc_name
}

output "subnet_names" {
  description = "Names of all subnets"
  value       = module.networking.subnet_names
}

output "internal_lb_sg_name" {
  description = "Security group name for internal load balancer"
  value       = module.networking.internal_lb_sg_name
}

output "external_lb_sg_name" {
  description = "Security group name for external (public) load balancer"
  value       = module.networking.external_lb_sg_name
}

output "web_instance_sg_name" {
  description = "Security group name for public web instances"
  value       = module.networking.web_instance_sg_name
}

output "app_instance_sg_name" {
  description = "Security group name for private app instances"
  value       = module.networking.app_instance_sg_name
}

output "db_instance_sg_name" {
  description = "Security group name for private DB instances"
  value       = module.networking.db_instance_sg_name
}
