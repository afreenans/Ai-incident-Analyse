###############################################################################
# Autonomous Infrastructure Workflow System
# Root Terraform Configuration
###############################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state — replace bucket/key/region for your environment
  backend "s3" {
    bucket         = "your-tfstate-bucket"
    key            = "autonomous-cicd/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Autonomous-CICD-Optimizer"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.project_owner
    }
  }
}

###############################################################################
# VPC Module
###############################################################################
module "vpc" {
  source = "./modules/vpc"

  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway  = var.enable_nat_gateway
  enable_flow_logs    = var.enable_flow_logs
}

###############################################################################
# IAM Module
###############################################################################
module "iam" {
  source = "./modules/iam"

  environment    = var.environment
  app_name       = var.app_name
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = var.aws_region
}

###############################################################################
# EC2 / App Server Module
###############################################################################
module "ec2" {
  source = "./modules/ec2"

  environment         = var.environment
  app_name            = var.app_name
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  instance_type       = var.instance_type
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  ami_id              = data.aws_ami.amazon_linux.id
  key_name            = var.key_name
  iam_instance_profile = module.iam.ec2_instance_profile_name
  app_port            = var.app_port
}

###############################################################################
# CloudWatch Monitoring Module
###############################################################################
module "cloudwatch" {
  source = "./modules/cloudwatch"

  environment         = var.environment
  app_name            = var.app_name
  aws_region          = var.aws_region
  asg_name            = module.ec2.asg_name
  alb_arn_suffix      = module.ec2.alb_arn_suffix
  alarm_email         = var.alarm_email
  log_retention_days  = var.log_retention_days
}

###############################################################################
# Data Sources
###############################################################################
data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
