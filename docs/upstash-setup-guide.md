# Upstash Redis Setup Guide

## Step 1: Create a Redis Database in Upstash

1. Log into your Upstash account at https://console.upstash.com
2. Click **"Create Database"** or **"Redis"**
3. Fill in the details:
   - **Name**: `midday-redis` (or any name you prefer)
   - **Type**: Choose **"Regional"** (recommended) or **"Global"**
   - **Region**: Choose the region closest to your Vercel deployment
     - For US: `us-east-1`, `us-west-1`
     - For EU: `eu-west-1`, `eu-central-1`
     - For Asia: `ap-northeast-1`, `ap-southeast-1`
   - **Primary Region**: Select your preferred region
4. Click **"Create"**

## Step 2: Get Your Connection String

After creating the database:

1. Click on your newly created Redis database
2. You'll see a page with connection details
3. Look for **"REST API"** section - this shows:
   - **UPSTASH_REDIS_REST_URL**
   - **UPSTASH_REDIS_REST_TOKEN**

4. **BUT** - For this application, you need the **standard Redis connection string**:
   - Look for **"Redis CLI"** or **"Connection String"** section
   - You should see something like:
     ```
     rediss://default:AbCdEf123456@your-endpoint.upstash.io:6379
     ```
   - Or you might see separate fields:
     - **Endpoint**: `your-endpoint.upstash.io:6379`
     - **Password**: `AbCdEf123456`
     - **Port**: `6379`

## Step 3: Format the Connection String

If you have separate fields, format it as:
```
rediss://default:[PASSWORD]@[ENDPOINT]:[PORT]
```

Example:
```
rediss://default:AbCdEf123456@us1-ample-pony-12345.upstash.io:6379
```

**Important Notes:**
- Use `rediss://` (with double 's') for TLS/SSL connection
- `default` is the username (Upstash uses "default" as username)
- Replace `[PASSWORD]` with your actual password
- Replace `[ENDPOINT]` with your endpoint (without port)
- Port is usually `6379`

## Step 4: What Information I Need

Please provide me with:

1. **Redis Connection String** (the full `rediss://` URL)
   - OR the separate components:
     - Endpoint (e.g., `us1-ample-pony-12345.upstash.io`)
     - Password
     - Port (usually 6379)

2. **Region** you selected (for reference)

Once you provide this, I'll update your `.env` file with the correct values!

## Alternative: If You Only See REST API Credentials

If Upstash only shows REST API credentials and not the standard Redis connection string:

1. The REST credentials are:
   - `UPSTASH_REDIS_REST_URL`
   - `UPSTASH_REDIS_REST_TOKEN`

2. However, this application uses the standard Redis protocol, so you'll need to:
   - Look for a "Redis CLI" or "Connection" tab in the Upstash dashboard
   - Or check if there's a "Show Connection String" button
   - The connection string should be available somewhere in the database details

## Quick Check: Where to Find It

In the Upstash dashboard:
- Click on your Redis database
- Look for tabs/sections: "Details", "Connection", "Redis CLI", or "Connect"
- The connection string is usually shown in one of these sections

