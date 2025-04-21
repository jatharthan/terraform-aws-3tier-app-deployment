variable "project_prefix" {
  description = "Project prefix to be used in naming the bucket"
  type        = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "aws_security_group" {
  type = string
}