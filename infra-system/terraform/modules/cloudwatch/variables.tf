variable "environment"        { type = string }
variable "app_name"           { type = string }
variable "aws_region"         { type = string }
variable "asg_name"           { type = string }
variable "alb_arn_suffix"     { type = string }
variable "alarm_email"        { type = string }
variable "log_retention_days" { type = number; default = 30 }

output "sns_topic_arn"   { value = aws_sns_topic.alarms.arn }
output "dashboard_name"  { value = aws_cloudwatch_dashboard.main.dashboard_name }
output "app_log_group"   { value = aws_cloudwatch_log_group.app.name }
