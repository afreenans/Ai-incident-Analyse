# ── prod.tfvars ───────────────────────────────────────────────────────────────
# Production environment — higher availability, larger instances
# NEVER commit real secrets. All sensitive values come from GitHub Secrets.

aws_region           = "us-east-1"
environment          = "prod"
app_name             = "autonomous-cicd-optimizer"
project_owner        = "platform-team"
alarm_email          = "alerts@yourteam.com"   # Set via GitHub Secret in CI

vpc_cidr             = "10.1.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
enable_nat_gateway   = true
enable_flow_logs     = true

instance_type        = "t3.medium"
asg_min_size         = 2
asg_max_size         = 6
asg_desired_capacity = 2

app_port             = 8000
log_retention_days   = 90
