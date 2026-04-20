variable "environment"          { type = string }
variable "app_name"             { type = string }
variable "vpc_id"               { type = string }
variable "public_subnet_ids"    { type = list(string) }
variable "private_subnet_ids"   { type = list(string) }
variable "instance_type"        { type = string; default = "t3.small" }
variable "min_size"             { type = number; default = 1 }
variable "max_size"             { type = number; default = 4 }
variable "desired_capacity"     { type = number; default = 2 }
variable "ami_id"               { type = string }
variable "key_name"             { type = string; default = "" }
variable "iam_instance_profile" { type = string }
variable "app_port"             { type = number; default = 8000 }
variable "aws_region"           { type = string; default = "us-east-1" }

output "alb_dns_name"   { value = aws_lb.main.dns_name }
output "alb_arn_suffix" { value = aws_lb.main.arn_suffix }
output "asg_name"       { value = aws_autoscaling_group.app.name }
output "tg_arn"         { value = aws_lb_target_group.app.arn }
