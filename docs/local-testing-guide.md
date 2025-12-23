# Local Testing Guide

## Prerequisites Check

✅ Environment variables configured
✅ Supabase connection set up
✅ Upstash Redis configured

## Step 1: Install Bun

The project uses Bun as the package manager. Install it:

```bash
# macOS/Linux
curl -fsSL https://bun.sh/install | bash

# Or using Homebrew
brew install bun
```

Verify installation:
```bash
bun --version
```

## Step 2: Install Dependencies

```bash
cd /Users/Dan/code/danpring/midday_elevate
bun install
```

This will install all dependencies for the monorepo.

## Step 3: Run Database Migrations

Before starting the app, we need to run database migrations:

```bash
cd packages/db
bun run drizzle-kit push
```

Or if using migrations:
```bash
bun run drizzle-kit migrate
```

## Step 4: Start Development Servers

You have a few options:

### Option A: Start Everything (Recommended for first test)
```bash
# From root directory
bun dev
```

This starts:
- Dashboard on http://localhost:3001
- API on http://localhost:3003
- Other services as needed

### Option B: Start Individual Services

```bash
# Dashboard only
bun dev:dashboard

# API only  
bun dev:api

# Both separately (in different terminals)
bun dev:dashboard  # Terminal 1
bun dev:api        # Terminal 2
```

## Step 5: Test the Setup

1. **Check Dashboard**: Open http://localhost:3001
2. **Check API Health**: Open http://localhost:3003/health
3. **Check Redis Connection**: The app should connect to Upstash automatically
4. **Check Database**: Try logging in or creating an account

## Troubleshooting

### If Bun is not found:
- Install Bun (see Step 1)
- Restart your terminal

### If dependencies fail to install:
```bash
# Clean and reinstall
bun clean
bun install
```

### If Redis connection fails:
- Verify `REDIS_URL` in `.env` is correct
- Check Upstash dashboard to ensure database is active
- Test connection: The app will show errors if Redis is unreachable

### If database connection fails:
- Verify database password in connection strings
- Check Supabase dashboard to ensure database is running
- Verify connection strings use correct format

### If ports are already in use:
```bash
# Check what's using the ports
lsof -i :3001
lsof -i :3003

# Kill processes if needed
kill -9 [PID]
```

## Expected Behavior

When everything is working:
- ✅ Dashboard loads at http://localhost:3001
- ✅ API responds at http://localhost:3003/health
- ✅ No Redis connection errors in console
- ✅ No database connection errors in console
- ✅ You can access the login/signup page

## Next Steps After Local Test

Once local testing works:
1. Deploy to Vercel (Dashboard)
2. Deploy API separately (or keep on Vercel)
3. Deploy Worker to Fly.io/Railway
4. Update environment variables in production

