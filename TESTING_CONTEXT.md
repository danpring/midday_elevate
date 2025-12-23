# Testing Context for Midday Application

## Overview
This document provides context for testing the Midday application setup. Another agent will run the test script to verify the local environment is properly configured.

## What is Being Tested

### Application Architecture
Midday is a business management application (invoicing, time tracking, financial management) built as a monorepo with:
- **Dashboard** (Next.js) - Frontend application on port 3001
- **API** (Bun/Hono/tRPC) - Backend API server on port 3003
- **Worker** (BullMQ) - Background job processor on port 8080
- **Engine** (Cloudflare Worker) - Banking integrations on port 3002

### Key Dependencies
1. **Supabase** - Database, authentication, and storage
   - PostgreSQL database
   - Auth service
   - Storage buckets

2. **Upstash Redis** - Caching and job queues
   - Used for API response caching
   - Powers BullMQ job queue system
   - Required for background job processing

3. **Bun** - JavaScript runtime and package manager
   - Used instead of Node.js/npm
   - Faster package installation and execution

## Test Script Purpose

The `test-setup.sh` script verifies:

### 1. Prerequisites
- ✅ Bun is installed and accessible
- ✅ Dependencies are installed (node_modules exists)

### 2. Environment Variables
- ✅ Supabase configuration (URL, keys)
- ✅ Redis configuration (connection strings)
- ✅ Database connection strings (all three: primary, pooler, session)
- ✅ Encryption keys (properly generated)
- ✅ Application URLs configured

### 3. Connection Tests
- ✅ Database connectivity (if psql available)
- ✅ Redis connectivity (if redis-cli available)

## Expected Test Results

### Success Criteria
- All environment variables are set (not using placeholders)
- Connection strings are properly formatted
- Encryption keys are generated (64-char hex for encryption key)
- Database connection strings don't contain `[YOUR-PASSWORD]` placeholder
- Redis URLs use proper format (`rediss://` or `redis://`)

### What "Pass" Means
- ✅ Configuration is complete
- ✅ Ready to run database migrations
- ✅ Ready to start development servers
- ✅ No critical missing configuration

### What "Fail" Means
- ❌ Missing required configuration
- ❌ Using placeholder values
- ❌ Invalid connection string formats
- ❌ Cannot connect to external services

## Important Notes for Testing Agent

### 1. Environment File Location
- The `.env` file is in the project root: `/Users/Dan/code/danpring/midday_elevate/.env`
- The script automatically loads it

### 2. What to Expect
- **If all tests pass**: The setup is complete and ready for development
- **If tests fail**: The script will indicate which specific configuration is missing or incorrect

### 3. Connection Tests
- Database and Redis connection tests are **optional** (marked with ⚠ if tools not available)
- These tests require `psql` and `redis-cli` to be installed
- If these tools aren't available, the tests are skipped but this is OK
- The application itself will test connections when it starts

### 4. Next Steps After Testing
If tests pass, the recommended next steps are:
1. Run database migrations: `cd packages/db && bun run drizzle-kit push`
2. Start development: `bun dev` or `bun dev:dashboard` + `bun dev:api`

## Configuration Details

### Supabase
- **Project**: Midday (in Elevate workspace)
- **Project ID**: xfbuhbakrtxrrebybkdi
- **Region**: ap-south-1
- **Database**: PostgreSQL 17.6

### Redis (Upstash)
- **Type**: Regional Redis database
- **Endpoint**: loved-hookworm-47026.upstash.io
- **Protocol**: TLS (rediss://)
- **Port**: 6379

### Encryption Keys
All encryption keys have been auto-generated:
- `MIDDAY_ENCRYPTION_KEY`: 64-character hex string
- `FILE_KEY_SECRET`: Base64 string
- `API_ROUTE_SECRET`: Base64 string
- `INVOICE_JWT_SECRET`: Base64 string
- `ENGINE_API_KEY`: Base64 string
- `API_SECRET_KEY`: Base64 string

## Running the Test

```bash
cd /Users/Dan/code/danpring/midday_elevate
./test-setup.sh
```

The script will:
1. Check prerequisites
2. Verify environment variables
3. Test connections (if tools available)
4. Provide a summary with next steps

## Troubleshooting

### If Bun is not found:
- Bun was installed to `~/.bun/bin/bun`
- May need to restart terminal or run: `export PATH="$HOME/.bun/bin:$PATH"`

### If dependencies are missing:
- Run: `bun install` from project root
- This installs all monorepo dependencies

### If connection tests fail:
- Check network connectivity
- Verify credentials in `.env` file
- Ensure Supabase database is active
- Ensure Upstash Redis database is active

## Success Indicators

After running the test script, you should see:
- ✅ All checks marked with green checkmarks
- ✅ "All tests passed!" message
- ✅ Next steps provided
- ✅ Exit code 0

If you see failures, the script will indicate exactly what needs to be fixed.

