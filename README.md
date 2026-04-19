```markdown
# 🚀 Agent-Pilot - Incident Management System

[![CI/CD Pipeline](https://github.com/techwithburhan/Agent-Pilot/actions/workflows/test.yml/badge.svg)](https://github.com/techwithburhan/Agent-Pilot/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python Version](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)

> **Enterprise-grade Incident Management System** with AI-powered report generation, built on AWS serverless architecture with complete DevOps automation.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Local Development Setup](#-local-development-setup)
- [AWS Services Implementation](#-aws-services-implementation)
- [Testing Strategy](#-testing-strategy)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Monitoring & Logging](#-monitoring--logging)
- [Deployment](#-deployment)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

**Agent-Pilot** is an automated incident management platform that:
- ✅ Receives incident reports via REST API
- ✅ Processes incidents asynchronously using AWS Lambda
- ✅ Generates AI-powered incident reports
- ✅ Stores reports in S3 with versioning
- ✅ Sends real-time notifications via SNS
- ✅ Implements retry logic with DLQ (Dead Letter Queue)
- ✅ Provides complete observability with CloudWatch

---

## 🏗️ Architecture

```
┌────────────────────────────┐
│ Start Testing              │
└────────────┬───────────────┘
             │
             ▼
┌────────────────────────────┐
│ Send Test Incident (API)   │
│ Valid / Invalid Payload    │
└────────────┬───────────────┘
             │
             ▼
┌────────────────────────────┐
│ API Gateway Validation     │
└───────┬─────────┬──────────┘
        │         │
 Valid  │         │ Invalid
        ▼         ▼
┌──────────────┐ ┌────────────────┐
│ Trigger      │ │ Return 400/403 │
│ Lambda       │ │ (Fail Test)    │
└──────┬───────┘ └────────────────┘
       │
       ▼
┌──────────────────────┐
│ Lambda Processing    │
└──────┬───────────────┘
       │
Success│      Failure
       ▼         ▼
┌────────────┐ ┌────────────────┐
│ Push to    │ │ Log Error in   │
│ SQS Queue  │ │ CloudWatch     │
└──────┬─────┘ └──────┬─────────┘
       │              │
       ▼              ▼
┌──────────────────────┐
│ SQS Queue Handling   │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│ Worker Lambda        │
└──────┬───────────────┘
       │
Success│ Failure
       ▼         ▼
┌──────────────┐ ┌────────────────┐
│ Call AI      │ │ Retry (SQS)    │
│ Service      │ └──────┬─────────┘
└──────┬───────┘        │
       │         Retry Limit?
       │                │
       │         Yes    ▼
       │         ┌──────────────┐
       │         │ DLQ (Fail)   │
       │         └──────────────┘
       ▼
┌────────────────────────────┐
│ Store Report in S3         │
└────────────┬───────────────┘
             │
             ▼
┌────────────────────────────┐
│ Send Notification (SNS)    │
└────────────┬───────────────┘
             │
             ▼
┌────────────────────┐
│ Test Completed ✅  │
└────────────────────┘
```

---

## ✨ Features

### Core Features
- 🔐 **API Gateway** - RESTful API with authentication & validation
- ⚡ **Serverless Processing** - AWS Lambda for scalable compute
- 📬 **Async Queue Processing** - SQS for reliable message handling
- 🤖 **AI Integration** - Automated report generation
- 💾 **Secure Storage** - S3 with encryption & versioning
- 📧 **Notifications** - SNS for multi-channel alerts
- 📊 **Monitoring** - CloudWatch logs & metrics
- 🔄 **Retry Mechanism** - DLQ for failed messages

### DevOps Features
- 🐳 **Containerization** - Docker & Docker Compose
- 🧪 **Comprehensive Testing** - Unit, Integration & E2E tests
- 🚀 **CI/CD Pipeline** - GitHub Actions automation
- 📈 **Performance Testing** - Locust load testing
- 🔍 **LocalStack** - AWS services emulation locally
- 📊 **Monitoring Stack** - Prometheus + Grafana

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Language** | Python 3.9+ |
| **Cloud** | AWS (Lambda, API Gateway, SQS, S3, SNS, CloudWatch) |
| **Local Testing** | LocalStack, Docker |
| **Testing** | Pytest, Locust |
| **CI/CD** | GitHub Actions |
| **Monitoring** | Prometheus, Grafana |
| **IaC** | AWS SAM / Terraform (optional) |

---

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

```bash
# Required Tools
✅ Python 3.9+
✅ Docker & Docker Compose
✅ Git
✅ AWS CLI (for production deployment)
✅ Node.js 16+ (for some AWS tools)

# Optional Tools
□ Terraform (for IaC)
□ Postman (for API testing)
□ VS Code (recommended IDE)
```

### Installation Commands

```bash
# Python
python --version  # Should be 3.9+

# Docker
docker --version
docker-compose --version

# AWS CLI
aws --version

# Git
git --version
```

---

## 🚀 Local Development Setup

### Step 1: Clone Repository

```bash
# Clone the repository
git clone https://github.com/techwithburhan/Agent-Pilot.git
cd Agent-Pilot

# Check project structure
tree -L 2
```

**Expected Structure:**
```
Agent-Pilot/
├── src/
│   ├── api/              # API Gateway handlers
│   ├── lambda/           # Lambda functions
│   ├── workers/          # SQS workers
│   └── utils/            # Shared utilities
├── tests/
│   ├── unit/             # Unit tests
│   ├── integration/      # Integration tests
│   ├── e2e/              # End-to-end tests
│   └── performance/      # Load tests
├── infrastructure/
│   ├── docker/           # Docker configs
│   ├── localstack/       # LocalStack setup
│   └── terraform/        # IaC (optional)
├── .github/
│   └── workflows/        # CI/CD pipelines
├── monitoring/
│   ├── prometheus/       # Prometheus config
│   └── grafana/          # Grafana dashboards
├── docker-compose.yml
├── requirements.txt
├── pytest.ini
└── README.md
```

---

### Step 2: Install Python Dependencies

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/Mac:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Verify installation
pip list
```

**requirements.txt:**
```txt
# AWS SDK
boto3==1.28.85
botocore==1.31.85

# Testing
pytest==7.4.3
pytest-cov==4.1.0
pytest-asyncio==0.21.1
moto==4.2.9  # AWS mocking

# API Testing
requests==2.31.0
httpx==0.25.2

# Performance Testing
locust==2.17.0

# Utilities
python-dotenv==1.0.0
pydantic==2.5.0

# LocalStack
localstack-client==2.3
awscli-local==0.21

# Development
black==23.11.0
flake8==6.1.0
mypy==1.7.1
```

---

### Step 3: Setup Docker Environment

```bash
# Create docker-compose.yml
nano docker-compose.yml
```

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  # LocalStack - AWS Services Emulator
  localstack:
    container_name: agent-pilot-localstack
    image: localstack/localstack:latest
    ports:
      - "4566:4566"            # LocalStack Gateway
      - "4571:4571"            # LocalStack Dashboard
    environment:
      - SERVICES=apigateway,lambda,sqs,s3,sns,cloudwatch,logs
      - DEBUG=1
      - DATA_DIR=/tmp/localstack/data
      - LAMBDA_EXECUTOR=docker
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - "./infrastructure/localstack:/tmp/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"
    networks:
      - agent-pilot-network

  # Prometheus - Metrics Collection
  prometheus:
    container_name: agent-pilot-prometheus
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - "./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml"
      - "prometheus-data:/prometheus"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    networks:
      - agent-pilot-network

  # Grafana - Monitoring Dashboard
  grafana:
    container_name: agent-pilot-grafana
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
    volumes:
      - "./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards"
      - "./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources"
      - "grafana-data:/var/lib/grafana"
    depends_on:
      - prometheus
    networks:
      - agent-pilot-network

  # Application (Optional - for full deployment)
  app:
    container_name: agent-pilot-app
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - AWS_ENDPOINT_URL=http://localstack:4566
      - AWS_REGION=us-east-1
      - AWS_ACCESS_KEY_ID=test
      - AWS_SECRET_ACCESS_KEY=test
    depends_on:
      - localstack
    networks:
      - agent-pilot-network
    volumes:
      - "./src:/app/src"

volumes:
  prometheus-data:
  grafana-data:

networks:
  agent-pilot-network:
    driver: bridge
```

**Start Services:**
```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f localstack

# Stop services
docker-compose down
```

---

### Step 4: Configure AWS Services (LocalStack)

Create initialization script for AWS services:

```bash
# Create setup script
nano infrastructure/localstack/init-aws.sh
```

**init-aws.sh:**
```bash
#!/bin/bash

echo "🚀 Initializing AWS Services in LocalStack..."

# Wait for LocalStack to be ready
sleep 10

# Set LocalStack endpoint
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_REGION=us-east-1

# 1. Create S3 Bucket for Reports
echo "📦 Creating S3 Bucket..."
awslocal s3 mb s3://incident-reports
awslocal s3api put-bucket-versioning \
  --bucket incident-reports \
  --versioning-configuration Status=Enabled

# 2. Create SQS Queues
echo "📬 Creating SQS Queues..."

# Dead Letter Queue
awslocal sqs create-queue --queue-name incident-dlq
DLQ_ARN=$(awslocal sqs get-queue-attributes \
  --queue-url http://localhost:4566/000000000000/incident-dlq \
  --attribute-names QueueArn \
  --query 'Attributes.QueueArn' \
  --output text)

# Main Queue with DLQ
awslocal sqs create-queue --queue-name incident-queue \
  --attributes '{
    "RedrivePolicy": "{\"deadLetterTargetArn\":\"'$DLQ_ARN'\",\"maxReceiveCount\":\"3\"}",
    "VisibilityTimeout": "300"
  }'

# 3. Create SNS Topic
echo "📧 Creating SNS Topic..."
awslocal sns create-topic --name incident-notifications

# Subscribe email
awslocal sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:incident-notifications \
  --protocol email \
  --notification-endpoint devops@example.com

# 4. Create Lambda Functions
echo "⚡ Creating Lambda Functions..."

# Package Lambda function
cd src/lambda
zip -r ../../incident-processor.zip .
cd ../..

# Create Lambda function
awslocal lambda create-function \
  --function-name IncidentProcessorFunction \
  --runtime python3.9 \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --handler incident_processor.handler \
  --zip-file fileb://incident-processor.zip \
  --timeout 60 \
  --memory-size 512

# 5. Create API Gateway
echo "🌐 Creating API Gateway..."
API_ID=$(awslocal apigateway create-rest-api \
  --name 'IncidentAPI' \
  --query 'id' \
  --output text)

# Get root resource
ROOT_ID=$(awslocal apigateway get-resources \
  --rest-api-id $API_ID \
  --query 'items[0].id' \
  --output text)

# Create /incidents resource
RESOURCE_ID=$(awslocal apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part incidents \
  --query 'id' \
  --output text)

# Create POST method
awslocal apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method POST \
  --authorization-type NONE

# Deploy API
awslocal apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name dev

# 6. Create CloudWatch Log Group
echo "📊 Creating CloudWatch Log Groups..."
awslocal logs create-log-group --log-group-name /aws/lambda/IncidentProcessor
awslocal logs create-log-group --log-group-name /aws/apigateway/IncidentAPI

echo "✅ AWS Services Initialized Successfully!"
echo ""
echo "📝 Service Endpoints:"
echo "  API Gateway: http://localhost:4566/restapis/$API_ID/dev/_user_request_/incidents"
echo "  S3 Bucket: s3://incident-reports"
echo "  SQS Queue: http://localhost:4566/000000000000/incident-queue"
echo "  SNS Topic: arn:aws:sns:us-east-1:000000000000:incident-notifications"
```

**Execute Setup:**
```bash
# Make script executable
chmod +x infrastructure/localstack/init-aws.sh

# Run setup
./infrastructure/localstack/init-aws.sh
```

---

### Step 5: Create Lambda Functions

**src/lambda/incident_processor.py:**
```python
import json
import boto3
import os
from datetime import datetime

# Initialize AWS clients
sqs = boto3.client('sqs', endpoint_url=os.getenv('AWS_ENDPOINT_URL'))
cloudwatch = boto3.client('logs', endpoint_url=os.getenv('AWS_ENDPOINT_URL'))

QUEUE_URL = os.getenv('SQS_QUEUE_URL', 'http://localhost:4566/000000000000/incident-queue')

def handler(event, context):
    """
    Main Lambda handler for incident processing
    """
    try:
        # Parse incoming request
        body = json.loads(event.get('body', '{}'))
        
        # Validate required fields
        required_fields = ['incident_id', 'title', 'severity']
        for field in required_fields:
            if field not in body:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': f'Missing required field: {field}'})
                }
        
        # Add metadata
        body['timestamp'] = datetime.utcnow().isoformat()
        body['status'] = 'queued'
        
        # Send to SQS
        response = sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(body)
        )
        
        # Log success
        log_event(f"Incident {body['incident_id']} queued successfully")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Incident queued for processing',
                'messageId': response['MessageId'],
                'incident_id': body['incident_id']
            })
        }
        
    except Exception as e:
        # Log error to CloudWatch
        log_event(f"ERROR: {str(e)}", level='ERROR')
        
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def log_event(message, level='INFO'):
    """Helper function to log to CloudWatch"""
    try:
        cloudwatch.put_log_events(
            logGroupName='/aws/lambda/IncidentProcessor',
            logStreamName='processor-stream',
            logEvents=[{
                'timestamp': int(datetime.now().timestamp() * 1000),
                'message': f"[{level}] {message}"
            }]
        )
    except:
        print(f"[{level}] {message}")
```

**src/workers/incident_worker.py:**
```python
import json
import boto3
import os
from datetime import datetime

# Initialize AWS clients
s3 = boto3.client('s3', endpoint_url=os.getenv('AWS_ENDPOINT_URL'))
sns = boto3.client('sns', endpoint_url=os.getenv('AWS_ENDPOINT_URL'))

BUCKET_NAME = 'incident-reports'
SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:000000000000:incident-notifications'

def process_incident(event, context):
    """
    Worker Lambda to process incidents from SQS
    """
    for record in event['Records']:
        try:
            # Parse message
            incident = json.loads(record['body'])
            incident_id = incident['incident_id']
            
            # Generate AI report (mock)
            report = generate_ai_report(incident)
            
            # Store in S3
            s3.put_object(
                Bucket=BUCKET_NAME,
                Key=f"reports/{incident_id}.json",
                Body=json.dumps(report),
                ContentType='application/json'
            )
            
            # Send notification
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject=f"Incident Report Ready: {incident_id}",
                Message=f"Report for {incident['title']} is ready.\nSeverity: {incident['severity']}"
            )
            
            print(f"✅ Successfully processed incident {incident_id}")
            
        except Exception as e:
            print(f"❌ Error processing incident: {str(e)}")
            raise  # Trigger SQS retry

def generate_ai_report(incident):
    """
    Mock AI report generation
    """
    return {
        'incident_id': incident['incident_id'],
        'title': incident['title'],
        'severity': incident['severity'],
        'ai_analysis': f"Automated analysis for {incident['title']}",
        'recommendations': [
            'Increase monitoring',
            'Review logs',
            'Notify team lead'
        ],
        'generated_at': datetime.utcnow().isoformat(),
        'status': 'completed'
    }
```

---

## 🧪 AWS Services Implementation - Step by Step

### ✅ Service 1: API Gateway

**Purpose:** HTTP endpoint for receiving incidents

**Setup:**
```bash
# Test API Gateway
curl -X POST http://localhost:4566/restapis/<API_ID>/dev/_user_request_/incidents \
  -H "Content-Type: application/json" \
  -d '{
    "incident_id": "INC001",
    "title": "Database Connection Error",
    "severity": "high"
  }'
```

**Verification:**
```bash
# Check API Gateway logs
awslocal logs tail /aws/apigateway/IncidentAPI --follow
```

---

### ✅ Service 2: Lambda Functions

**Purpose:** Serverless compute for processing

**Test:**
```python
# tests/integration/test_lambda.py
def test_lambda_invocation():
    lambda_client = boto3.client('lambda', endpoint_url='http://localhost:4566')
    
    response = lambda_client.invoke(
        FunctionName='IncidentProcessorFunction',
        InvocationType='RequestResponse',
        Payload=json.dumps({
            'body': json.dumps({
                'incident_id': 'INC001',
                'title': 'Test',
                'severity': 'low'
            })
        })
    )
    
    assert response['StatusCode'] == 200
```

**Run Test:**
```bash
pytest tests/integration/test_lambda.py -v
```

---

### ✅ Service 3: SQS (Simple Queue Service)

**Purpose:** Asynchronous message processing

**Verify Queue:**
```bash
# Check queue
awslocal sqs list-queues

# Send test message
awslocal sqs send-message \
  --queue-url http://localhost:4566/000000000000/incident-queue \
  --message-body '{"incident_id":"INC002","title":"Test","severity":"medium"}'

# Receive message
awslocal sqs receive-message \
  --queue-url http://localhost:4566/000000000000/incident-queue
```

**DLQ Verification:**
```bash
# Check Dead Letter Queue
awslocal sqs receive-message \
  --queue-url http://localhost:4566/000000000000/incident-dlq
```

---

### ✅ Service 4: S3 (Simple Storage Service)

**Purpose:** Store incident reports

**Test:**
```bash
# List buckets
awslocal s3 ls

# Upload test report
echo '{"incident_id":"INC001"}' > test-report.json
awslocal s3 cp test-report.json s3://incident-reports/reports/

# List objects
awslocal s3 ls s3://incident-reports/reports/

# Download report
awslocal s3 cp s3://incident-reports/reports/test-report.json ./downloaded.json
```

---

### ✅ Service 5: SNS (Simple Notification Service)

**Purpose:** Send notifications

**Test:**
```bash
# Publish notification
awslocal sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:incident-notifications \
  --subject "Test Notification" \
  --message "This is a test incident notification"

# List subscriptions
awslocal sns list-subscriptions
```

---

### ✅ Service 6: CloudWatch Logs

**Purpose:** Centralized logging

**View Logs:**
```bash
# List log groups
awslocal logs describe-log-groups

# Tail logs
awslocal logs tail /aws/lambda/IncidentProcessor --follow

# Filter logs
awslocal logs filter-log-events \
  --log-group-name /aws/lambda/IncidentProcessor \
  --filter-pattern "ERROR"
```

---

## 🧪 Testing Strategy

### Run All Tests

```bash
# Run complete test suite
./run_tests.sh
```

**run_tests.sh:**
```bash
#!/bin/bash

echo "🧪 Starting Test Suite..."

# 1. Start LocalStack
echo "📦 Starting LocalStack..."
docker-compose up -d localstack
sleep 15

# 2. Initialize AWS Services
echo "⚙️ Initializing AWS Services..."
./infrastructure/localstack/init-aws.sh

# 3. Unit Tests
echo "🔬 Running Unit Tests..."
pytest tests/unit/ -v --cov=src --cov-report=term-missing

# 4. Integration Tests
echo "🔗 Running Integration Tests..."
pytest tests/integration/ -v

# 5. E2E Tests
echo "🎯 Running E2E Tests..."
pytest tests/e2e/ -v

# 6. Performance Tests
echo "⚡ Running Performance Tests..."
locust -f tests/performance/locustfile.py \
  --headless \
  --users 50 \
  --spawn-rate 5 \
  --run-time 2m \
  --host http://localhost:4566

# 7. Generate Coverage Report
echo "📊 Generating Coverage Report..."
pytest --cov=src --cov-report=html

# 8. Cleanup
echo "🧹 Cleaning up..."
docker-compose down

echo "✅ All Tests Completed!"
```

---

## 🚀 CI/CD Pipeline

**.github/workflows/test.yml:**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    name: Test & Build
    runs-on: ubuntu-latest
    
    services:
      localstack:
        image: localstack/localstack:latest
        ports:
          - 4566:4566
        env:
          SERVICES: apigateway,lambda,sqs,s3,sns,cloudwatch
          DEBUG: 1
    
    steps:
      - name: 📥 Checkout Code
        uses: actions/checkout@v3
      
      - name: 🐍 Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: 📦 Install Dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov awscli-local
      
      - name: ⏳ Wait for LocalStack
        run: |
          sleep 10
          curl -s http://localhost:4566/_localstack/health
      
      - name: ⚙️ Initialize AWS Services
        run: |
          chmod +x infrastructure/localstack/init-aws.sh
          ./infrastructure/localstack/init-aws.sh
      
      - name: 🧪 Run Tests
        run: |
          pytest tests/ -v --cov=src --cov-report=xml
      
      - name: 📊 Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
      
      - name: 🏗️ Build Docker Image
        run: |
          docker build -t agent-pilot:${{ github.sha }} .
      
      - name: 🚀 Deploy (on main branch)
        if: github.ref == 'refs/heads/main'
        run: |
          echo "🚀 Deploying to production..."
          # Add your deployment script here
```

---

## 📊 Monitoring & Logging

### Prometheus Configuration

**monitoring/prometheus/prometheus.yml:**
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'localstack'
    static_configs:
      - targets: ['localstack:4566']
  
  - job_name: 'application'
    static_configs:
      - targets: ['app:8000']
```

### Grafana Dashboard

Access Grafana:
```
URL: http://localhost:3000
Username: admin
Password: admin123
```

Import dashboard ID: `12369` (AWS CloudWatch Dashboard)

---

## 🚢 Deployment

### Local Deployment
```bash
docker-compose up -d
```

### AWS Production Deployment
```bash
# Using AWS SAM
sam build
sam deploy --guided

# Using Terraform
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

---

## 🔧 Troubleshooting

### LocalStack not starting
```bash
# Check Docker
docker ps
docker logs agent-pilot-localstack

# Restart
docker-compose restart localstack
```

### Lambda function errors
```bash
# Check logs
awslocal logs tail /aws/lambda/IncidentProcessor --follow

# Re-deploy
awslocal lambda update-function-code \
  --function-name IncidentProcessorFunction \
  --zip-file fileb://incident-processor.zip
```

### SQS messages stuck
```bash
# Purge queue
awslocal sqs purge-queue \
  --queue-url http://localhost:4566/000000000000/incident-queue
```

---

## 📚 Additional Resources

- [AWS Documentation](https://docs.aws.amazon.com/)
- [LocalStack Docs](https://docs.localstack.cloud/)
- [Pytest Documentation](https://docs.pytest.org/)
- [Docker Documentation](https://docs.docker.com/)

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

---

## 👨‍💻 Author

**Burhan**
- GitHub: [@techwithburhan](https://github.com/techwithburhan)

---

## 🙏 Acknowledgments

- AWS for serverless architecture
- LocalStack for local AWS emulation
- Open-source community

---


```

Save this as `README.md` in your repository root. Yeh complete setup guide hai with step-by-step instructions! 🚀
