# ── dev.tfvars ────────────────────────────────────────────────────────────────
# Copy this to terraform.tfvars for local dev usage
# NEVER commit real secrets or account IDs

aws_region           = "us-east-1"
environment          = "dev"
app_name             = "autonomous-cicd-optimizer"
project_owner        = "platform-team"
alarm_email          = "your-email@example.com"

vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
enable_nat_gateway   = true
enable_flow_logs     = false   # Disable in dev to save cost

instance_type        = "t3.micro"
asg_min_size         = 1
asg_max_size         = 2
asg_desired_capacity = 1

app_port             = 8000
log_retention_days   = 7
