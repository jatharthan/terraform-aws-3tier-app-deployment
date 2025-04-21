variable "project_prefix" {
  description = "Project prefix to be used in naming the bucket"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private subnets for app tier"
  type        = list(string)
}

variable "public_web_subnet_ids" {
  description = "Public subnets for web tier"
  type        = list(string)
}

variable "private_app_sg_id" {
  description = "Security group ID for app tier"
  type        = string
}

variable "public_web_sg_id" {
  description = "Security group ID for web tier"
  type        = string
}

variable "internal_lb_sg_id" {
  description = "Security group for internal load balancer"
  type        = string
}

variable "public_lb_sg_id" {
  description = "Security group for public load balancer"
  type        = string
}

variable "aws_iam_instance_profile" {
  description = "instance profile"
  type        = string
}
