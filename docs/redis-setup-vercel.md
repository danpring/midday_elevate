# Redis Setup Guide for Vercel Deployment

## What Redis Does in This Application

Redis serves **two critical functions** in Midday:

### 1. **Caching Layer** (`REDIS_URL`)
Redis acts as a distributed cache to improve performance and reduce database load:

- **API Key Cache** (30 min TTL) - Caches API key lookups
- **User Cache** (30 min TTL) - Caches user data
- **Team Cache** (30 min TTL) - Caches team access permissions
- **Team Permissions Cache** (30 min TTL) - Caches permission lookups
- **Replication Cache** (10 sec TTL) - Tracks recent mutations for read-after-write consistency
- **Chat Cache** - User and team context for AI chat (30 min / 5 min TTL)
- **Widget Preferences** - UI preferences
- **Suggested Actions** - Tracks action usage (7 days TTL)

**Why it matters:** Without Redis caching, every API request would hit the database, causing:
- Slower response times
- Higher database load
- Higher costs
- Potential "No procedure found" TRPC errors

### 2. **Job Queue System** (`REDIS_QUEUE_URL`)
Redis powers BullMQ for background job processing:

**Queues:**
- **Inbox Queue** - Email/invoice processing, document matching (100 concurrent jobs)
- **Documents Queue** - OCR, document classification (100 concurrent jobs)
- **Transactions Queue** - Transaction exports, processing (10 concurrent jobs)
- **Embeddings Queue** - AI embedding generation (20 concurrent jobs)
- **Rates Queue** - Exchange rate updates (1 concurrent job)

**Job Types:**
- Process email attachments
- Match invoices to transactions
- Generate AI embeddings
- Export transaction data
- Process documents (OCR, classification)
- Sync inbox accounts
- Update exchange rates

**Why it matters:** Background jobs handle time-consuming tasks without blocking user requests.

---

## Vercel Deployment Considerations

### ⚠️ **Vercel Limitations:**

1. **Serverless Functions** - Vercel runs your API as serverless functions
   - Each request may hit a cold instance
   - No persistent connections
   - Functions timeout after 60s (Pro) or 10s (Hobby)

2. **No Long-Running Processes** - Can't run the Worker server on Vercel
   - Worker needs to stay connected to Redis
   - Background jobs can't run in serverless functions

3. **Edge Network** - Vercel's edge network is optimized for static content
   - Redis connections from edge functions have higher latency

### ✅ **What Works on Vercel:**
- **Dashboard** (Next.js app) - Perfect for Vercel
- **API** (tRPC endpoints) - Works but needs Redis for caching
- **Caching** - Redis caching works fine from serverless functions

### ❌ **What Doesn't Work on Vercel:**
- **Worker Server** - Must run separately (Fly.io, Railway, Render, etc.)

---

## Recommended Architecture for Vercel

```
┌─────────────────┐
│   Vercel        │
│                 │
│  ┌───────────┐  │
│  │ Dashboard │  │  (Next.js - Perfect for Vercel)
│  └───────────┘  │
│                 │
│  ┌───────────┐  │
│  │   API     │  │  (tRPC Serverless Functions)
│  └───────────┘  │
└────────┬────────┘
         │
         ├─────────────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐  ┌─────────────────┐
│  Upstash Redis  │  │  Worker Server │
│  (Cloud Redis)  │  │  (Fly.io/etc)  │
│                 │  │                 │
│  - Caching      │  │  - Job Queue    │
│  - Job Queue    │  │  - Processing   │
└─────────────────┘  └─────────────────┘
         │
         ▼
┌─────────────────┐
│   Supabase      │
│   (Database)    │
└─────────────────┘
```

---

## Best Redis Solutions for Vercel

### 🏆 **Option 1: Upstash Redis (RECOMMENDED)**

**Why Upstash:**
- ✅ **Serverless-friendly** - Built for serverless architectures
- ✅ **Pay-per-request** - Only pay for what you use
- ✅ **Global edge network** - Low latency from Vercel
- ✅ **Automatic scaling** - No capacity planning needed
- ✅ **Free tier** - 10,000 commands/day free
- ✅ **REST API option** - Can use HTTP instead of TCP (better for serverless)
- ✅ **Durable** - Data persists across cold starts

**Pricing:**
- Free: 10,000 commands/day
- Pay-as-you-go: $0.20 per 100K commands
- Very affordable for personal use

**Setup:**
1. Sign up at https://upstash.com
2. Create a Redis database
3. Choose region closest to your Vercel region
4. Copy connection string
5. Add to `.env`:
   ```bash
   REDIS_URL=rediss://default:[PASSWORD]@[REGION].upstash.io:6379
   REDIS_QUEUE_URL=rediss://default:[PASSWORD]@[REGION].upstash.io:6379
   ```

**For Worker Server:**
- Use same Upstash Redis instance
- Worker can run on Fly.io, Railway, or Render
- Both API and Worker connect to same Redis

---

### 🥈 **Option 2: Redis Cloud (Redis Labs)**

**Why Redis Cloud:**
- ✅ **Managed Redis** - Fully managed service
- ✅ **Free tier** - 30MB free
- ✅ **Good performance** - Standard Redis performance
- ✅ **Multiple regions** - Choose closest to Vercel

**Pricing:**
- Free: 30MB storage
- Paid: Starts at $5/month for 100MB

**Setup:**
1. Sign up at https://redis.com/try-free/
2. Create database
3. Copy connection string
4. Add to `.env`

---

### 🥉 **Option 3: Railway Redis**

**Why Railway:**
- ✅ **Simple setup** - One-click Redis deployment
- ✅ **Integrated** - Can run Worker on same platform
- ✅ **Good for small scale** - Simple pricing

**Pricing:**
- $5/month for Redis + Worker

**Setup:**
1. Create Railway account
2. Deploy Redis template
3. Copy connection string
4. Deploy Worker on same Railway project

---

### ❌ **Not Recommended for Vercel:**

- **Self-hosted Redis** - Requires always-on server (defeats Vercel's serverless model)
- **Docker Redis on VPS** - Same issue, plus maintenance overhead
- **AWS ElastiCache** - Overkill for personal use, complex setup

---

## Recommended Setup for Your Use Case

### **For Personal Use on Vercel:**

1. **Use Upstash Redis** (Free tier is likely enough)
   - One Redis instance for both caching and job queues
   - Set both `REDIS_URL` and `REDIS_QUEUE_URL` to same connection string

2. **Deploy Worker Separately:**
   - **Option A:** Fly.io (recommended by Midday team)
     - Free tier available
     - Good for background workers
   - **Option B:** Railway
     - Simple deployment
     - $5/month
   - **Option C:** Render
     - Free tier available
     - Easy setup

3. **Environment Variables:**
   ```bash
   # Vercel Dashboard → Settings → Environment Variables
   REDIS_URL=rediss://default:[PASSWORD]@[REGION].upstash.io:6379
   REDIS_QUEUE_URL=rediss://default:[PASSWORD]@[REGION].upstash.io:6379
   ```

---

## Cost Estimate (Personal Use)

**Upstash Redis (Free Tier):**
- 10,000 commands/day free
- Likely sufficient for personal use
- **Cost: $0/month**

**If you exceed free tier:**
- ~$2-5/month for typical personal usage

**Worker Server (Fly.io Free Tier):**
- 3 shared-cpu VMs free
- **Cost: $0/month**

**Total: $0-5/month** for Redis + Worker

---

## Migration Steps

1. **Create Upstash Redis:**
   - Sign up at upstash.com
   - Create database in region closest to your Vercel region
   - Copy connection string

2. **Update Environment Variables:**
   - Add `REDIS_URL` and `REDIS_QUEUE_URL` to Vercel
   - Update local `.env` for testing

3. **Deploy Worker:**
   - Set up Fly.io account
   - Deploy worker with same Redis connection
   - Or use Railway/Render

4. **Test:**
   - Verify caching works
   - Verify jobs process correctly

---

## Summary

**Redis is essential for:**
- ✅ Performance (caching reduces database load)
- ✅ Background jobs (email processing, document OCR, etc.)
- ✅ Scalability (distributed cache across serverless instances)

**For Vercel deployment:**
- ✅ Use **Upstash Redis** (serverless-friendly, free tier available)
- ✅ Deploy **Worker separately** on Fly.io, Railway, or Render
- ✅ Same Redis instance can serve both caching and job queues

**Cost:** $0-5/month for personal use

