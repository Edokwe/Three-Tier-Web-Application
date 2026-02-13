resource "aws_cloudwatch_metric_alarm" "high_blocked_requests" {
  count               = var.enabled ? 1 : 0
  alarm_name          = "${var.environment}-waf-high-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = "60"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors blocked requests by WAF"
  treat_missing_data  = "notBreaching"

  dimensions = {
    WebACL = aws_wafv2_web_acl.main[0].name
    Region = "us-east-1"
    Rule   = "ALL"
  }
}

resource "aws_cloudwatch_dashboard" "waf_dashboard" {
  count          = var.enabled ? 1 : 0
  dashboard_name = "${var.environment}-waf-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/WAFV2", "AllowedRequests", "WebACL", aws_wafv2_web_acl.main[0].name, "Region", "us-east-1", "Rule", "ALL"],
            [".", "BlockedRequests", ".", ".", ".", ".", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Allowed vs Blocked Requests"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/WAFV2", "BlockedRequests", "WebACL", aws_wafv2_web_acl.main[0].name, "Region", "us-east-1", "Rule", "AWS-AWSManagedRulesCommonRuleSet"],
            [".", ".", ".", ".", ".", ".", ".", "RateLimit"],
            [".", ".", ".", ".", ".", ".", ".", "AWS-AWSManagedRulesAmazonIpReputationList"],
            [".", ".", ".", ".", ".", ".", ".", "AWS-AWSManagedRulesKnownBadInputsRuleSet"],
            [".", ".", ".", ".", ".", ".", ".", "BlockBadUserAgents"]
          ]
          view    = "timeSeries"
          stacked = true
          region  = "us-east-1"
          title   = "Blocked Requests by Rule"
        }
      }
    ]
  })
}
