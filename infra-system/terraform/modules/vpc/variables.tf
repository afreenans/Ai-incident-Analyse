variable "environment"          { type = string }
variable "app_name"             { type = string; default = "autonomous-cicd-optimizer" }
variable "vpc_cidr"             { type = string }
variable "availability_zones"   { type = list(string) }
variable "public_subnet_cidrs"  { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "enable_nat_gateway"   { type = bool; default = true }
variable "enable_flow_logs"     { type = bool; default = true }
