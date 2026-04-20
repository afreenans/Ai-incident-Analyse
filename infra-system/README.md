# 🏗️ Automated Infrastructure Workflow System
### Extending: Autonomous CI/CD Pipeline Optimizer

---

## What This Adds

Your existing repo was a **smart FastAPI backend** that scores CI/CD pipeline risk.
This layer wraps it in **full cloud infrastructure** — Terraform, GitHub Actions CI/CD, and AWS monitoring — so it runs production-grade on AWS with zero manual steps after the first deploy.

```
Your App (FastAPI)
      +
This Infra Layer (Terraform + GitHub Actions + CloudWatch)
      ║
      ▼
Production on AWS — auto-scaling, monitored, secure
```

---

## Quick Start (5 steps)

```bash
# 1. Bootstrap remote state (run once)
chmod +x scripts/bootstrap-state.sh
./scripts/bootstrap-state.sh

# 2. Initialize Terraform
terraform -chdir=terraform init

# 3. Preview what will be created
terraform -chdir=terraform plan -var-file=terraform/dev.tfvars \
  -var="alarm_email=you@example.com"

# 4. Deploy
terraform -chdir=terraform apply -var-file=terraform/dev.tfvars \
  -var="alarm_email=you@example.com"

# 5. Get your app URL
terraform -chdir=terraform output app_url
```

After that, every `git push` to `main` → auto-deploys via GitHub Actions.

---

## What Gets Created

| Resource | Purpose |
|----------|---------|
| VPC + subnets | Isolated network, public + private tiers |
| Application Load Balancer | Public entry point, health checks |
| Auto Scaling Group (EC2 × 1–4) | Your FastAPI app, auto-scales on CPU |
| NAT Gateway | Private EC2 can call external APIs |
| IAM roles (EC2 + GitHub OIDC) | Least-privilege, no static credentials |
| S3 buckets | Terraform state, app artifacts, ALB logs |
| SSM Parameter Store | Non-secret app config |
| Secrets Manager | API keys, webhook secrets |
| CloudWatch logs + alarms | Real-time monitoring |
| SNS → Email alerts | Alarm notifications |

---

## GitHub Actions Secrets Needed

| Secret | Value |
|--------|-------|
| `AWS_DEPLOY_ROLE_ARN` | Output from `terraform output` → IAM role ARN |
| `ARTIFACT_BUCKET` | Your S3 artifact bucket name |
| `ALARM_EMAIL` | Where CloudWatch alerts should go |

---

## Full Documentation

📖 See **[docs/INFRASTRUCTURE_GUIDE.md](docs/INFRASTRUCTURE_GUIDE.md)** for:
- Detailed setup instructions
- Security features explained
- CloudWatch dashboard walkthrough
- Error handling & debugging
- Cost estimate
- Teardown instructions

---

## Files Added by This Layer

```
terraform/                    ← All infrastructure as code
  main.tf                     ← Root config, wires all modules
  variables.tf                ← All tunable parameters
  outputs.tf                  ← What to note after apply
  dev.tfvars                  ← Dev environment values
  modules/
    vpc/                      ← VPC, subnets, NAT, flow logs
    ec2/                      ← ALB, ASG, launch template, SGs
    iam/                      ← EC2 role, GitHub OIDC role
    cloudwatch/               ← Alarms, dashboard, log groups, SNS

.github/workflows/
  cicd.yml                    ← Full 6-stage CI/CD pipeline
  destroy.yml                 ← Manual teardown (dev/staging only)

scripts/
  validate.sh                 ← Pre-push local checks
  bootstrap-state.sh          ← One-time S3 + DynamoDB state setup

docs/
  INFRASTRUCTURE_GUIDE.md     ← Complete setup + operations guide
```
