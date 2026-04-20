###############################################################################
# Outputs — Autonomous Infrastructure Workflow System
###############################################################################

output "vpc_id" {
  description = "ID of the provisioned VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.ec2.alb_dns_name
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ec2.asg_name
}

output "app_url" {
  description = "Full URL to access the application"
  value       = "http://${module.ec2.alb_dns_name}:${var.app_port}"
}

output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch monitoring dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.cloudwatch.dashboard_name}"
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 IAM instance profile"
  value       = module.iam.ec2_instance_profile_arn
}

output "sns_alarm_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = module.cloudwatch.sns_topic_arn
}
