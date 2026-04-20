###############################################################################
# Module: CloudWatch — Alarms, Dashboard, Log Groups, SNS
###############################################################################

# ── SNS Topic for Alerts ──────────────────────────────────────────────────────
resource "aws_sns_topic" "alarms" {
  name              = "${var.environment}-${var.app_name}-alarms"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ── Log Groups ────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "app" {
  name              = "/app/${var.environment}/${var.app_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "system" {
  name              = "/system/${var.environment}/${var.app_name}"
  retention_in_days = var.log_retention_days
}

# ── Metric Filters (extract ERROR count from logs) ────────────────────────────
resource "aws_cloudwatch_log_metric_filter" "app_errors" {
  name           = "${var.environment}-app-error-count"
  pattern        = "[timestamp, level=ERROR, ...]"
  log_group_name = aws_cloudwatch_log_group.app.name

  metric_transformation {
    name          = "AppErrorCount"
    namespace     = "CICDOptimizer/${var.environment}"
    value         = "1"
    default_value = "0"
    unit          = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "webhook_failures" {
  name           = "${var.environment}-webhook-failures"
  pattern        = "[timestamp, level, message=\"*webhook*failed*\", ...]"
  log_group_name = aws_cloudwatch_log_group.app.name

  metric_transformation {
    name          = "WebhookFailureCount"
    namespace     = "CICDOptimizer/${var.environment}"
    value         = "1"
    default_value = "0"
    unit          = "Count"
  }
}

# ── CloudWatch Alarms ─────────────────────────────────────────────────────────

# ALB: 5xx error rate > 5%
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.environment}-alb-5xx-high"
  alarm_description   = "ALB 5xx error rate exceeded 5% — investigate app health"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  dimensions          = { LoadBalancer = var.alb_arn_suffix }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 2
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
}

# ALB: unhealthy host count > 0
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.environment}-unhealthy-hosts"
  alarm_description   = "One or more ALB target hosts are unhealthy"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  dimensions          = { LoadBalancer = var.alb_arn_suffix }
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "breaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
}

# ASG: CPU > 80%
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-asg-cpu-high"
  alarm_description   = "ASG average CPU exceeded 80%"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions          = { AutoScalingGroupName = var.asg_name }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
}

# App errors > 10 in 5 minutes
resource "aws_cloudwatch_metric_alarm" "app_errors" {
  alarm_name          = "${var.environment}-app-errors-high"
  alarm_description   = "Application error rate is abnormally high"
  namespace           = "CICDOptimizer/${var.environment}"
  metric_name         = "AppErrorCount"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
}

# ── CloudWatch Dashboard ──────────────────────────────────────────────────────
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-${var.app_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "text"
        x = 0; y = 0; width = 24; height = 1
        properties = {
          markdown = "## Autonomous CI/CD Pipeline Optimizer — ${upper(var.environment)} Dashboard"
        }
      },
      {
        type = "metric"
        x = 0; y = 1; width = 8; height = 6
        properties = {
          title  = "ALB Request Count"
          period = 300
          stat   = "Sum"
          metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]]
        }
      },
      {
        type = "metric"
        x = 8; y = 1; width = 8; height = 6
        properties = {
          title  = "ALB 5xx Errors"
          period = 300
          stat   = "Sum"
          metrics = [["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix]]
        }
      },
      {
        type = "metric"
        x = 16; y = 1; width = 8; height = 6
        properties = {
          title  = "ASG CPU Utilization"
          period = 60
          stat   = "Average"
          metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]]
        }
      },
      {
        type = "metric"
        x = 0; y = 7; width = 12; height = 6
        properties = {
          title  = "App Error Count (custom)"
          period = 300
          stat   = "Sum"
          metrics = [["CICDOptimizer/${var.environment}", "AppErrorCount"]]
        }
      },
      {
        type = "metric"
        x = 12; y = 7; width = 12; height = 6
        properties = {
          title  = "Webhook Failures"
          period = 300
          stat   = "Sum"
          metrics = [["CICDOptimizer/${var.environment}", "WebhookFailureCount"]]
        }
      },
      {
        type = "log"
        x = 0; y = 13; width = 24; height = 6
        properties = {
          title   = "Recent App Errors (last 1h)"
          region  = var.aws_region
          query   = "SOURCE '/app/${var.environment}/${var.app_name}' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 50"
          view    = "table"
        }
      }
    ]
  })
}
