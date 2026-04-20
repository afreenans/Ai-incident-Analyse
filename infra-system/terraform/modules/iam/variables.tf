variable "environment"    { type = string }
variable "app_name"       { type = string }
variable "aws_account_id" { type = string }
variable "aws_region"     { type = string }

output "ec2_instance_profile_name" { value = aws_iam_instance_profile.ec2.name }
output "ec2_instance_profile_arn"  { value = aws_iam_instance_profile.ec2.arn }
output "github_actions_role_arn"   { value = aws_iam_role.github_actions.arn }
