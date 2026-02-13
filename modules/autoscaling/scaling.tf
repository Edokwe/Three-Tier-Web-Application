locals {
  # Parse ALB ARN to get suffix: app/load-balancer-name/load-balancer-id
  # ARN format: arn:aws:elasticloadbalancing:region:account-id:loadbalancer/app/load-balancer-name/load-balancer-id
  alb_arn_parts = split(":", var.alb_arn)
  alb_resource_id = element(local.alb_arn_parts, length(local.alb_arn_parts) - 1)
  
  # Parse Target Group ARN to get suffix: targetgroup/target-group-name/target-group-id
  # ARN format: arn:aws:elasticloadbalancing:region:account-id:targetgroup/target-group-name/target-group-id
  tg_arn_parts = split(":", var.target_group_arn)
  tg_resource_id = element(local.tg_arn_parts, length(local.tg_arn_parts) - 1)
}


resource "aws_autoscaling_policy" "target_tracking_cpu" {
  name                   = "target-tracking-cpu"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_autoscaling_policy" "target_tracking_requests" {
  name                   = "target-tracking-alb-requests"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${local.alb_resource_id}/${local.tg_resource_id}"
    }
    target_value = 1000.0
  }
}
