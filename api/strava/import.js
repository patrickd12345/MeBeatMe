// Vercel serverless function for Strava activity import
import { addSession } from '../dataStore.js';
export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method === 'POST') {
    // Handle Strava activity import
    try {
      console.log('=== STRAVA IMPORT DEBUG START ===');
      let { access_token, count = 10, type = 'Run', days = 30 } = req.body;
      console.log('Request body:', { count, type, days, hasToken: !!access_token });
      
      // Fallback: try read cookie if token not supplied in body
      if (!access_token && req.headers.cookie) {
        const m = /(?:^|; )strava_access_token=([^;]+)/.exec(req.headers.cookie);
        if (m) access_token = decodeURIComponent(m[1]);
        console.log('Found token in cookie:', !!access_token);
      }
      
      if (!access_token) {
        console.log('ERROR: No access token provided');
        res.status(400).json({
          success: false,
          error: 'No access token provided'
        });
        return;
      }
      
      console.log('Using access token:', access_token.substring(0, 10) + '...');
      
      // Calculate date range
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);
      console.log('Date range:', { startDate: startDate.toISOString(), endDate: endDate.toISOString() });
      
      // Fetch activities from Strava
      const stravaUrl = `https://www.strava.com/api/v3/athlete/activities?after=${Math.floor(startDate.getTime() / 1000)}&before=${Math.floor(endDate.getTime() / 1000)}&per_page=${count}`;
      console.log('Fetching from Strava URL:', stravaUrl);
      
      const activitiesResponse = await fetch(stravaUrl, {
        headers: {
          'Authorization': `Bearer ${access_token}`
        }
      });
      
      console.log('Strava API response status:', activitiesResponse.status);
      
      if (!activitiesResponse.ok) {
        const errorText = await activitiesResponse.text();
        console.error('Strava API error:', activitiesResponse.status, errorText);
        res.status(400).json({
          success: false,
          error: 'Failed to fetch activities from Strava',
          details: `HTTP ${activitiesResponse.status}: ${errorText}`
        });
        return;
      }
      
      const activities = await activitiesResponse.json();
      console.log('Received activities from Strava:', activities.length, 'total activities');
      console.log('Activity types:', activities.map(a => a.type).slice(0, 10));
      
      // Filter and process activities
      const runActivities = activities.filter(activity => activity.type === 'Run');
      console.log('Filtered running activities:', runActivities.length);
      
      const processedActivities = [];
      for (const activity of runActivities) {
        try {
          console.log('Processing activity:', activity.name, 'Distance(m):', activity.distance, 'moving_time(s):', activity.moving_time, 'elapsed_time(s):', activity.elapsed_time);
          
          // Calculate PPI using the Purdy formula
          const distanceMeters = activity.distance;
          // Use total elapsed time when available; fall back to moving time
          const timeSeconds = (typeof activity.elapsed_time === 'number' && activity.elapsed_time > 0)
            ? activity.elapsed_time
            : activity.moving_time;
          
          const ppi = calculatePPI(distanceMeters, timeSeconds);
          console.log('Calculated PPI:', ppi);
          
          // Save to shared data store
          const sessionData = {
            distance: distanceMeters,
            duration: timeSeconds,
            ppi: ppi,
            createdAt: new Date(activity.start_date).getTime(),
            source: 'strava',
            activityId: activity.id,
            name: activity.name
          };
          
          console.log('Saving session data:', sessionData);
          const savedSession = await addSession(sessionData);
          console.log(`✅ Saved session: ${savedSession.id} for activity: ${activity.name}`);
          
          processedActivities.push({
            id: activity.id,
            name: activity.name,
            distance: (distanceMeters / 1000).toFixed(2),
            time: formatTime(timeSeconds),
            date: activity.start_date,
            ppi: ppi.toFixed(1),
            // numeric fields to allow optimistic rendering on dashboard
            distanceMeters: distanceMeters,
            durationSeconds: timeSeconds,
            createdAtMs: new Date(activity.start_date).getTime(),
            success: true,
            sessionId: savedSession.id
          });
        } catch (error) {
          console.error('Error processing activity:', activity.name, error);
          processedActivities.push({
            id: activity.id,
            name: activity.name,
            success: false,
            error: error.message
          });
        }
      }
      
      console.log('=== STRAVA IMPORT DEBUG END ===');
      console.log('Final processed activities:', processedActivities.length);
      
      res.status(200).json({
        success: true,
        imported: processedActivities.filter(a => a.success).length,
        total: activities.length,
        activities: processedActivities
      });
      
    } catch (error) {
      console.error('Error handling Strava import:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to import activities from Strava',
        details: error.message
      });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}

// Helper function to format time
function formatTime(seconds) {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;
  
  if (hours > 0) {
    return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  } else {
    return `${minutes}:${secs.toString().padStart(2, '0')}`;
  }
}

// Purdy formula PPI calculation
function calculatePPI(distanceMeters, timeSeconds) {
  if (distanceMeters <= 0 || timeSeconds <= 0) {
    return 100; // Minimum score
  }
  
  // Get baseline time for this distance
  const baselineTime = getBaselineTime(distanceMeters);
  
  // Calculate performance ratio (actual time / baseline time)
  const performanceRatio = timeSeconds / baselineTime;
  
  // Purdy formula: PPI = 1000 * (actual_time / baseline_time)^(-2.0)
  const rawScore = 1000.0 * Math.pow(performanceRatio, -2.0);
  
  // Clamp to reasonable range (100-2000)
  return Math.max(100, Math.min(2000, rawScore));
}

// Get baseline time for a given distance using interpolation
function getBaselineTime(distanceMeters) {
  // Elite baseline times (in seconds) - realistic values
  const baselines = [
    { distance: 1500, time: 210 },    // 3:30 (realistic elite)
    { distance: 5000, time: 755 },    // 12:35 (realistic elite) 
    { distance: 10000, time: 1571 },  // 26:11 (realistic elite)
    { distance: 21097, time: 3540 },  // 59:00 (half marathon)
    { distance: 42195, time: 7460 }   // 2:04:20 (marathon)
  ];
  
  // Find closest baseline or interpolate
  if (distanceMeters <= baselines[0].distance) {
    return baselines[0].time;
  }
  if (distanceMeters >= baselines[baselines.length - 1].distance) {
    return baselines[baselines.length - 1].time;
  }
  
  // Linear interpolation in log-log space
  for (let i = 0; i < baselines.length - 1; i++) {
    const current = baselines[i];
    const next = baselines[i + 1];
    
    if (distanceMeters >= current.distance && distanceMeters <= next.distance) {
      const logDist1 = Math.log(current.distance);
      const logDist2 = Math.log(next.distance);
      const logTime1 = Math.log(current.time);
      const logTime2 = Math.log(next.time);
      const logDistTarget = Math.log(distanceMeters);
      
      const ratio = (logDistTarget - logDist1) / (logDist2 - logDist1);
      const logTimeTarget = logTime1 + ratio * (logTime2 - logTime1);
      
      return Math.exp(logTimeTarget);
    }
  }
  
  return baselines[baselines.length - 1].time;
}
