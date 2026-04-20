#!/usr/bin/env bash
###############################################################################
# scripts/validate.sh — Local validation before pushing to CI
# Usage: ./scripts/validate.sh
###############################################################################
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

pass() { echo -e "${GREEN}✔ $1${NC}"; }
fail() { echo -e "${RED}✘ $1${NC}"; exit 1; }
info() { echo -e "${YELLOW}→ $1${NC}"; }

echo "============================================================"
echo "  Autonomous CI/CD Optimizer — Pre-push Validation"
echo "============================================================"

# ── Python checks ─────────────────────────────────────────────────────────────
info "Checking Python environment..."
python3 -m pip install -q ruff mypy bandit safety 2>/dev/null
pass "Dev tools installed"

info "Running ruff lint..."
ruff check . --quiet && pass "Lint passed" || fail "Lint failed"

info "Running mypy type check..."
mypy app/ --ignore-missing-imports --no-error-summary --quiet \
  && pass "Type check passed" || fail "Type check failed"

info "Running bandit security scan..."
bandit -r app/ -ll -x tests/ -q \
  && pass "Security scan passed" || fail "Security issues found"

info "Running pytest..."
pytest tests/ --tb=short -q \
  && pass "All tests passed" || fail "Tests failed"

# ── Terraform checks ──────────────────────────────────────────────────────────
if command -v terraform &> /dev/null; then
  info "Checking Terraform formatting..."
  terraform -chdir=terraform fmt -check -recursive \
    && pass "Terraform fmt OK" || { fail "Run: terraform -chdir=terraform fmt -recursive"; }

  info "Validating Terraform config..."
  terraform -chdir=terraform init -backend=false -input=false -quiet
  terraform -chdir=terraform validate \
    && pass "Terraform validate OK" || fail "Terraform validation failed"
else
  echo -e "${YELLOW}  Terraform not installed — skipping TF checks${NC}"
fi

echo ""
echo -e "${GREEN}============================================================"
echo "  All checks passed — safe to push!"
echo -e "============================================================${NC}"
