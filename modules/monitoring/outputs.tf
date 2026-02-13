output "cloudwatch_log_group_arn" {
  description = "The ARN of the application CloudWatch log group"
  value       = aws_cloudwatch_log_group.application_logs.arn
}

output "dashboard_name" {
  description = "The name of the Application Dashboard"
  value       = aws_cloudwatch_dashboard.app_dashboard.dashboard_name
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}
