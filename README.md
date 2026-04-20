# 🚀 Ai Incident Analyse

---

## 📌 Overview

This system provisions, manages, and monitors a **production-ready AWS infrastructure** for the Autonomous CI/CD Pipeline . It uses Terraform for Infrastructure as Code, GitHub Actions for the CI/CD pipeline, and CloudWatch for observability — all wired together with zero static AWS credentials.

---

## 🏗️ Architecture at a Glance

```
Developer pushes code to GitHub
         │
         ▼
┌──────────────────────────────────────────────┐
│          GitHub Actions Pipeline             │
│  validate → test → build → terraform → deploy → smoke │
└──────────────────────────┬───────────────────┘
                           │ OIDC (no static keys)
                           ▼
         ┌─────────────────────────────────────┐
         │          AWS Cloud (us-east-1)       │
         │                                     │
         │  Internet → ALB (public subnets)    │
         │              │                      │
         │              ▼                      │
         │  Auto Scaling Group (private nets)  │
         │  EC2 × 1–4  ←→  CloudWatch Agent   │
         │              │                      │
         │              ▼                      │
         │  SQLite / S3 Artifact Bucket        │
         │  SSM Parameter Store (config)       │
         │  Secrets Manager (secrets)          │
         │  CloudWatch Logs + Alarms + SNS     │
         └─────────────────────────────────────┘
```

---

## 📁 Repository Layout

```
infra-system/
├── terraform/
│   ├── main.tf                        # Root — wires all modules
│   ├── variables.tf                   # All input variables
│   ├── outputs.tf                     # Key infrastructure outputs
│   ├── dev.tfvars                     # Dev environment values
│   └── modules/
│       ├── vpc/                       # VPC, subnets, NAT, flow logs
│       ├── ec2/                       # ALB, ASG, launch template, SGs
│       ├── iam/                       # EC2 role, GitHub Actions OIDC role
│       └── cloudwatch/                # Log groups, alarms, dashboard, SNS
│
├── .github/workflows/
│   ├── cicd.yml                       # Main 6-stage CI/CD pipeline
│   └── destroy.yml                    # Manual infrastructure teardown
│
├── scripts/
│   ├── validate.sh                    # Pre-push local checks
│   └── bootstrap-state.sh             # One-time S3 + DynamoDB state setup
│
├── tests/                             # (from your app repo)
├── docs/
│   └── INFRASTRUCTURE_GUIDE.md        # This file
└── README.md
```

---

## ✅ Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Terraform | ≥ 1.6 | https://developer.hashicorp.com/terraform/install |
| AWS CLI | ≥ 2.x | https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html |
| Python | 3.11 | https://www.python.org/downloads/ |
| Git | any | https://git-scm.com/ |

---

## 🔐 AWS Setup (One-Time)

### Step 1 — Create the S3 Remote State Backend

```bash
# Edit scripts/bootstrap-state.sh and set your bucket name, then:
chmod +x scripts/bootstrap-state.sh
AWS_PROFILE=your-profile ./scripts/bootstrap-state.sh
```

### Step 2 — Create OIDC Provider for GitHub Actions

Run this once in your AWS account so GitHub Actions can assume roles without static keys:

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### Step 3 — Update `terraform/main.tf`

Replace these placeholders with your real values:

```hcl
backend "s3" {
  bucket         = "your-tfstate-bucket"   # ← your bucket name
  key            = "autonomous-cicd/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-lock"
}
```

### Step 4 — Set GitHub Actions Secrets

Go to your repo → **Settings → Secrets and variables → Actions** and add:

| Secret Name | Value |
|-------------|-------|
| `AWS_DEPLOY_ROLE_ARN` | ARN of the GitHub Actions IAM role created by Terraform |
| `ARTIFACT_BUCKET` | Name of your S3 artifact bucket |
| `ALARM_EMAIL` | Email for CloudWatch alert notifications |

> **Never** add `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` — the pipeline uses OIDC.

---

## 🚀 First-Time Deployment (Manual)

```bash
# 1. Initialize Terraform
terraform -chdir=terraform init

# 2. Plan (review what will be created)
terraform -chdir=terraform plan -var-file=dev.tfvars \
  -var="alarm_email=you@example.com"

# 3. Apply
terraform -chdir=terraform apply -var-file=dev.tfvars \
  -var="alarm_email=you@example.com"

# 4. Get outputs
terraform -chdir=terraform output
```

Expected output:
```
alb_dns_name             = "dev-autonomous-cicd-optimizer-alb-XXXX.us-east-1.elb.amazonaws.com"
app_url                  = "http://dev-autonomous-cicd-optimizer-alb-XXXX.us-east-1.elb.amazonaws.com:8000"
cloudwatch_dashboard_url = "https://us-east-1.console.aws.amazon.com/cloudwatch/home?..."
```

---

## ⚙️ CI/CD Pipeline Stages

Every push to `main` triggers all 6 stages automatically:

```
┌──────────────────────────────────────────────────────────────────────┐
│                     GitHub Actions Pipeline                          │
│                                                                      │
│  [validate]──►[test]──►[build]──►[terraform]──►[deploy]──►[smoke]  │
│                                                                      │
│  validate:  ruff lint, mypy, bandit, safety, terraform fmt          │
│  test:      pytest --cov-fail-under=70                              │
│  build:     tar app, upload to S3 (versioned + latest/)             │
│  terraform: plan on PR, auto-apply on main                          │
│  deploy:    rolling ASG instance refresh (50% min healthy)          │
│  smoke:     /health check + /status/checks must be PASS             │
└──────────────────────────────────────────────────────────────────────┘
```

### Pull Request behaviour
- Runs **validate** and **test** only (no deploy)
- Posts Terraform plan as a PR comment
- Blocks merge if any check fails

### Push to `main` behaviour
- Runs all 6 stages end-to-end
- Deploys to **dev** environment automatically
- Triggers CloudWatch alert if smoke test fails

---

## 🌿 Environment Management

| Environment | Auto-Deploy | Min Instances | Instance Type |
|-------------|------------|---------------|---------------|
| `dev`       | ✅ on push to `main` | 1 | t3.micro |
| `staging`   | 🔒 manual trigger | 2 | t3.small |
| `prod`      | 🔒 manual + approval | 2 | t3.medium |

To deploy to staging or prod manually:

```
GitHub → Actions → "CI/CD Pipeline" → Run workflow → Select environment
```

---

## 📊 Monitoring & Alerting

### CloudWatch Dashboard

Access your live dashboard via the `cloudwatch_dashboard_url` Terraform output. It shows:
- ALB request count and 5xx error rate
- ASG CPU utilization
- Custom app error count (extracted from logs)
- Webhook failure count
- Live log tail for `ERROR` lines

### Alarms (SNS → Email)

| Alarm | Trigger Condition |
|-------|------------------|
| `alb-5xx-high` | More than 10 HTTP 5xx errors in 5 minutes |
| `unhealthy-hosts` | Any ALB target becomes unhealthy |
| `asg-cpu-high` | Average CPU > 80% for 15 minutes |
| `app-errors-high` | More than 10 ERROR log entries in 5 minutes |

### Log Groups

| Log Group | Contents |
|-----------|----------|
| `/app/{env}/autonomous-cicd-optimizer` | Application logs (FastAPI + uvicorn) |
| `/system/{env}/autonomous-cicd-optimizer` | System/bootstrap logs |
| `/aws/vpc/flow-logs/{env}` | VPC network flow logs |

---

## 🔐 Security Features

### No Static AWS Credentials
- GitHub Actions authenticates via **OIDC** — no `AWS_ACCESS_KEY_ID` ever stored
- EC2 instances use **IAM instance profiles** — no credentials on disk

### Least-Privilege IAM
- EC2 role: can only write to its own log group and read its own SSM parameters
- GitHub Actions role: scoped to ASG operations + S3 state bucket only
- No wildcard `*` resource on sensitive actions

### Secrets Management
- App secrets stored in **AWS Secrets Manager** at `{env}/{app-name}/env`
- Non-secret config in **SSM Parameter Store**
- Secrets injected into systemd service as environment variables at boot
- Nothing sensitive in Git, nothing in EC2 user data plain text

### Network Security
- EC2 instances in **private subnets** — no public IPs
- ALB is the only public entry point
- Security group rules: EC2 only accepts traffic from ALB SG
- **IMDSv2** enforced on all EC2 instances (prevents SSRF attacks on metadata)
- EBS volumes encrypted at rest

### Additional Hardening
- `enable_deletion_protection = true` on ALB in prod
- VPC flow logs enabled in staging/prod
- S3 buckets have all public access blocked
- ALB access logs stored in a dedicated, lifecycle-managed S3 bucket
- systemd service runs as unprivileged `appuser` with `NoNewPrivileges=yes`

---

## 📈 Scalability

The infrastructure scales automatically using a **Target Tracking Auto Scaling Policy**:

- **Scale-out**: triggered when average CPU > 60% — adds instances within ~3 minutes
- **Scale-in**: removes instances when CPU drops back — gradual to avoid thrashing
- **Min/Max**: configurable per environment via `asg_min_size` / `asg_max_size`
- **Deployment**: rolling instance refresh ensures zero-downtime deploys

To change capacity limits without redeploying:
```bash
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name dev-autonomous-cicd-optimizer-asg \
  --min-size 2 --max-size 8 --desired-capacity 3
```

---

## 🐛 Error Handling & Debugging

### Deployment Fails — Instance Refresh
```bash
# Check refresh status
aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name dev-autonomous-cicd-optimizer-asg

# Check instance health
aws autoscaling describe-auto-scaling-instances \
  --filters Name=auto-scaling-group-name,Values=dev-autonomous-cicd-optimizer-asg
```

### App Not Responding
```bash
# Check logs via CloudWatch Logs Insights
aws logs filter-log-events \
  --log-group-name /app/dev/autonomous-cicd-optimizer \
  --filter-pattern "ERROR" \
  --start-time $(date -d '1 hour ago' +%s000)

# Connect to instance via SSM (no SSH key needed!)
aws ssm start-session --target <instance-id>
sudo journalctl -u autonomous-cicd-optimizer -f
```

### Terraform State Issues
```bash
# Check who holds the lock
aws dynamodb get-item \
  --table-name terraform-lock \
  --key '{"LockID": {"S": "your-tfstate-bucket/autonomous-cicd/terraform.tfstate"}}'

# Force-unlock if a pipeline was interrupted
terraform -chdir=terraform force-unlock <lock-id>
```

---

## 🧪 Running Tests Locally

```bash
# Full local validation (lint + type check + security + tests + terraform fmt)
chmod +x scripts/validate.sh
./scripts/validate.sh

# Tests only
pytest tests/ -v --cov=app --cov-report=term-missing

# Single test file
pytest tests/test_risk.py -v
```

---

## 🗑️ Teardown

To destroy all infrastructure (dev/staging only — prod is protected):

```
GitHub → Actions → "Destroy Infrastructure" → Run workflow
→ Select environment: dev
→ Type: DESTROY
→ Run workflow
```

Or locally:
```bash
terraform -chdir=terraform destroy \
  -var-file=dev.tfvars \
  -var="alarm_email=you@example.com"
```

---

## 💰 Cost Estimate (dev environment)

| Resource | Monthly Cost |
|----------|-------------|
| EC2 t3.micro × 1 | ~$8.50 |
| ALB | ~$16 |
| NAT Gateway | ~$32 |
| S3 (state + artifacts + logs) | ~$2 |
| CloudWatch logs + metrics | ~$5 |
| **Total (dev)** | **~$63/month** |

> Tip: Destroy dev at end of day with the destroy workflow to save ~80% of compute cost.

---

## 📋 Required GitHub Secrets Summary

```
AWS_DEPLOY_ROLE_ARN     → arn:aws:iam::ACCOUNT_ID:role/dev-app-github-actions-role
ARTIFACT_BUCKET         → your-app-artifacts-bucket-name
ALARM_EMAIL             → alerts@yourteam.com
```

---

*Generated for: Bhardwaj5568 / Autonomous-CI-CD-Pipeline-Optimizer*
*Infrastructure version: 1.0.0*



