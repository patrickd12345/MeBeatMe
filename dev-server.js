// Simple Express server for development
const express = require('express');
const path = require('path');
const { getWorkoutData, addSession, deleteSession } = require('./api/shared/dataStore.js');

const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());

// API Routes (must come before static file serving)
app.get('/api/sync/bests', (req, res) => {
  const workoutData = getWorkoutData();
  
  // Create a bests object with bucket keys (dashboard expects this format)
  const bests = {};
  if (workoutData.sessions.length > 0) {
    // For now, put the best PPI in a default bucket
    // In a real implementation, you'd categorize by distance ranges
    bests['KM_3_8'] = workoutData.bestPpi; // Default bucket for the hardcoded run
  }
  
  res.json({
    status: 'success',
    bests: bests,
    bestPpi: workoutData.bestPpi
  });
});

app.get('/api/sync/sessions', (req, res) => {
  const workoutData = getWorkoutData();
  
  // Transform sessions to match dashboard expectations
  const transformedSessions = workoutData.sessions.map(session => ({
    id: session.id,
    filename: session.name || session.id, // Use name if available, otherwise id
    distance: session.distance,
    duration: session.duration,
    ppi: session.ppi,
    createdAt: session.createdAt,
    bucket: 'Running' // Default bucket for all sessions
  }));
  
  const sessionsData = {
    status: 'success',
    sessions: transformedSessions,
    count: transformedSessions.length,
    bestPpi: workoutData.bestPpi
  };
  res.json(sessionsData);
});

app.post('/api/sync/sessions', (req, res) => {
  try {
    const workoutData = req.body;
    const distance = workoutData.distanceMeters || 0;
    const time = workoutData.elapsedSeconds || 0;
    const timestamp = workoutData.startedAtEpochMs || Date.now();
    
    const ppi = calculatePPI(distance, time);
    
    const sessionData = {
      distance: distance,
      duration: time,
      ppi: ppi,
      createdAt: timestamp
    };
    
    const newSession = addSession(sessionData);
    
    res.json({
      status: 'success',
      message: 'Session added successfully',
      ppi: ppi.toFixed(1),
      sessionId: newSession.id
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: 'Internal server error' });
  }
});

app.delete('/api/sync/sessions', (req, res) => {
  try {
    const workoutId = req.query.id;
    const deletedSession = deleteSession(workoutId);
    
    if (!deletedSession) {
      res.status(404).json({ status: 'error', message: 'Workout not found' });
      return;
    }
    
    res.json({ status: 'success', message: 'Workout deleted successfully' });
  } catch (error) {
    res.status(500).json({ status: 'error', message: 'Internal server error' });
  }
});

app.get('/api/strava/callback', (req, res) => {
  // Handle Strava OAuth callback
  const code = req.query.code;
  const error = req.query.error;
  
  if (error) {
    // Send error back to parent window
    res.send(`
      <script>
        if (window.opener) {
          window.opener.postMessage({
            type: 'strava-auth-error',
            error: '${error}'
          }, '*');
          window.close();
        }
      </script>
    `);
    return;
  }
  
  if (code) {
    // Send success back to parent window
    res.send(`
      <script>
        if (window.opener) {
          window.opener.postMessage({
            type: 'strava-auth-success',
            code: '${code}'
          }, '*');
          window.close();
        }
      </script>
    `);
  } else {
    res.send(`
      <script>
        if (window.opener) {
          window.opener.postMessage({
            type: 'strava-auth-error',
            error: 'No authorization code received'
          }, '*');
          window.close();
        }
      </script>
    `);
  }
});

app.post('/api/strava/token', (req, res) => {
  // Mock token exchange for testing
  res.json({
    success: true,
    access_token: 'mock_token_for_testing',
    refresh_token: 'mock_refresh_token',
    expires_at: Date.now() + 3600000 // 1 hour from now
  });
});

app.post('/api/strava/import', async (req, res) => {
  try {
    const { access_token, count = 10 } = req.body;
    
    // For testing, we'll simulate importing activities
    // In production, this would call the real Strava API
    const mockActivities = [
      { distance: 5000, duration: 1500, name: 'Morning Run', start_date: new Date().toISOString() },
      { distance: 10000, duration: 3000, name: 'Long Run', start_date: new Date().toISOString() },
      { distance: 3000, duration: 900, name: 'Speed Work', start_date: new Date().toISOString() },
      { distance: 8000, duration: 2400, name: 'Tempo Run', start_date: new Date().toISOString() },
      { distance: 15000, duration: 4500, name: 'Long Run 2', start_date: new Date().toISOString() }
    ];
    
    const runActivities = mockActivities.slice(0, count).map(activity => {
      const ppi = calculatePPI(activity.distance, activity.duration);
      
      const sessionData = {
        distance: activity.distance,
        duration: activity.duration,
        ppi: ppi,
        createdAt: new Date(activity.start_date).getTime(),
        source: 'strava',
        activityId: activity.name,
        name: activity.name
      };
      
      const savedSession = addSession(sessionData);
      
      return {
        id: activity.name,
        name: activity.name,
        distance: (activity.distance / 1000).toFixed(2),
        time: formatTime(activity.duration),
        date: activity.start_date,
        ppi: ppi.toFixed(1),
        success: true,
        sessionId: savedSession.id
      };
    });
    
    res.json({
      success: true,
      imported: runActivities.length,
      total: mockActivities.length,
      activities: runActivities
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Serve static files (must come after API routes)
app.use(express.static('.'));

// CORS middleware
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
    return;
  }
  next();
});


// Serve dashboard.html as the main page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'dashboard.html'));
});

// Purdy formula PPI calculation
function calculatePPI(distanceMeters, timeSeconds) {
  const baselineTime = getBaselineTime(distanceMeters);
  const ratio = baselineTime / timeSeconds;
  return 1000.0 * Math.pow(ratio, 3);
}

function getBaselineTime(distanceMeters) {
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

app.listen(PORT, () => {
  console.log(`🚀 MeBeatMe Development Server running at http://localhost:${PORT}`);
  console.log(`📊 Dashboard: http://localhost:${PORT}`);
  console.log(`🔧 API endpoints working with our fixes!`);
  console.log(`\n✅ Try importing activities - they should now show up in the dashboard!`);
});
