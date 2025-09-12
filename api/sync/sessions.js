// Vercel serverless function for sync/sessions endpoint
import { getWorkoutData, addSession, deleteSession } from '../dataStore.js';

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
    // Handle adding a session directly
    try {
      const workoutData = req.body;
      const distance = workoutData.distanceMeters || 0;
      const time = workoutData.elapsedSeconds || 0;
      const timestamp = workoutData.startedAtEpochMs || Date.now();
      const name = typeof workoutData.name === 'string' ? workoutData.name : undefined;
      
      // Calculate PPI using Purdy formula
      const ppi = calculatePPI(distance, time);
      
      const sessionData = {
        distance: distance,
        duration: time,
        ppi: ppi,
        createdAt: timestamp,
        ...(name ? { name } : {})
      };
      
      const newSession = await addSession(sessionData);
      
      res.status(200).json({
        status: 'success',
        message: 'Session added successfully',
        ppi: ppi.toFixed(1),
        sessionId: newSession.id
      });
      
    } catch (error) {
      console.error('Error processing session:', error);
      res.status(500).json({
        status: 'error',
        message: 'Internal server error'
      });
    }
  } else if (req.method === 'GET') {
    // Return session data with transformed fields for dashboard
    const workoutData = await getWorkoutData();
    let storeSessions = workoutData.sessions.map(session => ({
      id: session.id,
      filename: session.name || session.id, // Use name if available, otherwise id
      distance: session.distance,
      duration: session.duration,
      ppi: session.ppi,
      createdAt: session.createdAt
    }));

    // Merge cookie-based session cache if present (to reflect recent imports immediately)
    try {
      const cookieHeader = req.headers.cookie || '';
      const m = /(?:^|; )mbm_sessions=([^;]+)/.exec(cookieHeader);
      if (m) {
        const cached = JSON.parse(decodeURIComponent(m[1]));
        if (Array.isArray(cached) && cached.length) {
          const seen = new Set(storeSessions.map(s => s.id));
          cached.forEach(s => {
            if (s && s.id && !seen.has(s.id)) {
              storeSessions.unshift({
                id: s.id,
                filename: s.name || s.id,
                distance: s.distance,
                duration: s.duration,
                ppi: s.ppi,
                createdAt: s.createdAt
              });
            }
          });
        }
      }
    } catch (e) {
      console.log('Session cookie merge skipped:', e.message);
    }
    
    const sessionsData = {
      status: 'success',
      sessions: storeSessions,
      count: storeSessions.length,
      bestPpi: workoutData.bestPpi
    };
    
    res.status(200).json(sessionsData);
  } else if (req.method === 'DELETE') {
    // Handle workout deletion
    try {
      const workoutId = req.query.id || req.url.split('/').pop();
      
      const deletedSession = await deleteSession(workoutId);
      if (!deletedSession) {
        res.status(404).json({
          status: 'error',
          message: 'Workout not found'
        });
        return;
      }
      
      console.log(`Deleted session: ${workoutId}`);
      
      res.status(200).json({
        status: 'success',
        message: 'Workout deleted successfully'
      });
      
    } catch (error) {
      console.error('Error deleting workout:', error);
      res.status(500).json({
        status: 'error',
        message: 'Internal server error'
      });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}

// Purdy Points calculation
function calculatePPI(distanceMeters, timeSeconds) {
  const baselineTime = getInterpolatedBaselineTime(distanceMeters);
  const ratio = baselineTime / timeSeconds;
  return 1000.0 * Math.pow(ratio, 3);
}

function getInterpolatedBaselineTime(distanceMeters) {
  const baselines = [
    [1500, 210],    // 3:30
    [5000, 755],    // 12:35 
    [10000, 1571],  // 26:11
    [21097, 3540],  // 59:00
    [42195, 7460]   // 2:04:20
  ];
  
  if (distanceMeters <= baselines[0][0]) {
    return baselines[0][1];
  }
  if (distanceMeters >= baselines[baselines.length - 1][0]) {
    return baselines[baselines.length - 1][1];
  }
  
  for (let i = 0; i < baselines.length - 1; i++) {
    const currentDist = baselines[i][0];
    const nextDist = baselines[i + 1][0];
    
    if (distanceMeters >= currentDist && distanceMeters <= nextDist) {
      const logDist1 = Math.log(currentDist);
      const logDist2 = Math.log(nextDist);
      const logTime1 = Math.log(baselines[i][1]);
      const logTime2 = Math.log(baselines[i + 1][1]);
      const logDistTarget = Math.log(distanceMeters);
      
      const ratio = (logDistTarget - logDist1) / (logDist2 - logDist1);
      const logTimeTarget = logTime1 + ratio * (logTime2 - logTime1);
      
      return Math.exp(logTimeTarget);
    }
  }
  
  return baselines[baselines.length - 1][1];
}
