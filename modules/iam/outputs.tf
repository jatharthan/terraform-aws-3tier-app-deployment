output "iam_role_name" {
  description = "IAM roles created"
  value       = aws_iam_role.ec2_ssm_s3_role.name
}

output "aws_iam_instance_profile"{
  description = "IAM instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}
