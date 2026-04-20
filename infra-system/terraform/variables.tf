###############################################################################
# Variables — Autonomous Infrastructure Workflow System
###############################################################################

# ── Core ──────────────────────────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy all resources into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment: dev | staging | prod"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "autonomous-cicd-optimizer"
}

variable "project_owner" {
  description = "Team or person owning this infrastructure (used in tags)"
  type        = string
  default     = "platform-team"
}

# ── Networking ────────────────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to deploy subnets into"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_nat_gateway" {
  description = "Provision a NAT gateway for private subnet outbound traffic"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs to CloudWatch"
  type        = bool
  default     = true
}

# ── Compute ───────────────────────────────────────────────────────────────────
variable "instance_type" {
  description = "EC2 instance type for the application server"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access (leave empty to disable)"
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Port the FastAPI application listens on"
  type        = number
  default     = 8000
}

# ── Auto Scaling ──────────────────────────────────────────────────────────────
variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances at steady state"
  type        = number
  default     = 2
}

# ── Monitoring ────────────────────────────────────────────────────────────────
variable "alarm_email" {
  description = "Email address to send CloudWatch alarm notifications to"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch log groups"
  type        = number
  default     = 30
}
