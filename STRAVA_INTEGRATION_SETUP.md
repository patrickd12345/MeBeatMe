# 🏃‍♂️ Strava Integration Setup Guide

## Overview

MeBeatMe now includes full Strava integration for importing your running activities and automatically calculating PPI scores! This guide will help you set up the integration.

## 🚀 Quick Setup

### 1. Create Strava Application

1. **Go to Strava API**: Visit [https://www.strava.com/settings/api](https://www.strava.com/settings/api)
2. **Create Application**: Click "Create App" or "Register Your Application"
3. **Fill in Details**:
   - **Application Name**: `MeBeatMe Dashboard`
   - **Category**: `Web`
   - **Club**: Leave blank
   - **Website**: `http://localhost:8082` (for development)
   - **Authorization Callback Domain**: `localhost`

4. **Get Credentials**: Note down your:
   - **Client ID**
   - **Client Secret**

### 2. Configure MeBeatMe

#### Update Dashboard Configuration
Edit `dashboard.html` and replace `YOUR_STRAVA_CLIENT_ID` with your actual Client ID:

```javascript
// Line ~1323 in dashboard.html
const clientId = 'YOUR_ACTUAL_STRAVA_CLIENT_ID';
```

#### Update Server Configuration
Edit `SimpleHttpServer.java` and replace the placeholder values:

```java
// Lines ~340-341 in SimpleHttpServer.java
String clientId = "YOUR_ACTUAL_STRAVA_CLIENT_ID";
String clientSecret = "YOUR_ACTUAL_STRAVA_CLIENT_SECRET";
```

### 3. Start the Services

```bash
# Terminal 1: Start API Server
javac SimpleHttpServer.java
java SimpleHttpServer

# Terminal 2: Start Web Server
python -m http.server 8082

# Open Dashboard
start http://localhost:8082/dashboard.html
```

## 🎯 How It Works

### Authentication Flow
1. **Click "Import from Strava"** in the dashboard
2. **Authorize with Strava** - Opens Strava OAuth popup
3. **Grant Permissions** - Allow MeBeatMe to read your activities
4. **Automatic Token Exchange** - Server exchanges code for access token

### Import Process
1. **Configure Import Settings**:
   - Number of activities (10, 25, 50, 100)
   - Activity type (Run, Trail Run, Treadmill, All)
   - Date range (7, 30, 90, 365 days)

2. **Automatic Processing**:
   - Fetches activities from Strava API
   - Calculates PPI for each activity using Purdy formula
   - Stores activities in MeBeatMe database
   - Updates "PPI to beat" if new best is found

3. **Real-time Progress**:
   - Progress bar shows import status
   - Live list of imported activities
   - Success/error indicators

## 🔧 Features

### ✅ **Complete Integration**
- **OAuth Authentication**: Secure Strava login
- **Activity Import**: Fetch recent running activities
- **PPI Calculation**: Automatic Purdy Points calculation
- **Data Storage**: Activities stored in MeBeatMe database
- **Real-time Updates**: Dashboard refreshes with new data

### ✅ **Smart Filtering**
- **Activity Type**: Filter by Run, Trail Run, Treadmill
- **Date Range**: Import last 7, 30, 90, or 365 days
- **Quantity Control**: Import 10-100 activities at once

### ✅ **User Experience**
- **Modern UI**: Beautiful Strava-themed interface
- **Progress Tracking**: Real-time import progress
- **Error Handling**: Comprehensive error messages
- **Success Feedback**: Clear confirmation of imported activities

## 📊 Data Flow

```
Strava API → MeBeatMe Server → PPI Calculation → Dashboard Display
     ↓              ↓              ↓              ↓
OAuth Token → Activity Data → Purdy Formula → Real-time UI
```

## 🛠️ Technical Details

### API Endpoints
- `POST /strava/token` - Exchange OAuth code for access token
- `POST /strava/import` - Import activities from Strava

### Data Processing
- **Distance**: Converted from meters to kilometers
- **Time**: Parsed from Strava's moving_time field
- **PPI**: Calculated using elite baseline times and Purdy formula
- **Storage**: Activities stored with Strava IDs for deduplication

### Security
- **OAuth 2.0**: Industry-standard authentication
- **Token Management**: Secure token exchange and storage
- **CORS Support**: Proper cross-origin request handling

## 🚨 Troubleshooting

### Common Issues

1. **"Failed to exchange code for token"**
   - Check Client ID and Client Secret are correct
   - Verify callback domain matches Strava app settings

2. **"Failed to fetch activities from Strava"**
   - Check access token is valid
   - Verify Strava API rate limits

3. **"No activities found"**
   - Check date range settings
   - Verify activity type filter
   - Ensure you have activities in the selected time period

### Debug Mode
Check server console for detailed logs:
```bash
# Server logs show:
# - OAuth token exchange requests
# - Strava API calls
# - Imported activities with PPI scores
# - Error messages
```

## 🔄 Next Steps

### Production Deployment
For production use, update:
- **Callback URL**: Change from `localhost` to your domain
- **HTTPS**: Ensure secure connections
- **Environment Variables**: Store credentials securely

### Advanced Features
- **Automatic Sync**: Periodic activity updates
- **Activity Deduplication**: Prevent duplicate imports
- **Bulk Import**: Import entire activity history
- **Export**: Export MeBeatMe data back to Strava

## 📝 Notes

- **Rate Limits**: Strava API has rate limits (100 requests per 15 minutes)
- **Data Privacy**: Only activity data is accessed, no personal information
- **Token Expiry**: Strava tokens expire after 6 hours (refresh tokens available)
- **Mock Data**: Current implementation includes mock data for testing

---

**Ready to import your Strava activities and see your PPI scores? Follow the setup steps above and start importing!** 🏃‍♂️✨
