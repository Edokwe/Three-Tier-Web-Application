output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = var.enabled ? aws_wafv2_web_acl.main[0].id : ""
}

output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = var.enabled ? aws_wafv2_web_acl.main[0].arn : ""
}

output "log_group_name" {
  description = "The name of the CloudWatch Log Group for WAF logging"
  value       = var.enabled ? aws_cloudwatch_log_group.waf_logs[0].name : ""
}
