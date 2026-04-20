#!/usr/bin/env bash
###############################################################################
# scripts/bootstrap-state.sh
# Run ONCE to create the S3 + DynamoDB remote state backend
# Usage: AWS_PROFILE=your-profile ./scripts/bootstrap-state.sh
###############################################################################
set -euo pipefail

BUCKET="your-tfstate-bucket"     # Change me
TABLE="terraform-lock"
REGION="us-east-1"

echo "Creating Terraform remote state backend..."

# S3 bucket with versioning + encryption
aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" 2>/dev/null || true

aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration '{
    "Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]
  }'

aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "✔ S3 bucket ready: $BUCKET"

# DynamoDB for state locking
aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" 2>/dev/null || true

echo "✔ DynamoDB lock table ready: $TABLE"
echo ""
echo "Backend is ready. Now run: terraform -chdir=terraform init"
