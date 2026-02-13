output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.arn
}

output "launch_template_id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.web_lt.id
}

output "launch_template_latest_version" {
  description = "The latest version of the Launch Template"
  value       = aws_launch_template.web_lt.latest_version
}

output "web_security_group_id" {
  description = "The ID of the security group for the web tier instances"
  value       = aws_security_group.web_sg.id
}

output "web_instance_role_arn" {
  description = "The ARN of the IAM role for the web tier instances"
  value       = aws_iam_role.web_role.arn
}
