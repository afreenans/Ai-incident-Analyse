# 🚀 Agent-Pilot — Incident Management System

[![CI/CD Pipeline](https://github.com/techwithburhan/Agent-Pilot/actions/workflows/test.yml/badge.svg)](https://github.com/techwithburhan/Agent-Pilot/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python Version](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![AWS](https://img.shields.io/badge/AWS-Serverless-orange.svg)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)

> **Enterprise-grade Incident Management System** with AI-powered report generation, built on AWS serverless architecture with complete DevOps automation.

---

## 📋 Table of Contents

1. [Overview](#-overview)
2. [Architecture](#-architecture)
3. [Features](#-features)
4. [Tech Stack](#-tech-stack)
5. [Prerequisites](#-prerequisites)
6. [Local Development Setup](#-local-development-setup)
7. [AWS Services Implementation](#-aws-services-implementation)
8. [Testing Strategy](#-testing-strategy)
9. [CI/CD Pipeline](#-cicd-pipeline)
10. [Monitoring & Logging](#-monitoring--logging)
11. [Deployment](#-deployment)
12. [Troubleshooting](#-troubleshooting)
13. [Contributing](#-contributing)

---

## 🎯 Overview

**Agent-Pilot** is an automated incident management platform that:

- ✅ Receives incident reports via REST API (API Gateway)
- ✅ Processes incidents asynchronously using AWS Lambda
- ✅ Generates AI-powered incident analysis reports
- ✅ Stores reports in S3 with versioning enabled
- ✅ Sends real-time notifications via SNS
- ✅ Implements retry logic with DLQ (Dead Letter Queue)
- ✅ Provides complete observability with CloudWatch

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        CLIENT                           │
│              (REST API / HTTP Request)                  │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│              AWS API GATEWAY                            │
│         (Rate Limiting + Auth + Routing)                │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                 AWS SQS QUEUE                           │
│        (Message Buffer + Retry Logic)                   │
│           └── Dead Letter Queue (DLQ)                   │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│               AWS LAMBDA                                │
│   ┌──────────────────────────────────────────────┐     │
│   │  1. Parse & Validate Incident Payload        │     │
│   │  2. AI Report Generation (Claude/OpenAI)     │     │
│   │  3. Store Report → S3                        │     │
│   │  4. Publish Notification → SNS               │     │
│   └──────────────────────────────────────────────┘     │
└───────────┬────────────────────┬────────────────────────┘
            │                    │
            ▼                    ▼
┌───────────────────┐  ┌─────────────────────────────────┐
│     AWS S3        │  │          AWS SNS                 │
│ (Report Storage   │  │   (Email / SMS Notifications)    │
│  + Versioning)    │  └─────────────────────────────────┘
└───────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────┐
│              AWS CLOUDWATCH                             │
│     (Logs + Metrics + Alerts + Dashboards)              │
└─────────────────────────────────────────────────────────┘
```

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔄 **Async Processing** | SQS-based queue decouples API from Lambda processing |
| 🤖 **AI Report Generation** | Auto-generates structured incident analysis using LLM |
| 🗂️ **Versioned Storage** | S3 with versioning keeps full history of all reports |
| 📣 **Real-time Notifications** | SNS pushes alerts to email/Slack/SMS on incident creation |
| 🔁 **Retry + DLQ** | Failed messages retry 3× then land in Dead Letter Queue |
| 📊 **Full Observability** | CloudWatch dashboards, log groups, and metric alarms |
| 🔐 **IAM Least Privilege** | Every service uses scoped IAM roles, no wildcard permissions |
| 🧪 **Test Coverage** | Unit + Integration tests with CI enforcement |

---

## 🛠️ Tech Stack

### Cloud & Infrastructure
- **AWS Lambda** — Serverless compute
- **AWS API Gateway** — REST API endpoint
- **AWS SQS** — Message queue + DLQ
- **AWS S3** — Object storage with versioning
- **AWS SNS** — Pub/Sub notifications
- **AWS CloudWatch** — Observability & alerting
- **AWS IAM** — Role-based access control

### Application
- **Python 3.9+** — Core Lambda runtime
- **Boto3** — AWS SDK for Python
- **Pydantic** — Request/response validation
- **Anthropic SDK / OpenAI SDK** — AI report generation

### DevOps & Automation
- **Terraform** — Infrastructure as Code
- **GitHub Actions** — CI/CD pipeline
- **Docker** — Local Lambda simulation
- **pytest** — Testing framework

---

## ✅ Prerequisites

Before starting, make sure you have the following installed and configured:

```bash
# Check versions
python --version        # 3.9+
aws --version           # AWS CLI v2
terraform --version     # >= 1.5.0
docker --version        # Any recent version
```

### AWS Account Setup

1. Create an AWS account at [aws.amazon.com](https://aws.amazon.com)
2. Create an IAM user with programmatic access
3. Attach the following managed policies (for dev/test):
   - `AmazonS3FullAccess`
   - `AmazonSQSFullAccess`
   - `AmazonSNSFullAccess`
   - `AWSLambda_FullAccess`
   - `CloudWatchFullAccess`

4. Configure AWS CLI:
```bash
aws configure
# AWS Access Key ID: <your-key>
# AWS Secret Access Key: <your-secret>
# Default region: ap-south-1          # or your preferred region
# Default output format: json
```

---

## 💻 Local Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/techwithburhan/Agent-Pilot.git
cd Agent-Pilot
```

### 2. Create a Virtual Environment

```bash
python -m venv venv

# Activate (Linux/macOS)
source venv/bin/activate

# Activate (Windows)
.\venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
pip install -r requirements-dev.txt   # For testing tools
```

### 4. Set Environment Variables

Create a `.env` file in the project root:

```env
# AWS Config
AWS_REGION=ap-south-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key

# Application Config
SQS_QUEUE_URL=https://sqs.ap-south-1.amazonaws.com/<account-id>/agent-pilot-queue
S3_BUCKET_NAME=agent-pilot-reports
SNS_TOPIC_ARN=arn:aws:sns:ap-south-1:<account-id>:agent-pilot-notifications
DLQ_URL=https://sqs.ap-south-1.amazonaws.com/<account-id>/agent-pilot-dlq

# AI Config
ANTHROPIC_API_KEY=your_anthropic_key   # or OPENAI_API_KEY
```

> ⚠️ **Never commit `.env` to Git.** It is already listed in `.gitignore`.

### 5. Run Locally with Docker

```bash
# Build local Lambda image
docker build -t agent-pilot-local .

# Run the container
docker run -p 9000:8080 \
  --env-file .env \
  agent-pilot-local

# Test the local endpoint
curl -X POST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -H "Content-Type: application/json" \
  -d '{
    "incident_id": "INC-001",
    "severity": "HIGH",
    "title": "Database connection timeout",
    "description": "Primary DB unreachable from app servers since 14:32 IST",
    "reported_by": "monitoring-alert"
  }'
```

---

## ☁️ AWS Services Implementation

### API Gateway

The REST API exposes a single `POST /incident` endpoint that accepts incident payloads and pushes them to SQS.

```
POST /incident
Content-Type: application/json

{
  "incident_id": "INC-2025-001",
  "severity": "HIGH",            # LOW | MEDIUM | HIGH | CRITICAL
  "title": "Service degradation",
  "description": "Detailed description of the incident...",
  "reported_by": "grafana-alert"
}
```

### SQS Queue + DLQ

| Property | Value |
|---|---|
| Queue Type | Standard |
| Visibility Timeout | 300s |
| Max Receive Count | 3 |
| DLQ Retention | 14 days |

```bash
# Manually send a test message to SQS
aws sqs send-message \
  --queue-url $SQS_QUEUE_URL \
  --message-body '{"incident_id":"INC-TEST","severity":"LOW","title":"Test"}'
```

### Lambda Function

- **Runtime:** Python 3.9
- **Memory:** 512 MB
- **Timeout:** 60 seconds
- **Trigger:** SQS event source mapping (batch size: 1)

```bash
# Invoke Lambda directly (for testing)
aws lambda invoke \
  --function-name agent-pilot-processor \
  --payload file://tests/sample_event.json \
  output.json && cat output.json
```

### S3 Bucket

Reports are stored with the following key structure:

```
agent-pilot-reports/
  └── YYYY/
       └── MM/
            └── DD/
                 └── INC-2025-001-report.json
```

```bash
# List all generated reports
aws s3 ls s3://agent-pilot-reports/ --recursive

# Download a specific report
aws s3 cp s3://agent-pilot-reports/2025/06/01/INC-001-report.json ./report.json
```

### SNS Notifications

Subscribe your email to receive alerts:

```bash
aws sns subscribe \
  --topic-arn $SNS_TOPIC_ARN \
  --protocol email \
  --notification-endpoint your@email.com
```

> Check your inbox and confirm the subscription link.

---

## 🧪 Testing Strategy

### Unit Tests

Tests mock all AWS services using `moto` — no real AWS calls are made.

```bash
# Run unit tests
pytest tests/unit/ -v

# With coverage report
pytest tests/unit/ -v --cov=src --cov-report=term-missing
```

### Integration Tests

Integration tests hit real AWS resources. Requires valid `.env` configured.

```bash
pytest tests/integration/ -v
```

### Sample Test Structure

```
tests/
├── unit/
│   ├── test_incident_parser.py
│   ├── test_report_generator.py
│   └── test_s3_storage.py
├── integration/
│   ├── test_sqs_flow.py
│   └── test_end_to_end.py
└── sample_event.json
```

### Sample `sample_event.json`

```json
{
  "Records": [
    {
      "messageId": "test-msg-001",
      "body": "{\"incident_id\":\"INC-001\",\"severity\":\"HIGH\",\"title\":\"DB timeout\",\"description\":\"Primary DB unreachable\",\"reported_by\":\"cloudwatch-alarm\"}"
    }
  ]
}
```

---

## 🔄 CI/CD Pipeline

The pipeline is defined in `.github/workflows/test.yml` and runs on every push and pull request to `main`.

### Pipeline Stages

```
Push to main / PR
      │
      ▼
┌─────────────┐
│   Lint      │  flake8, black --check
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Unit Test  │  pytest tests/unit/ --cov
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Build      │  docker build
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Deploy     │  terraform apply (on merge to main only)
└─────────────┘
```

### GitHub Secrets Required

Go to **Settings → Secrets → Actions** and add:

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret |
| `AWS_REGION` | e.g. `ap-south-1` |
| `ANTHROPIC_API_KEY` | AI provider key |

---

## 📊 Monitoring & Logging

### CloudWatch Log Groups

| Log Group | Description |
|---|---|
| `/aws/lambda/agent-pilot-processor` | Lambda execution logs |
| `/aws/apigateway/agent-pilot-api` | API Gateway access logs |

```bash
# Tail Lambda logs live
aws logs tail /aws/lambda/agent-pilot-processor --follow
```

### CloudWatch Alarms

The following alarms are configured:

| Alarm | Condition | Action |
|---|---|---|
| High Error Rate | Lambda errors > 5 in 5 min | SNS Alert |
| DLQ Message Count | DLQ messages > 0 | SNS Alert |
| Lambda Duration | p95 > 30s | SNS Alert |

### CloudWatch Dashboard

A pre-built dashboard `AgentPilot-Overview` shows:
- Incidents processed per hour
- Lambda error rate
- SQS queue depth
- DLQ message count
- S3 report upload count

---

## 🚀 Deployment

### First-Time Deployment (Terraform)

```bash
cd infra/

# Initialize Terraform
terraform init

# Preview changes
terraform plan -var-file="vars/prod.tfvars"

# Apply infrastructure
terraform apply -var-file="vars/prod.tfvars"
```

### Deploy Lambda Code Only

```bash
# Zip and deploy Lambda function
zip -r lambda.zip src/ requirements.txt

aws lambda update-function-code \
  --function-name agent-pilot-processor \
  --zip-file fileb://lambda.zip
```

### Destroy Infrastructure

```bash
# ⚠️ This will delete ALL resources
terraform destroy -var-file="vars/prod.tfvars"
```

---

## 🔧 Troubleshooting

### Lambda Not Triggering from SQS

```bash
# Check event source mapping is enabled
aws lambda list-event-source-mappings \
  --function-name agent-pilot-processor

# Enable if disabled
aws lambda update-event-source-mapping \
  --uuid <mapping-uuid> \
  --enabled
```

### Messages Stuck in DLQ

```bash
# View DLQ messages
aws sqs receive-message \
  --queue-url $DLQ_URL \
  --max-number-of-messages 10

# Redrive messages back to main queue (after fixing the bug)
# Set DLQ redrive policy via console or update source mapping
```

### S3 Permission Denied

Check Lambda execution role has `s3:PutObject` on the correct bucket ARN:

```json
{
  "Effect": "Allow",
  "Action": ["s3:PutObject", "s3:GetObject"],
  "Resource": "arn:aws:s3:::agent-pilot-reports/*"
}
```

### Environment Variables Missing in Lambda

```bash
aws lambda update-function-configuration \
  --function-name agent-pilot-processor \
  --environment "Variables={S3_BUCKET_NAME=agent-pilot-reports,SNS_TOPIC_ARN=arn:aws:sns:...}"
```

### Local Docker Not Connecting to AWS

Ensure your `.env` is mounted and credentials are valid:

```bash
# Verify credentials work
aws sts get-caller-identity
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make changes and write tests
4. Ensure all tests pass: `pytest tests/unit/ -v`
5. Push and open a Pull Request

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 👤 Author

**Burhan Khan** — Cloud & DevOps Engineer

[![GitHub](https://img.shields.io/badge/GitHub-techwithburhan-black?logo=github)](https://github.com/techwithburhan)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-techwithburhan-blue?logo=linkedin)](https://linkedin.com/in/techwithburhan)
[![Blog](https://img.shields.io/badge/Blog-Hashnode-2962FF?logo=hashnode)](https://techwithburhan.hashnode.dev)

---

> Built with ❤️ by [techwithburhan](https://github.com/techwithburhan) — *"Automate everything, observe everything."*
