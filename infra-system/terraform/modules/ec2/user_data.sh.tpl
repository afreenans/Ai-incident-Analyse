#!/bin/bash
# Bootstrap script for Autonomous CI/CD Pipeline Optimizer
# Environment: ${environment}  App: ${app_name}  Port: ${app_port}
set -euo pipefail

LOG_FILE="/var/log/bootstrap.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Starting bootstrap for ${app_name} (${environment})"

# ── System Updates ────────────────────────────────────────────────────────────
dnf update -y
dnf install -y python3.11 python3.11-pip git awscli jq

# ── CloudWatch Agent ──────────────────────────────────────────────────────────
dnf install -y amazon-cloudwatch-agent

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CWCONFIG'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/app/*.log",
            "log_group_name": "/app/${environment}/${app_name}",
            "log_stream_name": "{instance_id}/app",
            "timestamp_format": "%Y-%m-%dT%H:%M:%SZ"
          },
          {
            "file_path": "/var/log/bootstrap.log",
            "log_group_name": "/app/${environment}/${app_name}",
            "log_stream_name": "{instance_id}/bootstrap"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "CICDOptimizer/${environment}",
    "metrics_collected": {
      "cpu": { "measurement": ["cpu_usage_active"], "metrics_collection_interval": 60 },
      "mem": { "measurement": ["mem_used_percent"], "metrics_collection_interval": 60 },
      "disk": { "measurement": ["disk_used_percent"], "resources": ["/"], "metrics_collection_interval": 60 }
    }
  }
}
CWCONFIG

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# ── App User & Directory ──────────────────────────────────────────────────────
useradd -r -s /sbin/nologin appuser || true
mkdir -p /opt/app /var/log/app
chown appuser:appuser /opt/app /var/log/app

# ── Fetch app secrets from Secrets Manager ────────────────────────────────────
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "${environment}/${app_name}/env" \
  --region "${aws_region}" \
  --query SecretString \
  --output text 2>/dev/null || echo "{}")

# Write env file (only accessible by appuser)
echo "$SECRET_JSON" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' \
  > /opt/app/.env
chmod 600 /opt/app/.env
chown appuser:appuser /opt/app/.env

# ── Pull latest app code from S3 artifact (set by CI/CD pipeline) ─────────────
ARTIFACT_BUCKET=$(aws ssm get-parameter \
  --name "/${environment}/${app_name}/artifact-bucket" \
  --region "${aws_region}" --query Parameter.Value --output text 2>/dev/null || echo "")

if [ -n "$ARTIFACT_BUCKET" ]; then
  aws s3 cp "s3://$ARTIFACT_BUCKET/latest/app.tar.gz" /opt/app/app.tar.gz
  tar -xzf /opt/app/app.tar.gz -C /opt/app
  rm /opt/app/app.tar.gz
  cd /opt/app
  python3.11 -m pip install -r requirements.txt --quiet
fi

# ── Systemd Service ───────────────────────────────────────────────────────────
cat > /etc/systemd/system/${app_name}.service << SYSTEMD
[Unit]
Description=Autonomous CI/CD Pipeline Optimizer
After=network.target
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/app
EnvironmentFile=/opt/app/.env
ExecStart=/usr/bin/python3.11 -m uvicorn app.main:app --host 0.0.0.0 --port ${app_port} --workers 2
Restart=on-failure
RestartSec=10
StandardOutput=append:/var/log/app/app.log
StandardError=append:/var/log/app/app-error.log

# Security hardening
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/log/app

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl daemon-reload
systemctl enable ${app_name}
systemctl start ${app_name}

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Bootstrap complete. Service: ${app_name} on :${app_port}"
