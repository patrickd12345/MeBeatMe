# 🚀 MeBeatMe Vercel Deployment Guide

## Deploy to Vercel in Minutes!

This guide will help you deploy MeBeatMe to Vercel and configure it as a subdomain of ready2race.run.

## 📋 Prerequisites

- **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
- **GitHub Repository**: Your MeBeatMe code in a GitHub repo
- **Domain Control**: DNS access to ready2race.run

## 🚀 Quick Deployment

### 1. **Connect to Vercel**
```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy from your project directory
vercel
```

### 2. **Configure Domain**
In Vercel dashboard:
- Go to Project Settings → Domains
- Add `mebeatme.ready2race.run`
- Follow DNS configuration instructions

### 3. **Set Environment Variables**
In Vercel dashboard → Settings → Environment Variables:
```
FULL_DOMAIN=mebeatme.ready2race.run
CORS_ORIGINS=https://mebeatme.ready2race.run,https://ready2race.run
LOG_LEVEL=INFO
```

## 📁 Project Structure

```
MeBeatMe/
├── api/                    # Vercel serverless functions
│   ├── health.js          # Health check endpoint
│   ├── sync/
│   │   ├── bests.js       # Best PPI data
│   │   ├── sessions.js    # Workout sessions
│   │   └── runs.js        # Add/delete workouts
│   └── strava/
│       ├── token.js       # OAuth token exchange
│       └── import.js      # Activity import
├── dashboard.html         # Main web dashboard
├── vercel.json           # Vercel configuration
└── package.json          # Dependencies (optional)
```

## 🌐 API Endpoints

Your deployed app will have these endpoints:

- **Health**: `https://mebeatme.ready2race.run/api/health`
- **Dashboard**: `https://mebeatme.ready2race.run/dashboard.html`
- **API Bests**: `https://mebeatme.ready2race.run/api/sync/bests`
- **API Sessions**: `https://mebeatme.ready2race.run/api/sync/sessions`
- **API Runs**: `https://mebeatme.ready2race.run/api/sync/runs`
- **Strava Token**: `https://mebeatme.ready2race.run/api/strava/token`
- **Strava Import**: `https://mebeatme.ready2race.run/api/strava/import`

## 🔧 Configuration

### Vercel Configuration (`vercel.json`)
```json
{
  "version": 2,
  "name": "mebeatme",
  "builds": [
    {
      "src": "api/**/*.js",
      "use": "@vercel/node"
    },
    {
      "src": "dashboard.html",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/api/$1"
    },
    {
      "src": "/(.*)",
      "dest": "/$1"
    }
  ]
}
```

### Environment Variables
- `FULL_DOMAIN`: Your subdomain
- `CORS_ORIGINS`: Allowed origins for CORS
- `LOG_LEVEL`: Logging level (INFO, DEBUG, ERROR)

## 🎯 Features Included

✅ **Serverless Functions**: Auto-scaling API endpoints
✅ **Global CDN**: Fast loading worldwide
✅ **Automatic SSL**: HTTPS enabled by default
✅ **Custom Domain**: mebeatme.ready2race.run
✅ **Environment Variables**: Secure configuration
✅ **Git Integration**: Auto-deploy on push
✅ **Preview Deployments**: Test before going live

## 🔒 Security Features

- **HTTPS Only**: Automatic SSL certificates
- **CORS Protection**: Configured for your domains
- **Environment Variables**: Secure secrets management
- **Serverless Security**: Isolated function execution

## 📊 Monitoring

- **Vercel Analytics**: Built-in performance monitoring
- **Function Logs**: Real-time serverless function logs
- **Error Tracking**: Automatic error reporting
- **Uptime Monitoring**: 99.99% uptime SLA

## 🚀 Deployment Commands

```bash
# Deploy to production
vercel --prod

# Deploy preview
vercel

# Check deployment status
vercel ls

# View logs
vercel logs
```

## 🔄 Updates

To update your deployment:
1. Push changes to GitHub
2. Vercel automatically deploys
3. Or run `vercel --prod` manually

## 🧪 Testing

```bash
# Test health endpoint
curl https://mebeatme.ready2race.run/api/health

# Test API endpoints
curl https://mebeatme.ready2race.run/api/sync/bests
```

## 📈 Scaling

Vercel automatically handles:
- **Traffic spikes**: Auto-scaling serverless functions
- **Global distribution**: CDN edge locations
- **Performance optimization**: Automatic optimizations
- **Cost efficiency**: Pay only for usage

## 🎉 Benefits of Vercel Deployment

- **Zero Configuration**: Deploy in minutes
- **Automatic Scaling**: Handle any traffic load
- **Global Performance**: CDN worldwide
- **Developer Experience**: Git-based workflow
- **Cost Effective**: Pay per usage
- **Reliability**: 99.99% uptime SLA

---

**🎯 Your MeBeatMe dashboard will be live at:**
**https://mebeatme.ready2race.run**

**🚀 Deploy now with: `vercel --prod`**
