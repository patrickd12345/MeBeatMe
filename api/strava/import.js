// Vercel serverless function for Strava activity import
import { addSession } from '../shared/dataStore.js';
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
      let { access_token, count = 10, type = 'Run', days = 30 } = req.body;
      // Fallback: try read cookie if token not supplied in body
      if (!access_token && req.headers.cookie) {
        const m = /(?:^|; )strava_access_token=([^;]+)/.exec(req.headers.cookie);
        if (m) access_token = decodeURIComponent(m[1]);
      }
      
      if (!access_token) {
        res.status(400).json({
          success: false,
          error: 'No access token provided'
        });
        return;
      }
      
      // Calculate date range
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);
      
      // Fetch activities from Strava
      const activitiesResponse = await fetch(
        `https://www.strava.com/api/v3/athlete/activities?after=${Math.floor(startDate.getTime() / 1000)}&before=${Math.floor(endDate.getTime() / 1000)}&per_page=${count}`,
        {
          headers: {
            'Authorization': `Bearer ${access_token}`
          }
        }
      );
      
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
      
      // Filter and process activities
      const runActivities = activities
        .filter(activity => activity.type === 'Run')
        .map(activity => {
          // Calculate PPI using the Purdy formula
          const distanceMeters = activity.distance;
          const timeSeconds = activity.moving_time;
          
          const ppi = calculatePPI(distanceMeters, timeSeconds);
          
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
          
          const savedSession = await addSession(sessionData);
          console.log(`Saved session: ${savedSession.id} for activity: ${activity.name}`);
          
          return {
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
          };
        });
      
      res.status(200).json({
        success: true,
        imported: runActivities.length,
        total: activities.length,
        activities: runActivities
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
