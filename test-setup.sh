#!/bin/bash

# ============================================================================
# Midday Application Setup Test Script
# ============================================================================
# 
# PURPOSE:
# This script tests the local setup of the Midday application to ensure
# all components are properly configured before running the development servers.
#
# WHAT IT TESTS:
# 1. Bun installation and version
# 2. Dependencies installation status
# 3. Environment variables configuration (Supabase, Redis, Database)
# 4. Supabase database connectivity
# 5. Upstash Redis connectivity
# 6. Database connection strings format
# 7. Encryption keys presence
#
# EXPECTED RESULTS:
# - All checks should pass (exit code 0)
# - If any check fails, the script will report the issue and exit with code 1
#
# USAGE:
#   chmod +x test-setup.sh
#   ./test-setup.sh
#
# ============================================================================

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0

# Function to print test result
print_test() {
    local status=$1
    local message=$2
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $message"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $message"
        ((FAILED++))
    fi
}

# Function to print section header
print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Start
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  Midday Application Setup Test                      ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${RED}✗${NC} .env file not found"
    exit 1
fi

# ============================================================================
# SECTION 1: Prerequisites Check
# ============================================================================
print_section "1. PREREQUISITES CHECK"

# Check Bun installation
if command -v bun &> /dev/null; then
    BUN_VERSION=$(bun --version)
    print_test "PASS" "Bun installed (version: $BUN_VERSION)"
else
    print_test "FAIL" "Bun not installed - run: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

# Check if dependencies are installed
if [ -d "node_modules" ] && [ -f "bun.lock" ]; then
    print_test "PASS" "Dependencies installed (node_modules exists)"
else
    print_test "FAIL" "Dependencies not installed - run: bun install"
    exit 1
fi

# ============================================================================
# SECTION 2: Environment Variables Check
# ============================================================================
print_section "2. ENVIRONMENT VARIABLES CHECK"

# Supabase Configuration
if [ -n "$NEXT_PUBLIC_SUPABASE_URL" ] && [ "$NEXT_PUBLIC_SUPABASE_URL" != "https://your-project-id.supabase.co" ]; then
    print_test "PASS" "Supabase URL configured: ${NEXT_PUBLIC_SUPABASE_URL:0:40}..."
else
    print_test "FAIL" "Supabase URL not configured or using placeholder"
fi

if [ -n "$NEXT_PUBLIC_SUPABASE_ANON_KEY" ] && [ "$NEXT_PUBLIC_SUPABASE_ANON_KEY" != "your-anon-key-here" ]; then
    print_test "PASS" "Supabase Anon Key configured"
else
    print_test "FAIL" "Supabase Anon Key not configured or using placeholder"
fi

if [ -n "$SUPABASE_SERVICE_KEY" ] && [ "$SUPABASE_SERVICE_KEY" != "your-service-role-key-here" ]; then
    print_test "PASS" "Supabase Service Key configured"
else
    print_test "FAIL" "Supabase Service Key not configured or using placeholder"
fi

# Redis Configuration
if [ -n "$REDIS_URL" ] && [[ "$REDIS_URL" == rediss://* ]] || [[ "$REDIS_URL" == redis://* ]]; then
    print_test "PASS" "Redis URL configured: ${REDIS_URL:0:50}..."
else
    print_test "FAIL" "Redis URL not configured or invalid format"
fi

if [ -n "$REDIS_QUEUE_URL" ] && [[ "$REDIS_QUEUE_URL" == rediss://* ]] || [[ "$REDIS_QUEUE_URL" == redis://* ]]; then
    print_test "PASS" "Redis Queue URL configured"
else
    print_test "FAIL" "Redis Queue URL not configured or invalid format"
fi

# Database Configuration
if [ -n "$DATABASE_PRIMARY_URL" ] && [[ "$DATABASE_PRIMARY_URL" == postgresql://* ]] && [[ "$DATABASE_PRIMARY_URL" != *"[YOUR-PASSWORD]"* ]]; then
    print_test "PASS" "Database Primary URL configured"
else
    print_test "FAIL" "Database Primary URL not configured or contains placeholder"
fi

if [ -n "$DATABASE_PRIMARY_POOLER_URL" ] && [[ "$DATABASE_PRIMARY_POOLER_URL" == postgresql://* ]] && [[ "$DATABASE_PRIMARY_POOLER_URL" != *"[YOUR-PASSWORD]"* ]]; then
    print_test "PASS" "Database Pooler URL configured"
else
    print_test "FAIL" "Database Pooler URL not configured or contains placeholder"
fi

if [ -n "$DATABASE_SESSION_POOLER" ] && [[ "$DATABASE_SESSION_POOLER" == postgresql://* ]] && [[ "$DATABASE_SESSION_POOLER" != *"[YOUR-PASSWORD]"* ]]; then
    print_test "PASS" "Database Session Pooler configured"
else
    print_test "FAIL" "Database Session Pooler not configured or contains placeholder"
fi

# Encryption Keys
if [ -n "$MIDDAY_ENCRYPTION_KEY" ] && [ ${#MIDDAY_ENCRYPTION_KEY} -eq 64 ]; then
    print_test "PASS" "Encryption Key configured (64 hex characters)"
else
    print_test "FAIL" "Encryption Key not configured or invalid length"
fi

if [ -n "$FILE_KEY_SECRET" ]; then
    print_test "PASS" "File Key Secret configured"
else
    print_test "FAIL" "File Key Secret not configured"
fi

if [ -n "$API_ROUTE_SECRET" ]; then
    print_test "PASS" "API Route Secret configured"
else
    print_test "FAIL" "API Route Secret not configured"
fi

# Application URLs
if [ -n "$NEXT_PUBLIC_API_URL" ]; then
    print_test "PASS" "API URL configured: $NEXT_PUBLIC_API_URL"
else
    print_test "FAIL" "API URL not configured"
fi

if [ -n "$ENGINE_API_URL" ]; then
    print_test "PASS" "Engine API URL configured: $ENGINE_API_URL"
else
    print_test "FAIL" "Engine API URL not configured"
fi

# ============================================================================
# SECTION 3: Connection Tests
# ============================================================================
print_section "3. CONNECTION TESTS"

# Test Supabase Database Connection
echo -n "Testing Supabase database connection... "
if command -v psql &> /dev/null; then
    # Try to connect (with timeout to avoid hanging)
    if timeout 5 psql "$DATABASE_SESSION_POOLER" -c "SELECT 1;" > /dev/null 2>&1; then
        print_test "PASS" "Supabase database connection successful"
    else
        print_test "FAIL" "Cannot connect to Supabase database (check connection string and network)"
    fi
else
    echo -e "${YELLOW}⚠${NC} psql not installed - skipping database connection test"
    echo "   (This is OK - the app will test the connection when it starts)"
fi

# Test Redis Connection (if redis-cli is available)
echo -n "Testing Redis connection... "
if command -v redis-cli &> /dev/null; then
    # Extract connection details from REDIS_URL
    if timeout 3 redis-cli -u "$REDIS_URL" ping > /dev/null 2>&1; then
        print_test "PASS" "Redis connection successful"
    else
        print_test "FAIL" "Cannot connect to Redis (check REDIS_URL and network)"
    fi
else
    echo -e "${YELLOW}⚠${NC} redis-cli not installed - skipping Redis connection test"
    echo "   (This is OK - the app will test the connection when it starts)"
fi

# ============================================================================
# SECTION 4: Summary
# ============================================================================
print_section "4. TEST SUMMARY"

TOTAL=$((PASSED + FAILED))
echo ""
echo -e "Total Tests: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED${NC}"
    echo ""
    echo -e "${YELLOW}⚠ Some tests failed. Please fix the issues above before starting the application.${NC}"
    exit 1
else
    echo -e "${GREEN}Failed: 0${NC}"
    echo ""
    echo -e "${GREEN}✓ All tests passed! The setup looks good.${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "  1. Run database migrations: cd packages/db && bun run drizzle-kit push"
    echo "  2. Start development servers:"
    echo "     - Full stack: bun dev"
    echo "     - Dashboard only: bun dev:dashboard"
    echo "     - API only: bun dev:api"
    echo ""
    echo "  3. Access the application:"
    echo "     - Dashboard: http://localhost:3001"
    echo "     - API Health: http://localhost:3003/health"
    echo ""
    exit 0
fi

